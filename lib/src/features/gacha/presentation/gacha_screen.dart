import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gacha_models_simple.dart';
import '../models/gacha_limits_models.dart';
import '../widgets/gacha_machine_widget.dart';
import '../services/gacha_sound_service.dart';
import 'providers/gacha_providers.dart';
import '../../voting/widgets/star_point_balance_widget.dart';
import '../providers/gacha_attempts_manager.dart';
import '../services/ad_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    // MPパターンのガチャ回数マネージャーを監視
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? '';

    if (userId.isEmpty) {
      return const Center(
        child: Text('ログインが必要です'),
      );
    }

    final gachaAttemptsState = ref.watch(gachaAttemptsManagerProvider(userId));
    final gachaState = ref.watch(gachaViewModelProvider);

    // ガチャ状態の変更を監視
    ref.listen<GachaState>(gachaViewModelProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        success: (result, previousBalance, newBalance) {
          _showResultSheet(context, result);
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    final contentChildren = <Widget>[
      // 1. ヘッダー部分
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7A73F8),
                Color(0xFF8090FA),
                Color(0xFF43BEB4),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7167F8).withOpacity(0.22),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -28,
                right: -18,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.32),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 46,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '1日1回無料',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.28),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.refresh,
                                      size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${gachaAttemptsState.stats.calculatedAvailableAttempts}回',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.orangeAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.orangeAccent
                                            .withOpacity(0.45),
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 320),
                                      transitionBuilder: (child, anim) =>
                                          ScaleTransition(
                                              scale: anim, child: child),
                                      child: Text(
                                        '+${gachaAttemptsState.stats.bonusAttempts.clamp(0, 3)}/3',
                                        key: ValueKey<int>(
                                          gachaAttemptsState
                                              .stats.bonusAttempts,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '広告視聴で+3回、限定チケットもゲットしよう！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: gachaAttemptsState.stats.bonusAttempts >= 3
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFFFFD54F), Color(0xFFFFA726)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: gachaAttemptsState.stats.bonusAttempts >= 3
                              ? Colors.white30
                              : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: gachaAttemptsState.stats.bonusAttempts >= 3
                            ? null
                            : () async {
                                final adService = ref.read(adServiceProvider);
                                final result = await adService.showAd(AdType.video);
                                if (!context.mounted) return;
                                if (result.success) {
                                  await ref.read(gachaAttemptsManagerProvider(userId).notifier).refreshAttempts();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('チケットを1枚付与しました')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('広告視聴に失敗しました: ${result.errorMessage ?? ''}')),
                                  );
                                }
                              },
                        icon: Icon(
                          Icons.ondemand_video,
                          color: gachaAttemptsState.stats.bonusAttempts >= 3
                              ? Colors.white54
                              : Colors.deepPurple.shade900,
                        ),
                        label: Text(
                          gachaAttemptsState.stats.bonusAttempts >= 3
                              ? '本日の上限に達しています'
                              : '広告視聴で+1回',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              gachaAttemptsState.stats.bonusAttempts >= 3
                                  ? Colors.white12
                                  : Colors.transparent,
                          shadowColor: Colors.black.withOpacity(0.1),
                          elevation: 0,
                          foregroundColor:
                              gachaAttemptsState.stats.bonusAttempts >= 3
                                  ? Colors.white60
                                  : Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (gachaAttemptsState.error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              gachaAttemptsState.error!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.orange),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(gachaAttemptsManagerProvider(userId)
                                      .notifier)
                                  .clearError();
                            },
                            child: const Text('閉じる',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),

      // 2. 残高ウィジェット
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: StarPointBalanceWidget(showTransactionHistory: false),
      ),
      const SizedBox(height: 8),

      // 3. メインコンテンツエリア (状態によって表示を切り替える)
      Expanded(
        child: Center(
          child: gachaState.when(
            initial: () => _buildInitialContent(context, ref),
            loading: () => _buildLoadingContent(),
            success: (result, previousBalance, newBalance) =>
                _buildSuccessContent(
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

      const SizedBox(height: 12),

      // 4. 底部のガチャボタン
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildGachaButton(context, ref, gachaState, gachaAttemptsState),
      ),
    ];

    contentChildren.addAll(_buildDebugControls(userId, ref));

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: contentChildren,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 以下、各状態に対応するウィジェットを返すヘルパーメソッド
  // (これらは元のGachaScreenから移動または再定義)
  Widget _buildInitialContent(BuildContext context, WidgetRef ref) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 320,
          child: FittedBox(
            fit: BoxFit.contain,
            child: GachaMachineWidget(isActive: false),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'ガチャを引く準備ができました',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDebugControls(String userId, WidgetRef ref) {
    if (userId.isEmpty) {
      return const [];
    }

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  ref
                      .read(gachaAttemptsManagerProvider(userId).notifier)
                      .debugInfo();
                },
                child: const Text(
                  'デバッグ情報',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  await ref
                      .read(gachaAttemptsManagerProvider(userId).notifier)
                      .resetToTenAttempts();
                },
                child: const Text(
                  '10回リセット',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
    ];
  }

  Widget _buildLoadingContent() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 320,
          child: FittedBox(
            fit: BoxFit.contain,
            child: GachaMachineWidget(
              isActive: true,
              onAnimationComplete: null,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'ガチャを実行中...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(BuildContext context, WidgetRef ref,
      GachaResult result, int previousBalance, int newBalance) {
    // 成功直後の強制リフレッシュは行わない（DB応答の遅延による0上書きを防止）

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
        const Icon(
          Icons.celebration,
          size: 120,
          color: Colors.amber,
        ),
        const SizedBox(height: 24),
        Text(
          '$amountポイント獲得！',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(
      BuildContext context, WidgetRef ref, String message) {
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

  Widget _buildGachaButton(BuildContext context, WidgetRef ref,
      GachaState state, GachaAttemptsState attemptsState) {
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

    final noChance = attemptsState.stats.calculatedAvailableAttempts <= 0;
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? '';

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (isLoading || noChance || userId.isEmpty)
            ? null
            : () async {
                if (isSuccess) {
                  ref.read(gachaViewModelProvider.notifier).reset();
                } else {
                  await GachaSoundService().playLeverPull();
                  await ref.read(gachaViewModelProvider.notifier).draw();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading || noChance
              ? Colors.grey
              : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: isLoading || noChance ? 0 : 4,
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
                  Text('実行中...',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isSuccess ? Icons.refresh : Icons.casino, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    noChance
                        ? '回数不足'
                        : isSuccess
                            ? 'もう一度引く'
                            : 'ガチャを引く',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
  void _showResultDialog(
      BuildContext context, WidgetRef ref, GachaResult result) {
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

  void _showResultSheet(BuildContext context, GachaResult result) {
    final rarity = _mapResultToRarity(result);
    final rarityLabel = _rarityLabel(rarity);
    final colors = _rarityColors(rarity);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      rarityLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    result.when(
                      point: (amount) => Text(
                        '+$amount スターポイント',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ticket: (type, name, color) => Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.white.withOpacity(0.9)),
                          const SizedBox(width: 8),
                          const Text(
                            'おめでとう！',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colors.last,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('閉じる',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (rarity == 'SSR') const Positioned.fill(child: _RarityShineOverlay()),
          ],
        );
      },
    );
  }

  String _mapResultToRarity(GachaResult result) {
    return result.when(
      point: (amount) {
        if (amount >= 100) return 'SSR';
        if (amount >= 50) return 'SR';
        if (amount >= 30) return 'R';
        return 'N';
      },
      ticket: (type, name, color) {
        if (type == 'gold') return 'SSR';
        return 'SR';
      },
    );
  }

  String _rarityLabel(String rarity) {
    switch (rarity) {
      case 'SSR':
        return '超激レア';
      case 'SR':
        return '激レア';
      case 'R':
        return 'レア';
      default:
        return 'ノーマル';
    }
  }

  List<Color> _rarityColors(String rarity) {
    switch (rarity) {
      case 'SSR':
        return const [Color(0xFFFFD54F), Color(0xFFFF8F00)];
      case 'SR':
        return const [Color(0xFF7E57C2), Color(0xFF512DA8)];
      case 'R':
        return const [Color(0xFF42A5F5), Color(0xFF1E88E5)];
      default:
        return const [Color(0xFFBDBDBD), Color(0xFF9E9E9E)];
    }
  }
}

/// SSR専用のシャイン演出（放射状の光を回転させる）
class _RarityShineOverlay extends StatefulWidget {
  const _RarityShineOverlay();
  @override
  State<_RarityShineOverlay> createState() => _RarityShineOverlayState();
}

class _RarityShineOverlayState extends State<_RarityShineOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Opacity(
            opacity: 0.5,
            child: CustomPaint(
              painter: _RaysPainter(angle: _ctrl.value * 6.28318),
            ),
          );
        },
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  final double angle;
  _RaysPainter({required this.angle});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 4);
    final radius = size.width * 0.9;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF59D).withOpacity(0.8),
          const Color(0x00FFFFFF),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..blendMode = BlendMode.plus;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    for (int i = 0; i < 12; i++) {
      final path = Path();
      path.moveTo(0, 0);
      path.lineTo(radius, 14);
      path.lineTo(radius * 0.6, -14);
      path.close();
      canvas.drawPath(path, paint);
      canvas.rotate(6.28318 / 12);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RaysPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
