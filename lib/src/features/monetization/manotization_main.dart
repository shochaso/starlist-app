import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/features/data_integration/models/youtube_video.dart';
import 'src/features/data_integration/repositories/youtube_repository.dart';
import 'src/features/data_integration/services/youtube_api_service.dart';
import 'src/features/monetization/models/ad_model.dart';
import 'src/features/monetization/services/ad_service.dart';
import 'src/features/monetization/services/affiliate_service.dart';
import 'src/features/monetization/screens/monetized_screens.dart';
import 'src/widgets/consumption_data_widget.dart';
import 'src/widgets/youtube_search_screen.dart';

void main() {
  runApp(const ProviderScope(child: StarlistApp()));
}

class StarlistApp extends StatelessWidget {
  const StarlistApp({super.key});

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
  const StarlistHomePage({super.key});

  @override
  ConsumerState<StarlistHomePage> createState() => _StarlistHomePageState();
}

class _StarlistHomePageState extends ConsumerState<StarlistHomePage> {
  int _selectedIndex = 0;
  
  // 仮のAPIキー（実際のアプリでは環境変数や安全な方法で管理する必要があります）
  final String _apiKey = 'YOUR_YOUTUBE_API_KEY';
  
  // 仮のユーザー情報（実際のアプリでは認証システムから取得）
  final String _userId = 'user123';
  String _userType = UserType.free; // デフォルトは無料ユーザー
  
  // セッション時間（広告表示の頻度制御に使用）
  int _sessionDurationMinutes = 0;
  
  @override
  void initState() {
    super.initState();
    
    // YouTubeリポジトリの初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final youtubeApiService = YouTubeApiService(apiKey: _apiKey);
      final youtubeRepository = YouTubeRepository(apiService: youtubeApiService);
      
      ref.read(youtubeRepositoryProvider.notifier).state = youtubeRepository;
      
      // セッション時間を追跡するタイマーを開始
      _startSessionTimer();
    });
  }
  
  /// セッション時間を追跡するタイマーを開始
  void _startSessionTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _sessionDurationMinutes++;
        });
        _startSessionTimer(); // 再帰的に呼び出してタイマーを継続
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starlist'),
        actions: [
          // 会員タイプ切り替えボタン（デモ用）
          IconButton(
            icon: const Icon(Icons.switch_account),
            onPressed: _showUserTypeSwitchDialog,
          ),
        ],
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
          BottomNavigationBar.item(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return MonetizedHomeScreen(
          userId: _userId,
          userType: _userType,
          sessionDurationMinutes: _sessionDurationMinutes,
        );
      case 1:
        return const YouTubeSearchScreen();
      case 2:
        if (_userType == UserType.star) {
          // スターの場合はスタープロフィール画面を表示
          return MonetizedStarProfileScreen(
            starId: _userId,
            userId: _userId,
            userType: _userType,
          );
        } else {
          // 一般ユーザーの場合はプロフィール画面を表示
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
                
                // スターの日常データ
                const Expanded(
                  child: DailyLifeDataWidget(
                    userId: 'user123',
                    title: '私のスターの日常',
                  ),
                ),
              ],
            ),
          );
        }
      case 3:
        return MonetizedSettingsScreen(
          userId: _userId,
          userType: _userType,
        );
      default:
        return const Center(
          child: Text('不明なタブ'),
        );
    }
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  /// ユーザータイプ切り替えダイアログを表示（デモ用）
  void _showUserTypeSwitchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ユーザータイプを選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('無料ユーザー'),
              selected: _userType == UserType.free,
              onTap: () {
                setState(() {
                  _userType = UserType.free;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('スタンダード会員'),
              selected: _userType == UserType.standard,
              onTap: () {
                setState(() {
                  _userType = UserType.standard;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('プレミアム会員'),
              selected: _userType == UserType.premium,
              onTap: () {
                setState(() {
                  _userType = UserType.premium;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('スター'),
              selected: _userType == UserType.star,
              onTap: () {
                setState(() {
                  _userType = UserType.star;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
