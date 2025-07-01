import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StarlistHomeScreen extends ConsumerStatefulWidget {
  const StarlistHomeScreen({super.key});

  @override
  ConsumerState<StarlistHomeScreen> createState() => _StarlistHomeScreenState();
}

class _StarlistHomeScreenState extends ConsumerState<StarlistHomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTabIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: _buildSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(
                Icons.menu,
                color: Color(0xFF6B7280),
                size: 24,
              ),
            ),
            const Expanded(
              child: Text(
                'ホーム',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF6B7280),
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF6B7280),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F1F1), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Starlist',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF6B7280),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSidebarItem(Icons.home, 'ホーム', 0),
                  _buildSidebarItem(Icons.search, '検索', 1),
                  _buildSidebarItem(Icons.people, 'フォロー中', 2),
                  _buildSidebarItem(Icons.star, 'マイリスト', 3),
                  _buildSidebarItem(Icons.camera_alt, 'データ取込み', 4),
                  _buildSidebarItem(Icons.pie_chart, 'スターダッシュボード', 5),
                  _buildSidebarItem(Icons.person, 'マイページ', 6),
                  _buildSidebarItem(Icons.workspace_premium, 'プランを管理', 7),
                  _buildSidebarItem(Icons.settings, '設定', 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE5F2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF6B7280),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF333333),
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecommendedStarsSection(),
          const SizedBox(height: 32),
          _buildPopularStarsSection(),
          const SizedBox(height: 32),
          _buildGenreStarsSection(),
        ],
      ),
    );
  }

  Widget _buildRecommendedStarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'おすすめのスター',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedStars.length,
            itemBuilder: (context, index) {
              final star = _recommendedStars[index];
              return Container(
                width: 120,
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : 12,
                  right: index == _recommendedStars.length - 1 ? 0 : 0,
                ),
                child: _buildStarCard(star),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularStarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '人気のスター',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_popularStars.length, (index) {
          final star = _popularStars[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildPopularStarItem(star, index + 1),
          );
        }),
      ],
    );
  }

  Widget _buildGenreStarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ジャンル別おすすめスター',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        ..._genreStars.map((genre) => _buildGenreSection(genre)),
      ],
    );
  }

  Widget _buildStarCard(StarData star) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: star.gradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                star.icon,
                color: star.iconColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            star.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            star.category,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF8E8E93),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: star.isFollowing 
                        ? const Color(0xFFE9E9EB) 
                        : const Color(0xFF007AFF),
                    foregroundColor: star.isFollowing 
                        ? const Color(0xFF007AFF) 
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    minimumSize: const Size(0, 28),
                  ),
                  child: Text(
                    star.isFollowing ? 'フォロー中' : 'フォロー',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularStarItem(StarData star, int rank) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: rank == 1 ? 20 : rank == 2 ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: rank == 1 
                    ? const Color(0xFFF59E0B)
                    : rank == 2 
                        ? const Color(0xFF6B7280)
                        : const Color(0xFFF97316),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: star.gradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                star.icon,
                color: star.iconColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  star.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  star.followers,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: star.isFollowing 
                  ? const Color(0xFFE9E9EB) 
                  : const Color(0xFF007AFF),
              foregroundColor: star.isFollowing 
                  ? const Color(0xFF007AFF) 
                  : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: Text(
              star.isFollowing ? 'フォロー中' : 'フォロー',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreSection(GenreData genre) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            genre.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: genre.stars.length,
              itemBuilder: (context, index) {
                final star = genre.stars[index];
                return Container(
                  width: 120,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 12,
                    right: index == genre.stars.length - 1 ? 0 : 0,
                  ),
                  child: _buildStarCard(star),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// データモデル
class StarData {
  final String name;
  final String category;
  final String followers;
  final IconData icon;
  final Color iconColor;
  final LinearGradient gradient;
  final bool isFollowing;

  StarData({
    required this.name,
    required this.category,
    required this.followers,
    required this.icon,
    required this.iconColor,
    required this.gradient,
    this.isFollowing = false,
  });
}

class GenreData {
  final String name;
  final List<StarData> stars;

  GenreData({
    required this.name,
    required this.stars,
  });
}

// サンプルデータ
final List<StarData> _recommendedStars = [
  StarData(
    name: 'Hikakin (ヒカキン)',
    category: 'トップYouTuber',
    followers: '1.2M',
    icon: Icons.play_circle_filled,
    iconColor: const Color(0xFFEF4444),
    gradient: const LinearGradient(
      colors: [Color(0xFFEF4444), Color(0xFFE11D48)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  StarData(
    name: '渡辺直美',
    category: 'インフルエンサー',
    followers: '890K',
    icon: Icons.camera_alt,
    iconColor: const Color(0xFFEC4899),
    gradient: const LinearGradient(
      colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  StarData(
    name: '有吉弘行',
    category: 'タレント',
    followers: '650K',
    icon: Icons.person,
    iconColor: const Color(0xFF3B82F6),
    gradient: const LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF0EA5E9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    isFollowing: true,
  ),
  StarData(
    name: '米津玄師',
    category: 'ミュージシャン',
    followers: '2.1M',
    icon: Icons.music_note,
    iconColor: const Color(0xFF10B981),
    gradient: const LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
];

final List<StarData> _popularStars = [
  StarData(
    name: '田中 太郎',
    category: 'YouTuber',
    followers: '24.5万フォロワー',
    icon: Icons.play_circle_filled,
    iconColor: const Color(0xFF6366F1),
    gradient: const LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  StarData(
    name: '佐藤 花子',
    category: 'インフルエンサー',
    followers: '18.3万フォロワー',
    icon: Icons.camera_alt,
    iconColor: const Color(0xFF10B981),
    gradient: const LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    isFollowing: true,
  ),
  StarData(
    name: '鈴木 次郎',
    category: 'ミュージシャン',
    followers: '9.7万フォロワー',
    icon: Icons.music_note,
    iconColor: const Color(0xFFEF4444),
    gradient: const LinearGradient(
      colors: [Color(0xFFEF4444), Color(0xFFE11D48)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
];

final List<GenreData> _genreStars = [
  GenreData(
    name: '俳優',
    stars: [
      StarData(
        name: '俳優 男性 A',
        category: '実力派',
        followers: '500K',
        icon: Icons.person,
        iconColor: const Color(0xFF3B82F6),
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      StarData(
        name: '俳優 男性 B',
        category: '若手注目株',
        followers: '320K',
        icon: Icons.person_outline,
        iconColor: const Color(0xFF6366F1),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ],
  ),
  GenreData(
    name: '歌手',
    stars: [
      StarData(
        name: '歌手 男性 A',
        category: 'シンガー',
        followers: '800K',
        icon: Icons.mic,
        iconColor: const Color(0xFF10B981),
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      StarData(
        name: '歌手 女性 A',
        category: 'アイドル',
        followers: '1.2M',
        icon: Icons.music_note,
        iconColor: const Color(0xFFEC4899),
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ],
  ),
]; 