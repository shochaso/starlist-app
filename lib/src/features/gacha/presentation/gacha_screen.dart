import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../models/gacha_models_simple.dart';
import '../widgets/gacha_machine_widget.dart';
import '../services/gacha_sound_service.dart';
import 'providers/gacha_providers.dart';
import '../../../features/voting/providers/voting_providers.dart';
import '../../../../providers/user_provider.dart';
import '../../voting/widgets/star_point_balance_widget.dart';

/// ガチャメイン画面
class GachaScreen extends ConsumerWidget {
  const GachaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ガチャ'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      // body部分を別のウィジェットとして呼び出す
      body: const _GachaView(),
    );
  }
}

// Scaffoldの中身を定義する新しいウィジェット
class _GachaView extends ConsumerWidget {
  const _GachaView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.listenをbuildメソッド直下に配置
    ref.listen<GachaState>(gachaViewModelProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        success: (_, __, ___) {},
        error: (message) {
          // 前の状態がエラーでない場合のみSnackBarを表示
          bool wasError = false;
          previous?.when(
            initial: () => wasError = false,
            loading: () => wasError = false,
            success: (_, __, ___) => wasError = false,
            error: (_) => wasError = true,
          );
          
          if (!wasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
      );
    });

    final gachaState = ref.watch(gachaViewModelProvider);

    // ここからがUIの本体
    return Container(
      width: double.infinity,
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
            // 1. ヘッダー部分
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 56,
                    color: Colors.amber,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'ガチャを引いて\nスターポイントやチケットをゲット！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 2. 残高ウィジェット
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: StarPointBalanceWidget(showTransactionHistory: false),
            ),
            const SizedBox(height: 12),

            // 3. メインコンテンツエリア (状態によって表示を切り替える)
            Expanded(
              child: Center(
                child: gachaState.when(
                  initial: () => _buildInitialContent(context, ref),
                  loading: () => _buildLoadingContent(),
                  success: (result, previousBalance, newBalance) => _buildSuccessContent(
                    context,
                    ref,
                    result,
                    previousBalance,
                    newBalance,
                  ),
                  error: (message) => _buildErrorContent(context, ref, message),
                ),
              ),
            ),

            // 4. 底部のガチャボタン
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildGachaButton(context, ref, gachaState),
            ),
          ],
        ),
      ),
    );
  }

  // 以下、各状態に対応するウィジェットを返すヘルパーメソッド
  // (これらは元のGachaScreenから移動または再定義)
  Widget _buildInitialContent(BuildContext context, WidgetRef ref) {
    // 初期状態のUI (例: ガチャマシンの画像など)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 待機状態のガチャマシン
        const GachaMachineWidget(
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
    );
  }

  Widget _buildLoadingContent() {
    // ローディング中のUI
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ガチャポンマシンアニメーション
        const GachaMachineWidget(
          isActive: true,
          onAnimationComplete: null,
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
    );
  }

  Widget _buildSuccessContent(
    BuildContext context, 
    WidgetRef ref, 
    GachaResult result, 
    int previousBalance, 
    int newBalance
  ) {
    // 成功時に残高を強制更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      result.when(
        point: (amount) {
          // ポイント獲得時は確実に残高を更新
          final user = ref.read(currentUserProvider);
          if (user.id.isNotEmpty) {
            final balanceManager = ref.read(starPointBalanceManagerProvider(user.id).notifier);
            balanceManager.refreshBalance();
            
            // デバッグ情報を出力
            balanceManager.debugInfo();
            
            // 従来のプロバイダーも無効化（互換性のため）
            ref.invalidate(userStarPointBalanceProvider(user.id));
            ref.invalidate(currentUserStarPointBalanceProvider(user.id));
          }
        },
        ticket: (ticketType, displayName, color) {
          // チケット獲得時も同様に残高を更新
          final user = ref.read(currentUserProvider);
          if (user.id.isNotEmpty) {
            final balanceManager = ref.read(starPointBalanceManagerProvider(user.id).notifier);
            balanceManager.refreshBalance();
            
            // デバッグ情報を出力
            balanceManager.debugInfo();
            
            // 従来のプロバイダーも無効化（互換性のため）
            ref.invalidate(userStarPointBalanceProvider(user.id));
            ref.invalidate(currentUserStarPointBalanceProvider(user.id));
          }
        },
      );
    });
    
    // resultのタイプに応じて表示を切り替える
    return result.when(
      point: (amount) => _buildPointResult(context, amount, newBalance),
      ticket: (ticketType, displayName, color) {
        // チケット獲得時の表示（カウントアップはしない想定）
        // 必要であれば、こちらもポイント換算してカウントアップ演出が可能
        return _buildTicketDisplay(displayName, color);
      },
    );
  }

  Widget _buildPointResult(BuildContext context, int amount, int newBalance) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ガチャ完了アイコン
        const Icon(
          Icons.celebration,
          size: 120,
          color: Colors.amber,
        ),
        const SizedBox(height: 24),

        // 獲得ポイントメッセージ
        Text(
          '10ポイント獲得！',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

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

  Widget _buildGachaButton(BuildContext context, WidgetRef ref, GachaState state) {
    // 状態に基づいてボタンの表示と動作を決定
    bool isLoading = false;
    bool isSuccess = false;
    
    state.when(
      initial: () {
        isLoading = false;
        isSuccess = false;
      },
      loading: () {
        isLoading = true;
        isSuccess = false;
      },
      success: (_, __, ___) {
        isLoading = false;
        isSuccess = true;
      },
      error: (_) {
        isLoading = false;
        isSuccess = false;
      },
    );
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading 
          ? null 
          : () async {
              if (isSuccess) {
                // もう一度引く前に残高を強制更新
                final user = ref.read(currentUserProvider);
                if (user.id.isNotEmpty) {
                  final balanceManager = ref.read(starPointBalanceManagerProvider(user.id).notifier);
                  balanceManager.refreshBalance();
                  
                  // デバッグ情報を出力
                  balanceManager.debugInfo();
                  
                  // 従来のプロバイダーも無効化（互換性のため）
                  ref.invalidate(userStarPointBalanceProvider(user.id));
                  ref.invalidate(currentUserStarPointBalanceProvider(user.id));
                }
                ref.read(gachaViewModelProvider.notifier).reset();
              } else {
                await GachaSoundService().playLeverPull();
                ref.read(gachaViewModelProvider.notifier).draw();
              }
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
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isSuccess ? Icons.refresh : Icons.casino, size: 24),
                SizedBox(width: 8),
                Text(
                  isSuccess ? 'もう一度引く' : 'ガチャを引く',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildTicketDisplay(String displayName, Color color) {
    return Column(
      children: [
        Icon(
          Icons.card_giftcard,
          size: 48,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          '$displayNameチケットを獲得しました！',
          style: TextStyle(
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _applyGachaReward(WidgetRef ref, GachaResult result) async {
    // 一時的にデータベース処理を無効化（データベースエラー回避）
    print('ガチャ報酬付与（モック）: ${result.toString()}');
    
    // 本来の実装（データベースが利用可能になったら有効化）
    /*
    final user = ref.read(currentUserProvider);
    final userId = user.id;
    final repo = ref.read(votingRepositoryProvider);

    await result.when(
      point: (amount) async {
        await repo.grantSPointsWithSource(userId, amount, 'ガチャ獲得', 'purchase');
        // 残高を即座に更新
        ref.invalidate(userStarPointBalanceProvider(userId));
      },
      ticket: (ticketType, displayName, color) async {
        // チケットは簡易にポイント換算（仮: シルバー=500、ゴールド=1200）
        final amount = ticketType == 'gold' ? 1200 : 500;
        await repo.grantSPointsWithSource(userId, amount, '$displayName（ガチャ）', 'purchase');
        // 残高を即座に更新
        ref.invalidate(userStarPointBalanceProvider(userId));
      },
    );
    */
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
                '+$amount スターポイント',
                style: TextStyle(
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

