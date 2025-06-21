class ApiEndpoints {
  static const String baseUrl = "https://api.example.com/v1";

  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String logout = "/auth/logout";
  static const String refreshToken = "/auth/refresh-token";
  static const String resetPassword = "/auth/reset-password";

  // User
  static const String userProfile = "/users/profile";
  static const String updateProfile = "/users/profile/update";
  static const String changePassword = "/users/change-password";

  // Payment
  static const String createPayment = "/payments/create";
  static const String getPayments = "/payments";
  static const String cancelPayment = "/payments/cancel";
  static const String refundPayment = "/payments/refund";

  // Subscription
  static const String getPlans = "/subscriptions/plans";
  static const String subscribe = "/subscriptions/subscribe";
  static const String cancelSubscription = "/subscriptions/cancel";
  static const String updateSubscription = "/subscriptions/update";

  // Privacy
  static const String getPrivacySettings = "/privacy/settings";
  static const String updatePrivacySettings = "/privacy/settings/update";
  static const String blockUser = "/privacy/block-user";
  static const String unblockUser = "/privacy/unblock-user";

  // Ranking
  static const String getRankings = "/rankings";
  static const String getUserRanking = "/rankings/user";
  static const String updateScore = "/rankings/update-score";

  // YouTube
  static const String searchVideos = "/youtube/search";
  static const String getVideoDetails = "/youtube/video";
  static const String getChannelVideos = "/youtube/channel";
  static const String getRelatedVideos = "/youtube/related";
  static const String getPopularVideos = "/youtube/popular";
}
