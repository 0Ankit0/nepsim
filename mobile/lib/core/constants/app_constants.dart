class AppConstants {
  AppConstants._();

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // Route names
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String otpVerifyRoute = '/otp-verify';
  static const String resetPasswordRoute = '/reset-password';
  
  // Tab 1: Simulate
  static const String simulateRoute = '/simulate';
  static const String tradingRoute = '/simulate/trading';
  static const String portfolioRoute = '/simulate/portfolio';
  
  static const String stockSearchRoute = '/market';
  static const String stockDetailRoute = '/market/detail';

  // Analysis
  static const String analysisLoadingRoute = '/analysis/loading';
  static const String analysisResultsRoute = '/analysis/results';
  static const String tradeTimelineRoute = '/analysis/timeline';
  // Tab 2: Learn
  static const String learnRoute = '/learn';
  static const String lessonDetailRoute = '/learn/detail';
  static const String quizRoute = '/learn/quiz';
  // Tab 3: History & Profile
  static const String historyRoute = '/history';
  static const String achievementsRoute = '/achievements';
  
  // Secondary routes
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String tokensRoute = '/settings/tokens';
  static const String notificationsRoute = '/notifications';
  static const String paymentsRoute = '/payments';

  // Social auth — the backend redirects here after OAuth; the WebView intercepts it
  static const String socialAuthCallbackPrefix = '/auth-callback';

  // New feature routes
  static const String userPortfolioRoute = '/user-portfolio';
  static const String watchlistRoute = '/watchlist';
  static const String marketAnalysisRoute = '/market-analysis';
  static const String marketAnalysisDetailRoute = '/market-analysis/detail';
}
