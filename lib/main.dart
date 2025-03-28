import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/features/data_integration/models/youtube_video.dart';
import 'src/features/data_integration/repositories/youtube_repository.dart';
import 'src/features/data_integration/services/youtube_api_service.dart';
import 'src/widgets/consumption_data_widget.dart';
import 'src/widgets/youtube_search_screen.dart';

void main() {
  runApp(const ProviderScope(child: StarlistApp()));
}

class StarlistApp extends StatelessWidget {
  const StarlistApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Starlist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const StarlistHomePage(),
    );
  }
}

class StarlistHomePage extends ConsumerStatefulWidget {
  const StarlistHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<StarlistHomePage> createState() => _StarlistHomePageState();
}

class _StarlistHomePageState extends ConsumerState<StarlistHomePage> {
  int _selectedIndex = 0;
  
  // 仮のAPIキー（実際のアプリでは環境変数や安全な方法で管理する必要があります）
  final String _apiKey = 'YOUR_YOUTUBE_API_KEY';
  
  @override
  void initState() {
    super.initState();
    
    // YouTubeリポジトリの初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final youtubeApiService = YouTubeApiService(apiKey: _apiKey);
      final youtubeRepository = YouTubeRepository(apiService: youtubeApiService);
      
      ref.read(youtubeRepositoryProvider.notifier).state = youtubeRepository;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starlist'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBar.item(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.search),
            label: '検索',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const HomeTab();
      case 1:
        return const YouTubeSearchScreen();
      case 2:
        return const ProfileTab();
      default:
        return const HomeTab();
    }
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'おすすめのスター',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text('おすすめのスターがここに表示されます'),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 仮のユーザーID
    const userId = 'user123';
    
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
                    'ユーザー名',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '@username',
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
          
          // 消費習慣データ
          const Expanded(
            child: ConsumptionDataWidget(
              userId: userId,
              title: '私の消費習慣',
            ),
          ),
        ],
      ),
    );
  }
}
