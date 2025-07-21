import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../models/gacha_models_simple.dart';
import '../widgets/gacha_machine_widget.dart';
import '../services/gacha_sound_service.dart';
import 'providers/gacha_providers.dart';

/// ガチャメイン画面
class GachaScreen extends ConsumerWidget {
  const GachaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gachaState = ref.watch(gachaViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ガチャ'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー部分
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: Colors.amber,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'ガチャを引いて\nスターポイントやチケットをゲット！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // メインコンテンツエリア
              Expanded(
                child: gachaState.when(
                  initial: () => _buildInitialContent(context, ref),
                  loading: () => _buildLoadingContent(),
                  success: (result) => _buildSuccessContent(context, ref, result),
                  error: (message) => _buildErrorContent(context, ref, message),
                ),
              ),

              // 底部のガチャボタン
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildGachaButton(context, ref, gachaState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 初期状態のコンテンツ
  Widget _buildInitialContent(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 待機状態のガチャマシン
          GachaMachineWidget(
            isActive: false,
          ),
          const SizedBox(height: 24),
          const Text(
            'ガチャを引く準備ができました',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// ローディング中のコンテンツ（ガチャポンマシンアニメーション）
  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ガチャポンマシンアニメーション
          GachaMachineWidget(
            isActive: true,
            onAnimationComplete: () {
              // アニメーション完了後の処理は既存の状態管理で行う
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'ガチャを実行中...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 成功時のコンテンツ
  Widget _buildSuccessContent(BuildContext context, WidgetRef ref, GachaResult result) {
    // 結果表示後、自動的にダイアログを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showResultDialog(context, ref, result);
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            size: 120,
            color: Colors.amber,
          ),
          const SizedBox(height: 24),
          const Text(
            'ガチャ完了！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 12),
          _buildResultPreview(result),
        ],
      ),
    );
  }

  /// エラー時のコンテンツ
  Widget _buildErrorContent(BuildContext context, WidgetRef ref, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 120,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          const Text(
            'エラーが発生しました',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// ガチャボタン
  Widget _buildGachaButton(BuildContext context, WidgetRef ref, GachaState state) {
    bool isLoading = false;
    state.when(
      initial: () => isLoading = false,
      loading: () => isLoading = true,
      success: (_) => isLoading = false,
      error: (_) => isLoading = false,
    );
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading 
          ? null 
          : () async {
              // 音効果とハプティックフィードバックを再生
              await GachaSoundService().playLeverPull();
              // ガチャ実行
              ref.read(gachaViewModelProvider.notifier).draw();
            },
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: isLoading ? 0 : 4,
        ),
        child: isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '実行中...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.casino, size: 24),
                SizedBox(width: 8),
                Text(
                  'ガチャを引く',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
      ),
    );
  }

  /// 結果のプレビュー表示
  Widget _buildResultPreview(GachaResult result) {
    return result.when(
      point: (amount) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          '$amount スターポイント獲得！',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      ticket: (ticketType, displayName, color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          '$displayName獲得！',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  /// 結果表示ダイアログ
  void _showResultDialog(BuildContext context, WidgetRef ref, GachaResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アイコン表示
            result.when(
              point: (amount) => const Icon(
                Icons.stars,
                size: 64,
                color: Colors.blue,
              ),
              ticket: (ticketType, displayName, color) => Icon(
                Icons.card_giftcard,
                size: 64,
                color: color,
              ),
            ),
            const SizedBox(height: 16),

            // 結果テキスト
            const Text(
              '獲得アイテム',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            result.when(
              point: (amount) => Text(
                '$amount スターポイント',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              ticket: (ticketType, displayName, color) => Text(
                displayName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 閉じるボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(gachaViewModelProvider.notifier).reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}