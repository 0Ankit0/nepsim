import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/models/portfolio_models.dart';
import '../../data/repositories/portfolio_repository.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository(ref.watch(dioClientProvider).dio);
});

final portfolioItemsProvider = FutureProvider<List<PortfolioItemResponse>>((ref) async {
  return ref.watch(portfolioRepositoryProvider).getPortfolio();
});

final portfolioAlertsProvider = FutureProvider<List<PortfolioAlertResponse>>((ref) async {
  return ref.watch(portfolioRepositoryProvider).getAlerts();
});

final portfolioNotifierProvider =
    AsyncNotifierProvider<PortfolioNotifier, List<PortfolioItemResponse>>(
  PortfolioNotifier.new,
);

class PortfolioNotifier extends AsyncNotifier<List<PortfolioItemResponse>> {
  @override
  Future<List<PortfolioItemResponse>> build() async {
    return ref.watch(portfolioRepositoryProvider).getPortfolio();
  }

  Future<void> addItem(PortfolioItemCreate item) async {
    final repo = ref.read(portfolioRepositoryProvider);
    await repo.addItem(item);
    ref.invalidateSelf();
  }

  Future<void> removeItem(int id) async {
    final repo = ref.read(portfolioRepositoryProvider);
    await repo.removeItem(id);
    ref.invalidateSelf();
  }

  Future<List<PortfolioAlertResponse>> analyzeAll() async {
    final repo = ref.read(portfolioRepositoryProvider);
    final alerts = await repo.analyzeAll();
    ref.invalidate(portfolioAlertsProvider);
    return alerts;
  }
}
