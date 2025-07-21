import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/star_point_models.dart';
import '../providers/voting_providers.dart';

/// スターポイント残高表示ウィジェット
class StarPointBalanceWidget extends ConsumerWidget {
  final bool showTransactionHistory;
  final VoidCallback? onTap;

  const StarPointBalanceWidget({
    Key? key,
    this.showTransactionHistory = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(starPointBalanceProvider);

    return balanceAsync.when(
      data: (balance) => _buildBalanceCard(context, ref, balance),
      loading: () => _buildLoadingCard(context),
      error: (error, stack) => _buildErrorCard(context, error),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WidgetRef ref, StarPointBalance balance) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? (showTransactionHistory ? () => _showTransactionHistory(context, ref) : null),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'スターポイント残高',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${balance.balance.toStringAsFixed(0)} スターポイント',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              if (showTransactionHistory)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).disabledColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.stars,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'スターポイント残高',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const SizedBox(
                  width: 60,
                  height: 20,
                  child: LinearProgressIndicator(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, Object error) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'スターポイント残高',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '読み込みエラー',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionHistory(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TransactionHistorySheet(),
    );
  }
}

/// スターポイント取引履歴シート
class _TransactionHistorySheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(starPointTransactionsProvider);
    final balanceAsync = ref.watch(starPointBalanceProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'スターポイント履歴',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 残高サマリー
          balanceAsync.when(
            data: (balance) => _buildBalanceSummary(context, balance),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 20),
          
          // 取引履歴リスト
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) => _buildTransactionsList(context, transactions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('エラーが発生しました: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummary(BuildContext context, StarPointBalance balance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            title: '現在残高',
            value: '${balance.balance} スターポイント',
            icon: Icons.account_balance_wallet,
          ),
          _SummaryItem(
            title: '累計獲得',
            value: '${balance.totalEarned} スターポイント',
            icon: Icons.trending_up,
          ),
          _SummaryItem(
            title: '累計使用',
            value: '${balance.totalSpent} スターポイント',
            icon: Icons.trending_down,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, List<StarPointTransaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('取引履歴がありません'),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _TransactionItem(transaction: transaction);
      },
    );
  }
}

/// 残高サマリーアイテム
class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 取引履歴アイテム
class _TransactionItem extends StatelessWidget {
  final StarPointTransaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isEarning = transaction.isEarning;
    final color = isEarning 
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            _getTransactionIcon(transaction.sourceType),
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description ?? _getDefaultDescription(transaction),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _formatDate(transaction.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          '${isEarning ? '+' : ''}${transaction.amount} スターポイント',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(StarPointSourceType sourceType) {
    switch (sourceType) {
      case StarPointSourceType.dailyLogin:
        return Icons.login;
      case StarPointSourceType.voting:
        return Icons.how_to_vote;
      case StarPointSourceType.premiumQuestion:
        return Icons.help;
      case StarPointSourceType.purchase:
        return Icons.shopping_cart;
      case StarPointSourceType.admin:
        return Icons.admin_panel_settings;
    }
  }

  String _getDefaultDescription(StarPointTransaction transaction) {
    switch (transaction.sourceType) {
      case StarPointSourceType.dailyLogin:
        return '日次ログインボーナス';
      case StarPointSourceType.voting:
        return '投票参加';
      case StarPointSourceType.premiumQuestion:
        return 'プレミアム質問';
      case StarPointSourceType.purchase:
        return 'スターポイント購入';
      case StarPointSourceType.admin:
        return '管理者操作';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}