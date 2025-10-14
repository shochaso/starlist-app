import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:starlist_app/consts/debug_flags.dart';
import 'package:starlist_app/features/data_integration/widgets/icon_probe_banner.dart';
import 'package:starlist_app/utils/key_normalizer.dart';
import 'package:starlist_app/widgets/icon_diag_hud.dart';
import '../../../src/core/components/service_icons.dart';
import '../../../services/service_icon_registry.dart';
import '../../../src/core/constants/service_definitions.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../providers/user_provider.dart';
import '../../star/screens/star_dashboard_screen.dart';
import '../../../src/features/subscription/screens/subscription_plans_screen.dart';
import 'youtube_import_screen.dart';
import 'music_import_screen.dart';
import 'shopping_import_screen.dart';
import 'receipt_import_screen.dart';
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

  // カテゴリ別サービス（要件に合わせた表示）
  final Map<String, List<Map<String, dynamic>>> _baseServiceCategories = {
    '動画配信': [
      {
        'id': 'prime_video',
        'title': 'Amazon Prime Video',
        'subtitle': '映画・ドラマ・オリジナル'
      },
      {'id': 'netflix', 'title': 'Netflix', 'subtitle': '映画・ドラマ・シリーズ'},
      {'id': 'unext', 'title': 'U-NEXT', 'subtitle': '映画・アニメ・雑誌'},
      {'id': 'hulu', 'title': 'Hulu', 'subtitle': '海外ドラマ・アニメ'},
      {'id': 'abema', 'title': 'ABEMA', 'subtitle': 'アニメ・バラエティ・ニュース'},
      {
        'id': 'manual_entry_video',
        'title': 'その他',
        'subtitle': 'リストにないサービスを登録',
        'isManualEntry': true,
        'iconData': Icons.edit_note,
        'iconColor': const Color(0xFF94A3B8),
      },
    ],
    'ショッピング': [
      {'id': 'amazon', 'title': 'Amazon', 'subtitle': '注文履歴・お気に入り'},
      {'id': 'yahoo_shopping', 'title': 'Yahoo!ショッピング', 'subtitle': '購入履歴'},
      {'id': 'rakuten', 'title': '楽天市場', 'subtitle': '購入履歴'},
      {
        'id': 'shein',
        'title': 'SHEIN',
        'subtitle': 'ファストファッション通販',
        'iconData': Icons.shopping_bag,
        'iconColor': const Color(0xFFF54785),
      },
      {
        'id': 'manual_entry_shopping',
        'title': 'その他',
        'subtitle': 'リストにないサービスを登録',
        'isManualEntry': true,
        'iconData': Icons.edit_note,
        'iconColor': const Color(0xFF94A3B8),
      },
    ],
    'フードデリバリ': [
      {'id': 'ubereats', 'title': 'Uber Eats', 'subtitle': 'フードデリバリー'},
      {
        'id': 'demaecan',
        'title': '出前館',
        'subtitle': 'フードデリバリー',
        'iconData': Icons.delivery_dining,
        'iconColor': const Color(0xFFFF7043),
      },
      {
        'id': 'manual_entry_food',
        'title': 'その他',
        'subtitle': 'リストにないサービスを登録',
        'isManualEntry': true,
        'iconData': Icons.edit_note,
        'iconColor': const Color(0xFF94A3B8),
      },
    ],
    'コンビニ': [
      {
        'id': 'seven_eleven',
        'title': 'セブン-イレブン',
        'subtitle': '最寄りコンビニの利用',
        'iconData': Icons.local_convenience_store,
        'iconColor': const Color(0xFFF58220),
      },
      {
        'id': 'family_mart',
        'title': 'ファミリーマート',
        'subtitle': '最寄りコンビニの利用',
        'iconData': Icons.local_convenience_store,
        'iconColor': const Color(0xFF1BA548),
      },
      {
        'id': 'lawson',
        'title': 'ローソン',
        'subtitle': '最寄りコンビニの利用',
        'iconData': Icons.local_convenience_store,
        'iconColor': const Color(0xFF0078C8),
      },
      {
        'id': 'daily_yamazaki',
        'title': 'デイリーヤマザキ',
        'subtitle': '最寄りコンビニの利用',
        'iconData': Icons.local_convenience_store,
        'iconColor': const Color(0xFFD6001C),
      },
      {
        'id': 'ministop',
        'title': 'ミニストップ',
        'subtitle': '最寄りコンビニの利用',
        'iconData': Icons.local_convenience_store,
        'iconColor': const Color(0xFF005BAC),
      },
      {
        'id': 'manual_entry_convenience',
        'title': 'その他',
        'subtitle': 'リストにないサービスを登録',
        'isManualEntry': true,
        'iconData': Icons.edit_note,
        'iconColor': const Color(0xFF94A3B8),
      },
    ],
    '音楽': [
      {'id': 'amazon_music', 'title': 'Amazon Music', 'subtitle': '音楽ストリーミング'},
      {'id': 'spotify', 'title': 'Spotify', 'subtitle': '音楽ストリーミング'},
      {'id': 'apple_music', 'title': 'Apple Music', 'subtitle': '音楽再生履歴'},
      {
        'id': 'manual_entry_music',
        'title': 'その他',
        'subtitle': 'リストにないサービスを登録',
        'isManualEntry': true,
        'iconData': Icons.edit_note,
        'iconColor': const Color(0xFF94A3B8),
      },
    ],
    'ゲーム（プレイのみ）': [
      {'id': 'steam', 'title': 'Steam', 'subtitle': 'PCゲームプレイ履歴'},
      {'id': 'playstation', 'title': 'PlayStation', 'subtitle': 'コンソールゲーム実績'},
      {'id': 'nintendo', 'title': 'Nintendo', 'subtitle': 'Nintendo Switchなど'},
      {
        'id': 'manual_entry_game',
        'title': 'その他',
        'subtitle': 'リストにないサービスを登録',
        'isManualEntry': true,
        'iconData': Icons.edit_note,
        'iconColor': const Color(0xFF94A3B8),
      },
    ],
    'スマホアプリ': [
      {
        'id': 'app_store',
        'title': 'App Store',
        'subtitle': 'iOSアプリ購入・履歴',
        'iconData': Icons.apps,
        'iconColor': const Color(0xFF0A84FF),
      },
      {
        'id': 'google_play',
        'title': 'Google Play',
        'subtitle': 'Androidアプリ購入・履歴',
        'iconData': Icons.android,
        'iconColor': const Color(0xFF34A853),
      },
      {
        'id': 'manual_entry_apps',
        'title': 'その他',
        'subtitle': 'リストにないサービスを登録',
        'isManualEntry': true,
        'iconData': Icons.edit_note,
        'iconColor': const Color(0xFF94A3B8),
      },
    ],
    'ファッション': [
      {'id': 'zozotown', 'title': 'ZOZOTOWN', 'subtitle': 'ファッション通販'},
      {
        'id': 'uniqlo',
        'title': 'UNIQLO',
        'subtitle': 'オンラインストア・アプリ',
        'iconData': Icons.checkroom,
        'iconColor': const Color(0xFFDC143C),
      },
      {
        'id': 'gu',
        'title': 'GU',
        'subtitle': 'オンラインストア・アプリ',
        'iconData': Icons.checkroom,
        'iconColor': const Color(0xFF1E88E5),
      },
      {
        'id': 'shein_fashion',
        'title': 'SHEIN',
        'subtitle': 'ファストファッション通販',
        'iconData': Icons.shopping_bag,
        'iconColor': const Color(0xFFF54785),
        'linkedServiceId': 'shein',
      },
      {
        'id': 'manual_entry_fashion',
        'title': 'その他',
        'subtitle': 'リストにないサービスを登録',
        'isManualEntry': true,
        'iconData': Icons.edit_note,
        'iconColor': const Color(0xFF94A3B8),
      },
    ],
    '本': [
      {
        'id': 'amazon_books',
        'title': 'Amazon Books',
        'subtitle': '書籍購入履歴',
        'iconData': Icons.menu_book,
        'iconColor': const Color(0xFFFF9900),
      },
      {'id': 'kindle', 'title': 'Kindle', 'subtitle': '電子書籍ライブラリ'},
      {
        'id': 'rakuten_books',
        'title': '楽天ブックス',
        'subtitle': '書籍・電子書籍',
        'iconData': Icons.menu_book,
        'iconColor': const Color(0xFFBF0000),
      },
      {
        'id': 'audible',
        'title': 'Audible',
        'subtitle': 'オーディオブック',
        'iconData': Icons.headset,
        'iconColor': const Color(0xFFFF6B6B),
      },
      {
        'id': 'manual_entry_books',
        'title': 'その他',
        'subtitle': 'リストにないサービスを登録',
        'isManualEntry': true,
        'iconData': Icons.edit_note,
        'iconColor': const Color(0xFF4ECDC4),
      },
    ],
  };

  // 非表示扱いのカテゴリ（手入力で選択できる）
  final Map<String, List<Map<String, dynamic>>> _hiddenServiceCategories = {
    'アプリ使用時間': [
      {
        'id': 'ios_screen_time',
        'title': 'iOSスクリーンタイム',
        'subtitle': '使用状況レポートを取り込み',
        'iconData': Icons.hourglass_bottom,
        'iconColor': const Color(0xFF0A84FF),
      },
      {
        'id': 'android_digital_wellbeing',
        'title': 'Android Digital Wellbeing',
        'subtitle': '使用時間ダッシュボードを取り込み',
        'iconData': Icons.insights,
        'iconColor': const Color(0xFF34A853),
      },
    ],
  };

  // ユーザーが手入力で追加したサービスを保持
  final Map<String, List<Map<String, dynamic>>> _customServices = {};

  // レガシーデータカテゴリ（互換性のため残しておく）
  final List<Map<String, dynamic>> dataCategories = [
    {
      'id': 'youtube',
      'title': 'YouTube',
      'subtitle': '視聴履歴・チャンネル',
      'icon': Icons.play_circle_filled,
      'description': 'YouTubeの視聴履歴、お気に入りチャンネル、プレイリストなどを記録',
      'placeholder':
          '例：\n動画タイトル: iPhone 15 レビュー\nチャンネル: テックレビューアー田中\n視聴日: 2024/01/15\n\nまたは視聴履歴画面をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'spotify',
      'title': 'Spotify',
      'subtitle': '音楽・再生履歴',
      'icon': Icons.music_note,
      'description': 'Spotifyの再生履歴、お気に入りアーティスト、プレイリストを記録',
      'placeholder':
          '例：\n楽曲: 夜に駆ける\nアーティスト: YOASOBI\n再生日: 2024/01/15\n\nまたはSpotifyの再生履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'netflix',
      'title': 'Netflix',
      'subtitle': '映画・ドラマ視聴',
      'icon': Icons.movie,
      'description': 'Netflixの視聴履歴、お気に入り作品を記録',
      'placeholder':
          '例：\n作品名: ストレンジャー・シングス\nシーズン: 4\n視聴日: 2024/01/15\n\nまたはNetflixの視聴履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'abema',
      'title': 'ABEMA',
      'subtitle': 'アニメ・バラエティ・ニュース',
      'icon': Icons.tv,
      'description': 'ABEMAの視聴履歴、お気に入り番組、チャンネルを記録',
      'placeholder':
          '例：\n番組名: 今日好きになりました\nチャンネル: ABEMA SPECIAL\n視聴日: 2024/01/15\n\nまたはABEMAの視聴履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'amazon',
      'title': 'Amazon',
      'subtitle': '購入履歴・商品',
      'icon': Icons.shopping_bag,
      'description': 'Amazonでの購入履歴、お気に入り商品を記録',
      'placeholder':
          '例：\n商品名: iPhone 15 Pro\n価格: 159,800円\n購入日: 2024/01/15\n\nまたはAmazonの注文履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'receipt',
      'title': 'レシート',
      'subtitle': '店舗での購入',
      'icon': Icons.receipt,
      'description': 'コンビニ、レストラン、ショップでの購入記録',
      'placeholder':
          '例：\n店舗: セブンイレブン\n商品: おにぎり、コーヒー\n金額: 298円\n日付: 2024/01/15\n\nまたはレシートをOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'books',
      'title': '書籍・漫画',
      'subtitle': '読書履歴',
      'icon': Icons.book,
      'description': '読んだ本、漫画、電子書籍の記録',
      'placeholder':
          '例：\n書籍名: 人を動かす\n著者: デール・カーネギー\n読了日: 2024/01/15\n\nまたは読書履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'food',
      'title': '食事・グルメ',
      'subtitle': 'レストラン・料理',
      'icon': Icons.restaurant,
      'description': 'レストラン、カフェ、自炊の記録',
      'placeholder':
          '例：\n店舗名: スターバックス\nメニュー: ドリップコーヒー\n価格: 350円\n日付: 2024/01/15\n\nまたはメニューや注文履歴をOCRで読み取ったテキストをペーストしてください',
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

    if (kDebugMode) {
      Future.microtask(_debugDumpUnextSvg);
    }
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
        backgroundColor:
            isDark ? const Color(0xFF0A0A0B) : const Color(0xFFFBFBFD),
        appBar: AppBar(
          backgroundColor:
              isDark ? const Color(0xFF0A0A0B) : const Color(0xFFFBFBFD),
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
        color: isDark ? const Color(0xFF0A0A0B) : const Color(0xFFFBFBFD),
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
    final scrollableContent = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kDebugMode)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('PROBE', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),
                  Image.asset(
                    'assets/service_icons/seven_eleven.png',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 12),
                  ServiceIconRegistry.iconFor('seven_eleven', size: 28),
                  const SizedBox(width: 12),
                  ServiceIconRegistry.iconFor(
                    normalizeKey('key-seven_eleven'),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  _UnextSvgProbe(),
                  const SizedBox(width: 12),
                  ServiceIconRegistry.iconFor('unext', size: 28),
                ],
              ),
            ),
          if (kIconProbe) const IconProbeBanner(),
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

    if (!kDebugMode) {
      return scrollableContent;
    }

    return Stack(
      children: [
        scrollableContent,
        const IconDiagHUD(),
      ],
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
                ? Border.all(
                    color: const Color(0xFF9333EA).withOpacity(0.3), width: 1)
                : Border.all(
                    color: const Color(0xFF667EEA).withOpacity(0.2), width: 1),
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
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFF667EEA).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : const Color(0xFF667EEA).withOpacity(0.1),
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
                      ? const Color(0xFF4ECDC4).withOpacity(0.1)
                      : const Color(0xFF4ECDC4).withOpacity(0.1),
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
          'カテゴリ別サービス',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // 各ジャンルを縦に並べて表示
        ..._baseServiceCategories.entries.map((entry) {
          final categoryName = entry.key;
          final services = _getDisplayServicesForCategory(categoryName);

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
                        child: _buildCategoryServiceCard(
                          categoryName,
                          service,
                          isDark,
                        ),
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
          final serviceData = _connectedServices[service['id']] ??
              {
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
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.white.withOpacity(0.9),
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
  List<Map<String, dynamic>> _getDisplayServicesForCategory(
      String categoryName) {
    final base = List<Map<String, dynamic>>.from(
      _baseServiceCategories[categoryName] ?? const [],
    );
    final custom = _customServices[categoryName] ?? const [];
    final manualIndex =
        base.indexWhere((service) => service['isManualEntry'] == true);

    if (custom.isNotEmpty) {
      if (manualIndex != -1) {
        base.insertAll(
            manualIndex, custom.map((service) => {...service}).toList());
      } else {
        base.addAll(custom.map((service) => {...service}));
      }
    }

    return base;
  }

  // ジャンル別サービス用カード（実際のロゴ使用）
  Widget _buildCategoryServiceCard(
    String categoryName,
    Map<String, dynamic> service,
    bool isDark,
  ) {
    final bool isManualEntry = service['isManualEntry'] == true;
    final bool isCustom = service['isCustom'] == true;
    final String rawServiceId = service['id'] as String? ?? '';
    final String? linkedServiceId = service['linkedServiceId'] as String?;
    final String effectiveServiceId = linkedServiceId ?? rawServiceId;
    final String normalizedServiceId = normalizeKey(effectiveServiceId);
    final String resolvedServiceId = resolveAlias(normalizedServiceId);
    final bool isImplemented = isManualEntry || isCustom
        ? true
        : _isServiceImplemented(effectiveServiceId);
    final String title = service['title'] as String? ?? 'サービス';
    final String subtitle = (service['subtitle'] as String?)?.trim() ?? '';
    final IconData? iconData = service['iconData'] as IconData?;
    final Color manualIconColor =
        isDark ? Colors.white70 : const Color(0xFF94A3B8);
    final Color iconColor = isManualEntry
        ? manualIconColor
        : service['iconColor'] as Color? ??
            (isDark ? Colors.white : const Color(0xFF1A1A2E));
    final double iconSize = (service['iconSize'] as double?) ?? 31;

    Widget buildIcon() {
      if (iconData != null) {
        return Icon(iconData, size: iconSize, color: iconColor);
      }
      return ServiceIconRegistry.iconFor(resolvedServiceId, size: iconSize);
    }

    final resolvedPath = ServiceIconRegistry.pathFor(resolvedServiceId);
    final resolvedLabel =
        resolvedPath != null ? resolvedPath.split('/').last : 'MISS';

    void handleTap() {
      if (isManualEntry) {
        _showManualServiceDialog(categoryName);
        return;
      }
      if (isCustom) {
        if (linkedServiceId != null && linkedServiceId.isNotEmpty) {
          _navigateToService(
            linkedServiceId,
            displayName: title,
            categoryName: categoryName,
            serviceData: service,
          );
        } else {
          _showCustomServiceMessage(service);
        }
        return;
      }
      final targetId =
          effectiveServiceId.isEmpty ? rawServiceId : effectiveServiceId;
      _navigateToService(
        targetId,
        displayName: title,
        categoryName: categoryName,
        serviceData: service,
      );
    }

    final bool showComingSoonBadge =
        !isManualEntry && !isCustom && !isImplemented;

    final LinearGradient gradient = isManualEntry
        ? (isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1F22), Color(0xFF26272B)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF5F7FA), Color(0xFFE9ECF0)],
              ))
        : isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isImplemented
                    ? [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)]
                    : [
                        const Color(0xFF2A2A2A).withOpacity(0.6),
                        const Color(0xFF1F1F1F).withOpacity(0.6),
                      ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isImplemented
                    ? [Colors.white, const Color(0xFFFAFBFC)]
                    : [Colors.grey[100]!, const Color(0xFFF5F5F5)],
              );

    final Border border = Border.all(
      color: isManualEntry
          ? (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0))
          : isImplemented
              ? (isDark
                  ? const Color(0xFF404040).withOpacity(0.3)
                  : const Color(0xFFE2E8F0).withOpacity(0.6))
              : const Color(0xFFFFC107).withOpacity(0.3),
      width: isManualEntry
          ? 1.5
          : isImplemented
              ? 1
              : 2,
    );

    return GestureDetector(
      onTap: handleTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: showComingSoonBadge ? 0.5 : 1.0,
                    child: buildIcon(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: isManualEntry
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : showComingSoonBadge
                              ? (isDark ? Colors.grey[500] : Colors.grey[600])
                              : (isDark ? Colors.white : Colors.black87),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isManualEntry
                            ? (isDark
                                ? Colors.white70
                                : const Color(0xFF0F172A).withOpacity(0.7))
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'key=$effectiveServiceId → $resolvedServiceId  path=$resolvedLabel',
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (showComingSoonBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

  void _showCustomServiceMessage(Map<String, dynamic> service) {
    final String title = service['title'] as String? ?? 'カスタムサービス';
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title は手入力として登録済みです。対応機能の追加をお待ちください。'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<String> _getAllCategoryNames() {
    final List<String> names = List<String>.from(_baseServiceCategories.keys);
    for (final entry in _hiddenServiceCategories.entries) {
      if (!names.contains(entry.key)) {
        names.add(entry.key);
      }
    }
    return names;
  }

  List<Map<String, dynamic>> _getManualServiceOptions(String categoryName) {
    final List<Map<String, dynamic>> options = [];
    if (_baseServiceCategories.containsKey(categoryName)) {
      options.addAll(
        _baseServiceCategories[categoryName]!
            .where((service) => service['isManualEntry'] != true)
            .map((service) => {...service}),
      );
    }
    if (_hiddenServiceCategories.containsKey(categoryName)) {
      options.addAll(
        _hiddenServiceCategories[categoryName]!.map((service) => {...service}),
      );
    }
    if (_customServices.containsKey(categoryName)) {
      options.addAll(
        _customServices[categoryName]!
            .where((service) => service['isManualEntry'] != true)
            .map((service) => {...service}),
      );
    }
    return options;
  }

  void _showManualServiceDialog(String initialCategory) {
    final themeState = ref.watch(themeProviderEnhanced);
    final bool isDark = themeState.isDarkMode;
    final List<String> categories = _getAllCategoryNames();
    if (categories.isEmpty) return;

    String selectedCategory = categories.contains(initialCategory)
        ? initialCategory
        : categories.first;
    String selectedServiceId = 'custom';
    Map<String, dynamic>? selectedService;
    final TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Future<void>.delayed(Duration.zero, () {
      final options = _getManualServiceOptions(selectedCategory);
      if (options.isNotEmpty) {
        selectedService = null;
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF121215) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final options = _getManualServiceOptions(selectedCategory);

              void updateSelectedService(String value) {
                setSheetState(() {
                  selectedServiceId = value;
                  selectedService = options.firstWhere(
                      (item) => item['id'] == value,
                      orElse: () => {});
                  if (value == 'custom' || selectedService == null) {
                    selectedService = null;
                    nameController.text = nameController.text;
                  } else {
                    final preset = selectedService?['title'] as String?;
                    if (preset != null && preset.isNotEmpty) {
                      nameController.text = preset;
                    }
                  }
                });
              }

              void updateCategory(String? value) {
                if (value == null) return;
                setSheetState(() {
                  selectedCategory = value;
                  selectedServiceId = 'custom';
                  selectedService = null;
                  nameController.clear();
                });
              }

              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit_note,
                          color: isDark
                              ? const Color(0xFF4ECDC4)
                              : const Color(0xFF0EA5E9),
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'サービスを手入力で追加',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'カテゴリを選択',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      items: categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: updateCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1F1F23)
                            : const Color(0xFFF5F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '既存サービスから選択（任意）',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: options.any(
                              (option) => option['id'] == selectedServiceId)
                          ? selectedServiceId
                          : 'custom',
                      items: [
                        const DropdownMenuItem(
                          value: 'custom',
                          child: Text('リストにないサービスを手入力'),
                        ),
                        ...options.map(
                          (option) => DropdownMenuItem(
                            value: option['id'] as String,
                            child: Text(option['title'] as String? ?? ''),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        updateSelectedService(value);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1F1F23)
                            : const Color(0xFFF5F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'サービス名',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'サービス名を入力してください';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '例：SHEINホームインテリア',
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1F1F23)
                            : const Color(0xFFF5F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          final String name = nameController.text.trim();
                          final linkedId = selectedServiceId != 'custom'
                              ? selectedServiceId
                              : null;
                          final Map<String, dynamic> newEntry = {
                            'id': linkedId ??
                                'custom_${DateTime.now().millisecondsSinceEpoch}',
                            'title': name,
                            'subtitle':
                                selectedService?['subtitle'] as String? ??
                                    '手入力追加',
                            'iconData': selectedService?['iconData'],
                            'iconColor': selectedService?['iconColor'],
                            'iconSize': selectedService?['iconSize'],
                            'isCustom': true,
                            if (linkedId != null) 'linkedServiceId': linkedId,
                          };

                          setState(() {
                            final list = _customServices.putIfAbsent(
                              selectedCategory,
                              () => [],
                            );
                            list.add(newEntry);
                          });

                          Navigator.of(sheetContext).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('$name を$selectedCategoryに追加しました'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('追加する'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ECDC4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() => nameController.dispose());
  }

  // サービスが実装済みかどうかを判定
  bool _isServiceImplemented(String serviceId) {
    final implementedServices = [
      'youtube',
      'spotify',
      'youtube_music',
      'amazon',
      'rakuten',
      'yahoo_shopping',
      'mercari',
      'other_ec',
      'receipt',
      'prime_video',
      'netflix',
      'abema',
      'hulu',
      'disney',
      'unext'
    ];
    return implementedServices.contains(serviceId);
  }

  String _resolveShoppingImportType(String serviceId) {
    switch (serviceId) {
      case 'amazon':
        return 'amazon';
      case 'rakuten':
        return 'rakuten';
      case 'yahoo_shopping':
        return 'yahoo_shopping';
      case 'shein':
      case 'shein_fashion':
        return 'shein';
      case 'mercari':
        return 'other';
      case 'other_ec':
      default:
        return 'other';
    }
  }

  // API サービス用カード（実際のロゴ使用）
  Widget _buildApiServiceCard(Map<String, dynamic> service,
      Map<String, dynamic> serviceData, bool isDark) {
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
                    ? const Color(0xFF404040).withOpacity(0.3)
                    : const Color(0xFFE2E8F0).withOpacity(0.6)),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
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
              color: isConnected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF4ECDC4),
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
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : const Color(0xFF667EEA).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.white.withOpacity(0.9),
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
                      color: ServiceIcons.getService(service['id']!)
                              ?.color
                              .withOpacity(0.2) ??
                          const Color(0xFF4ECDC4).withOpacity(0.2),
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
                color: const Color(0xFF4ECDC4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFF4ECDC4), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      source == 'camera' ? 'カメラを起動します' : 'ギャラリーを開きます',
                      style: const TextStyle(
                          color: Color(0xFF4ECDC4), fontSize: 12),
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
                final services = [
                  'youtube',
                  'spotify',
                  'netflix',
                  'abema',
                  'amazon',
                  'instagram',
                  'tiktok'
                ];
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

  void _navigateToService(
    String serviceId, {
    String? displayName,
    String? categoryName,
    Map<String, dynamic>? serviceData,
  }) {
    final resolvedName = displayName ?? _getServiceDisplayName(serviceId);
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
      case 'shein':
      case 'shein_fashion':
      case 'mercari':
      case 'other_ec':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShoppingImportScreen(
              initialImportType: _resolveShoppingImportType(serviceId),
              allowTypeSwitch: serviceId == 'amazon' ? false : true,
              customServiceName: resolvedName,
            ),
          ),
        );
        break;
      case 'prime_video':
      case 'amazon_prime':
      case 'netflix':
      case 'abema':
      case 'hulu':
      case 'disney':
      case 'disney_plus':
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
        _showComingSoonDialog(serviceId, displayName: resolvedName);
        break;
    }
  }

  void _selectServiceForOCR(String serviceId) {
    _navigateToService(serviceId);
  }

  void _showComingSoonDialog(String serviceId, {String? displayName}) {
    final serviceName = displayName ?? _getServiceDisplayName(serviceId);
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
      case 'amazon_prime':
      case 'prime_video':
        return 'Amazon Prime Video';
      case 'netflix':
        return 'Netflix';
      case 'abema':
        return 'ABEMA';
      case 'hulu':
        return 'Hulu';
      case 'disney':
        return 'Disney+';
      case 'disney_plus':
        return 'Disney+';
      case 'unext':
        return 'U-NEXT';
      case 'dtv':
        return 'dTV';
      case 'fod':
        return 'FOD';
      case 'amazon':
        return 'Amazon';
      case 'rakuten':
        return '楽天市場';
      case 'yahoo_shopping':
        return 'Yahoo!ショッピング';
      case 'shein':
      case 'shein_fashion':
        return 'SHEIN';
      case 'demaecan':
        return '出前館';
      case 'restaurant':
        return 'レストラン・カフェ';
      case 'delivery':
        return 'デリバリー';
      case 'cooking':
        return '自炊';
      case 'instagram':
        return 'Instagram';
      case 'tiktok':
        return 'TikTok';
      case 'twitter':
        return 'Twitter/X';
      case 'facebook':
        return 'Facebook';
      case 'games':
        return 'ゲーム';
      case 'books':
        return '書籍・漫画';
      case 'cinema':
        return '映画館';
      case 'credit_card':
        return 'クレジットカード';
      case 'electronic_money':
        return '電子マネー';
      case 'smartphone_apps':
        return 'スマホアプリ';
      case 'app_store':
        return 'App Store';
      case 'google_play':
        return 'Google Play';
      case 'web_services':
        return 'ウェブサービス';
      case 'game_apps':
        return 'ゲームアプリ';
      case 'amazon_books':
        return 'Amazon Books';
      case 'kindle':
        return 'Kindle';
      case 'rakuten_books':
        return '楽天ブックス';
      case 'audible':
        return 'Audible';
      case 'seven_eleven':
        return 'セブン-イレブン';
      case 'family_mart':
        return 'ファミリーマート';
      case 'lawson':
        return 'ローソン';
      case 'daily_yamazaki':
        return 'デイリーヤマザキ';
      case 'ministop':
        return 'ミニストップ';
      case 'ios_screen_time':
        return 'iOSスクリーンタイム';
      case 'android_digital_wellbeing':
        return 'Android Digital Wellbeing';
      default:
        return serviceId;
    }
  }

  Color _getServiceColor(String serviceId) {
    switch (serviceId) {
      case 'amazon_prime':
      case 'prime_video':
        return const Color(0xFF00A8E1);
      case 'netflix':
        return const Color(0xFFE50914);
      case 'abema':
        return const Color(0xFF00D4AA);
      case 'hulu':
        return const Color(0xFF1CE783);
      case 'disney':
      case 'disney_plus':
        return const Color(0xFF113CCF);
      case 'unext':
        return const Color(0xFF000000);
      case 'dtv':
        return const Color(0xFFFF6B35);
      case 'fod':
        return const Color(0xFF0078D4);
      case 'amazon':
        return const Color(0xFFFF9900);
      case 'rakuten':
        return const Color(0xFFBF0000);
      case 'yahoo_shopping':
        return const Color(0xFF7B0099);
      case 'shein':
      case 'shein_fashion':
        return const Color(0xFFF54785);
      case 'demaecan':
        return const Color(0xFFFF7043);
      case 'restaurant':
        return const Color(0xFFFF5722);
      case 'delivery':
        return const Color(0xFF4CAF50);
      case 'cooking':
        return const Color(0xFFFFC107);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'games':
        return const Color(0xFF9C27B0);
      case 'books':
        return const Color(0xFF8D6E63);
      case 'cinema':
        return const Color(0xFF795548);
      case 'credit_card':
        return const Color(0xFF1976D2);
      case 'electronic_money':
        return const Color(0xFF4CAF50);
      case 'smartphone_apps':
      case 'app_store':
        return const Color(0xFF2196F3);
      case 'google_play':
        return const Color(0xFF34A853);
      case 'web_services':
        return const Color(0xFF3F51B5);
      case 'game_apps':
        return const Color(0xFFE91E63);
      case 'amazon_books':
        return const Color(0xFFFF9900);
      case 'kindle':
        return const Color(0xFF2F2F2F);
      case 'rakuten_books':
        return const Color(0xFFBF0000);
      case 'audible':
        return const Color(0xFFFF6B6B);
      case 'seven_eleven':
        return const Color(0xFFF58220);
      case 'family_mart':
        return const Color(0xFF1BA548);
      case 'lawson':
        return const Color(0xFF0078C8);
      case 'daily_yamazaki':
        return const Color(0xFFD6001C);
      case 'ministop':
        return const Color(0xFF005BAC);
      case 'ios_screen_time':
        return const Color(0xFF0A84FF);
      case 'android_digital_wellbeing':
        return const Color(0xFF34A853);
      default:
        return const Color(0xFF4ECDC4);
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
          final serviceData = _connectedServices[service['id']] ??
              {
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
                border: Border.all(
                    color: isDark
                        ? const Color(0xFF333333)
                        : const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(item['status'] as String)
                          .withOpacity(0.2),
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
        content: Text(
            '${ServiceIcons.getService(serviceId)?.name ?? serviceId}との連携を開始します'),
        backgroundColor: ServiceIcons.getService(serviceId)?.color ??
            const Color(0xFF4ECDC4),
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
                          color: (isDark ? Colors.black : Colors.black)
                              .withOpacity(0.2),
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
                        color: const Color(0xFF4ECDC4).withOpacity(0.4),
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
                    const Color(0xFF4ECDC4).withOpacity(0.15),
                    const Color(0xFF44A08D).withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.1),
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
                      color: const Color(0xFF4ECDC4).withOpacity(0.2),
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
                    color:
                        (isDark ? Colors.black : Colors.black).withOpacity(0.2),
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
                          color:
                              (isDark ? Colors.grey[700]! : Colors.grey[300]!)
                                  .withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final clipboardData =
                            await Clipboard.getData('text/plain');
                        if (clipboardData?.text != null) {
                          _textController.text = clipboardData!.text!;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? Colors.grey[700] : Colors.grey[200],
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
                          color: const Color(0xFF4ECDC4).withOpacity(0.4),
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
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
                      color: Colors.white.withOpacity(0.2),
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
                    icon: const Icon(Icons.close,
                        color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
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
                        MaterialPageRoute(
                            builder: (context) => const StarDashboardScreen()),
                      );
                    });
                  }),
                  _buildDrawerItem(Icons.workspace_premium, 'プランを管理', false,
                      () {
                    Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubscriptionPlansScreen()),
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

  Widget _buildDrawerItem(
      IconData icon, String title, bool isActive, VoidCallback onTap) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive ? const Color(0xFF4ECDC4).withOpacity(0.15) : null,
        border: isActive
            ? Border.all(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                width: 1,
              )
            : null,
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
        trailing: isActive
            ? const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF4ECDC4),
                size: 14,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Future<void> _debugDumpUnextSvg() async {
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      debugPrint(
        '[U-NEXT] in manifest: '
        '${manifest.contains('"assets/service_icons/unext.svg"')}',
      );
      final xml = await rootBundle.loadString('assets/service_icons/unext.svg');
      final head = xml.length > 240 ? xml.substring(0, 240) : xml;
      debugPrint('[U-NEXT] SVG head: $head');
    } catch (error, stack) {
      debugPrint('[U-NEXT] SVG load error: $error');
      debugPrint(stack.toString());
    }
  }
}

class _UnextSvgProbe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.16),
        border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _SvgSample(),
          SizedBox(height: 4),
          Text('SvgPicture', style: TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}

class _SvgSample extends StatelessWidget {
  const _SvgSample();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/service_icons/unext.svg',
      width: 40,
      height: 24,
      allowDrawingOutsideViewBox: true,
      colorFilter: const ColorFilter.mode(Color(0xFF00AEEF), BlendMode.srcIn),
      placeholderBuilder: (_) => const Icon(Icons.image_not_supported, size: 18),
    );
  }
}
