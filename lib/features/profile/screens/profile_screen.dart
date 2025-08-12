import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_provider.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
// import '../../../src/widgets/profile_header.dart';
import '../../../data/test_accounts_data.dart';
import '../../star/screens/generic_star_detail_page.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    if (currentUser.id.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('ログアウトしました。ログインしてください。'),
        ),
      );
    }

    final Map<String, dynamic> userProfile = {
      'name': currentUser.name,
      'username': '@${currentUser.email.split('@')[0]}',
      'email': currentUser.email,
      'bio': 'Starlistを楽しんでいます！',
      'joinDate': '2023年8月',
      'avatar': null,
      'isVerified': currentUser.isVerified,
      'location': '東京都',
      'website': 'https://starlist.com',
    };
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      body: DefaultTabController(
        length: 5,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit, color: isDark ? Colors.white : Colors.black87),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
                      );
                    },
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(child: Text(userProfile['name'], style: TextStyle(fontSize: 24, color: isDark ? Colors.white : Colors.black))),
                ),
                bottom: TabBar(
                  isScrollable: true,
                  indicatorColor: const Color(0xFF4ECDC4),
                  labelColor: const Color(0xFF4ECDC4),
                  unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
                  tabs: const [
                    Tab(text: 'フォロー中'),
                    Tab(text: 'お気に入り'),
                    Tab(text: 'プレイリスト'),
                    Tab(text: '保存済み'),
                    Tab(text: 'アクティビティ'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildFollowingTab(context, isDark),
              _buildFavoritesTab(context, isDark),
              _buildPlaylistsTab(context, isDark),
              _buildSavedTab(context, isDark),
              Container(), // アクティビティタブ
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowingTab(BuildContext context, bool isDark) {
    // Implement following tab UI
    return const Center(child: Text("フォロー中"));
  }

  Widget _buildFavoritesTab(BuildContext context, bool isDark) {
    // Implement favorites tab UI
    return const Center(child: Text("お気に入り"));
  }

  Widget _buildPlaylistsTab(BuildContext context, bool isDark) {
    // Implement playlists tab UI
    return const Center(child: Text("プレイリスト"));
  }

  Widget _buildSavedTab(BuildContext context, bool isDark) {
    // Implement saved tab UI
    return const Center(child: Text("保存済み"));
  }
} 