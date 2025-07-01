import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/core/components/service_icons.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../providers/user_provider.dart';
import '../../star/screens/star_dashboard_screen.dart';
import '../../subscription/screens/plan_management_screen.dart';
import '../../app/screens/settings_screen.dart';
import 'youtube_import_screen.dart';
import 'music_import_screen.dart';
import 'shopping_import_screen.dart';
import 'receipt_import_screen.dart';
import 'app_usage_import_screen.dart';

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

  // データカテゴリ（統一されたサービスアイコンを使用）
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
      'id': 'other_sns',
      'title': 'その他SNS',
      'subtitle': 'X・Instagram等',
      'icon': Icons.share,
      'description': 'X(Twitter)、Instagram、TikTok等のSNSデータを記録',
      'placeholder': '例：\n投稿内容: 今日のランチ\nプラットフォーム: Instagram\nいいね数: 25\n投稿日: 2024/01/15\n\nまたはSNSの投稿履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'other_video',
      'title': 'その他動画',
      'subtitle': 'Twitch・Vimeo等',
      'icon': Icons.play_circle,
      'description': 'Twitch、Vimeo、ニコニコ動画等の視聴履歴を記録',
      'placeholder': '例：\n動画タイトル: ゲーム実況配信\nプラットフォーム: Twitch\n配信者: StreamerABC\n視聴時間: 2時間\n視聴日: 2024/01/15\n\nまたは動画プラットフォームの視聴履歴をOCRで読み取ったテキストをペーストしてください',
    },
    {
      'id': 'other_shopping',
      'title': 'その他Shopping',
      'subtitle': '楽天・Yahoo等',
      'icon': Icons.shopping_cart,
      'description': '楽天、Yahoo!ショッピング、メルカリ等での購入履歴を記録',
      'placeholder': '例：\n商品名: ワイヤレスイヤホン\nショップ: 楽天市場\n価格: 8,980円\n購入日: 2024/01/15\n\nまたはショッピングサイトの購入履歴をOCRで読み取ったテキストをペーストしてください',
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
          title: Text(
            'データ取り込み',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
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
          // メインサービス（6種類）
          _buildMainServicesSection(),
          const SizedBox(height: 24),
          
          // メインOCR機能
          _buildOCRMainSection(),
          const SizedBox(height: 24),
          
          // 取込み履歴
          _buildImportHistorySection(),
          const SizedBox(height: 24),
          
          // データソース管理
          _buildDataSourcesSection(),
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
                ? Border.all(color: const Color(0xFF9333EA).withValues(alpha: 0.3), width: 1)
                : Border.all(color: const Color(0xFF667EEA).withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? const Color(0xFF667EEA).withValues(alpha: 0.25) 
                    : const Color(0xFF667EEA).withValues(alpha: 0.15),
                blurRadius: 32,
                offset: const Offset(0, 16),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: isDark 
                    ? Colors.black.withValues(alpha: 0.3) 
                    : Colors.white.withValues(alpha: 0.8),
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
                      ? Colors.white.withValues(alpha: 0.15) 
                      : const Color(0xFF667EEA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.2) 
                        : const Color(0xFF667EEA).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withValues(alpha: 0.3) 
                          : const Color(0xFF667EEA).withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: isDark ? Colors.white : const Color(0xFF667EEA),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'スクリーンショットを取込む',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'カメラで撮影またはギャラリーから選択',
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                                ? Colors.black.withValues(alpha: 0.3) 
                                : const Color(0xFF667EEA).withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _startOCRCapture('camera'),
                        icon: const Icon(Icons.camera_alt_rounded, size: 22),
                        label: const Text('カメラ', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark 
                              ? Colors.white 
                              : const Color(0xFF667EEA),
                          foregroundColor: isDark 
                              ? const Color(0xFF667EEA) 
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                                ? Colors.black.withValues(alpha: 0.3) 
                                : const Color(0xFF667EEA).withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _startOCRCapture('gallery'),
                        icon: const Icon(Icons.photo_library_rounded, size: 22),
                        label: const Text('ギャラリー', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark 
                              ? Colors.white.withValues(alpha: 0.1) 
                              : Colors.white,
                          foregroundColor: isDark 
                              ? Colors.white 
                              : const Color(0xFF667EEA),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark 
                                  ? Colors.white.withValues(alpha: 0.3) 
                                  : const Color(0xFF667EEA).withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainServicesSection() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    // メインサービス6種類
    final mainServices = [
      {'id': 'youtube', 'name': 'YouTube', 'description': '動画・チャンネル情報'},
      {'id': 'spotify', 'name': 'Spotify', 'description': '音楽・プレイリスト'},
      {'id': 'netflix', 'name': 'Netflix', 'description': '映画・ドラマ'},
      {'id': 'receipt', 'name': 'レシート', 'description': '食事・購入記録'},
      {'id': 'app_usage', 'name': 'アプリ', 'description': 'スクリーンタイム'},
      {'id': 'amazon', 'name': 'Amazon', 'description': '商品・購入履歴'},
    ];
    
    // その他カテゴリー3種類
    final otherServices = [
      {'id': 'other_sns', 'name': 'その他SNS', 'description': 'X・Instagram等'},
      {'id': 'other_video', 'name': 'その他動画', 'description': 'Twitch・Vimeo等'},
      {'id': 'other_shopping', 'name': 'その他Shopping', 'description': '楽天・Yahoo等'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'サービス別取込み',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _showAllServices(),
              child: const Text(
                'すべて見る',
                style: TextStyle(color: Color(0xFF4ECDC4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // メインサービスグリッド
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: mainServices.length,
          itemBuilder: (context, index) {
            final service = mainServices[index];
            return _buildServiceCard(service);
          },
        ),
        
        const SizedBox(height: 24),
        
        // その他カテゴリーセクション
        Text(
          'その他のサービス',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // その他サービス - 横並び特別レイアウト
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: otherServices.length,
            itemBuilder: (context, index) {
              final service = otherServices[index];
              return Container(
                width: 120,
                margin: EdgeInsets.only(right: index < otherServices.length - 1 ? 12 : 0),
                child: _buildOtherServiceCard(service),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOtherServiceCard(Map<String, dynamic> service) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    
    return GestureDetector(
      onTap: () => _selectServiceForOCR(service['id']),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [
                    const Color(0xFF2A2A2A),
                    const Color(0xFF1F1F1F),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF8F9FA),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark 
                ? const Color(0xFF404040) 
                : const Color(0xFFE1E5E9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.3) 
                  : const Color(0xFF64748B).withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: _getOtherServiceGradient(service['id']),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: _getOtherServiceColor(service['id']).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getOtherServiceIcon(service['id']),
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                service['name'],
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                service['description'],
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getOtherServiceGradient(String serviceId) {
    switch (serviceId) {
      case 'other_sns':
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
        );
      case 'other_video':
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
        );
      case 'other_shopping':
        return const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF6B7280), Color(0xFF9CA3AF)],
        );
    }
  }

  Color _getOtherServiceColor(String serviceId) {
    switch (serviceId) {
      case 'other_sns':
        return const Color(0xFF8B5CF6);
      case 'other_video':
        return const Color(0xFFEF4444);
      case 'other_shopping':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getOtherServiceIcon(String serviceId) {
    switch (serviceId) {
      case 'other_sns':
        return Icons.share;
      case 'other_video':
        return Icons.play_circle;
      case 'other_shopping':
        return Icons.shopping_cart;
      default:
        return Icons.category;
    }
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
                  ? Colors.black.withValues(alpha: 0.4) 
                  : const Color(0xFF667EEA).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.03) 
                  : Colors.white.withValues(alpha: 0.9),
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
                      color: ServiceIcons.getService(service['id']!)?.color.withValues(alpha: 0.2) ?? const Color(0xFF4ECDC4).withValues(alpha: 0.2),
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
                color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
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
                final services = ['youtube', 'spotify', 'netflix', 'amazon', 'instagram', 'tiktok'];
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

  void _selectServiceForOCR(String serviceId) {
    // 各サービス専用画面に遷移
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
      case 'netflix':
        // 音楽・動画系は音楽取り込み画面へ
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MusicImportScreen(),
          ),
        );
        break;
      case 'amazon':
      case 'rakuten':
      case 'yahoo':
        // ショッピング系はショッピング取り込み画面へ
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShoppingImportScreen(),
          ),
        );
        break;
      case 'receipt':
        // レシート取り込み画面へ
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReceiptImportScreen(),
          ),
        );
        break;
      case 'app_usage':
        // アプリ使用履歴取り込み画面へ
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AppUsageImportScreen(),
          ),
        );
        break;
      case 'instagram':
      case 'tiktok':
      case 'other_sns':
      case 'other_video':
      case 'other_shopping':
      case 'other':
      default:
        // その他のカテゴリは汎用入力画面を表示
        setState(() {
          selectedCategory = serviceId;
          showProcessingResults = false;
        });
        _animationController.forward();
        break;
    }
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
        }).toList(),
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
                  color: _getStatusColor(item['status'] as String).withValues(alpha: 0.2),
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
        )).toList(),
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
                          color: (isDark ? Colors.black : Colors.black).withValues(alpha: 0.2),
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
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.4),
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
                    const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                    const Color(0xFF44A08D).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
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
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
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
                    color: (isDark ? Colors.black : Colors.black).withValues(alpha: 0.2),
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
                          color: (isDark ? Colors.grey[700]! : Colors.grey[300]!).withValues(alpha: 0.3),
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
                          color: const Color(0xFF4ECDC4).withValues(alpha: 0.4),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4ECDC4),
                  const Color(0xFF44A08D),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
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
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
                _buildDrawerItem(Icons.search, '検索', false, () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
                _buildDrawerItem(Icons.star, 'マイリスト', false, () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
                // スターのみ表示
                if (currentUser.isStar) ...[
                  _buildDrawerItem(Icons.camera_alt, 'データ取込み', true, () {
                    Navigator.pop(context);
                  }),
                  _buildDrawerItem(Icons.analytics, 'スターダッシュボード', false, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StarDashboardScreen()),
                    );
                  }),
                  _buildDrawerItem(Icons.workspace_premium, 'プランを管理', false, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PlanManagementScreen()),
                    );
                  }),
                ],
                _buildDrawerItem(Icons.person, 'マイページ', false, () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
                _buildDrawerItem(Icons.settings, '設定', false, () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
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
        color: isActive ? const Color(0xFF4ECDC4).withValues(alpha: 0.15) : null,
        border: isActive ? Border.all(
          color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
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