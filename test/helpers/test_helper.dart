import "package:flutter/material.dart";
import "package:mockito/mockito.dart";
import "package:starlist_app/src/features/auth/models/user_model.dart";
import "package:starlist_app/src/features/payment/models/payment_model.dart";
import "package:starlist_app/src/features/privacy/models/privacy_settings.dart";
import "package:starlist_app/src/features/ranking/models/ranking_entry.dart";
import "package:starlist_app/src/features/subscription/models/subscription_plan.dart";
import "package:starlist_app/src/features/subscription/models/subscription_status.dart";
import "package:starlist_app/src/features/youtube/models/youtube_video.dart";

class TestHelper {
  static UserModel createTestUser({
    String? id,
    String? email,
    String? username,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? "test_user_id",
      email: email ?? "test@example.com",
      username: username ?? "test_user",
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static PaymentModel createTestPayment({
    String? id,
    String? userId,
    double? amount,
    String? currency,
    PaymentStatus? status,
    PaymentMethod? method,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? "test_payment_id",
      userId: userId ?? "test_user_id",
      amount: amount ?? 1000,
      currency: currency ?? "JPY",
      status: status ?? PaymentStatus.completed,
      method: method ?? PaymentMethod.creditCard,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static PrivacySettings createTestPrivacySettings({
    bool? isProfilePublic,
    bool? showEmail,
    bool? showPhone,
    bool? showLocation,
    bool? allowFriendRequests,
    bool? allowMessages,
    bool? allowComments,
    bool? allowNotifications,
    List<String>? blockedUsers,
  }) {
    return PrivacySettings(
      isProfilePublic: isProfilePublic ?? true,
      showEmail: showEmail ?? false,
      showPhone: showPhone ?? false,
      showLocation: showLocation ?? false,
      allowFriendRequests: allowFriendRequests ?? true,
      allowMessages: allowMessages ?? true,
      allowComments: allowComments ?? true,
      allowNotifications: allowNotifications ?? true,
      blockedUsers: blockedUsers ?? [],
    );
  }

  static RankingEntry createTestRankingEntry({
    String? userId,
    String? username,
    String? avatarUrl,
    int? rank,
    double? score,
    DateTime? lastUpdated,
  }) {
    return RankingEntry(
      userId: userId ?? "test_user_id",
      username: username ?? "test_user",
      avatarUrl: avatarUrl,
      rank: rank ?? 1,
      score: score ?? 1000,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  static SubscriptionPlan createTestSubscriptionPlan({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    String? billingPeriod,
    List<String>? features,
    bool? isPopular,
  }) {
    return SubscriptionPlan(
      id: id ?? "test_plan_id",
      name: name ?? "Test Plan",
      description: description ?? "Test Description",
      price: price ?? 1000,
      currency: currency ?? "JPY",
      billingPeriod: billingPeriod ?? "monthly",
      features: features ?? [],
      isPopular: isPopular ?? false,
    );
  }

  static SubscriptionStatusModel createTestSubscriptionStatus({
    String? id,
    String? userId,
    String? planId,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextBillingDate,
    String? paymentMethodId,
  }) {
    return SubscriptionStatusModel(
      id: id ?? "test_subscription_id",
      userId: userId ?? "test_user_id",
      planId: planId ?? "test_plan_id",
      status: status ?? SubscriptionStatus.active,
      startDate: startDate ?? DateTime.now(),
      endDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
      nextBillingDate: nextBillingDate ?? DateTime.now().add(const Duration(days: 30)),
      paymentMethodId: paymentMethodId ?? "test_payment_method_id",
    );
  }

  static YouTubeVideo createTestYouTubeVideo({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    DateTime? publishedAt,
    String? channelId,
    String? channelTitle,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    Duration? duration,
  }) {
    return YouTubeVideo(
      id: id ?? "test_video_id",
      title: title ?? "Test Video",
      description: description ?? "Test Description",
      thumbnailUrl: thumbnailUrl ?? "https://example.com/thumb.jpg",
      publishedAt: publishedAt ?? DateTime.now(),
      channelId: channelId ?? "test_channel_id",
      channelTitle: channelTitle ?? "Test Channel",
      viewCount: viewCount ?? 1000,
      likeCount: likeCount ?? 100,
      commentCount: commentCount ?? 50,
      duration: duration ?? const Duration(minutes: 5),
    );
  }

  static Widget createTestWidget({
    Widget? child,
    ThemeData? theme,
    NavigatorObserver? navigatorObserver,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(body: child ?? Container()),
      navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
    );
  }
}
