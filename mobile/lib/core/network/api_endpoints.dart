class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login/';
  static const String register = '/auth/signup/';
  static const String logout = '/auth/logout/';
  static const String refresh = '/auth/refresh/';
  static const String me = '/users/me';
  static const String updateMe = '/users/me';
  static const String avatar = '/users/me/avatar';
  static const String changePassword = '/auth/change-password/';
  static const String passwordResetRequest = '/auth/password-reset-request/';
  static const String passwordResetConfirm = '/auth/password-reset-confirm/';
  static const String resendVerification = '/auth/resend-verification/';

  // Social Auth
  static const String socialProviders = '/auth/social/providers/';
  static String socialLogin(String provider) => '/auth/social/$provider/';

  // OTP / 2FA
  static const String otpEnable = '/auth/otp/enable/';
  static const String otpVerify = '/auth/otp/verify/';
  static const String otpValidate = '/auth/otp/validate/';
  static const String otpDisable = '/auth/otp/disable/';

  // Notifications
  static const String notifications = '/notifications/';
  static String markNotificationRead(String id) => '/notifications/$id/read/';
  static String deleteNotification(String id) => '/notifications/$id/';
  static const String markAllNotificationsRead = '/notifications/read-all/';
  static const String notificationPreferences = '/notifications/preferences/';

  // IAM - Token tracking
  static const String tokens = '/tokens/';
  static String revokeToken(String id) => '/tokens/revoke/$id';
  static const String revokeAll = '/tokens/revoke-all';

  // Payments
  static const String payments = '/payments/';
  static const String paymentProviders = '/payments/providers/';
  static const String paymentInitiate = '/payments/initiate/';
  static const String paymentVerify = '/payments/verify/';

  // ---------------------------------------------------------------------------
  // NEPSIM Domain Endpoints
  // ---------------------------------------------------------------------------

  // Market
  static const String stocks = '/market/stocks';
  static String stockDetail(String symbol) => '/market/stocks/$symbol';
  static String stockHistory(String symbol) => '/market/stocks/$symbol/history';
  static String stockIndicators(String symbol) => '/market/stocks/$symbol/indicators';
  static const String chartDrawings = '/market/chart-drawings';
  static String stockChartDrawings(String symbol) => '/market/chart-drawings/$symbol';
  static String deleteChartDrawing(String id) => '/market/chart-drawings/$id';

  // Simulator
  static const String simulations = '/simulations/';
  static String simulationDetail(int id) => '/simulations/$id';
  static String simulationTrade(int id) => '/simulations/$id/trade';
  static String simulationAdvanceDay(int id) => '/simulations/$id/advance-day';
  static String simulationEnd(int id) => '/simulations/$id/end';
  static String simulationTrades(int id) => '/simulations/$id/trades';

  // AI Analysis
  static String simulationAnalysis(int id) => '/simulations/$id/analysis';
  static String retrySimulationAnalysis(int id) => '/simulations/$id/analysis/retry';
  static const String aiInsights = '/learn/ai-insights';

  // Learn
  static const String lessons = '/learn/lessons';
  static String lessonDetail(int id) => '/learn/lessons/$id';
  static String submitQuiz(int quizId) => '/learn/quizzes/$quizId/submit';
  static const String quizProgress = '/learn/quiz-progress';

  // Gamification (Progress)
  static const String userProgress = '/users/me/progress';
  static const String userAchievements = '/users/me/achievements';
}
