import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/otp_verify_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/simulator/presentation/pages/start_simulation_page.dart';
import '../../features/simulator/presentation/pages/trading_page.dart';
import '../../features/simulator/presentation/pages/portfolio_page.dart';
import '../../features/learn/presentation/pages/curriculum_page.dart';
import '../../features/learn/presentation/pages/lesson_detail_page.dart';
import '../../features/learn/presentation/pages/quiz_page.dart';
import '../../features/progress/presentation/pages/history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/tokens_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/market/presentation/pages/stock_search_page.dart';
import '../../features/market/presentation/pages/stock_detail_page.dart';
import '../../features/analysis/presentation/pages/analysis_loading_page.dart';
import '../../features/analysis/presentation/pages/analysis_results_page.dart';
import '../../features/analysis/presentation/pages/trade_timeline_page.dart';
import '../../features/progress/presentation/pages/achievements_page.dart';
import '../constants/app_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppConstants.loginRoute,
    redirect: (context, state) {
      final isAuthenticated = authState.value?.isAuthenticated ?? false;
      final isLoading = authState.isLoading;
      final location = state.matchedLocation;

      if (isLoading) return null;

      final onAuthPage = location == AppConstants.loginRoute ||
          location == AppConstants.registerRoute ||
          location == AppConstants.forgotPasswordRoute ||
          location == AppConstants.resetPasswordRoute ||
          location == AppConstants.otpVerifyRoute;

      if (!isAuthenticated && !onAuthPage) {
        return AppConstants.loginRoute;
      }
      if (isAuthenticated && (location == AppConstants.loginRoute ||
          location == AppConstants.registerRoute)) {
        return AppConstants.simulateRoute;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.loginRoute,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppConstants.registerRoute,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppConstants.forgotPasswordRoute,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppConstants.otpVerifyRoute,
        builder: (context, state) {
          final tempToken = state.extra as String? ?? '';
          return OtpVerifyPage(tempToken: tempToken);
        },
      ),
      GoRoute(
        path: AppConstants.resetPasswordRoute,
        builder: (context, state) {
          final token = state.extra as String? ??
              state.uri.queryParameters['token'] ?? '';
          return ResetPasswordPage(token: token);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomePage(navigationShell: navigationShell),
        branches: [
          // Branch 0: Simulate
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.simulateRoute,
                builder: (context, state) => const StartSimulationPage(),
                routes: [
                  GoRoute(
                    path: 'trading',
                    builder: (context, state) {
                      final id = state.uri.queryParameters['id'];
                      return TradingPage(simulationId: int.tryParse(id ?? '') ?? 0);
                    },
                  ),
                  GoRoute(
                    path: 'portfolio',
                    builder: (context, state) {
                      final id = state.uri.queryParameters['id'];
                      return PortfolioPage(simulationId: int.tryParse(id ?? '') ?? 0);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 1: Learn More
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.learnRoute,
                builder: (context, state) => const CurriculumPage(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final id = state.uri.queryParameters['id'];
                      return LessonDetailPage(lessonId: int.tryParse(id ?? '') ?? 0);
                    },
                  ),
                  GoRoute(
                    path: 'quiz',
                    builder: (context, state) {
                      final id = state.uri.queryParameters['id'];
                      return QuizPage(lessonId: int.tryParse(id ?? '') ?? 0);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: My History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.historyRoute,
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
        ],
      ),
      // Secondary routes outside bottom nav
      GoRoute(
        path: AppConstants.profileRoute,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'tokens',
            builder: (context, state) => const TokensPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.notificationsRoute,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppConstants.paymentsRoute,
        builder: (context, state) => const PaymentsPage(),
      ),
      GoRoute(
        path: AppConstants.stockSearchRoute,
        builder: (context, state) => const StockSearchPage(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final symbol = state.uri.queryParameters['symbol'] ?? '';
              return StockDetailPage(symbol: symbol);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.achievementsRoute,
        builder: (context, state) => const AchievementsPage(),
      ),
      GoRoute(
        path: AppConstants.analysisLoadingRoute,
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0;
          return AnalysisLoadingPage(simulationId: id);
        },
      ),
      GoRoute(
        path: AppConstants.analysisResultsRoute,
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0;
          return AnalysisResultsPage(simulationId: id);
        },
      ),
      GoRoute(
        path: AppConstants.tradeTimelineRoute,
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0;
          return TradeTimelinePage(simulationId: id);
        },
      ),
    ],
  );
});
