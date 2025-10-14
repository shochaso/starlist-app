import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider_enhanced.dart';
import 'theme_mode_switcher.dart';

/// テーマテスト画面
class ThemeTestScreen extends ConsumerWidget {
  const ThemeTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProviderEnhanced);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('テーマテスト'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // テーマ状態表示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'テーマ状態',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('現在のモード: ${themeState.themeMode.displayName}'),
                    Text('ダークモード: ${themeState.isDarkMode ? "有効" : "無効"}'),
                    Text('システムダークモード: ${themeState.isSystemDarkMode ? "有効" : "無効"}'),
                    Text('読み込み中: ${themeState.isLoading ? "はい" : "いいえ"}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // テーマ切り替えコントロール
            const ThemeSettingsCard(
              title: 'テーマ切り替え',
              subtitle: '好みのテーマを選択してください',
            ),
            
            const SizedBox(height: 16),
            
            // シンプルな切り替えボタン
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'クイック切り替え',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ref.read(themeActionProvider).setLight();
                          },
                          child: const Text('ライト'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(themeActionProvider).setDark();
                          },
                          child: const Text('ダーク'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(themeActionProvider).setSystem();
                          },
                          child: const Text('システム'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: ThemeToggleButton(size: 32),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // カラーテスト
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'カラーテスト',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ColorChip(
                          label: 'Primary',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        _ColorChip(
                          label: 'Secondary',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        _ColorChip(
                          label: 'Surface',
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        _ColorChip(
                          label: 'Background',
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}