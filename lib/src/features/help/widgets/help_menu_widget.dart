import 'package:flutter/material.dart';
import '../screens/help_center_screen.dart';
import '../screens/privacy_screen.dart';

class HelpMenuWidget extends StatelessWidget {
  const HelpMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.help_outline),
      tooltip: 'ヘルプ',
      onSelected: (String value) {
        switch (value) {
          case 'help_center':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
            );
            break;
          case 'privacy':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyScreen()),
            );
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'help_center',
          child: Row(
            children: [
              Icon(Icons.help_center, color: Colors.blue),
              SizedBox(width: 12),
              Text('ヘルプセンター'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'privacy',
          child: Row(
            children: [
              Icon(Icons.privacy_tip, color: Colors.green),
              SizedBox(width: 12),
              Text('プライバシー'),
            ],
          ),
        ),
      ],
    );
  }
}

// サイドバー用のヘルプセクション
class SidebarHelpSection extends StatelessWidget {
  const SidebarHelpSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.help_outline),
      title: const Text('ヘルプ'),
      children: [
        ListTile(
          leading: const Icon(Icons.help_center, color: Colors.blue),
          title: const Text('ヘルプセンター'),
          onTap: () {
            Navigator.pop(context); // サイドバーを閉じる
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip, color: Colors.green),
          title: const Text('プライバシー'),
          onTap: () {
            Navigator.pop(context); // サイドバーを閉じる
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyScreen()),
            );
          },
        ),
      ],
    );
  }
}
