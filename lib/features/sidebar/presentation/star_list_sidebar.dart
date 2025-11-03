import 'package:flutter/material.dart';

class StarListSidebar extends StatelessWidget {
  const StarListSidebar({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildSidebarItem(context, Icons.home, 'ホーム', 0),
                  _buildSidebarItem(context, Icons.search, '検索', 1),
                  _buildSidebarItem(context, Icons.people, 'フォロー中', 2),
                  _buildSidebarItem(context, Icons.star, 'マイリスト', 3),
                  _buildSidebarItem(context, Icons.camera_alt, 'データ取込み', 4),
                  _buildSidebarItem(context, Icons.pie_chart, 'スターダッシュボード', 5),
                  _buildSidebarItem(context, Icons.person, 'マイページ', 6),
                  _buildSidebarItem(context, Icons.workspace_premium, 'プランを管理', 7),
                  _buildSidebarItem(context, Icons.settings, '設定', 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
      BuildContext context, IconData icon, String title, int index) {
    final isSelected = false; // 選択状態は親ウィジェットから受け取るように変更
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
          // タップ時の処理は親ウィジェットに委譲
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
