import type {
  Notification,
  NotificationList,
  NotificationPreference,
  NotificationPreferenceUpdate,
  User,
} from '@/types';
import type {
  PortfolioAlertResponse,
  PortfolioItemCreate,
  PortfolioItemResponse,
} from '@/api/portfolio';
import type {
  WatchlistAlertResponse,
  WatchlistItemCreate,
  WatchlistItemResponse,
} from '@/api/watchlist';
import type {
  AIAnalysisResponse,
  EndSimulationResponse,
  PortfolioHolding,
  SimulationResponse,
  SimulationSummary,
  TradeRequest,
  TradeResponse,
} from '@/api/simulator';

const STORAGE_KEY = 'nepsim-offline-state-v1';

export interface OfflineSyncSettings {
  backupGeminiKeyToCloud: boolean;
  cloudGeminiKeyStored: boolean;
  lastSyncAt: string | null;
}

interface OfflineSimulationRecord {
  simulation: SimulationResponse;
  trades: TradeResponse[];
  analysis: AIAnalysisResponse | null;
}

interface OfflineState {
  nextId: number;
  notifications: Notification[];
  notificationPreference: NotificationPreference;
  portfolioItems: PortfolioItemResponse[];
  portfolioAlerts: PortfolioAlertResponse[];
  watchlistItems: WatchlistItemResponse[];
  watchlistAlerts: WatchlistAlertResponse[];
  simulations: OfflineSimulationRecord[];
  geminiApiKey: string;
  syncSettings: OfflineSyncSettings;
}

const DEFAULT_NOTIFICATION_PREFERENCE: NotificationPreference = {
  id: 1,
  user_id: 0,
  websocket_enabled: true,
  email_enabled: false,
  push_enabled: false,
  sms_enabled: false,
};

const DEFAULT_SYNC_SETTINGS: OfflineSyncSettings = {
  backupGeminiKeyToCloud: false,
  cloudGeminiKeyStored: false,
  lastSyncAt: null,
};

const OFFLINE_GUEST_USER: User = {
  id: 'offline-guest',
  username: 'Guest',
  email: 'offline@device.local',
  is_active: true,
  is_superuser: false,
  is_confirmed: false,
  otp_enabled: false,
  otp_verified: false,
  first_name: 'Offline',
  last_name: 'User',
  roles: [],
};

function isBrowser() {
  return typeof window !== 'undefined';
}

function createDefaultState(): OfflineState {
  return {
    nextId: 2,
    notifications: [
      {
        id: 1,
        user_id: 0,
        title: 'Offline mode enabled',
        body: 'Your device is the source of truth until you choose to sync.',
        type: 'info',
        is_read: false,
        created_at: new Date().toISOString(),
      },
    ],
    notificationPreference: DEFAULT_NOTIFICATION_PREFERENCE,
    portfolioItems: [],
    portfolioAlerts: [],
    watchlistItems: [],
    watchlistAlerts: [],
    simulations: [],
    geminiApiKey: '',
    syncSettings: DEFAULT_SYNC_SETTINGS,
  };
}

function roundTo(value: number, digits: number = 2) {
  const factor = 10 ** digits;
  return Math.round(value * factor) / factor;
}

function dayNumber(date: string) {
  return Math.floor(new Date(date).getTime() / 86_400_000);
}

function seedFromSymbol(symbol: string) {
  return symbol
    .toUpperCase()
    .split('')
    .reduce((total, char) => total + char.charCodeAt(0), 0);
}

function estimatePrice(symbol: string, date: string, reference: number = 600) {
  const seed = seedFromSymbol(symbol);
  const seasonal = Math.sin(dayNumber(date) / 5 + seed / 10) * 0.08;
  const drift = ((seed % 19) - 9) / 100;
  return roundTo(Math.max(50, reference * (1 + seasonal + drift)));
}

function clone<T>(value: T): T {
  return JSON.parse(JSON.stringify(value)) as T;
}

function loadState(): OfflineState {
  if (!isBrowser()) {
    return createDefaultState();
  }

  const raw = window.localStorage.getItem(STORAGE_KEY);
  if (!raw) {
    const state = createDefaultState();
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    return state;
  }

  try {
    const parsed = JSON.parse(raw) as Partial<OfflineState>;
    return {
      ...createDefaultState(),
      ...parsed,
      notificationPreference: {
        ...DEFAULT_NOTIFICATION_PREFERENCE,
        ...(parsed.notificationPreference ?? {}),
      },
      syncSettings: {
        ...DEFAULT_SYNC_SETTINGS,
        ...(parsed.syncSettings ?? {}),
      },
    };
  } catch {
    const state = createDefaultState();
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    return state;
  }
}

function saveState(state: OfflineState) {
  if (!isBrowser()) return;
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function updateState<T>(updater: (state: OfflineState) => T): T {
  const state = loadState();
  const result = updater(state);
  saveState(state);
  return result;
}

function nextId(state: OfflineState) {
  const id = state.nextId;
  state.nextId += 1;
  return id;
}

function appendNotification(
  state: OfflineState,
  title: string,
  body: string,
  type: Notification['type'] = 'info'
) {
  state.notifications.unshift({
    id: nextId(state),
    user_id: 0,
    title,
    body,
    type,
    is_read: false,
    created_at: new Date().toISOString(),
  });
  state.notifications = state.notifications.slice(0, 50);
}

function enrichPortfolioItem(item: PortfolioItemResponse): PortfolioItemResponse {
  const current_price = estimatePrice(item.symbol, new Date().toISOString(), item.avg_buy_price || 600);
  const current_value = roundTo(current_price * item.quantity);
  const cost_basis = roundTo(item.avg_buy_price * item.quantity);
  const unrealised_pnl = roundTo(current_value - cost_basis);
  const unrealised_pnl_pct = cost_basis > 0 ? roundTo((unrealised_pnl / cost_basis) * 100) : 0;

  return {
    ...item,
    current_price,
    current_value,
    cost_basis,
    unrealised_pnl,
    unrealised_pnl_pct,
  };
}

function enrichWatchlistItem(item: WatchlistItemResponse): WatchlistItemResponse {
  const reference = item.target_price ?? item.stop_loss ?? 600;
  const current_price = estimatePrice(item.symbol, new Date().toISOString(), reference);
  const base = item.target_price ?? current_price;
  const diff_pct = base > 0 ? roundTo(((current_price - base) / base) * 100) : 0;

  return {
    ...item,
    current_price,
    diff_pct,
  };
}

function refreshSimulationMetrics(simulation: SimulationResponse) {
  const holdings = (simulation.holdings ?? []).map((holding) => {
    const current_price = estimatePrice(
      holding.symbol,
      simulation.current_sim_date,
      holding.average_buy_price
    );
    const current_value = roundTo(current_price * holding.quantity);
    const cost_basis = roundTo(holding.average_buy_price * holding.quantity);
    const unrealised_pnl = roundTo(current_value - cost_basis);
    const unrealised_pnl_pct = cost_basis > 0 ? roundTo((unrealised_pnl / cost_basis) * 100) : 0;

    return {
      ...holding,
      current_price,
      current_value,
      unrealised_pnl,
      unrealised_pnl_pct,
    };
  });

  const portfolio_value = roundTo(
    holdings.reduce((total, holding) => total + (holding.current_value ?? 0), 0)
  );
  const total_value = roundTo(simulation.cash_balance + portfolio_value);
  const total_pnl = roundTo(total_value - simulation.initial_capital);
  const total_pnl_pct =
    simulation.initial_capital > 0
      ? roundTo((total_pnl / simulation.initial_capital) * 100)
      : 0;

  simulation.holdings = holdings;
  simulation.portfolio_value = portfolio_value;
  simulation.total_value = total_value;
  simulation.total_pnl = total_pnl;
  simulation.total_pnl_pct = total_pnl_pct;
}

function createHoldingFromTrade(
  previous: PortfolioHolding | undefined,
  quantity: number,
  price: number,
  side: TradeRequest['side'],
  currentDate: string,
  symbol: string
): PortfolioHolding | null {
  if (side === 'buy') {
    const prevQty = previous?.quantity ?? 0;
    const prevCost = previous ? previous.average_buy_price * previous.quantity : 0;
    const newQuantity = prevQty + quantity;
    const average_buy_price = newQuantity > 0 ? roundTo((prevCost + price * quantity) / newQuantity) : price;

    return {
      symbol,
      quantity: newQuantity,
      average_buy_price,
      current_price: estimatePrice(symbol, currentDate, average_buy_price),
      current_value: null,
      unrealised_pnl: null,
      unrealised_pnl_pct: null,
    };
  }

  const prevQty = previous?.quantity ?? 0;
  const newQuantity = prevQty - quantity;
  if (newQuantity <= 0) {
    return null;
  }

  return {
    symbol,
    quantity: newQuantity,
    average_buy_price: previous?.average_buy_price ?? price,
    current_price: estimatePrice(symbol, currentDate, previous?.average_buy_price ?? price),
    current_value: null,
    unrealised_pnl: null,
    unrealised_pnl_pct: null,
  };
}

function buildSimulationAnalysis(record: OfflineSimulationRecord): AIAnalysisResponse {
  const trades = record.trades;
  const simulation = record.simulation;
  const total_pnl_pct = simulation.total_pnl_pct ?? 0;
  const winBias = Math.max(20, Math.min(95, 60 + total_pnl_pct));
  const riskScore = Math.max(20, Math.min(95, 75 - trades.length * 2));
  const timingScore = Math.max(20, Math.min(95, 55 + total_pnl_pct / 2));
  const selectionScore = Math.max(20, Math.min(95, 50 + (simulation.holdings?.length ?? 0) * 6));
  const patienceScore = Math.max(20, Math.min(95, 70 - Math.max(0, trades.length - 6) * 4));

  return {
    id: record.analysis?.id ?? record.simulation.id,
    simulation_id: simulation.id,
    status: 'completed',
    total_pnl: simulation.total_pnl ?? 0,
    total_pnl_pct,
    win_rate: trades.length > 0 ? roundTo(winBias) : 0,
    total_trades: trades.length,
    winning_trades: trades.length > 0 ? Math.max(1, Math.round((winBias / 100) * trades.length)) : 0,
    losing_trades: trades.length > 0 ? Math.max(0, trades.length - Math.round((winBias / 100) * trades.length)) : 0,
    summary_narrative:
      total_pnl_pct >= 0
        ? 'You protected capital well in offline mode. Keep validating entries before increasing trade size.'
        : 'This session stayed educational: position sizing and patience would have reduced the drawdown.',
    what_you_did_right: [
      {
        title: 'Offline-first journal discipline',
        detail: 'Your trades and holdings remained stored on-device, so the session stayed available without logging in.',
        impact_pct: Math.max(0.5, roundTo(Math.abs(total_pnl_pct) / 4 + 0.5)),
      },
    ],
    what_you_did_wrong: trades.length > 5
      ? [
          {
            title: 'High trading frequency',
            detail: 'Several trades were clustered closely together. Waiting for stronger confirmation could reduce noise trades.',
            impact_pct: -2.4,
          },
        ]
      : [],
    what_you_could_have_done: [
      {
        title: 'Sync-ready review',
        detail: 'Add notes and keep your Gemini key local until you explicitly enable encrypted cloud backup.',
      },
    ],
    trade_by_trade_commentary: trades.map((trade) => ({
      trade_id: trade.id,
      symbol: trade.symbol,
      side: trade.side,
      sim_date: trade.sim_date,
      commentary:
        trade.side === 'buy'
          ? 'Entry captured in offline mode. Re-check conviction and risk before scaling in.'
          : 'Exit recorded cleanly. Compare it against your original thesis to improve consistency.',
      quality_score: trade.side === 'buy' ? timingScore : patienceScore,
    })),
    timing_score: timingScore,
    selection_score: selectionScore,
    risk_score: riskScore,
    patience_score: patienceScore,
    llm_provider: 'device-local',
    created_at: new Date().toISOString(),
    completed_at: new Date().toISOString(),
  };
}

export function getOfflineGuestUser() {
  return OFFLINE_GUEST_USER;
}

export function getOfflineNotifications(params?: { unread_only?: boolean; skip?: number; limit?: number }): NotificationList {
  const state = loadState();
  let items = [...state.notifications];

  if (params?.unread_only) {
    items = items.filter((notification) => !notification.is_read);
  }

  const skip = params?.skip ?? 0;
  const limit = params?.limit ?? items.length;
  const sliced = items.slice(skip, skip + limit);

  return {
    items: sliced,
    total: items.length,
    unread_count: state.notifications.filter((notification) => !notification.is_read).length,
  };
}

export function markOfflineNotificationRead(id: number) {
  return updateState((state) => {
    const notification = state.notifications.find((item) => item.id === id);
    if (notification) notification.is_read = true;
    return notification ?? null;
  });
}

export function markAllOfflineNotificationsRead() {
  return updateState((state) => {
    state.notifications.forEach((notification) => {
      notification.is_read = true;
    });
    return { success: true };
  });
}

export function getOfflineNotificationPreferences() {
  return loadState().notificationPreference;
}

export function updateOfflineNotificationPreferences(data: NotificationPreferenceUpdate) {
  return updateState((state) => {
    state.notificationPreference = {
      ...state.notificationPreference,
      ...data,
    };
    appendNotification(state, 'Preferences updated', 'Offline notification preferences were saved on this device.');
    return state.notificationPreference;
  });
}

export function getOfflinePortfolioItems() {
  return loadState().portfolioItems.map(enrichPortfolioItem);
}

export function addOfflinePortfolioItem(payload: PortfolioItemCreate) {
  return updateState((state) => {
    const item: PortfolioItemResponse = {
      id: nextId(state),
      symbol: payload.symbol.toUpperCase(),
      quantity: payload.quantity,
      avg_buy_price: payload.avg_buy_price,
      buy_date: payload.buy_date,
      notes: payload.notes,
      created_at: new Date().toISOString(),
      cost_basis: roundTo(payload.quantity * payload.avg_buy_price),
    };
    state.portfolioItems.unshift(item);
    appendNotification(state, 'Portfolio updated', `${item.symbol} was added to your offline portfolio.`, 'success');
    return enrichPortfolioItem(item);
  });
}

export function removeOfflinePortfolioItem(id: number) {
  updateState((state) => {
    const target = state.portfolioItems.find((item) => item.id === id);
    state.portfolioItems = state.portfolioItems.filter((item) => item.id !== id);
    state.portfolioAlerts = state.portfolioAlerts.filter((alert) => alert.portfolio_item_id !== id);
    if (target) {
      appendNotification(state, 'Portfolio updated', `${target.symbol} was removed from your offline portfolio.`);
    }
    return null;
  });
}

export function analyzeOfflinePortfolio() {
  return updateState((state) => {
    state.portfolioAlerts = state.portfolioItems.map((item) => {
      const enriched = enrichPortfolioItem(item);
      const drawdown = enriched.unrealised_pnl_pct ?? 0;
      return {
        id: nextId(state),
        portfolio_item_id: item.id,
        symbol: item.symbol,
        alert_type: drawdown < -7 ? 'SELL_CONSIDER' : 'WARNING',
        signal_score: Math.max(35, Math.min(90, 70 + Math.round(drawdown))),
        analysis_summary:
          drawdown < -7
            ? 'Price drifted below your cost basis. Review whether the thesis still holds.'
            : 'Holding is stable. Keep notes up to date before syncing to the cloud.',
        key_signals: [
          'Offline snapshot stored on-device',
          'Review position sizing before the next rebalance',
        ],
        recommended_action: drawdown < -7 ? 'Review risk and trim if needed.' : 'Hold and monitor.',
        current_price: enriched.current_price,
        created_at: new Date().toISOString(),
        is_read: false,
      };
    });
    appendNotification(state, 'Portfolio analysis ready', 'Offline portfolio insights were generated on this device.');
    return clone(state.portfolioAlerts);
  });
}

export function getOfflinePortfolioAlerts() {
  return clone(loadState().portfolioAlerts);
}

export function markOfflinePortfolioAlertRead(id: number) {
  return updateState((state) => {
    const alert = state.portfolioAlerts.find((item) => item.id === id);
    if (alert) alert.is_read = true;
    return alert ?? null;
  });
}

export function getOfflineWatchlistItems() {
  return loadState().watchlistItems.map(enrichWatchlistItem);
}

export function addOfflineWatchlistItem(payload: WatchlistItemCreate) {
  return updateState((state) => {
    const item: WatchlistItemResponse = {
      id: nextId(state),
      symbol: payload.symbol.toUpperCase(),
      notes: payload.notes,
      target_price: payload.target_price,
      stop_loss: payload.stop_loss,
      created_at: new Date().toISOString(),
    };
    state.watchlistItems.unshift(item);
    appendNotification(state, 'Watchlist updated', `${item.symbol} was saved for offline tracking.`, 'success');
    return enrichWatchlistItem(item);
  });
}

export function removeOfflineWatchlistItem(id: number) {
  updateState((state) => {
    const target = state.watchlistItems.find((item) => item.id === id);
    state.watchlistItems = state.watchlistItems.filter((item) => item.id !== id);
    state.watchlistAlerts = state.watchlistAlerts.filter((alert) => alert.watchlist_item_id !== id);
    if (target) {
      appendNotification(state, 'Watchlist updated', `${target.symbol} was removed from your offline watchlist.`);
    }
    return null;
  });
}

export function checkOfflineWatchlistSignals() {
  return updateState((state) => {
    state.watchlistAlerts = state.watchlistItems.map((item) => {
      const enriched = enrichWatchlistItem(item);
      const bullish = (enriched.diff_pct ?? 0) <= -3;
      return {
        id: nextId(state),
        watchlist_item_id: item.id,
        symbol: item.symbol,
        alert_type: bullish ? 'BUY_CONSIDER' : 'ACCUMULATE',
        signal_score: bullish ? 82 : 64,
        analysis_summary: bullish
          ? 'Price is near your offline target zone. Review the chart before acting.'
          : 'Momentum is neutral. Keep the symbol on your local watchlist.',
        key_signals: ['Signal created from local device data', 'Review before syncing to another device'],
        entry_price: enriched.current_price,
        target_price: item.target_price,
        stop_loss_price: item.stop_loss,
        created_at: new Date().toISOString(),
        is_read: false,
      };
    });
    appendNotification(state, 'Watchlist scan complete', 'Offline watchlist signals were refreshed.');
    return clone(state.watchlistAlerts);
  });
}

export function getOfflineWatchlistAlerts() {
  return clone(loadState().watchlistAlerts);
}

export function markOfflineWatchlistAlertRead(id: number) {
  return updateState((state) => {
    const alert = state.watchlistAlerts.find((item) => item.id === id);
    if (alert) alert.is_read = true;
    return alert ?? null;
  });
}

export function listOfflineSimulations(): SimulationSummary[] {
  return loadState().simulations.map(({ simulation, trades }) => {
    refreshSimulationMetrics(simulation);
    return {
      id: simulation.id,
      name: simulation.name,
      status: simulation.status,
      seconds_per_day: simulation.seconds_per_day,
      initial_capital: simulation.initial_capital,
      started_at: simulation.started_at,
      ended_at: simulation.ended_at,
      total_pnl: simulation.total_pnl,
      total_pnl_pct: simulation.total_pnl_pct,
      total_trades: trades.length,
    };
  });
}

export function getOfflineSimulation(simulationId: number) {
  const record = loadState().simulations.find((item) => item.simulation.id === simulationId);
  if (!record) return null;
  refreshSimulationMetrics(record.simulation);
  return clone(record.simulation);
}

export function createOfflineSimulation(initial_capital: number, name?: string) {
  return updateState((state) => {
    const id = nextId(state);
    const today = new Date().toISOString();
    const simulation: SimulationResponse = {
      id,
      user_id: 0,
      name: name ?? `Offline Sim ${id}`,
      initial_capital,
      cash_balance: initial_capital,
      status: 'active',
      seconds_per_day: 10,
      period_start: today,
      period_end: today,
      current_sim_date: today,
      started_at: today,
      ended_at: null,
      portfolio_value: 0,
      total_value: initial_capital,
      total_pnl: 0,
      total_pnl_pct: 0,
      holdings: [],
    };
    state.simulations.unshift({ simulation, trades: [], analysis: null });
    appendNotification(state, 'Simulation created', `${simulation.name} is now available offline.`, 'success');
    return clone(simulation);
  });
}

export function executeOfflineTrade(simulationId: number, payload: TradeRequest) {
  return updateState((state) => {
    const record = state.simulations.find((item) => item.simulation.id === simulationId);
    if (!record) {
      throw new Error('Simulation not found.');
    }

    const simulation = record.simulation;
    refreshSimulationMetrics(simulation);

    const price = estimatePrice(payload.symbol, simulation.current_sim_date, 600);
    const gross = roundTo(price * payload.quantity);
    const broker_commission = roundTo(gross * 0.004);
    const sebon_commission = roundTo(gross * 0.00015);
    const dp_charge = payload.side === 'sell' ? 25 : 0;
    const total_cost = roundTo(gross + broker_commission + sebon_commission + (payload.side === 'buy' ? dp_charge : 0));

    const previousHolding = simulation.holdings?.find((holding) => holding.symbol === payload.symbol.toUpperCase());

    if (payload.side === 'buy' && total_cost > simulation.cash_balance) {
      throw new Error('Insufficient cash balance for this trade.');
    }

    if (payload.side === 'sell' && (!previousHolding || previousHolding.quantity < payload.quantity)) {
      throw new Error('You do not hold enough shares to sell that quantity.');
    }

    simulation.cash_balance =
      payload.side === 'buy'
        ? roundTo(simulation.cash_balance - total_cost)
        : roundTo(simulation.cash_balance + gross - broker_commission - sebon_commission - dp_charge);

    const nextHolding = createHoldingFromTrade(
      previousHolding,
      payload.quantity,
      price,
      payload.side,
      simulation.current_sim_date,
      payload.symbol.toUpperCase()
    );

    simulation.holdings = (simulation.holdings ?? [])
      .filter((holding) => holding.symbol !== payload.symbol.toUpperCase());

    if (nextHolding) {
      simulation.holdings.push(nextHolding);
    }

    const trade: TradeResponse = {
      id: nextId(state),
      simulation_id: simulationId,
      symbol: payload.symbol.toUpperCase(),
      side: payload.side,
      quantity: payload.quantity,
      executed_price: price,
      sebon_commission,
      broker_commission,
      dp_charge,
      total_cost,
      sim_date: simulation.current_sim_date,
      status: 'executed',
      rejection_reason: null,
      realised_pnl: payload.side === 'sell' && previousHolding
        ? roundTo((price - previousHolding.average_buy_price) * payload.quantity)
        : null,
      created_at: new Date().toISOString(),
      new_cash_balance: simulation.cash_balance,
      message: `Offline ${payload.side} order recorded successfully.`,
    };

    record.trades.unshift(trade);
    refreshSimulationMetrics(simulation);
    appendNotification(
      state,
      'Simulation trade saved',
      `${payload.side.toUpperCase()} ${payload.quantity} ${trade.symbol} shares in ${simulation.name ?? `Simulation #${simulation.id}`}.`,
      'success'
    );
    return clone(trade);
  });
}

export function advanceOfflineSimulationDay(simulationId: number) {
  return updateState((state) => {
    const record = state.simulations.find((item) => item.simulation.id === simulationId);
    if (!record) {
      throw new Error('Simulation not found.');
    }

    const nextDate = new Date(record.simulation.current_sim_date);
    nextDate.setDate(nextDate.getDate() + 1);
    record.simulation.current_sim_date = nextDate.toISOString();
    refreshSimulationMetrics(record.simulation);
    appendNotification(state, 'Simulation advanced', `${record.simulation.name ?? `Simulation #${record.simulation.id}`} moved to the next market day.`);
    return clone(record.simulation);
  });
}

export function endOfflineSimulation(simulationId: number): EndSimulationResponse {
  return updateState((state) => {
    const record = state.simulations.find((item) => item.simulation.id === simulationId);
    if (!record) {
      throw new Error('Simulation not found.');
    }

    record.simulation.status = 'ended';
    record.simulation.ended_at = new Date().toISOString();
    refreshSimulationMetrics(record.simulation);
    record.analysis = buildSimulationAnalysis(record);
    appendNotification(state, 'Simulation finished', `${record.simulation.name ?? `Simulation #${record.simulation.id}`} is ready for offline review.`, 'success');
    return {
      simulation_id: simulationId,
      status: 'ended',
      message: 'Offline simulation completed.',
      analysis_task_id: null,
    };
  });
}

export function getOfflineSimulationTrades(simulationId: number) {
  const record = loadState().simulations.find((item) => item.simulation.id === simulationId);
  return clone(record?.trades ?? []);
}

export function getOfflineSimulationAnalysis(simulationId: number) {
  return updateState((state) => {
    const record = state.simulations.find((item) => item.simulation.id === simulationId);
    if (!record) {
      throw new Error('Simulation not found.');
    }

    if (!record.analysis && record.simulation.status === 'ended') {
      record.analysis = buildSimulationAnalysis(record);
    }

    return record.analysis
      ? clone(record.analysis)
      : ({
          id: simulationId,
          simulation_id: simulationId,
          status: 'pending',
        } as AIAnalysisResponse);
  });
}

export function getLocalGeminiApiKey() {
  return loadState().geminiApiKey;
}

export function setLocalGeminiApiKey(apiKey: string) {
  return updateState((state) => {
    state.geminiApiKey = apiKey.trim();
    appendNotification(
      state,
      'Gemini key updated',
      apiKey.trim()
        ? 'Your Gemini API key is stored locally on this device.'
        : 'Your Gemini API key was removed from this device.'
    );
    return state.geminiApiKey;
  });
}

export function getOfflineSyncSettings() {
  return loadState().syncSettings;
}

export function updateOfflineSyncSettings(settings: Partial<OfflineSyncSettings>) {
  return updateState((state) => {
    state.syncSettings = {
      ...state.syncSettings,
      ...settings,
    };
    return clone(state.syncSettings);
  });
}
