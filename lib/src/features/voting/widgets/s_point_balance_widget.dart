import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/voting_models.dart';
import '../providers/voting_providers.dart';
import '../../../features/auth/providers/user_provider.dart';

/// Sポイント残高表示ウィジェット
class SPointBalanceWidget extends ConsumerWidget {
  final bool showFullInfo;
  final VoidCallback? onTap;

  const SPointBalanceWidget({
    Key? key,
    this.showFullInfo = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        
        final balanceAsync = ref.watch(userSPointBalanceProvider(user.id));
        
        return balanceAsync.when(
          data: (balance) => _buildBalanceDisplay(context, balance),
          loading: () => _buildLoadingDisplay(),
          error: (error, _) => _buildErrorDisplay(context),
        );
      },
      loading: () => _buildLoadingDisplay(),
      error: (error, _) => _buildErrorDisplay(context),
    );
  }

  Widget _buildBalanceDisplay(BuildContext context, SPointBalance? balance) {
    final theme = Theme.of(context);
    final points = balance?.balance ?? 0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars,
              color: theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '$points SP',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (showFullInfo && balance != null) ...[
              const SizedBox(width: 8),
              Text(
                '(獲得: ${balance.totalEarned}, 使用: ${balance.totalSpent})',
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 6),
          Text('SP'),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text('-- SP'),
        ],
      ),
    );
  }
}

/// Sポイント残高詳細ダイアログ
class SPointBalanceDialog extends ConsumerWidget {
  const SPointBalanceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        
        final balanceAsync = ref.watch(userSPointBalanceProvider(user.id));
        final transactionsAsync = ref.watch(sPointTransactionsProvider(user.id));
        final dailyBonusNotifier = ref.watch(dailyBonusActionProvider);
        final dailyBonusState = ref.watch(dailyBonusActionProvider);
        
        return Dialog(
          child: Container(
            width: 400,
            height: 500,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sポイント残高',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                
                // 残高表示
                balanceAsync.when(
                  data: (balance) => _buildBalanceCard(context, balance),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) => Text('エラー: $error'),
                ),
                
                const SizedBox(height: 16),
                
                // 日次ボーナス
                _buildDailyBonusSection(context, dailyBonusNotifier, dailyBonusState, user.id),
                
                const SizedBox(height: 16),
                
                // 取引履歴
                Text(
                  '取引履歴',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: transactionsAsync.when(
                    data: (transactions) => _buildTransactionsList(transactions),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('履歴の読み込みに失敗しました')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('エラーが発生しました')),
    );
  }

  Widget _buildBalanceCard(BuildContext context, SPointBalance? balance) {
    if (balance == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('残高情報が見つかりません'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.stars,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  '${balance.balance} SP',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, '総獲得', balance.totalEarned, Colors.green),
                _buildStatItem(context, '総使用', balance.totalSpent, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          '$value SP',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyBonusSection(BuildContext context, DailyBonusNotifier notifier, AsyncValue<DailyBonusResult?> state, String userId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '日次ログインボーナス',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            state.when(
              data: (result) {
                if (result == null) {
                  return ElevatedButton(
                    onPressed: () => notifier.claimDailyBonus(userId),
                    child: const Text('ボーナスを受け取る (+10 SP)'),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.message,
                        style: TextStyle(
                          color: result.granted ? Colors.green : Colors.orange,
                        ),
                      ),
                      if (!result.granted)
                        const SizedBox(height: 8),
                      if (!result.granted)
                        const Text(
                          '明日また来てください！',
                          style: TextStyle(fontSize: 12),
                        ),
                    ],
                  );
                }
              },
              loading: () => const ElevatedButton(
                onPressed: null,
                child: Text('処理中...'),
              ),
              error: (error, _) => Text(
                'エラー: $error',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<SPointTransaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('取引履歴がありません'),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          leading: Icon(
            transaction.isEarning ? Icons.add_circle : Icons.remove_circle,
            color: transaction.isEarning ? Colors.green : Colors.red,
          ),
          title: Text(transaction.description ?? '取引'),
          subtitle: Text(
            '${transaction.createdAt.month}/${transaction.createdAt.day} ${transaction.createdAt.hour}:${transaction.createdAt.minute.toString().padLeft(2, '0')}',
          ),
          trailing: Text(
            '${transaction.isEarning ? '+' : ''}${transaction.amount} SP',
            style: TextStyle(
              color: transaction.isEarning ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SPointBalanceDialog(),
    );
  }
}