import '../../../src/models/service_post_model.dart';
import '../../../src/providers/service_posts_provider.dart';

class StarDashboardManager {
  static final StarDashboardManager _instance = StarDashboardManager._internal();
  factory StarDashboardManager() => _instance;
  StarDashboardManager._internal() {
    _servicePostsManager = ServicePostsManager();
    _initialize();
  }

  late ServicePostsManager _servicePostsManager;

  // ダッシュボードデータ
  Map<String, dynamic> get dashboardData => {
    'totalRevenue': 125000,
    'monthlyRevenue': 45000,
    'totalFans': 2847,
    'activeFans': 1923,
    'contentViews': 15420,
    'engagementRate': 8.5,
    'dataImportCount': 342,
    'dataImportThisMonth': 28,
  };

  void _initialize() {
    _servicePostsManager.initialize();
  }

  // サービス投稿関連
  List<ServicePost> get servicePosts => _servicePostsManager.posts;
  List<ServiceStats> get serviceStats => _servicePostsManager.stats;

  void addServicePost(ServicePost post) {
    _servicePostsManager.addServicePost(post);
  }

  void updateServicePost(String id, ServicePost updatedPost) {
    _servicePostsManager.updateServicePost(id, updatedPost);
  }

  void togglePublicStatus(String id) {
    _servicePostsManager.togglePublicStatus(id);
  }

  void removeServicePost(String id) {
    _servicePostsManager.removeServicePost(id);
  }

  List<ServicePost> getPostsByService(String serviceId) {
    return _servicePostsManager.getPostsByService(serviceId);
  }

  List<ServicePost> getPublicPosts() {
    return _servicePostsManager.getPublicPosts();
  }

  ServiceStats? getServiceStats(String serviceId) {
    return _servicePostsManager.getServiceStats(serviceId);
  }

  // サービス別投稿統計を取得
  Map<String, int> getServicePostCounts() {
    final Map<String, int> counts = {};
    for (final post in servicePosts) {
      counts[post.serviceId] = (counts[post.serviceId] ?? 0) + 1;
    }
    return counts;
  }

  // 最近のサービス投稿を取得（件数指定）
  List<ServicePost> getRecentServicePosts({int limit = 5}) {
    final sortedPosts = List<ServicePost>.from(servicePosts);
    sortedPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedPosts.take(limit).toList();
  }

  // 人気のサービス投稿を取得
  List<ServicePost> getPopularServicePosts({int limit = 5}) {
    final sortedPosts = List<ServicePost>.from(servicePosts);
    sortedPosts.sort((a, b) => (b.viewCount + b.likeCount).compareTo(a.viewCount + a.likeCount));
    return sortedPosts.take(limit).toList();
  }
} 