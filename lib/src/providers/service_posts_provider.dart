import '../models/service_post_model.dart';

// サービス投稿管理クラス
class ServicePostsManager {
  static final ServicePostsManager _instance = ServicePostsManager._internal();
  factory ServicePostsManager() => _instance;
  ServicePostsManager._internal();

  List<ServicePost> _posts = [];
  List<ServiceStats> _stats = [];

  List<ServicePost> get posts => List.from(_posts);
  List<ServiceStats> get stats => List.from(_stats);

  // 初期データの読み込み
  void initialize() {
    _loadInitialData();
    _updateStats();
  }

  void _loadInitialData() {
    // サンプルデータ（実際の実装ではAPIから取得）
    _posts = [
      ServicePost(
        id: '1',
        starId: 'current_star',
        serviceId: 'youtube',
        serviceName: 'YouTube',
        title: 'Flutter 3.0の新機能解説',
        description: 'Flutter 3.0で追加された新機能について詳しく解説しています。',
        thumbnailUrl: null,
        serviceUrl: 'https://youtube.com/watch?v=example1',
        metadata: {
          'duration': '15:30',
          'views': 12400,
          'likes': 890,
          'category': 'Technology',
        },
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isPublic: true,
        viewCount: 156,
        likeCount: 23,
        tags: ['Flutter', 'プログラミング', '技術解説'],
      ),
      ServicePost(
        id: '2',
        starId: 'current_star',
        serviceId: 'spotify',
        serviceName: 'Spotify',
        title: 'コーディング用プレイリスト',
        description: '集中してコーディングできる音楽を集めたプレイリストです。',
        thumbnailUrl: null,
        serviceUrl: 'https://spotify.com/playlist/example',
        metadata: {
          'tracks': 45,
          'duration': '2h 30m',
          'followers': 234,
          'genre': 'Electronic',
        },
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        isPublic: true,
        viewCount: 89,
        likeCount: 12,
        tags: ['音楽', 'プレイリスト', 'コーディング'],
      ),
      ServicePost(
        id: '3',
        starId: 'current_star',
        serviceId: 'instagram',
        serviceName: 'Instagram',
        title: '開発環境のセットアップ風景',
        description: '新しいMacBookでの開発環境構築の様子を投稿しました。',
        thumbnailUrl: null,
        serviceUrl: 'https://instagram.com/p/example',
        metadata: {
          'likes': 456,
          'comments': 23,
          'type': 'photo',
          'hashtags': ['#dev', '#macbook', '#setup'],
        },
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        isPublic: false,
        viewCount: 234,
        likeCount: 45,
        tags: ['開発環境', 'セットアップ', 'Instagram'],
      ),
    ];
  }

  // 新しいサービス投稿を追加
  void addServicePost(ServicePost post) {
    _posts.insert(0, post);
    _updateStats();
  }

  // サービス投稿を更新
  void updateServicePost(String id, ServicePost updatedPost) {
    final index = _posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      _posts[index] = updatedPost;
      _updateStats();
    }
  }

  // サービス投稿を削除
  void removeServicePost(String id) {
    _posts.removeWhere((post) => post.id == id);
    _updateStats();
  }

  // 公開状態を変更
  void togglePublicStatus(String id) {
    final index = _posts.indexWhere((post) => post.id == id);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        isPublic: !_posts[index].isPublic,
        updatedAt: DateTime.now(),
      );
      _updateStats();
    }
  }

  // サービス別の投稿を取得
  List<ServicePost> getPostsByService(String serviceId) {
    return _posts.where((post) => post.serviceId == serviceId).toList();
  }

  // 公開投稿のみを取得
  List<ServicePost> getPublicPosts() {
    return _posts.where((post) => post.isPublic).toList();
  }

  // 統計を更新
  void _updateStats() {
    final Map<String, List<ServicePost>> groupedPosts = {};
    
    for (final post in _posts) {
      if (!groupedPosts.containsKey(post.serviceId)) {
        groupedPosts[post.serviceId] = [];
      }
      groupedPosts[post.serviceId]!.add(post);
    }

    _stats = groupedPosts.entries.map((entry) {
      final servicePosts = entry.value;
      final publicPosts = servicePosts.where((p) => p.isPublic).toList();
      
      return ServiceStats(
        serviceId: entry.key,
        serviceName: servicePosts.first.serviceName,
        totalPosts: servicePosts.length,
        publicPosts: publicPosts.length,
        totalViews: servicePosts.fold(0, (sum, post) => sum + post.viewCount),
        totalLikes: servicePosts.fold(0, (sum, post) => sum + post.likeCount),
        lastPosted: servicePosts
            .map((p) => p.createdAt)
            .reduce((a, b) => a.isAfter(b) ? a : b),
      );
    }).toList();
  }

  // サービス統計を取得
  ServiceStats? getServiceStats(String serviceId) {
    try {
      return _stats.firstWhere((stat) => stat.serviceId == serviceId);
    } catch (e) {
      return null;
    }
  }
} 