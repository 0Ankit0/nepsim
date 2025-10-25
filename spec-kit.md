# Feature Specification: NEPSE Market Simulator & AI Learning Platform

**Feature Branch**: `001-nepse-simulator`  
**Created**: 2025-10-25  
**Status**: Draft  
**Owner**: Ankit (project lead)  
**User Prompt**: "Create a NEPSE simulator with deep learning opportunity using collected data and AI, simulating future market based on trends and indicators. The app is a learning platform through simulation gaming where the user will be provided a certain amount of money and they buy or sell shares using that money. They can end the simulation and AI will provide deep dive summary of what they did right and what they did wrong along with detailed explanation on what they could've done."

---

## `/speckit.specify` - Feature Overview

Build a gamified NEPSE (Nepal Stock Exchange) trading simulator that enables users to learn stock trading through practice with virtual money. Users simulate real market conditions, make buy/sell decisions, and receive AI-powered deep-dive analysis of their performance, mistakes, and opportunities for improvement—transforming trading education into an interactive, feedback-rich learning experience.

### What Users Need (WHAT and WHY)

**As a beginner trader/student**, I need to:
- Start a simulation with virtual money (e.g., NPR 100,000)
- Buy and sell NEPSE stocks in a realistic simulated market environment
- See my portfolio performance in real-time (P&L, holdings)
- End the simulation whenever I choose
- Receive AI-generated analysis explaining what I did right, what I did wrong, and what I could have done better
- **Why**: Learn trading through safe practice without risking real capital, with personalized AI coaching

**As an intermediate trader**, I need to:
- Practice different trading strategies (day trading, swing trading, value investing)
- Get detailed AI feedback on timing, stock selection, risk management, and position sizing
- Compare my performance against market benchmarks and optimal strategies
- **Why**: Improve trading skills through deliberate practice with expert AI guidance

**As an educator/institution**, I need to:
- Provide students with a safe trading environment for experiential learning
- Track student progress and learning outcomes
- Offer standardized trading scenarios and challenges
- **Why**: Enhance financial literacy education with interactive, measurable learning tools

**As the platform (system perspective)**, I need to:
- Train deep learning models on historical NEPSE data to power realistic simulations
- Generate intelligent, contextual feedback using AI analysis of user trading decisions
- Track user behavior and learning patterns to improve AI recommendations
- **Why**: Create an effective learning platform that continuously improves

### User Stories (Prioritized)

#### P1 - Start Simulation and Trade with Virtual Money
**Independent Test**: Open app → start new simulation with NPR 100,000 → buy/sell stocks → view portfolio → verify balance updates

**Acceptance Scenarios**:
1. **Given** user opens mobile app, **When** user taps "Start New Simulation", **Then** new simulation created with configurable starting capital (default NPR 100,000) and user sees market dashboard
2. **Given** active simulation, **When** user searches for stock symbol (e.g., "NABIL"), **Then** user sees current price, historical chart, and "Buy" button
3. **Given** user wants to buy stock, **When** user enters quantity and taps "Buy", **Then** order executed at simulated market price, portfolio updated, and cash balance deducted including transaction costs
4. **Given** user holds stocks, **When** user taps "Sell" on holding, **Then** order executed, stocks removed from portfolio, and cash balance increased
5. **Given** active simulation, **When** user views portfolio screen, **Then** user sees current holdings, P&L (absolute and %), cash balance, and total portfolio value

#### P2 - Receive AI-Powered Performance Analysis and Feedback
**Independent Test**: Complete trading simulation → end simulation → verify AI generates comprehensive analysis of performance, mistakes, and recommendations

**Acceptance Scenarios**:
1. **Given** user has completed trades in simulation, **When** user taps "End Simulation", **Then** AI analysis job starts and user sees "Analyzing your performance..." loading screen
2. **Given** AI analysis complete, **When** user views results screen, **Then** user sees overall performance summary: total P&L, win rate, best/worst trades, Sharpe ratio
3. **Given** AI analysis results, **When** user scrolls to "What You Did Right" section, **Then** AI highlights successful decisions (e.g., "You bought NABIL at a local low after 3 days of decline—good timing")
4. **Given** AI analysis results, **When** user scrolls to "What You Did Wrong" section, **Then** AI explains mistakes with context (e.g., "You sold NICA too early, missing a 15% rally. The stock had strong fundamentals and upward momentum")
5. **Given** AI analysis results, **When** user scrolls to "What You Could Have Done" section, **Then** AI provides actionable alternative strategies (e.g., "If you had held NICA for 2 more weeks, your profit would have been NPR 8,500 higher. Consider using trailing stop-loss orders")
6. **Given** AI analysis results, **When** user taps on specific trade in timeline, **Then** user sees detailed AI commentary on that trade with market context and alternatives

#### P3 - Simulate Realistic Market Conditions with Advanced Charting
**Independent Test**: Verify simulation uses real historical NEPSE data, applies transaction costs, respects market hours/holidays, and provides comprehensive chart analysis tools

**Acceptance Scenarios**:
1. **Given** simulation starts, **When** backend selects historical period, **Then** simulation uses actual NEPSE daily OHLCV data from randomly selected past period (e.g., random 30-60 day window from 2020-2024)
2. **Given** user places buy order, **When** order executes, **Then** execution price includes realistic slippage (0.1-0.3%) and broker commission (0.4% SEBON fee + 0.6% broker)
3. **Given** simulation running, **When** simulated time reaches market close (3 PM NPT) or holiday, **Then** trading disabled with message "Market closed—trading resumes next business day"
4. **Given** user holds thinly traded stock, **When** user places large order, **Then** order partially filled based on historical volume data with increased slippage
5. **Given** user viewing stock chart, **When** user taps "Indicators" button, **Then** user sees menu with 50+ technical indicators organized by category: Trend (MA, EMA, SMA, VWAP), Momentum (RSI, MACD, Stochastic, CCI), Volatility (Bollinger Bands, ATR, Keltner Channels), Volume (Volume Profile, OBV, MFI)
6. **Given** user selects indicator (e.g., RSI), **When** indicator applied, **Then** indicator overlay appears on chart with configurable parameters (period, colors, thresholds)
7. **Given** user viewing stock chart, **When** user taps "Drawing Tools" button, **Then** user sees toolbar: Trendlines, Horizontal/Vertical Lines, Fibonacci Retracement, Fibonacci Extension, Support/Resistance Zones, Channels (Parallel, Regression), Shapes (Rectangle, Circle, Triangle), Text/Notes
8. **Given** user draws trendline, **When** user drags finger across chart, **Then** line persists on chart, snap-to-price feature helps precision, line saved per stock for future reference
9. **Given** user has multiple indicators/drawings, **When** user taps "Clear All" or individual delete, **Then** selected overlays removed from chart
10. **Given** user viewing chart, **When** user pinches to zoom or pans, **Then** chart maintains all indicators and drawings, updates smoothly with proper scaling

#### P4 - Track Learning Progress and Gamification
**Independent Test**: Complete multiple simulations → verify user sees progress metrics, achievements, and skill ratings

**Acceptance Scenarios**:
1. **Given** user completes first simulation, **When** user views profile, **Then** user sees stats: total simulations, average P&L, win rate, best streak
2. **Given** user achieves milestone, **When** milestone reached (e.g., 10% profit, 5 simulations completed), **Then** user receives badge/achievement notification
3. **Given** multiple completed simulations, **When** user views progress screen, **Then** user sees skill ratings (timing, stock selection, risk management, patience) generated by AI based on trading patterns
4. **Given** user struggles with specific aspect, **When** AI analysis identifies pattern (e.g., "sells winners too early 80% of the time"), **Then** AI provides targeted learning resources and practice challenges

#### P5 - Browse and Learn from Educational Content
**Independent Test**: Access "Learn More" tab → view lessons on technical analysis → complete quizzes → access previous simulation history

**Acceptance Scenarios**:
1. **Given** user taps "Learn More" tab on home screen, **When** screen loads, **Then** user sees structured curriculum on technical analysis with sections: Introduction, Chart Patterns, Technical Indicators, Volume Analysis, Risk Management
2. **Given** user selects lesson (e.g., "Understanding RSI"), **When** lesson opens, **Then** user sees visual diagrams/pictures, easy-to-understand text explanations, real NEPSE examples, and embedded interactive quiz at end of lesson
3. **Given** user completes quiz, **When** user submits answers, **Then** user receives immediate feedback with explanations for correct/incorrect answers, score recorded in progress tracking
4. **Given** user taps "Previous Analysis" tab on home screen, **When** screen loads, **Then** user sees scrollable list of all past simulations with summary cards (date, P&L, win rate, duration)
5. **Given** user taps on any previous simulation card, **When** detail screen opens, **Then** user sees full simulation details: all trades, AI analysis, portfolio evolution, metrics—identical to the post-simulation analysis screen
6. **Given** user viewing stock detail during simulation, **When** user taps "AI Insights", **Then** AI provides plain-English explanation of why stock might be good/bad buy based on current market conditions, fundamentals, technicals
7. **Given** user confused by term, **When** user long-presses financial term (e.g., "P/E ratio"), **Then** AI-powered contextual tooltip explains the concept with NEPSE-specific examples

### Edge Cases

- **User runs out of cash mid-simulation?** → Trading disabled; user can only sell holdings or reset simulation
- **Stock selected doesn't have data for simulated period?** → Stock disabled with message "Not available in this time period"; user picks different stock
- **User tries to buy more than they can afford?** → Show error "Insufficient funds. You can buy maximum X shares with NPR Y available"
- **User closes app during active simulation?** → Simulation state persisted in database; resumed when app reopens
- **AI analysis fails to generate?** → Show cached generic feedback + error report; retry analysis available
- **Multiple users start simulation on same device?** → Require login/account creation for cloud sync [NEEDS CLARIFICATION: multi-user requirement?]
- **User wants to pause simulation?** → Simulation auto-pauses when app backgrounded; market time doesn't advance
- **Stock undergoes split during simulation period?** → Prices auto-adjusted; AI explains split in analysis if user held stock
- **User tries to place multiple orders same day?** → All orders executed at day's closing price (daily resolution - no intraday executions)
- **User adds too many chart indicators causing performance issues?** → Warn after 10 indicators, limit to 15 max overlays, suggest removing unused ones
- **User's chart drawings lost due to app crash?** → Auto-save every 30 seconds; restore from last saved state on reopen
- **Historical data has missing days (gaps)?** → Simulation skips missing days, AI explains in context if it affected trading decisions

### Open Questions / Needs Clarification

- **[NEEDS CLARIFICATION]**: Multi-user deployment - Should the system support JWT-based authentication for multiple users, or is this a single-user local deployment? (FR-022)
- **[NEEDS CLARIFICATION]**: Data licensing - Are there any usage restrictions or licensing requirements on the collected NEPSE dataset?
- **[NEEDS CLARIFICATION]**: Educational content source - Should lessons be manually created, or should we use AI to generate initial content? Who will review for accuracy?
- **[NEEDS CLARIFICATION]**: Production deployment target - Cloud (AWS/GCP/Azure), on-premise, or local-only? This affects architecture decisions for Phase 0.
- **[NEEDS CLARIFICATION]**: LLM provider preference - OpenAI GPT-4 or Anthropic Claude? Budget for API calls?
- **[NEEDS CLARIFICATION]**: Mobile vs Web priority - Should we prioritize iOS, Android, or Web first, or launch all platforms simultaneously?

### Specification Quality Checklist

#### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain (6 outstanding - see above)
- [x] Requirements are testable and unambiguous (all FRs have clear acceptance criteria)
- [x] Success criteria are measurable (12 SCs with specific metrics)
- [x] Edge cases are documented (12 edge cases identified)
- [x] User stories have acceptance scenarios (5 prioritized stories with scenarios)

#### Consistency
- [x] No conflicting requirements detected
- [x] All user stories trace to functional requirements
- [x] All technical decisions support user stories
- [x] Non-functional requirements are explicit (performance, scalability in SCs)

#### Traceability
- [x] Each requirement has clear rationale (Why explained for each user persona)
- [x] Dependencies between requirements identified (implementation phases show dependencies)
- [x] Impact of changes assessed (daily-only data requirement affects multiple FRs)

---

## `/speckit.plan` - Implementation Plan

**Note**: This section contains high-level implementation approach. Detailed technical specifications should be extracted to separate files in `implementation-details/` directory as the project evolves.

### Technology Stack

**Backend**: Python 3.11+ with FastAPI
**Frontend**: React Native (cross-platform mobile: iOS, Android, Web)
**Database**: PostgreSQL (daily time-series data, user progress, simulations)
**LLM Integration**: OpenAI GPT-4 API or Anthropic Claude API (for AI feedback generation)
**Deep Learning** (optional): PyTorch, PyTorch Lightning (for price prediction models, pattern recognition)
**Data Processing**: pandas, numpy, pyarrow (Parquet)
**Technical Indicators**: pandas-ta or ta-lib (50+ indicators for charting and AI insights)
**Charting Library**: React Native chart library with custom overlays (Victory Native, react-native-chart-kit, or custom canvas)
**ORM**: SQLAlchemy with asyncpg for PostgreSQL
**API**: FastAPI with async support
**Caching** (optional): Redis for session state and chart data
**Task Queue** (optional): Celery or RQ for async AI analysis generation
**Analytics** (optional): Mixpanel or Amplitude for user behavior tracking

### Architecture Overview

```
Backend (Python FastAPI)
├── data/                   # Raw and processed datasets
│   ├── raw/                # Original collected data
│   └── processed/          # Validated, normalized Parquet files
│
├── src/
│   ├── ingestion/          # Data parsers, validators, corporate actions
│   ├── features/           # Technical indicators, feature engineering
│   ├── simulator/          # Event-driven market simulator engine
│   ├── models/             # DL forecasting models (LSTM, GRU, Transformers)
│   ├── backtest/           # Backtester, strategy wrapper, reporting
│   ├── api/                # FastAPI REST endpoints
│   ├── database/           # PostgreSQL models, migrations, queries
│   └── services/           # Business logic layer
│
├── experiments/            # MLFlow experiment artifacts
├── notebooks/              # Demo and analysis notebooks
├── tests/                  # Unit, integration tests
└── alembic/                # Database migrations

Frontend (React Native)
├── src/
│   ├── screens/            # Main app screens
│   │   ├── DataUpload/     # Upload and preview datasets
│   │   ├── Training/       # Model training dashboard
│   │   ├── Backtest/       # Configure and run backtests
│   │   └── Results/        # Visualize predictions, trades, P&L
│   ├── components/         # Reusable UI components
│   ├── services/           # API client (axios/fetch)
│   ├── store/              # State management (Redux/Zustand)
│   └── utils/              # Helper functions, formatters

Database (PostgreSQL + pgvector)
├── symbols                 # Stock symbols metadata
├── ohlcv_data              # Historical price data (time-series)
├── corporate_actions       # Splits, dividends
├── models                  # Trained model metadata
├── backtests               # Backtest run records
├── trades                  # Individual trade records
├── predictions             # Model predictions (with vector embeddings if using pgvector)
└── embeddings              # Feature embeddings for similarity search (pgvector)
```

### Core Components

#### 1. Data Ingestion & Market Data Service (`src/ingestion/` + `src/market_data/`)
- **Historical Data Loading**: Load and cache historical NEPSE daily OHLCV data (all data is daily resolution)
- **Random Period Selection**: Select realistic trading periods for simulation (avoid look-ahead)
- **Real-time Simulation Engine**: Stream historical daily data as "live" market data during simulation (1 sim day = configurable real time, e.g., 30 seconds)
- **Database Storage**: Store historical daily data in PostgreSQL time-series optimized tables
- **API**: Endpoints to fetch current simulated prices, historical charts, stock metadata

#### 2. Simulation & Trading Engine (`src/simulator/`)
- **User Session Management**: Create/pause/resume/end user trading sessions
- **Virtual Portfolio**: Track cash balance, stock holdings, P&L in real-time
- **Order Execution**: Execute buy/sell orders with realistic slippage, commissions, partial fills (daily resolution only - no intraday)
- **Market Rules**: Enforce NEPSE trading hours, holidays, price limits, minimum lot sizes (daily trading only)
- **Transaction Logging**: Store every trade, order, portfolio state change for AI analysis
- **Time Control**: Simulate passage of days (1 sim day = configurable real time, e.g., 30 seconds to 1 minute per trading day)

#### 3. AI Analysis & Feedback Engine (`src/ai_analysis/`)
- **Performance Calculator**: Compute metrics (total P&L, win rate, Sharpe, max drawdown, holding periods, turnover)
- **Decision Analyzer**: Analyze each buy/sell decision against market context:
  - Entry/exit timing quality (did user buy at local high/low?)
  - Holding period appropriateness (sold too early/late?)
  - Stock selection quality (picked winners vs losers?)
  - Risk management (position sizing, diversification)
- **LLM-Powered Feedback Generator**: Use GPT/Claude to generate natural language explanations:
  - "What You Did Right": Highlight successful decisions with reasoning
  - "What You Did Wrong": Explain mistakes with empathy and context
  - "What You Could Have Done": Provide counterfactual analysis and actionable alternatives
- **Comparison Engine**: Compare user performance vs:
  - Buy-and-hold strategy
  - Market index (NEPSE index)
  - Optimal hindsight strategy
- **Pattern Detection**: Identify behavioral patterns (panic selling, FOMO buying, overtrading)

#### 4. Deep Learning Models (`src/models/`)
- **Price Prediction Models** (Optional enhancement):
  - LSTM/GRU for next-day price forecasting using daily data
  - Used to power "AI Insights" feature (not to cheat simulation, but to educate users)
- **User Behavior Models**:
  - Predict user skill level based on trading patterns
  - Personalize difficulty and recommendations
- **Market Pattern Recognition**:
  - Identify support/resistance levels, trends, breakouts from daily data
  - Use in AI feedback explanations and auto-detect patterns for chart annotations

#### 5. Gamification & Progress Tracking (`src/gamification/`)
- **Achievement System**: Define and track badges/achievements (first profit, 5-trade streak, etc.)
- **Skill Ratings**: Calculate skill scores in categories (timing, selection, risk management, patience)
- **Leaderboards** (optional): Anonymous rankings by P&L, Sharpe, consistency
- **Challenge System**: Pre-defined trading scenarios with goals and rewards
- **Progress Analytics**: Track learning curve across multiple simulations

#### 6. FastAPI Backend (`src/api/`)
- **Simulation Endpoints**:
  - `POST /api/simulations/start` → Start new simulation with initial capital
  - `GET /api/simulations/{id}` → Get simulation state (portfolio, balance, trades)
  - `POST /api/simulations/{id}/trade` → Execute buy/sell order
  - `POST /api/simulations/{id}/end` → End simulation and trigger AI analysis
  - `GET /api/simulations/{id}/analysis` → Get AI-generated performance analysis
- **Market Data Endpoints**:
  - `GET /api/market/stocks` → List available stocks with metadata
  - `GET /api/market/stocks/{symbol}` → Get current simulated price and chart data
  - `GET /api/market/stocks/{symbol}/history` → Historical daily OHLCV data for charts
  - `GET /api/market/stocks/{symbol}/indicators` → Compute technical indicators on-demand (RSI, MACD, Bollinger Bands, etc.) with configurable parameters
  - `POST /api/market/chart-drawings/save` → Save user's chart drawings and annotations per stock
  - `GET /api/market/chart-drawings/{user_id}/{symbol}` → Retrieve saved chart drawings for stock
- **User & Progress Endpoints**:
  - `GET /api/users/{id}/simulations` → List user's past simulations with summaries (for "Previous Analysis" tab)
  - `GET /api/simulations/{id}/full-details` → Get complete simulation details including trades and AI analysis (for viewing past simulation)
  - `GET /api/users/{id}/progress` → Get skill ratings, achievements, stats
- **Educational Content & Quizzes**:
  - `GET /api/learn/lessons` → List all technical analysis lessons with sections
  - `GET /api/learn/lessons/{id}` → Get lesson content with pictures, text, and associated quiz
  - `GET /api/learn/quizzes/{lesson_id}` → Get quiz questions for specific lesson
  - `POST /api/learn/quizzes/{quiz_id}/submit` → Submit quiz answers, get score and feedback
  - `GET /api/users/{id}/quiz-progress` → Get user's quiz completion and scores
  - `POST /api/learn/ai-insights` → Get AI explanation of stock/concept

#### 7. React Native Frontend (`frontend/`)
- **Screens**:
  - **Home/Dashboard** (Tab Navigation):
    - **Tab 1 - Start New Simulation**: Primary CTA to begin new trading simulation, configure starting capital, view active simulation status
    - **Tab 2 - Learn More**: In-depth technical analysis education with visual aids, pictures, easy-to-understand descriptions, interactive quizzes
    - **Tab 3 - Previous Analysis**: Complete history of past simulations with summary cards, click to view full details of any past simulation
  - **Simulation Trading**: Live market view, search stocks, view portfolio, execute trades, see P&L
  - **Stock Detail with Advanced Charting**: 
    - Candlestick/Line/Area chart with pinch-zoom and pan
    - **Technical Indicators Panel** (50+ indicators organized by category):
      - Trend: SMA, EMA, WMA, VWAP, TEMA, HMA, McGinley Dynamic
      - Momentum: RSI, MACD, Stochastic, CCI, Williams %R, ROC, Momentum, TSI
      - Volatility: Bollinger Bands, ATR, Keltner Channels, Donchian Channels, Standard Deviation
      - Volume: Volume, Volume MA, OBV, Volume Profile, MFI, A/D Line, Chaikin Money Flow
      - Oscillators: Awesome Oscillator, Ultimate Oscillator, Aroon
      - Trend Following: Ichimoku Cloud, Supertrend, Parabolic SAR
    - **Drawing Tools Toolbar**:
      - Line Tools: Trendline, Horizontal Line, Vertical Line, Ray, Extended Line
      - Fibonacci: Retracement, Extension, Fan, Arc, Time Zones
      - Channels: Parallel Channel, Regression Channel
      - Shapes: Rectangle, Circle, Triangle, Arrow
      - Annotations: Text Notes, Price Labels, Info Box
      - Measurement: Distance Tool, Price Range Tool
    - **Chart Controls**: Timeframe selector (1M, 3M, 6M, 1Y, ALL), Chart type (Candlestick, Line, Area, Hollow Candles), Indicator settings, Drawing tool controls, Clear all/delete individual overlays
    - Company info, "Buy/Sell" buttons, AI insights button
  - **Portfolio**: Holdings list, allocation pie chart, performance graph
  - **Analysis Results**: Post-simulation AI feedback with tabs (Summary, Right, Wrong, Could Have Done, Trade Timeline)
  - **Profile & Progress**: Skill ratings, achievements, learning stats (separate from simulation history)
- **Key Features**:
  - Tab-based home navigation (Start New Simulation | Learn More | Previous Analysis)
  - Real-time portfolio value updates during simulation (daily resolution)
  - **Advanced Interactive Charting**:
    - 50+ technical indicators with configurable parameters
    - Professional drawing tools (trendlines, Fibonacci, channels, shapes, annotations)
    - Persistent chart annotations (saved per user per stock)
    - Multiple chart types (candlestick, line, area, hollow candles)
    - Smooth pinch-zoom, pan, and touch interactions
    - Indicator overlays with customizable colors and parameters
    - Auto-save chart state with undo/redo functionality
  - Trade confirmation dialogs with cost breakdown
  - AI loading states with engaging animations
  - Gamification elements (badges, level-up notifications)
  - Visual learning content with pictures and diagrams for technical analysis
  - Interactive quizzes with instant feedback and progress tracking
  - Complete simulation history with tap-to-view full details

#### 8. PostgreSQL Database (`database/`)
- **Schema**:
  - `users`: User accounts, preferences
  - `simulations`: Simulation sessions (user_id, start_time, end_time, initial_capital, final_portfolio_value, status)
  - `simulation_portfolios`: Current holdings per simulation
  - `trades`: All buy/sell transactions (simulation_id, symbol, side, quantity, price, timestamp, commission)
  - `market_data_ohlcv`: Historical NEPSE daily price data (date, symbol, open, high, low, close, volume)
  - `stocks_metadata`: Symbol info (name, sector, fundamentals)
  - `ai_analyses`: Generated AI feedback per simulation
  - `achievements`: User achievements and badges
  - `user_progress`: Skill ratings, stats per user
  - `educational_content`: Technical analysis lessons with sections, pictures, text content
  - `quizzes`: Quiz questions linked to lessons (question, options, correct_answer, explanation)
  - `user_quiz_results`: User quiz attempts and scores
  - `chart_drawings`: Saved chart annotations per user per stock (drawing_type, coordinates, parameters, style)
  - `challenges`: Pre-defined trading scenarios (optional future feature)

#### 9. LLM Integration (`src/llm/`)
- **Provider**: OpenAI GPT-4 or Anthropic Claude API
- **Prompt Engineering**: Structured prompts to generate:
  - Performance analysis narratives
  - Trade-by-trade commentary
  - Educational explanations
  - Personalized recommendations
- **Context Building**: Provide LLM with:
  - User's trades with timestamps and prices
  - Market conditions during each trade (trends, volatility, news)
  - Performance metrics and comparisons
  - User's historical patterns (if available)
- **Output Parsing**: Parse LLM JSON responses into structured feedback for frontend display

### Implementation Phases

**Phase -1: Pre-Implementation Gates**

Before beginning implementation, validate against architectural principles:

#### Simplicity Gate
- [x] Using ≤3 core projects? **YES** - Backend (Python FastAPI), Frontend (React Native), Database (PostgreSQL)
- [x] No future-proofing? **YES** - MVP focuses on daily trading only, no premature intraday support
- [x] No speculative features? **YES** - All features trace to prioritized user stories (P1-P5)
- [ ] **NEEDS REVIEW**: MLFlow and DVC add complexity - are these essential for MVP or Phase 5?

#### Anti-Abstraction Gate
- [x] Using frameworks directly? **YES** - FastAPI, React Native, SQLAlchemy used without wrappers
- [x] Single model representation? **YES** - One SQLAlchemy model per entity, no parallel representations
- [x] No unnecessary interfaces? **YES** - Direct database access via services, no repository pattern abstraction

#### Integration-First Gate
- [ ] **TODO**: API contracts must be defined before Phase 1 implementation (create `contracts/` directory)
- [ ] **TODO**: Contract tests must be written before implementation code
- [ ] **TODO**: Use real PostgreSQL in tests (no mocks), real LLM API in integration tests

#### Complexity Tracking
No complexity exceptions approved yet. Any deviations from simplicity principles must be documented here with justification.

---

**Phase 0: Setup & Data Foundation** (Week 0)
- Backend: Repository structure, pyproject.toml, dependencies (FastAPI, SQLAlchemy, asyncpg, pandas, etc.)
- Frontend: React Native project setup with Expo
- Database: PostgreSQL setup, initial schema (users, simulations, trades, market_data, stocks)
- Load historical NEPSE data into database
- LLM API setup (OpenAI/Claude account, test prompts)
- README with setup instructions

**Phase 1: Core Simulation Engine & Trading** (Week 1)
- Backend: Simulation session management (create, get, update state) - daily resolution only
- Backend: Virtual portfolio tracking (cash, holdings, P&L calculation)
- Backend: Order execution engine with realistic costs (daily trades only)
- Backend: Market data API (get stocks, daily prices, historical charts)
- Backend: FastAPI endpoints for starting simulation and executing trades
- Backend: Technical indicators calculation API (50+ indicators using pandas-ta/ta-lib)
- Frontend: Home screen (start simulation, view active simulation)
- Frontend: Trading screen (search stocks, view portfolio, buy/sell buttons)
- Frontend: Basic stock detail screen (price chart, company info, buy form)
- Deliverable: User can start simulation, buy/sell stocks, see portfolio update in real-time

**Phase 2: AI Analysis & Feedback** (Week 2)
- Backend: Performance metrics calculator (P&L, win rate, Sharpe, holding periods)
- Backend: Trade decision analyzer (timing quality, stock selection scoring)
- Backend: LLM integration for feedback generation (prompt engineering)
- Backend: API endpoint for ending simulation and getting AI analysis
- Frontend: "End Simulation" flow with loading animation
- Frontend: Analysis results screen with tabs (Summary, What You Did Right/Wrong/Could Have Done)
- Frontend: Trade timeline with AI commentary per trade
- Deliverable: User receives personalized AI feedback after completing simulation

**Phase 3: Progress Tracking & Gamification** (Week 3)
- Backend: Achievement system (define badges, track unlocks)
- Backend: Skill rating calculator (analyze patterns across simulations)
- Backend: User progress API endpoints
- Frontend: Profile screen (simulation history, stats, achievements)
- Frontend: Progress screen (skill ratings with radar chart, badges display)
- Frontend: Achievement unlock animations and notifications
- Frontend: Simulation history list with P&L summaries
- Deliverable: Users see progress across multiple simulations with gamification elements

**Phase 4: Learning Content & Advanced Charting** (Week 4)
- Backend: Educational content management (technical analysis lessons with pictures/diagrams in database)
- Backend: Quiz system (questions, answers, scoring API)
- Backend: Simulation history API (list all past simulations with summaries, get full details by ID)
- Backend: AI insights endpoint (explain stocks, concepts on demand)
- Backend: Chart drawings persistence API (save/load user annotations per stock)
- Frontend: Home screen with 3-tab navigation (Start New Simulation | Learn More | Previous Analysis)
- Frontend: "Learn More" tab (browse structured technical analysis curriculum with visual content)
- Frontend: Lesson detail screen (pictures, easy descriptions, embedded quizzes)
- Frontend: Quiz UI with instant feedback and score display
- Frontend: "Previous Analysis" tab (scrollable list of past simulations)
- Frontend: Previous simulation detail view (reuse analysis results screen component)
- Frontend: **Advanced Charting Features**:
  - Technical indicators panel with 50+ indicators organized by category
  - Drawing tools toolbar (trendlines, Fibonacci, channels, shapes, annotations)
  - Chart controls (timeframe selector, chart type switcher, settings)
  - Persistent chart annotations with save/load functionality
  - Smooth touch interactions with snap-to-price for precision
- Frontend: AI contextual help (long-press terms for explanations)
- Frontend: Polish UI/UX, add animations, improve charts
- Integration testing: Full user journey from onboarding → simulation → feedback → learning → quiz → history review → advanced chart analysis
- Deliverable: Complete learning platform with visual education, quizzes, full simulation history access, and professional-grade charting tools

**Phase 5: Advanced Features** (Post-MVP)
- Backend: Challenge system (pre-defined scenarios with goals and scoring)
- Backend: Leaderboards (anonymous rankings, privacy-preserving)
- Backend: Advanced DL models for price prediction (LSTM) to power AI insights
- Backend: Pattern recognition models (support/resistance detection)
- Frontend: Challenge mode with scenario instructions and goals (separate from Learn More tab)
- Frontend: Leaderboard screen
- Frontend: Advanced portfolio analytics (risk metrics, sector allocation)
- Frontend: Social features (share results, compare with friends)
- Frontend: Onboarding tutorial and interactive walkthrough
- Frontend: Advanced charting features (drawing tools, multiple timeframes)

### Implementation Plan Quality Checklist

#### Architecture Validation
- [x] Technology stack justified with rationale (each choice explained in context)
- [x] All components map to user stories (9 core components support P1-P5)
- [x] Dependencies explicitly documented (Phase 0 → 1 → 2 → 3 → 4 sequence)
- [x] Performance considerations addressed (SC-005, SC-007, SC-011 define targets)
- [ ] **TODO**: Security model not yet specified (authentication, authorization, data encryption)

#### Implementation Readiness
- [ ] **TODO**: API contracts need to be created in `contracts/` directory
- [ ] **TODO**: Data model schemas need detailed specification in `data-model.md`
- [ ] **TODO**: Test scenarios need extraction to `quickstart.md`
- [x] Phase gates clearly defined (Phase -1 gates enforce architectural principles)
- [x] Phases have clear deliverables (each phase has explicit "Deliverable:" statement)

#### Constitutional Compliance
- [x] Test-first approach enforced (Phase -1 Integration-First Gate requires contract tests first)
- [x] Simplicity validated (≤3 core projects, no unnecessary abstraction)
- [x] CLI interfaces where appropriate (backend API serves as CLI-accessible interface)
- [ ] **TODO**: Library-first principle - should simulator, AI analysis be standalone libraries?

---

## `/speckit.tasks` - Executable Task List

### Phase 0: Setup [P]
- [ ] [P] Create backend repository structure (data/, src/, experiments/, tests/, alembic/)
- [ ] [P] Create `pyproject.toml` with dependencies (FastAPI, SQLAlchemy, asyncpg, PyTorch, pandas, pyarrow, pandas-ta, mlflow, dvc, pytest)
- [ ] [P] Create React Native project (`npx create-expo-app` or `npx react-native init`)
- [ ] [P] Install PostgreSQL and pgvector extension
- [ ] [P] Create initial database schema (symbols, ohlcv_data, models, backtests, trades)
- [ ] [P] Initialize Alembic for database migrations
- [ ] [P] Initialize DVC for data versioning (`dvc init`)
- [ ] [P] Set up MLFlow tracking server
- [ ] [P] Create README.md for backend with setup instructions
- [ ] [P] Create README.md for frontend with setup instructions
- [ ] [P] Set up backend pre-commit hooks (ruff, black)
- [ ] [P] Set up frontend ESLint and Prettier

### Phase 1: Data Ingestion & Basic API [P]
- [ ] [P] Implement CSV parser with timezone handling (`src/ingestion/parsers.py`)
- [ ] [P] Implement Parquet reader (`src/ingestion/parsers.py`)
- [ ] [P] Create validation module: gap detection, duplicate checking, outlier flagging (`src/ingestion/validators.py`)
- [ ] [P] Implement symbol metadata loader (`src/ingestion/metadata.py`)
- [ ] [P] Create corporate actions adjuster (`src/ingestion/corporate_actions.py`)
- [ ] Create PostgreSQL ORM models (`src/database/models.py`)
- [ ] Create database service layer (`src/database/services.py`)
- [ ] Create FastAPI app structure (`src/api/main.py`)
- [ ] Implement POST `/api/ingest` endpoint
- [ ] Implement GET `/api/symbols` endpoint
- [ ] Implement GET `/api/ohlcv/{symbol}` endpoint
- [ ] Write unit tests for parsers (`tests/test_ingestion.py`)
- [ ] Write API integration tests (`tests/test_api.py`)
- [ ] [P] Create React Native API client (`frontend/src/services/api.js`)
- [ ] [P] Create DataUpload screen (`frontend/src/screens/DataUpload.js`)
- [ ] [P] Create DataPreview screen (`frontend/src/screens/DataPreview.js`)
- [ ] [P] Implement file picker and upload functionality

### Phase 2: Simulator Engine & Backtest API [Sequential]
- [ ] Design Order, Trade, Position data models (`src/simulator/models.py`)
- [ ] Create database tables for orders, trades, positions (Alembic migration)
- [ ] Implement event-driven simulator core (`src/simulator/engine.py`)
- [ ] Implement market order execution with transaction costs (`src/simulator/execution.py`)
- [ ] Implement position tracking and P&L calculation (`src/simulator/portfolio.py`)
- [ ] Create simulator configuration schema (YAML/Pydantic) (`src/simulator/config.py`)
- [ ] Write deterministic simulator test (`tests/test_simulator.py`)
- [ ] Implement backtester wrapper with database persistence (`src/backtest/backtester.py`)
- [ ] Create backtest report generator (`src/backtest/reporting.py`)
- [ ] Implement POST `/api/simulate` endpoint (start backtest job)
- [ ] Implement GET `/api/simulate/{id}/status` endpoint
- [ ] Implement GET `/api/simulate/{id}/results` endpoint
- [ ] Implement GET `/api/backtests` endpoint (list all backtests)
- [ ] [P] Create Backtest configuration screen (`frontend/src/screens/BacktestConfig.js`)
- [ ] [P] Create Backtest status screen with progress indicator (`frontend/src/screens/BacktestStatus.js`)
- [ ] [P] Implement polling for backtest status updates

### Phase 3: Feature Pipeline & ML Training API [P]
- [ ] [P] Implement technical indicators: EMA, RSI, MACD (`src/features/indicators.py`)
- [ ] [P] Implement derived features: returns, log-returns, rolling stats (`src/features/derived.py`)
- [ ] [P] Create feature cache (Parquet + PostgreSQL materialized views) (`src/features/cache.py`)
- [ ] [P] Create feature configuration schema (YAML) (`src/features/config.py`)
- [ ] [P] (Optional) Implement pgvector embeddings for features (`src/features/embeddings.py`)
- [ ] Write unit tests for indicators (`tests/test_features.py`)
- [ ] Create time-series dataset class for PyTorch (`src/models/dataset.py`)
- [ ] Implement LSTM forecasting model (`src/models/lstm.py`)
- [ ] Create PyTorch Lightning training module (`src/models/trainer.py`)
- [ ] Integrate MLFlow logging (`src/models/mlflow_utils.py`)
- [ ] Implement walk-forward cross-validation (`src/models/validation.py`)
- [ ] Create database models for trained models metadata (`src/database/models.py`)
- [ ] Implement POST `/api/train` endpoint (start training job)
- [ ] Implement GET `/api/train/{id}/status` endpoint
- [ ] Implement GET `/api/models` endpoint (list trained models)
- [ ] Implement GET `/api/predictions/{model_id}` endpoint
- [ ] Write model training smoke test (`tests/test_training.py`)
- [ ] [P] Create Training dashboard screen (`frontend/src/screens/Training.js`)
- [ ] [P] Create Model registry screen (`frontend/src/screens/ModelRegistry.js`)
- [ ] [P] Implement training progress visualization

### Phase 4: Results Visualization & Integration [Sequential]
- [ ] Implement GET `/api/simulate/{id}/trades` endpoint (get trade history)
- [ ] Implement GET `/api/simulate/{id}/metrics` endpoint (get performance metrics)
- [ ] Implement GET `/api/predictions/{model_id}/chart-data` endpoint
- [ ] Install React Native chart library (Victory Native or react-native-svg-charts)
- [ ] Create reusable chart components (`frontend/src/components/Charts/`)
- [ ] Create Results screen with tabs (`frontend/src/screens/Results.js`)
- [ ] Implement price chart with predictions overlay
- [ ] Implement trade timeline visualization
- [ ] Implement P&L curve chart
- [ ] Implement metrics summary cards
- [ ] Create Symbol explorer screen (`frontend/src/screens/SymbolExplorer.js`)
- [ ] Implement historical data chart for symbols
- [ ] Create end-to-end demo script (backend)
- [ ] Create demo walkthrough video (frontend)
- [ ] Write integration tests for full workflow
- [ ] Update README with complete setup and usage guide
- [ ] Create smoke test script (full pipeline in <10 min)

### Phase 5: Advanced Features (Post-MVP) [P]
- [ ] [P] Implement advanced DL models for price prediction (LSTM/GRU) using daily data to power AI insights
- [ ] [P] Create RL environment wrapper (Gymnasium) for daily trading agent training
- [ ] [P] Implement Temporal Fusion Transformer model for multi-day forecasting
- [ ] [P] Implement pgvector similarity search for pattern matching on daily data
- [ ] [P] Implement WebSocket endpoints for real-time updates (`src/api/websockets.py`)
- [ ] [P] Implement portfolio recommendations screen with AI-suggested strategies
- [ ] [P] Add push notifications for job completion
- [ ] [P] Create React Native Web build for desktop access
- [ ] [P] Implement JWT authentication (backend + frontend)
- [ ] [P] Add more drawing tools (Andrews Pitchfork, Gann Fan, Elliott Wave tools)
- [ ] [P] Implement chart templates (save/load entire chart setups)
- [ ] [P] Add auto-pattern detection (AI identifies head & shoulders, triangles, flags)
- [ ] [P] Implement alert system (price alerts, indicator crossovers)

**Legend**: [P] = Can be parallelized

---

## Supporting Documents

This specification should be accompanied by the following documents (to be created):

### Required for Implementation
1. **`data-model.md`** - Detailed database schema with:
   - Complete table definitions with all columns and types
   - Indexes and constraints
   - Relationships and foreign keys
   - Sample data structures
   - Migration scripts

2. **`contracts/`** - API contracts directory containing:
   - `api-simulation.yaml` - OpenAPI spec for simulation endpoints
   - `api-market-data.yaml` - OpenAPI spec for market data endpoints
   - `api-learning.yaml` - OpenAPI spec for educational content endpoints
   - `api-charting.yaml` - OpenAPI spec for chart indicators and drawings
   - `websocket-events.md` - WebSocket event schemas (if implemented)

3. **`quickstart.md`** - Key validation scenarios:
   - Happy path: Complete simulation workflow
   - Edge case validations for each identified edge case
   - Performance test scenarios (based on success criteria)
   - Manual testing checklist

4. **`research.md`** - Technical research findings:
   - Charting library comparison (Victory Native vs react-native-chart-kit vs custom canvas)
   - Technical indicator library evaluation (pandas-ta vs ta-lib)
   - LLM provider comparison (OpenAI GPT-4 vs Anthropic Claude)
   - React Native chart performance benchmarks
   - PostgreSQL time-series optimization strategies

### Optional Supporting Documents
5. **`implementation-details/`** - Detailed algorithms and code patterns:
   - `ai-prompts.md` - LLM prompt templates for feedback generation
   - `indicator-calculations.md` - Technical indicator formulas
   - `p&l-calculation.md` - Portfolio P&L calculation logic
   - `simulation-engine.md` - Event-driven simulator architecture

6. **`constitution.md`** - Project architectural principles (if adopting full SDD):
   - Library-first principle application
   - Test-first development guidelines
   - Simplicity and anti-abstraction rules
   - Integration-first testing approach

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST ingest daily OHLCV data from CSV/Parquet with configurable timestamp parsing and timezone handling (daily resolution only, no intraday data)
- **FR-002**: System MUST validate data for gaps, duplicates, outliers, and produce detailed validation reports
- **FR-003**: System MUST compute 50+ technical indicators (SMA, EMA, RSI, MACD, Bollinger Bands, VWAP, Stochastic, ATR, etc.) with configurable lookback periods
- **FR-004**: System MUST support training deep learning forecasting models (LSTM, GRU, Transformers) on daily data with PyTorch/PyTorch Lightning
- **FR-005**: System MUST implement event-driven market simulator supporting market orders at daily resolution only (no intraday trading)
- **FR-006**: System MUST apply transaction costs (commissions, slippage, bid-ask spread) configurable per simulation
- **FR-007**: System MUST track positions, compute P&L, and generate backtest reports with standard metrics (Sharpe, max drawdown, win rate)
- **FR-008**: System MUST log all experiments (hyperparameters, metrics, artifacts) to MLFlow
- **FR-009**: System MUST version datasets using DVC for reproducibility
- **FR-010**: Backend MUST provide FastAPI REST endpoints for all operations (ingest, train, simulate, query)
- **FR-011**: System MUST implement walk-forward cross-validation to prevent look-ahead bias
- **FR-012**: System MUST handle corporate actions (splits, dividends) by adjusting historical prices with audit log
- **FR-013**: System MUST store all data in PostgreSQL with proper indexing for daily time-series queries
- **FR-014**: System MUST support pgvector extension for feature embeddings and similarity search [Optional for MVP]
- **FR-015**: Frontend MUST be built with React Native supporting iOS, Android, and Web platforms
- **FR-016**: Frontend MUST communicate with backend exclusively via REST API
- **FR-017**: Frontend MUST display advanced interactive charts with 50+ technical indicators, professional drawing tools (trendlines, Fibonacci, channels, shapes), and persistent annotations
- **FR-018**: System MUST support async operations for long-running tasks (training, backtesting, AI analysis) with status polling
- **FR-019**: System MUST operate exclusively with daily resolution data (no intraday trading or tick data)
- **FR-020**: System MUST implement RL environment wrapper (OpenAI Gym compatible) for agent training [Optional for MVP]
- **FR-021**: System MUST provide WebSocket support for real-time training/backtest progress updates [Optional for MVP]
- **FR-022**: System MUST support JWT-based authentication for multi-user scenarios [NEEDS CLARIFICATION: single-user or multi-user deployment?]
- **FR-023**: System MUST provide structured technical analysis curriculum with visual content (pictures, diagrams) and easy-to-understand descriptions
- **FR-024**: System MUST implement interactive quizzes linked to lessons with instant feedback and score tracking
- **FR-025**: System MUST maintain complete history of all user simulations with ability to view full details of any past simulation
- **FR-026**: System MUST save and load user's chart drawings and annotations per stock with undo/redo functionality
- **FR-027**: System MUST provide on-demand technical indicator calculation API with configurable parameters for all chart overlays

### Key Entities

- **Symbol**: Traded security on NEPSE (ticker, name, sector, listing_status, tick_size, lot_size)
- **OHLCV Record**: Time-series data point (timestamp, symbol, open, high, low, close, volume, adjusted_close)
- **Order**: Trading instruction (order_id, symbol, side, type, quantity, limit_price, status)
- **Position**: Current holdings (symbol, quantity, average_entry_price, unrealized_pnl)
- **Trade**: Executed transaction (trade_id, order_id, symbol, quantity, price, timestamp, commission)
- **Model**: Trained artifact (model_id, architecture, hyperparameters, training_metrics, artifact_path)
- **Backtest**: Simulation run (backtest_id, model_id, data_period, config, trades, final_pnl, metrics)
- **CorporateAction**: Event affecting prices (symbol, action_type, effective_date, adjustment_factor)
- **Lesson**: Educational content unit (lesson_id, title, section, content_text, picture_urls, difficulty_level, order_index)
- **Quiz**: Assessment linked to lesson (quiz_id, lesson_id, questions, passing_score)
- **UserQuizResult**: User quiz attempt (user_id, quiz_id, score, answers, timestamp, passed)
- **ChartDrawing**: User's chart annotation (drawing_id, user_id, symbol, drawing_type, coordinates, parameters, style, created_at)

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: User completes full workflow (start simulation → trade stocks → end simulation → receive AI feedback) in <15 minutes for 30-day simulation
- **SC-002**: Ingestion pipeline processes 10 years of daily data for 100 symbols in <5 minutes
- **SC-003**: Simulator produces deterministic results (identical P&L) for same trades and config across multiple runs
- **SC-004**: Trained LSTM model achieves directional accuracy >55% on validation set (beats random 50% baseline) using daily data
- **SC-005**: Backend computes any of 50+ technical indicators for 5-year daily data in <2 seconds per indicator
- **SC-006**: AI feedback generation completes within 30 seconds for simulation with up to 50 trades
- **SC-007**: Chart renders smoothly (60 FPS) with up to 10 active indicators and 20 drawings on 2-year daily data
- **SC-008**: Chart annotations persist correctly: draw → save → close app → reopen → verify all drawings restored
- **SC-009**: System passes smoke test: start simulation, execute 5 trades, apply 5 indicators, draw 3 trendlines, end simulation, receive AI feedback - all within 10 minutes
- **SC-010**: 90% of operations complete without crashes; all failures log actionable error messages with recovery suggestions
- **SC-011**: User can apply any technical indicator with custom parameters and see results within 1 second
- **SC-012**: Quiz system provides instant feedback (<500ms) after answer submission with explanations

---

## Specification Status & Next Steps

### Current Status
✅ **COMPLETE**: Feature specification (`/speckit.specify`)
- User stories defined and prioritized (P1-P5)
- Acceptance scenarios documented
- Edge cases identified
- Open questions marked with [NEEDS CLARIFICATION]

✅ **COMPLETE**: High-level implementation plan (`/speckit.plan`)
- Technology stack selected
- Architecture designed (9 core components)
- Implementation phases defined (Phase -1 through Phase 5)
- Phase -1 gates established

⏳ **PENDING**: Detailed supporting documents
- `data-model.md` - Database schema
- `contracts/` - API specifications
- `quickstart.md` - Validation scenarios
- `research.md` - Technical research findings

⏳ **PENDING**: Task list generation (`/speckit.tasks`)
- After supporting documents are created, run `/speckit.tasks` to generate executable task list

### Recommended Next Steps

1. **Resolve Open Questions** (Priority: High)
   - Answer 6 [NEEDS CLARIFICATION] items in specification
   - Get stakeholder approval on multi-user vs single-user architecture
   - Confirm LLM provider and budget
   - Decide on deployment target (cloud vs local)

2. **Create Supporting Documents** (Priority: High)
   - Write `data-model.md` with complete PostgreSQL schema
   - Define API contracts in `contracts/` directory (OpenAPI specs)
   - Document key validation scenarios in `quickstart.md`
   - Research and compare technical options in `research.md`

3. **Phase -1 Gate Validation** (Priority: Medium)
   - Review MLFlow/DVC inclusion - move to Phase 5 if not essential for MVP?
   - Decide on library-first principle application (should simulator be standalone library?)
   - Create contract tests before any implementation begins

4. **Generate Tasks** (Priority: Medium)
   - Run `/speckit.tasks` to create executable task list in `tasks.md`
   - Tasks will be derived from plan, data model, contracts, and research
   - Tasks will be marked for parallelization where applicable

5. **Begin Implementation** (Priority: Low - only after above complete)
   - Phase 0: Setup & Data Foundation
   - Follow test-first development (contract tests → integration tests → implementation)
   - Track progress against generated task list

### Document Evolution
- **v1.0** (2025-10-25): Initial specification created from user prompt
- **v1.1** (2025-10-25): Updated for daily-only data, added advanced charting features
- **v1.2** (2025-10-25): Restructured to follow SDD methodology with `/speckit.*` commands
- **Next**: Awaiting clarifications and supporting document creation

---

**End of Feature Specification: 001-nepse-simulator**
