import "package:cloud_firestore/cloud_firestore.dart";
import "package:starlist/src/features/auth/models/user_model.dart";
import "package:starlist/src/features/payment/models/payment_model.dart";
import "package:starlist/src/features/privacy/models/privacy_settings.dart";
import "package:starlist/src/features/ranking/models/ranking_entry.dart";
import "package:starlist/src/features/subscription/models/subscription_plan.dart";
import "package:starlist/src/features/subscription/models/subscription_status.dart";
import "package:starlist/src/features/youtube/models/youtube_video.dart";

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection("users").doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection("users").doc(user.id).set(user.toJson());
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection("users").doc(user.id).update(user.toJson());
  }

  // Payment
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    final snapshot = await _firestore
        .collection("payments")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PaymentModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> createPayment(PaymentModel payment) async {
    await _firestore.collection("payments").doc(payment.id).set(payment.toJson());
  }

  Future<void> updatePayment(PaymentModel payment) async {
    await _firestore.collection("payments").doc(payment.id).update(payment.toJson());
  }

  // Privacy Settings
  Future<PrivacySettings?> getUserPrivacySettings(String userId) async {
    final doc = await _firestore.collection("privacy_settings").doc(userId).get();
    if (!doc.exists) return null;
    return PrivacySettings.fromJson(doc.data()!);
  }

  Future<void> updatePrivacySettings(String userId, PrivacySettings settings) async {
    await _firestore
        .collection("privacy_settings")
        .doc(userId)
        .set(settings.toJson());
  }

  // Ranking
  Future<List<RankingEntry>> getRankings(RankingType type) async {
    final snapshot = await _firestore
        .collection("rankings")
        .doc(type.toString().split(".").last)
        .collection("entries")
        .orderBy("score", descending: true)
        .limit(100)
        .get();
    return snapshot.docs
        .map((doc) => RankingEntry.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateUserRanking(RankingEntry entry) async {
    await _firestore
        .collection("rankings")
        .doc(entry.type.toString().split(".").last)
        .collection("entries")
        .doc(entry.userId)
        .set(entry.toJson());
  }

  // Subscription
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    final snapshot = await _firestore.collection("subscription_plans").get();
    return snapshot.docs
        .map((doc) => SubscriptionPlan.fromJson(doc.data()))
        .toList();
  }

  Future<SubscriptionStatusModel?> getCurrentSubscription(String userId) async {
    final doc = await _firestore.collection("subscriptions").doc(userId).get();
    if (!doc.exists) return null;
    return SubscriptionStatusModel.fromJson(doc.data()!);
  }

  Future<void> updateSubscription(SubscriptionStatusModel subscription) async {
    await _firestore
        .collection("subscriptions")
        .doc(subscription.userId)
        .set(subscription.toJson());
  }

  // YouTube
  Future<List<YouTubeVideo>> searchVideos(String query) async {
    final snapshot = await _firestore
        .collection("youtube_videos")
        .where("title", isGreaterThanOrEqualTo: query)
        .where("title", isLessThanOrEqualTo: "$query")
        .limit(10)
        .get();
    return snapshot.docs
        .map((doc) => YouTubeVideo.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveVideo(YouTubeVideo video) async {
    await _firestore.collection("youtube_videos").doc(video.id).set(video.toJson());
  }
}
