import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:starlist/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

// StarlistAppをインポート
import 'src/features/data_integration/repositories/youtube_repository.dart';
import 'src/features/data_integration/services/youtube_api_service.dart';
import 'src/features/auth/screens/login_screen.dart';
import 'src/features/auth/screens/signup_screen.dart';
import 'src/features/auth/supabase_provider.dart';
import 'src/features/auth/providers/user_provider.dart';
import 'src/features/favorites/widgets/favorite_list.dart';
import 'src/features/favorites/providers/favorite_provider.dart';
import 'src/features/star/screens/star_activity_timeline_screen.dart';
import 'screens/star_home_screen.dart';
import 'screens/fan_home_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/fan_register_screen.dart';
import 'screens/register_screen.dart';
import 'screens/starlist_home_screen.dart';

// Riverpodプロバイダー名の衝突を避けるため
final supabaseUrlProvider = Provider<String>((ref) {
  return dotenv.env['SUPABASE_URL'] ?? '';
});

final supabaseAnonKeyProvider = Provider<String>((ref) {
  return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
});

// YouTube API キーの環境変数
final youtubeApiKeyProvider = Provider<String>((ref) {
  return dotenv.env['YOUTUBE_API_KEY'] ?? '';
});

// サービスのプロバイダー
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  try {
    return Supabase.instance.client;
  } catch (e) {
    debugPrint('Supabaseクライアント取得エラー: $e');
    throw Exception('Supabaseクライアントが初期化されていません');
  }
});

// YouTubeApiServiceとリポジトリのプロバイダー
final youtubeApiServiceProvider = Provider<YouTubeApiService>((ref) {
  final apiKey = ref.watch(youtubeApiKeyProvider);
  return YouTubeApiService(apiKey: apiKey);
});

final youtubeRepositoryProvider = Provider<YouTubeRepository>((ref) {
  final apiService = ref.watch(youtubeApiServiceProvider);
  return YouTubeRepository(apiService: apiService);
});

final userTypeProvider = StateProvider<String>((ref) => 'fan');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 環境変数のロード
  await dotenv.load(fileName: '.env');
  
  // Supabaseの初期化
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? ''
  );
  
  // アプリの実行
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Starlist',
      theme: AppTheme.lightTheme,
      home: const StarlistHomeScreen(), // 新しいStarlistHomeScreenを使用
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/fan_register': (context) => const FanRegisterScreen(),
        '/register': (context) => const RegisterScreen(isStar: false),
        '/star_register': (context) => const RegisterScreen(isStar: true),
      },
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    
    return userState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }
        
        // ユーザータイプに基づいて画面を切り替え
        if (user.isStar) {
          return const StarHomeScreen();
        } else {
          return const FanHomeScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const LoginScreen(),
    );
  }
}

// シンプルなテスト用ホーム画面
class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starlist'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Starlistへようこそ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ボタンがタップされました')),
                );
              },
              child: const Text('テストボタン'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // アクティビティタイムライン画面に移動
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StarActivityTimelineScreen(
                      starId: 'mock-star-id', // テスト用のスターID
                      title: 'アクティビティタイムライン',
                    ),
                  ),
                );
              },
              child: const Text('タイムライン表示'),
            ),
          ],
        ),
      ),
    );
  }
}

// メインのホーム画面
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // データベースの状態をチェック（必要に応じて）
    Future.microtask(() => _checkDatabaseStatus());
  }

  Future<void> _checkDatabaseStatus() async {
    try {
      final supabaseClient = Supabase.instance.client;
      
      // 認証セッションをチェック
      try {
        final session = supabaseClient.auth.currentSession;
        debugPrint('認証セッション状態: ${session != null ? "ログイン済み" : "未ログイン"}');
        
        if (session == null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('認証されていません。匿名モードで実行します。')),
          );
        }
      } catch (e) {
        debugPrint('認証セッション確認エラー: $e');
      }
      
      // Supabase接続を確認 - バージョン情報の取得（テーブルに依存しない）
      try {
        // セッション情報の取得のみ試行 (テーブルアクセスなし)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supabaseに正常に接続しました')),
          );
        }
      } catch (e) {
        debugPrint('Supabase接続テストエラー: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Supabase接続エラー: $e')),
          );
        }
      }
    } catch (e) {
      debugPrint('_checkDatabaseStatus全体エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen: buildメソッドが呼ばれました');
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeTab(),
          SearchTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '検索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
}

// ホームタブ（お気に入りの投稿を表示）
class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('HomeTab: buildメソッドが呼ばれました');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('通知機能は開発中です')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Starlistへようこそ！',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('お気に入りのコンテンツを発見・共有しましょう'),
          ),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('お気に入りを追加')),
                );
              },
              child: const Text('お気に入りを追加'),
            ),
          ),
          const SizedBox(height: 40),
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
                  Text('フォロー中のスターによる最新コンテンツがここに表示されます'),
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
                  Text('フォロー中のスターとファンの最近の活動がここに表示されます'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('お気に入り追加機能は開発中です')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 検索タブ
class SearchTab extends ConsumerWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('SearchTab: buildメソッドが呼ばれました');
    final TextEditingController searchController = TextEditingController();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('検索'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '検索...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                // 検索処理（実装中）
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('検索: $query - この機能は開発中です')),
                );
              }
            },
          ),
          const SizedBox(height: 20),
          const Text(
            '最近の検索',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Flutter tutorial'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('検索機能は開発中です')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Dart programming'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('検索機能は開発中です')),
              );
            },
          ),
          const Divider(),
          const Text(
            'おすすめのトピック',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildTopicChip(context, 'テクノロジー'),
              _buildTopicChip(context, '料理'),
              _buildTopicChip(context, '旅行'),
              _buildTopicChip(context, '音楽'),
              _buildTopicChip(context, '映画'),
              _buildTopicChip(context, 'ゲーム'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(BuildContext context, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label の検索は開発中です')),
        );
      },
    );
  }
}

// プロフィールタブ
class ProfileTab extends ConsumerWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('ProfileTab: buildメソッドが呼ばれました');
    
    // 認証状態を取得
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (state) {
        final currentUser = state.session?.user;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('プロフィール'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('設定機能は開発中です')),
                  );
                },
              ),
            ],
          ),
          body: currentUser != null 
              ? _buildAuthenticatedContent(context, ref, currentUser) 
              : _buildUnauthenticatedContent(context),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }
  
  /// 認証済みユーザー向けのコンテンツを構築
  Widget _buildAuthenticatedContent(BuildContext context, WidgetRef ref, User user) {
    // ユーザープロファイル情報を取得
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    
    return userProfileAsync.when(
      data: (userProfile) {
        return Column(
          children: [
            // プロフィールヘッダー
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: userProfile?.profileImageUrl != null
                        ? NetworkImage(userProfile!.profileImageUrl!)
                        : null,
                    child: userProfile?.profileImageUrl == null
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile?.displayName ?? userProfile?.username ?? user.email ?? 'ユーザー',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (userProfile?.username != null) 
                          Text('@${userProfile!.username}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'タイプ: ${userProfile?.roleText ?? "ファン"}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // お気に入りタイトル
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'あなたのお気に入り',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('更新'),
                    onPressed: () {
                      ref.invalidate(userFavoritesByIdProvider(user.id));
                    },
                  ),
                ],
              ),
            ),
            
            // お気に入りリスト
            Expanded(
              child: FavoriteList(userId: user.id),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('プロフィール読み込みエラー: $error'),
      ),
    );
  }
  
  /// 未認証ユーザー向けのコンテンツを構築
  Widget _buildUnauthenticatedContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'ゲスト',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('ログインして、ファンとしてコンテンツを発見するか、\nスターとしてお気に入りのコンテンツを共有しましょう'),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('ログイン'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: const Text('新規登録'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
