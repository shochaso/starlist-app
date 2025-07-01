import "package:starlist/src/core/cache/cache_service.dart";
import "package:starlist/src/features/auth/models/user_model.dart";
import "package:starlist/src/features/payment/models/payment_model.dart";
import "package:starlist/src/features/privacy/models/privacy_settings.dart";
import "package:starlist/src/features/ranking/models/ranking_entry.dart";
import "package:starlist/src/features/subscription/models/subscription_plan.dart";
import "package:starlist/src/features/subscription/models/subscription_status.dart";
import "package:starlist/src/features/youtube/models/youtube_video.dart";

class CacheManager {
  final CacheService _cache;

  CacheManager(this._cache);

  // User
  Future<void> cacheUser(UserModel user) async {
    await _cache.set("user_${user.id}", user.toJson());
  }

  Future<UserModel?> getCachedUser(String userId) async {
    final data = _cache.get<Map<String, dynamic>>("user_$userId");
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  // Payment
  Future<void> cachePayments(String userId, List<PaymentModel> payments) async {
    await _cache.set(
      "payments_$userId",
      payments.map((p) => p.toJson()).toList(),
    );
  }

  Future<List<PaymentModel>?> getCachedPayments(String userId) async {
    final data = _cache.get<List<dynamic>>("payments_$userId");
    if (data == null) return null;
    return data.map((json) => PaymentModel.fromJson(json)).toList();
  }

  // Privacy Settings
  Future<void> cachePrivacySettings(String userId, PrivacySettings settings) async {
    await _cache.set("privacy_$userId", settings.toJson());
  }

  Future<PrivacySettings?> getCachedPrivacySettings(String userId) async {
    final data = _cache.get<Map<String, dynamic>>("privacy_$userId");
    if (data == null) return null;
    return PrivacySettings.fromJson(data);
  }

  // Ranking
  Future<void> cacheRankings(RankingType type, List<RankingEntry> rankings) async {
    await _cache.set(
      "rankings_${type.toString().split(".").last}",
      rankings.map((r) => r.toJson()).toList(),
    );
  }

  Future<List<RankingEntry>?> getCachedRankings(RankingType type) async {
    final data = _cache.get<List<dynamic>>("rankings_${type.toString().split(".").last}");
    if (data == null) return null;
    return data.map((json) => RankingEntry.fromJson(json)).toList();
  }

  // Subscription
  Future<void> cacheSubscriptionPlans(List<SubscriptionPlan> plans) async {
    await _cache.set("subscription_plans", plans.map((p) => p.toJson()).toList());
  }

  Future<List<SubscriptionPlan>?> getCachedSubscriptionPlans() async {
    final data = _cache.get<List<dynamic>>("subscription_plans");
    if (data == null) return null;
    return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
  }

  Future<void> cacheSubscriptionStatus(String userId, SubscriptionStatusModel status) async {
    await _cache.set("subscription_status_$userId", status.toJson());
  }

  Future<SubscriptionStatusModel?> getCachedSubscriptionStatus(String userId) async {
    final data = _cache.get<Map<String, dynamic>>("subscription_status_$userId");
    if (data == null) return null;
    return SubscriptionStatusModel.fromJson(data);
  }

  // YouTube
  Future<void> cacheVideo(YouTubeVideo video) async {
    await _cache.set("video_${video.id}", video.toJson());
  }

  Future<YouTubeVideo?> getCachedVideo(String videoId) async {
    final data = _cache.get<Map<String, dynamic>>("video_$videoId");
    if (data == null) return null;
    return YouTubeVideo.fromJson(data);
  }

  Future<void> cacheSearchResults(String query, List<YouTubeVideo> videos) async {
    await _cache.set(
      "search_$query",
      videos.map((v) => v.toJson()).toList(),
    );
  }

  Future<List<YouTubeVideo>?> getCachedSearchResults(String query) async {
    final data = _cache.get<List<dynamic>>("search_$query");
    if (data == null) return null;
    return data.map((json) => YouTubeVideo.fromJson(json)).toList();
  }

  // Clear
  Future<void> clearUserCache(String userId) async {
    await Future.wait([
      _cache.delete("user_$userId"),
      _cache.delete("payments_$userId"),
      _cache.delete("privacy_$userId"),
      _cache.delete("subscription_status_$userId"),
    ]);
  }

  Future<void> clearAllCache() async {
    await _cache.clear();
  }
}
