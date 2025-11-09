import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/birthday_models.dart';

/// 誕生日設定カードウィジェット
class BirthdaySettingCard extends ConsumerWidget {
  final BirthdayNotificationSetting setting;
  final Function(BirthdayNotificationSetting) onSettingChanged;

  const BirthdaySettingCard({
    super.key,
    required this.setting,
    required this.onSettingChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          // スター情報とメイン通知トグル
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity( 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF4ECDC4),
                size: 20,
              ),
            ),
            title: Text(
              'スター ID: ${setting.starId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              setting.customMessage ?? 'デフォルトメッセージ',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Switch(
              value: setting.notificationEnabled,
              onChanged: (value) {
                onSettingChanged(setting.copyWith(
                  notificationEnabled: value,
                  updatedAt: DateTime.now(),
                ));
              },
              thumbColor: WidgetStateProperty.resolveWith<Color?>(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFF4ECDC4)
                    : null,
              ),
            ),
          ),
          
          // 詳細設定（通知が有効な場合のみ表示）
          if (setting.notificationEnabled) ...[
            const Divider(color: Color(0xFF333333), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 事前通知日数設定
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Color(0xFF4ECDC4),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '事前通知',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DropdownButton<int>(
                        value: setting.notificationDaysBefore,
                        dropdownColor: const Color(0xFF2A2A2A),
                        style: const TextStyle(color: Colors.white),
                        underline: Container(),
                        items: [0, 1, 3, 7, 14].map((days) {
                          return DropdownMenuItem<int>(
                            value: days,
                            child: Text(
                              days == 0 ? '当日' : '$days日前',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onSettingChanged(setting.copyWith(
                              notificationDaysBefore: value,
                              updatedAt: DateTime.now(),
                            ));
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // カスタムメッセージ設定
                  Row(
                    children: [
                      const Icon(
                        Icons.message,
                        color: Color(0xFF4ECDC4),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'カスタムメッセージ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showCustomMessageDialog(context),
                        icon: const Icon(
                          Icons.edit,
                          color: Color(0xFF4ECDC4),
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// カスタムメッセージ編集ダイアログ
  void _showCustomMessageDialog(BuildContext context) {
    final controller = TextEditingController(text: setting.customMessage ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'カスタムメッセージ',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '誕生日メッセージを入力...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4ECDC4)),
            ),
          ),
          maxLines: 3,
          maxLength: 200,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              onSettingChanged(setting.copyWith(
                customMessage: controller.text.trim().isEmpty ? null : controller.text.trim(),
                updatedAt: DateTime.now(),
              ));
              Navigator.pop(context);
            },
            child: const Text(
              '保存',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );
  }
}
