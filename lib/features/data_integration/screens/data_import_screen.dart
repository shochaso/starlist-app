import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../src/core/components/service_icons.dart';
import '../../../src/core/constants/service_definitions.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../providers/user_provider.dart';
import '../../star/screens/star_dashboard_screen.dart';
import '../../../src/features/subscription/screens/subscription_plans_screen.dart';
import '../../app/screens/settings_screen.dart';
import 'youtube_import_screen.dart';
import 'music_import_screen.dart';
import 'shopping_import_screen.dart';
import 'receipt_import_screen.dart';
import 'app_usage_import_screen.dart';
import 'youtube_music_import_screen.dart';
import 'video_import_screen.dart';
import 'sns_import_screen.dart';
import 'entertainment_import_screen.dart';
import 'food_import_screen.dart';
import 'payment_import_screen.dart';
import 'digital_import_screen.dart';
import 'package:go_router/go_router.dart';

class DataImportScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  
  const DataImportScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<DataImportScreen> createState() => _DataImportScreenState();
}

class _DataImportScreenState extends ConsumerState<DataImportScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedCategory;
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _floatingAnimationController;
  late Animation<double> _fadeAnimation;
  bool isProcessing = false;
  bool showProcessingResults = false;
  List<Map<String, dynamic>> processedVideos = [];
  
  // 接続済みサービスのデータ
  final Map<String, Map<String, dynamic>> _connectedServices = {
    'amazon': {
      'isConnected': true,
      'dataCount': 89,
      'lastSync': '3時間前',
    },
    'rakuten': {
      'isConnected': false,
      'dataCount': 0,
      'lastSync': '未接続',
    },
    'valuecommerce': {
      'isConnected': false,
      'dataCount': 0,
      'lastSync': '未接続',
    },
  };

  // API接続対象サービス（統一されたサービスアイコンを使用）
  final List<Map<String, dynamic>> _apiServices = [
    {
      'id': 'amazon',
      'name': 'Amazonアソシエイト',
      'description': 'アフィリエイトリンク機能・商品情報取得',
      'status': 'available',
    },
    {
      'id': 'rakuten',
      'name': '楽天アフィリエイト',
      'description': 'アフィリエイトリンク機能・商品情報取得',
      'status': 'available',
    },
    {
      'id': 'valuecommerce',
      'name': 'バリューコマース',
      'description': 'アフィリエイトリンク機能・商品情報取得',
      'status': 'available',
    },
  ];

  // メインサービス（MVP版 - 主要サービスのみ表示）
  final List<Map<String, dynamic>> mainServices = [
    {
      'id': 'youtube',
      'title': 'YouTube',
      'subtitle': '',
      'priority': 1,
    },
    {
      'id': 'amazon',
      'title': 'Amazon',
      'subtitle': '',
      'priority': 2,
    },
    {
      'id': 'spotify',
      'title': 'Spotify',
      'subtitle': '',
      'priority': 3,
    },
    {
      'id': 'receipt',
      'title': 'レシート',
      'subtitle': '',
      'priority': 4,
    },
    // MVP版では以下のサービスを非表示
    // {
    //   'id': 'prime_video',
    //   'title': 'Amazon Prime',
    //   'subtitle': '',
    //   'priority': 5,
    // },
    // {
    //   'id': 'netflix',
    //   'title': 'Netflix',
    //   'subtitle': '',
    //   'priority': 6,
    // },
  ];

  // ジャンル別サービス（MVP版 - 主要サービスのみ表示）
  final Map<String, List<Map<String, dynamic>>> serviceCategories = {
    '動画': [
      {'id': 'youtube', 'title': 'YouTube', 'subtitle': '動画共有・ライブ配信'},
      // MVP版では他の動画サービスを非表示
      // {'id': 'netflix', 'title': 'Netflix', 'subtitle': '映画・ドラマストリーミング'},
      // {'id': 'prime_video', 'title': 'Amazon Prime', 'subtitle': '映画・ドラマ・オリジナル作品'},
      // {'id': 'disney_plus', 'title': 'Disney+', 'subtitle': 'ディズニー・マーベル・スター・ウォーズ'},
      // {'id': 'niconico', 'title': 'ニコニコ動画', 'subtitle': '動画共有・生放送'},
      // {'id': 'abema', 'title': 'ABEMA', 'subtitle': 'アニメ・バラエティ・ニュース'},
      // {'id': 'hulu', 'title': 'Hulu', 'subtitle': '海外ドラマ・アニメ'},
      // {'id': 'unext', 'title': 'U-NEXT', 'subtitle': '映画・アニメ・雑誌'},
    ],
    // MVP版では配信カテゴリを非表示
    // '配信': [
    //   {'id': 'twitch', 'title': 'Twitch', 'subtitle': 'ゲーム配信・ライブストリーミング'},
    //   {'id': 'twitcasting', 'title': 'ツイキャス', 'subtitle': 'ライブ配信'},
    //   {'id': 'furatch', 'title': 'ふわっち', 'subtitle': 'ライブ配信'},
    //   {'id': 'palmu', 'title': 'Palmu', 'subtitle': 'ライブ配信'},
    //   {'id': 'showroom', 'title': 'SHOWROOM', 'subtitle': 'ライブ配信・応援'},
    //   {'id': '17live', 'title': '17LIVE', 'subtitle': 'ライブ配信'},
    //   {'id': 'line_live', 'title': 'LINE LIVE', 'subtitle': 'ライブ配信'},
    //   {'id': 'mildom', 'title': 'Mildom', 'subtitle': 'ゲーム配信'},
    //   {'id': 'openrec', 'title': 'OPENREC', 'subtitle': 'ゲーム配信'},
    //   {'id': 'mirrativ', 'title': 'Mirrativ', 'subtitle': 'スマホゲーム配信'},
    //   {'id': 'reality', 'title': 'REALITY', 'subtitle': 'バーチャル配信'},
    //   {'id': 'iriam', 'title': 'IRIAM', 'subtitle': 'バーチャル配信'},
    //   {'id': 'bigolive', 'title': 'BIGO LIVE', 'subtitle': 'グローバル配信'},
    //   {'id': 'spoon', 'title': 'Spoon', 'subtitle': '音声配信'},
    //   {'id': 'pococha', 'title': 'Pococha', 'subtitle': 'ライブコミュニケーション'},
    //   {'id': 'tangome', 'title': 'TangoMe', 'subtitle': 'ライブ配信'},
    // ],
    '音楽': [
      {'id': 'spotify', 'title': 'Spotify', 'subtitle': '音楽ストリーミング'},
      // MVP版では他の音楽サービスを非表示
      // {'id': 'youtube_music', 'title': 'YouTube Music', 'subtitle': '音楽再生サービス'},
      // {'id': 'amazon_music', 'title': 'Amazon Music', 'subtitle': '音楽ストリーミング・プレイリスト'},
      // {'id': 'apple_music', 'title': 'Apple Music', 'subtitle': '再生履歴'},
      // {'id': 'live_concert', 'title': 'ライブ・コンサート', 'subtitle': '参加したライブ記録'},
    ],
    'ショッピング': [
      {'id': 'amazon', 'title': 'Amazon', 'subtitle': '購入履歴・お気に入り'},
      // MVP版では他のショッピングサービスを非表示
      // {'id': 'rakuten', 'title': '楽天市場', 'subtitle': '購入履歴・お気に入り'},
      // {'id': 'zozotown', 'title': 'ZOZOTOWN', 'subtitle': 'ファッション購入履歴'},
      // {'id': 'qoo10', 'title': 'Qoo10', 'subtitle': '韓国コスメ・ファッション'},
      // {'id': 'yahoo_shopping', 'title': 'Yahoo!ショッピング', 'subtitle': '購入履歴'},
      // {'id': 'mercari', 'title': 'メルカリ', 'subtitle': 'フリマ取引履歴'},
      // {'id': 'other_ec', 'title': 'その他EC', 'subtitle': 'オンラインショップ'},
    ],
    // MVP版ではSNSカテゴリを非表示
    // 'SNS': [
    //   {'id': 'instagram', 'title': 'Instagram', 'subtitle': '投稿・ストーリー'},
    //   {'id': 'tiktok', 'title': 'TikTok', 'subtitle': 'ショート動画'},
    //   {'id': 'x', 'title': 'X (Twitter)', 'subtitle': 'ツイート・フォロー'},
    //   {'id': 'facebook', 'title': 'Facebook', 'subtitle': '投稿・いいね'},
    //   {'id': 'bereal', 'title': 'BeReal', 'subtitle': 'リアルタイム写真共有'},
    //   {'id': 'threads', 'title': 'Threads', 'subtitle': 'テキスト共有SNS'},
    //   {'id': 'snapchat', 'title': 'Snapchat', 'subtitle': 'スナップ・ストーリー'},
    //   {'id': 'linkedin', 'title': 'LinkedIn', 'subtitle': 'ビジネスネットワーク'},
    // ],
    // MVP版では購入・決済カテゴリを非表示
    // '購入・決済': [
    //   {'id': 'credit_card', 'title': 'クレジットカード', 'subtitle': '決済履歴', 'icon': Icons.credit_card, 'color': const Color(0xFF1976D2)},
    //   {'id': 'electronic_money', 'title': '電子マネー', 'subtitle': '交通系IC・QR決済', 'icon': Icons.contactless, 'color': const Color(0xFF4CAF50)},
    // ],
    // MVP版ではエンタメカテゴリを非表示
    // 'エンタメ': [
    //   {'id': 'games', 'title': 'ゲーム', 'subtitle': 'プレイ履歴・実績', 'icon': Icons.sports_esports, 'color': const Color(0xFF9C27B0)},
    //   {'id': 'books_manga', 'title': '書籍・漫画', 'subtitle': '読書履歴・電子書籍', 'icon': Icons.book, 'color': const Color(0xFF8D6E63)},
    //   {'id': 'cinema', 'title': '映画館', 'subtitle': '鑑賞履歴', 'icon': Icons.local_movies, 'color': const Color(0xFF795548)},
    // ],
    // MVP版では飲食・グルメカテゴリを非表示
    // '飲食・グルメ': [
    //   {'id': 'restaurant', 'title': 'レストラン・カフェ', 'subtitle': '外食記録', 'icon': Icons.restaurant, 'color': const Color(0xFFFF5722)},
    //   {'id': 'delivery', 'title': 'デリバリー', 'subtitle': 'Uber Eats、出前館等', 'icon': Icons.delivery_dining, 'color': const Color(0xFF4CAF50)},
    //   {'id': 'cooking', 'title': '自炊', 'subtitle': '料理記録', 'icon': Icons.kitchen, 'color': const Color(0xFFFFC107)},
    // ],
    // MVP版ではアプリ・デジタルカテゴリを非表示
    // 'アプリ・デジタル': [
    //   {'id': 'smartphone_apps', 'title': 'スマホアプリ', 'subtitle': '使用時間・頻度', 'icon': Icons.phone_android, 'color': const Color(0xFF2196F3)},
    //   {'id': 'web_services', 'title': 'ウェブサービス', 'subtitle': '利用履歴', 'icon': Icons.web, 'color': const Color(0xFF3F51B5)},
    //   {'id': 'game_apps', 'title': 'ゲームアプリ', 'subtitle': 'プレイ時間・課金', 'icon': Icons.games, 'color': const Color(0xFFE91E63)},
    // ],
  };

  // レガシーデータカテゴリ（互換性のため残しておく）
  final List<Map<String, dynamic>> dataCategories = [
    {
      'id': 'youtube',
      'title': 'YouTube',
      'subtitle': '視聴履歴・チャンネル',
      'icon': Icons.play_circle_filled,
      'description': 'YouTubeの視聴履歴、お気に入りチャンネル、プレイリストなどを記録',
      'placeholder': '例：\n動画タイトル: iPhone 15 レビュー\nチャンネル: テックレビューアー田中\n視聴日: 2024/01/15\n\nまたは視聴履歴画面をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'spotify',
      'title': 'Spotify',
      'subtitle': '音楽・再生履歴',
      'icon': Icons.music_note,
      'description': 'Spotifyの再生履歴、お気に入りアーティスト、プレイリストを記録',
      'placeholder': '例：\n楽曲: 夜に駆ける\nアーティスト: YOASOBI\n再生日: 2024/01/15\n\nまたはSpotifyの再生履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'netflix',
      'title': 'Netflix',
      'subtitle': '映画・ドラマ視聴',
      'icon': Icons.movie,
      'description': 'Netflixの視聴履歴、お気に入り作品を記録',
      'placeholder': '例：\n作品名: ストレンジャー・シングス\nシーズン: 4\n視聴日: 2024/01/15\n\nまたはNetflixの視聴履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'abema',
      'title': 'ABEMA',
      'subtitle': 'アニメ・バラエティ・ニュース',
      'icon': Icons.tv,
      'description': 'ABEMAの視聴履歴、お気に入り番組、チャンネルを記録',
      'placeholder': '例：\n番組名: 今日好きになりました\nチャンネル: ABEMA SPECIAL\n視聴日: 2024/01/15\n\nまたはABEMAの視聴履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'amazon',
      'title': 'Amazon',
      'subtitle': '購入履歴・商品',
      'icon': Icons.shopping_bag,
      'description': 'Amazonでの購入履歴、お気に入り商品を記録',
      'placeholder': '例：\n商品名: iPhone 15 Pro\n価格: 159,800円\n購入日: 2024/01/15\n\nまたはAmazonの注文履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'receipt',
      'title': 'レシート',
      'subtitle': '店舗での購入',
      'icon': Icons.receipt,
      'description': 'コンビニ、レストラン、ショップでの購入記録',
      'placeholder': '例：\n店舗: セブンイレブン\n商品: おにぎり、コーヒー\n金額: 298円\n日付: 2024/01/15\n\nまたはレシートをOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'books',
      'title': '書籍・漫画',
      'subtitle': '読書履歴',
      'icon': Icons.book,
      'description': '読んだ本、漫画、電子書籍の記録',
      'placeholder': '例：\n書籍名: 人を動かす\n著者: デール・カーネギー\n読了日: 2024/01/15\n\nまたは読書履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'food',
      'title': '食事・グルメ',
      'subtitle': 'レストラン・料理',
      'icon': Icons.restaurant,
      'description': 'レストラン、カフェ、自炊の記録',
      'placeholder': '例：\n店舗名: スターバックス\nメニュー: ドリップコーヒー\n価格: 350円\n日付: 2024/01/15\n\nまたはメニューや注文履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'other',
      'title': 'その他',
      'subtitle': '自由入力',
      'icon': Icons.add_circle,
      'description': 'その他の日常データを自由に記録',
      'placeholder': '自由にテキストを入力してください。\n\n例：\n・アプリの使用時間\n・旅行の記録\n・習い事の記録\nなど',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingAnimationController.dispose();
    _textController.dispose();
    super.dispose();
  }


  void _clearSelection() {
    _animationController.reverse().then((_) {
      setState(() {
        selectedCategory = null;
        showProcessingResults = false;
        processedVideos.clear();
        _textController.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    if (widget.showAppBar) {
      // Standalone mode with AppBar (when navigated to directly)
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: isDark 
            ? const Color(0xFF0A0A0B) 
            : const Color(0xFFFBFBFD),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0A0A0B) : const Color(0xFFFBFBFD),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: const SizedBox.shrink(),
        ),
        drawer: _buildDrawer(),
        body: SafeArea(
          child: selectedCategory == null
              ? _buildMainDashboard()
              : showProcessingResults
                  ? _buildProcessingResults()
                  : _buildCategoryInputScreen(),
        ),
      );
    } else {
      // Tab mode without AppBar (when used in StarlistMainScreen)
      return Container(
        color: isDark 
            ? const Color(0xFF0A0A0B) 
            : const Color(0xFFFBFBFD),
        child: SafeArea(
          child: selectedCategory == null
              ? _buildMainDashboard()
              : showProcessingResults
                  ? _buildProcessingResults()
                  : _buildCategoryInputScreen(),
        ),
      );
    }
  }

  Widget _buildMainDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // メインサービス（優先度の高い6つ）
          _buildPriorityServicesSection(),
          const SizedBox(height: 32),
          
          // ジャンル別サービス（9カテゴリ）
          _buildCategoryServicesSection(),
          const SizedBox(height: 32),
          
          // API連携・アフィリエイト
          _buildApiAffiliateSection(),
          const SizedBox(height: 24),
          
          // メインOCR機能
          _buildOCRMainSection(),
          const SizedBox(height: 24),
          
          // 取込み履歴
          _buildImportHistorySection(),
        ],
      ),
    );
  }

  Widget _buildOCRMainSection() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'スクリーンショット取込み',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'スクリーンショットをOCRで読み取り、自動でデータを分類します',
            style: TextStyle(
              color: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // メインOCRカード - 超モダンデザイン
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: isDark 
                ? const LinearGradient(
                    colors: [
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                      Color(0xFF6B73FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [
                      Color(0xFFE0E7FF),
                      Color(0xFFF3E8FF),
                      Color(0xFFE0F2FE),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(24),
            border: isDark 
                ? Border.all(color: const Color(0xFF9333EA).withOpacity(0.3), width: 1)
                : Border.all(color: const Color(0xFF667EEA).withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? const Color(0xFF667EEA).withOpacity(0.25) 
                    : const Color(0xFF667EEA).withOpacity(0.15),
                blurRadius: 32,
                offset: const Offset(0, 16),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.3) 
                    : Colors.white.withOpacity(0.8),
                blurRadius: 1,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // アイコンエリア - グラスモーフィズム風
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.white.withOpacity(0.15) 
                      : const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withOpacity( 0.2) 
                        : const Color(0xFF667EEA).withOpacity( 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withOpacity( 0.3) 
                          : const Color(0xFF667EEA).withOpacity( 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.text_snippet_outlined,
                  color: isDark ? Colors.white : const Color(0xFF667EEA),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'データを手動入力',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '実装済みのサービス連携機能をご利用ください',
                style: TextStyle(
                  color: isDark 
                      ? const Color(0xFFB0B3B8) 
                      : const Color(0xFF65676B),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF4ECDC4).withOpacity( 0.1)
                      : const Color(0xFF4ECDC4).withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4ECDC4),
                    width: 1,
                  ),
                ),
                child: Column(
                children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4ECDC4),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '画像読み込み機能は現在開発中です',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 優先度の高いメインサービス6つ
  Widget _buildPriorityServicesSection() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
          '人気サービス',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
        const SizedBox(height: 8),
        const SizedBox(height: 20),
        
        // 3×2グリッドで6つのメインサービス
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: mainServices.length,
          itemBuilder: (context, index) {
            final service = mainServices[index];
            return _buildPriorityServiceCard(service, isDark);
          },
        ),
      ],
    );
  }

  // ジャンル別サービス（横スクロール）
  Widget _buildCategoryServicesSection() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ジャンル別サービス',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        // 各ジャンルを縦に並べて表示
        ...serviceCategories.entries.map((entry) {
          final categoryName = entry.key;
          final services = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // 横スクロールサービスリスト
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 4 : 8,
                          right: index == services.length - 1 ? 4 : 0,
                        ),
                        child: _buildCategoryServiceCard(service, isDark),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // API連携・アフィリエイトセクション
  Widget _buildApiAffiliateSection() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API連携・アフィリエイト',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        // API サービス一覧
        ..._apiServices.map((service) {
          final serviceData = _connectedServices[service['id']] ?? {
            'isConnected': false,
            'dataCount': 0,
            'lastSync': '未接続',
          };
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildApiServiceCard(service, serviceData, isDark),
          );
        }),
      ],
    );
  }

  // 優先度サービス用カード（実際のロゴ使用）
  Widget _buildPriorityServiceCard(Map<String, dynamic> service, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToService(service['id']),
                    child: Container(
                      decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A2A2A), Color(0xFF1F1F1F)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFAFBFC)],
                ),
          borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                                ? Colors.black.withOpacity( 0.3) 
                  : Colors.black.withOpacity( 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity( 0.2)
                  : Colors.white.withOpacity( 0.9),
              blurRadius: 0,
              offset: const Offset(0, 1),
              spreadRadius: 0,
                          ),
                        ],
                      ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 実際のサービスロゴを使用
              ServiceIcons.buildIcon(
                serviceId: service['id'],
                size: 43,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              Text(
                service['title'],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                service['subtitle'],
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ジャンル別サービス用カード（実際のロゴ使用）
  Widget _buildCategoryServiceCard(Map<String, dynamic> service, bool isDark) {
    final isImplemented = _isServiceImplemented(service['id']);
    
    return GestureDetector(
      onTap: () => _navigateToService(service['id']),
                    child: Container(
        width: 160,
                      decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isImplemented 
                    ? [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)]
                    : [const Color(0xFF2A2A2A).withOpacity(0.6), const Color(0xFF1F1F1F).withOpacity(0.6)],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isImplemented 
                    ? [Colors.white, const Color(0xFFFAFBFC)]
                    : [Colors.grey[100]!, const Color(0xFFF5F5F5)],
                ),
                        borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isImplemented 
              ? (isDark 
                  ? const Color(0xFF404040).withOpacity( 0.3)
                  : const Color(0xFFE2E8F0).withOpacity( 0.6))
              : const Color(0xFFFFC107).withOpacity( 0.3),
            width: isImplemented ? 1 : 2,
          ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                                ? Colors.black.withOpacity( 0.3) 
                  : Colors.black.withOpacity( 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
              spreadRadius: 0,
                          ),
                        ],
                      ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 実際のサービスロゴを使用
                  Opacity(
                    opacity: isImplemented ? 1.0 : 0.5,
                    child: ServiceIcons.buildIcon(
                      serviceId: service['id'],
                      size: 31,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      service['title'],
                      style: TextStyle(
                        color: isImplemented 
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.grey[500] : Colors.grey[600]),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (service['subtitle'].isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Flexible(
                      child: Text(
                        service['subtitle'],
                        style: TextStyle(
                          color: isImplemented 
                            ? (isDark ? Colors.grey[400] : Colors.grey[600])
                            : (isDark ? Colors.grey[600] : Colors.grey[500]),
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 未実装サービス用のバッジ
            if (!isImplemented)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '開発中',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
        ),
      ),
    );
  }

  // サービスが実装済みかどうかを判定
  bool _isServiceImplemented(String serviceId) {
    final implementedServices = [
      'youtube', 'spotify', 'youtube_music', 'amazon', 'rakuten', 
      'yahoo_shopping', 'mercari', 'other_ec', 'receipt', 'prime_video',
      'netflix', 'abema', 'hulu', 'disney', 'unext'
    ];
    return implementedServices.contains(serviceId);
  }

  // API サービス用カード（実際のロゴ使用）
  Widget _buildApiServiceCard(Map<String, dynamic> service, Map<String, dynamic> serviceData, bool isDark) {
    final isConnected = serviceData['isConnected'] as bool;
    
    return GestureDetector(
      onTap: () => _connectService(service['id']),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A2A2A), Color(0xFF1F1F1F)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFAFBFC)],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnected 
                ? const Color(0xFF4CAF50)
                : (isDark 
                    ? const Color(0xFF404040).withOpacity( 0.3)
                    : const Color(0xFFE2E8F0).withOpacity( 0.6)),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity( 0.3)
                  : Colors.black.withOpacity( 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // 実際のサービスロゴを使用
            ServiceIcons.buildIcon(
              serviceId: service['id'],
              size: 48,
              isDark: isDark,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                    service['name'],
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isConnected 
                        ? '${serviceData['dataCount']}件のデータ • ${serviceData['lastSync']}'
                        : service['description'],
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
              ),
            ),
          ],
        ),
            ),
            Icon(
              isConnected ? Icons.check_circle : Icons.add_circle_outline,
              color: isConnected ? const Color(0xFF4CAF50) : const Color(0xFF4ECDC4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return GestureDetector(
      onTap: () => _selectServiceForOCR(service['id']),
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF1C1C1E) 
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark 
                ? const Color(0xFF38383A) 
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity( 0.4) 
                  : const Color(0xFF667EEA).withOpacity( 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark 
                  ? Colors.white.withOpacity( 0.03) 
                  : Colors.white.withOpacity( 0.9),
              blurRadius: 1,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: ServiceIcons.getServiceGradient(service['id']!),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: ServiceIcons.getService(service['id']!)?.color.withOpacity( 0.2) ?? const Color(0xFF4ECDC4).withOpacity( 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ServiceIcons.buildIcon(
                  serviceId: service['id']!,
                  size: 24,
                  isDark: false,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service['name'],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                service['description'],
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startOCRCapture(String source) {
    // OCR機能の実装
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'OCR取込み',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'スクリーンショットからテキストを読み取ります。\n読み取り後、適切なサービスを選択してください。',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity( 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFF4ECDC4), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      source == 'camera' ? 'カメラを起動します' : 'ギャラリーを開きます',
                      style: const TextStyle(color: Color(0xFF4ECDC4), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processOCRCapture(source);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
            ),
            child: const Text('開始'),
          ),
        ],
      ),
    );
  }

  void _processOCRCapture(String source) {
    // OCR処理のシミュレーション
    setState(() {
      isProcessing = true;
    });

    // 3秒後にサービス選択画面を表示
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isProcessing = false;
      });
    _showServiceSelectionForOCR();
    });
  }

  void _showServiceSelectionForOCR() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'サービスを選択',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'OCRで読み取ったテキストをどのサービスに分類しますか？',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // サービス選択グリッド
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final services = ['youtube', 'spotify', 'netflix', 'abema', 'amazon', 'instagram', 'tiktok'];
                final serviceId = services[index];
                return _buildServiceSelectionCard(serviceId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelectionCard(String serviceId) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context);
            _selectServiceForOCR(serviceId);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ServiceIcons.buildIcon(
                  serviceId: serviceId,
                  size: 24,
                  isDark: true,
                ),
                const SizedBox(height: 8),
                Text(
                  ServiceIcons.getService(serviceId)?.name ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToService(String serviceId) {
    switch (serviceId) {
      case 'youtube':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const YouTubeImportScreen(),
        ),
      );
        break;
      case 'spotify':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MusicImportScreen(),
          ),
        );
        break;
      case 'youtube_music':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const YouTubeMusicImportScreen(),
          ),
        );
        break;
      case 'amazon':
      case 'rakuten':
      case 'yahoo_shopping':
      case 'mercari':
      case 'other_ec':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShoppingImportScreen(),
          ),
        );
        break;
      case 'amazon_prime':
      case 'netflix':
      case 'abema':
      case 'hulu':
      case 'disney':
      case 'unext':
      case 'dtv':
      case 'fod':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoImportScreen(
              serviceId: serviceId,
              serviceName: _getServiceDisplayName(serviceId),
              serviceColor: _getServiceColor(serviceId),
              serviceIcon: _getServiceIcon(serviceId),
            ),
          ),
        );
        break;
      case 'receipt':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReceiptImportScreen(),
          ),
        );
        break;
      case 'restaurant':
      case 'delivery':
      case 'cooking':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodImportScreen(
              serviceId: serviceId,
              serviceName: _getServiceDisplayName(serviceId),
              serviceColor: _getServiceColor(serviceId),
              serviceIcon: _getServiceIcon(serviceId),
            ),
          ),
        );
        break;
      case 'instagram':
      case 'tiktok':
      case 'twitter':
      case 'facebook':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SnsImportScreen(
              serviceId: serviceId,
              serviceName: _getServiceDisplayName(serviceId),
              serviceColor: _getServiceColor(serviceId),
              serviceIcon: _getServiceIcon(serviceId),
            ),
          ),
        );
        break;
      case 'games':
      case 'books':
      case 'cinema':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EntertainmentImportScreen(
              serviceId: serviceId,
              serviceName: _getServiceDisplayName(serviceId),
              serviceColor: _getServiceColor(serviceId),
              serviceIcon: _getServiceIcon(serviceId),
            ),
          ),
        );
        break;
      case 'credit_card':
      case 'electronic_money':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentImportScreen(
              serviceId: serviceId,
              serviceName: _getServiceDisplayName(serviceId),
              serviceColor: _getServiceColor(serviceId),
              serviceIcon: _getServiceIcon(serviceId),
            ),
          ),
        );
        break;
      case 'smartphone_apps':
      case 'web_services':
      case 'game_apps':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DigitalImportScreen(
              serviceId: serviceId,
              serviceName: _getServiceDisplayName(serviceId),
              serviceColor: _getServiceColor(serviceId),
              serviceIcon: _getServiceIcon(serviceId),
            ),
          ),
        );
        break;
      default:
        // 未実装サービスの場合、詳細な案内ダイアログを表示
        _showComingSoonDialog(serviceId);
        break;
    }
  }

  void _selectServiceForOCR(String serviceId) {
      _navigateToService(serviceId);
  }

  void _showComingSoonDialog(String serviceId) {
    final serviceName = _getServiceDisplayName(serviceId);
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.construction,
                color: Color(0xFFFFC107),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$serviceName\n開発中',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$serviceNameのデータ取り込み機能は現在開発中です。',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF4ECDC4),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '代替手段',
                        style: TextStyle(
                          color: Color(0xFF4ECDC4),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 手動でデータを入力\n• スクリーンショットのOCR読み取り\n• 実装済みサービスをご利用ください',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '了解',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 手動入力画面に遷移
      setState(() {
                selectedCategory = 'other';
              });
              _animationController.forward();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('手動入力'),
          ),
        ],
      ),
    );
  }

  String _getServiceDisplayName(String serviceId) {
    switch (serviceId) {
      case 'amazon_prime': return 'Amazon Prime';
      case 'netflix': return 'Netflix';
      case 'abema': return 'ABEMA';
      case 'hulu': return 'Hulu';
      case 'disney': return 'Disney+';
      case 'unext': return 'U-NEXT';
      case 'dtv': return 'dTV';
      case 'fod': return 'FOD';
      case 'restaurant': return 'レストラン・カフェ';
      case 'delivery': return 'デリバリー';
      case 'cooking': return '自炊';
      case 'instagram': return 'Instagram';
      case 'tiktok': return 'TikTok';
      case 'twitter': return 'Twitter/X';
      case 'facebook': return 'Facebook';
      case 'games': return 'ゲーム';
      case 'books': return '書籍・漫画';
      case 'cinema': return '映画館';
      case 'credit_card': return 'クレジットカード';
      case 'electronic_money': return '電子マネー';
      case 'smartphone_apps': return 'スマホアプリ';
      case 'web_services': return 'ウェブサービス';
      case 'game_apps': return 'ゲームアプリ';
      default: return serviceId;
    }
  }

  Color _getServiceColor(String serviceId) {
    switch (serviceId) {
      case 'amazon_prime': return const Color(0xFF00A8E1);
      case 'netflix': return const Color(0xFFE50914);
      case 'abema': return const Color(0xFF00D4AA);
      case 'hulu': return const Color(0xFF1CE783);
      case 'disney': return const Color(0xFF113CCF);
      case 'unext': return const Color(0xFF000000);
      case 'dtv': return const Color(0xFFFF6B35);
      case 'fod': return const Color(0xFF0078D4);
      case 'restaurant': return const Color(0xFFFF5722);
      case 'delivery': return const Color(0xFF4CAF50);
      case 'cooking': return const Color(0xFFFFC107);
      case 'instagram': return const Color(0xFFE4405F);
      case 'tiktok': return const Color(0xFF000000);
      case 'twitter': return const Color(0xFF1DA1F2);
      case 'facebook': return const Color(0xFF1877F2);
      case 'games': return const Color(0xFF9C27B0);
      case 'books': return const Color(0xFF8D6E63);
      case 'cinema': return const Color(0xFF795548);
      case 'credit_card': return const Color(0xFF1976D2);
      case 'electronic_money': return const Color(0xFF4CAF50);
      case 'smartphone_apps': return const Color(0xFF2196F3);
      case 'web_services': return const Color(0xFF3F51B5);
      case 'game_apps': return const Color(0xFFE91E63);
      default: return const Color(0xFF4ECDC4);
    }
  }

  IconData _getServiceIcon(String serviceId) {
    // ServiceDefinitionsクラスを使用して正しいアイコンを取得
    // 存在しないサービスIDの場合は適切なフォールバックアイコンを使用
    final icon = ServiceDefinitions.getServiceIcon(serviceId);
    if (icon == FontAwesomeIcons.question) {
      // service_definitionsに存在しないサービスの場合のフォールバック
      switch (serviceId) {
        case 'openrec':
        case 'mirrativ':
        case 'reality':
        case 'iriam':
        case 'bigolive':
        case 'spoon':
        case 'tangome':
          return FontAwesomeIcons.video; // 配信サービス用
        case 'books_manga':
          return FontAwesomeIcons.book; // 書籍用
        case 'cinema':
          return FontAwesomeIcons.film; // 映画用
        case 'restaurant':
          return FontAwesomeIcons.utensils; // レストラン用
        case 'delivery':
          return FontAwesomeIcons.truck; // デリバリー用
        case 'cooking':
          return FontAwesomeIcons.kitchenSet; // 料理用
        case 'games':
          return FontAwesomeIcons.gamepad; // ゲーム用
        case 'credit_card':
          return FontAwesomeIcons.creditCard; // クレジットカード用
        case 'electronic_money':
          return FontAwesomeIcons.mobileScreen; // 電子マネー用
        case 'smartphone_apps':
          return FontAwesomeIcons.mobileScreen; // スマホアプリ用
        case 'web_services':
          return FontAwesomeIcons.globe; // ウェブサービス用
        case 'game_apps':
          return FontAwesomeIcons.gamepad; // ゲームアプリ用
        default:
          return FontAwesomeIcons.question;
      }
    }
    return icon;
  }

  void _showAllServices() {
    // すべてのサービスを表示する画面への遷移
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'すべてのサービス',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: dataCategories.length,
                  itemBuilder: (context, index) {
                    final category = dataCategories[index];
                    return _buildServiceCard(category);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSourcesSection() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'データソース管理',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _showApiConnectionScreen,
              icon: const Icon(Icons.api, color: Color(0xFF4ECDC4), size: 16),
              label: const Text(
                'API連携',
                style: TextStyle(color: Color(0xFF4ECDC4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 接続済みサービス
        ..._apiServices.map((service) {
          final serviceData = _connectedServices[service['id']] ?? {
            'isConnected': false,
            'dataCount': 0,
            'lastSync': '未接続',
          };
          
          return ServiceIcons.buildServiceCard(
            serviceId: service['id'],
            title: service['name'],
            description: serviceData['isConnected'] 
                ? '${serviceData['dataCount']}件のデータ • ${serviceData['lastSync']}'
                : service['description'],
            onTap: () => _connectService(service['id']),
            isConnected: serviceData['isConnected'],
            isDark: isDark,
          );
        }),
      ],
    );
  }

  Widget _buildImportHistorySection() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    final history = [
      {
        'type': 'YouTube',
        'count': 5,
        'time': '2時間前',
        'status': 'success',
        'isPublic': true,
      },
      {
        'type': 'Spotify',
        'count': 12,
        'time': '5時間前',
        'status': 'success',
        'isPublic': false,
      },
      {
        'type': 'レシート',
        'count': 1,
        'time': '1日前',
        'status': 'processing',
        'isPublic': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '取込み履歴',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...history.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(item['status'] as String).withOpacity( 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(item['status'] as String),
                  color: _getStatusColor(item['status'] as String),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['type']} データ取込み',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${item['count']}件 • ${item['time']}',
                      style: TextStyle(
                        color: isDark ? Colors.grey : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPublicationToggle(item),
            ],
          ),
        )),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return const Color(0xFF10B981);
      case 'processing':
        return const Color(0xFFF59E0B);
      case 'error':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'processing':
        return Icons.refresh;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'success':
        return '完了';
      case 'processing':
        return '処理中';
      case 'error':
        return 'エラー';
      default:
        return '不明';
    }
  }
  
  Widget _buildPublicationToggle(Map<String, dynamic> item) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    final isPublic = item['isPublic'] as bool;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          item['isPublic'] = !isPublic;
        });
        
        // フィードバック
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item['type']}データが${!isPublic ? "公開" : "非公開"}に設定されました',
            ),
            backgroundColor: const Color(0xFF4ECDC4),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPublic 
              ? const Color(0xFF10B981).withOpacity(0.2)
              : isDark 
                  ? const Color(0xFF374151).withOpacity(0.3)
                  : const Color(0xFF9CA3AF).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPublic 
                ? const Color(0xFF10B981)
                : isDark 
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF9CA3AF),
            width: 1,
          ),
        ),
            child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPublic ? Icons.public : Icons.lock,
              color: isPublic 
                  ? const Color(0xFF10B981)
                  : isDark 
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              isPublic ? '公開中' : '非公開',
              style: TextStyle(
                color: isPublic 
                    ? const Color(0xFF10B981)
                    : isDark 
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _connectService(String serviceId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ServiceIcons.getService(serviceId)?.name ?? serviceId}との連携を開始します'),
        backgroundColor: ServiceIcons.getService(serviceId)?.color ?? const Color(0xFF4ECDC4),
      ),
    );
  }

  void _showApiConnectionScreen() {
    // API連携画面を表示する処理
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API連携画面を開きます'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  Widget _buildCategoryInputScreen() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    final category = dataCategories.firstWhere(
      (cat) => cat['id'] == selectedCategory,
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                GestureDetector(
                  onTap: _clearSelection,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : Colors.black).withOpacity( 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withOpacity( 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ServiceIcons.getService(category['id']) != null
                      ? ServiceIcons.buildIcon(
                          serviceId: category['id'],
                          size: 28,
                          isDark: false,
                        )
                      : Icon(
                          category['icon'],
                          color: Colors.white,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['title'],
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        category['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // OCR説明
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4ECDC4).withOpacity( 0.15),
                    const Color(0xFF44A08D).withOpacity( 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF4ECDC4).withOpacity( 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity( 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity( 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF4ECDC4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OCR機能を活用',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4ECDC4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'スマートフォンのOCR機能で画面を読み取り、テキストをコピーしてペーストしてください',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[300] : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // テキスト入力エリア
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.black).withOpacity( 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: category['placeholder'],
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.black38,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(24),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // アクションボタン
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.grey[700]! : Colors.grey[300]!).withOpacity( 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final clipboardData = await Clipboard.getData('text/plain');
                        if (clipboardData?.text != null) {
                          _textController.text = clipboardData!.text!;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.content_paste, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'ペースト',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ECDC4).withOpacity( 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : _processData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'データを取り込む',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100), // キーボード用の余白
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingResults() {
    // 既存の実装をそのまま維持
    return const Center(
      child: Text(
        '処理結果画面',
        style: TextStyle(color: Colors.white),
      ),
    );
}

  Future<void> _processData() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('テキストを入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    // シミュレートされた処理時間
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isProcessing = false;
    });

    // 成功メッセージ
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('データが正常に取り込まれました！'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: '確認',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }

    _clearSelection();
  }

  Widget _buildDrawer() {
    final currentUser = ref.watch(currentUserProvider);
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        children: [
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4ECDC4),
                  Color(0xFF44A08D),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity( 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Starlist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        currentUser.isStar ? 'スター' : 'ファン',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildDrawerItem(Icons.home, 'ホーム', false, () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) context.go('/home');
                  });
                }),
                _buildDrawerItem(Icons.search, '検索', false, () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) context.go('/home');
                  });
                }),
                _buildDrawerItem(Icons.star, 'マイリスト', false, () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) context.go('/home');
                  });
                }),
                // スターのみ表示
                if (currentUser.isStar) ...[
                  _buildDrawerItem(Icons.camera_alt, 'データ取込み', true, () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem(Icons.analytics, 'スターダッシュボード', false, () {
                    Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const StarDashboardScreen()),
                      );
                    });
                  }),
                  _buildDrawerItem(Icons.workspace_premium, 'プランを管理', false, () {
                    Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SubscriptionPlansScreen()),
                      );
                    });
                  }),
                ],
                _buildDrawerItem(Icons.person, 'マイページ', false, () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) context.go('/home');
                  });
                }),
                _buildDrawerItem(Icons.settings, '設定', false, () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) context.go('/settings');
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isActive, VoidCallback onTap) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive ? const Color(0xFF4ECDC4).withOpacity( 0.15) : null,
        border: isActive ? Border.all(
          color: const Color(0xFF4ECDC4).withOpacity( 0.3),
          width: 1,
        ) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive 
              ? const Color(0xFF4ECDC4)
              : (isDark ? Colors.white10 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive 
              ? Colors.white
              : (isDark ? Colors.white54 : Colors.grey.shade600),
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive 
              ? const Color(0xFF4ECDC4) 
              : (isDark ? Colors.white : Colors.grey.shade800),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: isActive ? const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF4ECDC4),
          size: 14,
        ) : null,
        onTap: onTap,
      ),
    );
  }

} 