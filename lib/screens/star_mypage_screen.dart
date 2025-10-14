import 'package:flutter/material.dart';
import '../features/profile/screens/profile_edit_screen.dart';
import '../features/app/screens/settings_screen.dart';

class StarMyPageScreen extends StatelessWidget {
  const StarMyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
    final accentColor = isDarkMode ? Colors.blue : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'スターアカウント',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プロフィールセクション
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                    child: const Icon(
                      Icons.star,
                      size: 40,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'スター名',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ミュージシャン',
                          style: TextStyle(
                            fontSize: 16,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'フォロワー: 12,345',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileEditScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('プロフィールを編集'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
            
            // SNS認証セクション
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'アカウント認証',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '以下のSNSアカウントと連携して本人確認を行います。\n認証済みの場合はバッジが表示されます。',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSocialAuthItem(
                    context: context,
                    icon: Icons.alternate_email,
                    platform: 'X (Twitter)',
                    isVerified: true,
                    username: '@star_account',
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 12),
                  _buildSocialAuthItem(
                    context: context,
                    icon: Icons.photo_camera,
                    platform: 'Instagram',
                    isVerified: true,
                    username: '@star_official',
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 12),
                  _buildSocialAuthItem(
                    context: context,
                    icon: Icons.music_note,
                    platform: 'TikTok',
                    isVerified: false,
                    username: '未連携',
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                    cardColor: cardColor,
                  ),
                ],
              ),
            ),
            
            Divider(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
            
            // アクティビティセクション
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'アクティビティ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      context: context,
                      title: '投稿',
                      value: '32',
                      icon: Icons.post_add,
                      cardColor: cardColor,
                      textColor: textColor,
                      iconColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatsCard(
                      context: context,
                      title: 'ファン',
                      value: '1.2k',
                      icon: Icons.people,
                      cardColor: cardColor,
                      textColor: textColor,
                      iconColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatsCard(
                      context: context,
                      title: '収入',
                      value: '¥25k',
                      icon: Icons.monetization_on,
                      cardColor: cardColor,
                      textColor: textColor,
                      iconColor: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300, height: 32),
            
            // コンテンツ管理
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'コンテンツ管理',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildMenuTile(
                    context: context,
                    title: '投稿の作成・管理',
                    icon: Icons.post_add,
                    iconColor: Colors.blue,
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                  ),
                  _buildMenuTile(
                    context: context,
                    title: 'コンテンツ販売',
                    icon: Icons.shopping_bag,
                    iconColor: Colors.purple,
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                  ),
                  _buildMenuTile(
                    context: context,
                    title: 'ライブ配信',
                    icon: Icons.live_tv,
                    iconColor: Colors.red,
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                  ),
                  _buildMenuTile(
                    context: context,
                    title: 'ファンメッセージ',
                    icon: Icons.message,
                    iconColor: Colors.green,
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSocialAuthItem({
    required BuildContext context,
    required IconData icon,
    required String platform,
    required bool isVerified,
    required String username,
    required Color backgroundColor,
    required Color textColor,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  username,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          isVerified
              ? const Icon(Icons.verified, color: Colors.blue)
              : ElevatedButton(
                  onPressed: () {
                    // 連携処理
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('連携する'),
                ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: textColor.withOpacity(0.5)),
      onTap: () {
        // タップ処理
      },
    );
  }
} 