import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/models/watchlist_models.dart';
import '../../data/repositories/watchlist_repository.dart';

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepository(ref.watch(dioClientProvider).dio);
});

final watchlistItemsProvider = FutureProvider<List<WatchlistItemResponse>>((ref) async {
  return ref.watch(watchlistRepositoryProvider).getWatchlist();
});

final watchlistAlertsProvider = FutureProvider<List<WatchlistAlertResponse>>((ref) async {
  return ref.watch(watchlistRepositoryProvider).getAlerts();
});

final watchlistNotifierProvider =
    AsyncNotifierProvider<WatchlistNotifier, List<WatchlistItemResponse>>(
  WatchlistNotifier.new,
);

class WatchlistNotifier extends AsyncNotifier<List<WatchlistItemResponse>> {
  @override
  Future<List<WatchlistItemResponse>> build() async {
    return ref.watch(watchlistRepositoryProvider).getWatchlist();
  }

  Future<void> addItem(WatchlistItemCreate item) async {
    final repo = ref.read(watchlistRepositoryProvider);
    await repo.addItem(item);
    ref.invalidateSelf();
  }

  Future<void> removeItem(int id) async {
    final repo = ref.read(watchlistRepositoryProvider);
    await repo.removeItem(id);
    ref.invalidateSelf();
  }

  Future<List<WatchlistAlertResponse>> checkSignals() async {
    final repo = ref.read(watchlistRepositoryProvider);
    final alerts = await repo.checkSignals();
    ref.invalidate(watchlistAlertsProvider);
    return alerts;
  }
}
