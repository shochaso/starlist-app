import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/notification_service.dart';
import '../../../services/search_service.dart';
import '../../../services/location_service.dart';
import '../../../services/sharing_service.dart';
import '../../../services/realtime_service.dart';
import '../../content/consumption_data_widget.dart';
import '../../youtube/youtube_search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final String _userId = 'demo-user-id'; // 実際の認証後にユーザーIDを取得
  
  final NotificationService _notificationService = NotificationService();
  final LocationService _locationService = LocationService();
  final SharingService _sharingService = SharingService();
  late final SearchService _searchService;
  late final RealtimeService _realtimeService;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Supabaseクライアントを取得してサービスを初期化
    final supabaseClient = Supabase.instance.client;
    _searchService = SearchService(supabaseClient);
    _realtimeService = RealtimeService(supabaseClient);
    
    // 通知のリスナーを設定
    _notificationService.notificationStream.listen((notification) {
      if (notification != null) {
        _showNotificationSnackBar(notification);
      }
    });
    
    // テスト用に通知を表示
    Future.delayed(const Duration(seconds: 3), () {
      _notificationService.showNotification(
        title: 'Starlistへようこそ',
        body: 'あなたのスターの日常を記録・共有しましょう',
        type: NotificationType.system,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _realtimeService.dispose();
    super.dispose();
  }
  
  void _showNotificationSnackBar(NotificationModel notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(notification.body),
          ],
        ),
        action: SnackBarAction(
          label: '閉じる',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
  
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }
  
  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    // 検索履歴を保存
    _searchService.saveSearchHistory(
      userId: _userId,
      query: query,
      searchType: 'content',
    );
    
    // 検索画面に遷移
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YouTubeSearchScreen(initialQuery: query),
      ),
    );
  }
  
  Future<void> _shareApp() async {
    await _sharingService.shareText(
      text: 'Starlistでスターの日常を記録・共有しよう！',
      subject: 'Starlistアプリを共有',
    );
  }
  
  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('現在地: ${address ?? "取得できませんでした"}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('位置情報を取得できませんでした'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '検索...',
                  border: InputBorder.none,
                ),
                onSubmitted: _performSearch,
              )
            : const Text('Starlist'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareApp,
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _getCurrentLocation,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'ホーム'),
            Tab(icon: Icon(Icons.explore), text: '探索'),
            Tab(icon: Icon(Icons.person), text: 'プロフィール'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildExploreTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // コンテンツ追加画面に遷移
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        // データの再読み込み
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'おすすめのスター',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('フォロー中のスターの最新コンテンツがここに表示されます'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近の活動',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('フォロー中のユーザーの最近の活動がここに表示されます'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'アクション',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('通知をテスト'),
                    onTap: () {
                      _notificationService.showNotification(
                        title: 'テスト通知',
                        body: 'これはテスト通知です',
                        type: NotificationType.system,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text('YouTube検索'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const YouTubeSearchScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExploreTab() {
    return const Center(
      child: Text('探索画面はここに表示されます'),
    );
  }
  
  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // プロフィールヘッダー
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'デモユーザー',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '@demo_user',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // スターの日常データ
          const Expanded(
            child: DailyLifeDataWidget(
              userId: 'demo-user-id',
            ),
          ),
        ],
      ),
    );
  }
} 