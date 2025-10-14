import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'social_link_repository.dart';

final socialAccountsFutureProvider =
    FutureProvider.autoDispose<List<SocialAccount>>((ref) async {
  final repository = ref.watch(socialLinkRepositoryProvider);
  return repository.fetchLinkedAccounts();
});

final socialLogsFutureProvider =
    FutureProvider.autoDispose<List<SocialLinkLog>>((ref) async {
  final repository = ref.watch(socialLinkRepositoryProvider);
  return repository.fetchLogs();
});

class SocialLinkScreen extends ConsumerWidget {
  const SocialLinkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(socialAccountsFutureProvider);
    final logs = ref.watch(socialLogsFutureProvider);

    ref.listen<AsyncValue<List<SocialAccount>>>(
      socialAccountsFutureProvider,
      (previous, next) {
        if (previous?.hasError == true && next.hasError) {
          return;
        }
        next.whenOrNull(error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SNS連携情報の取得に失敗しました: ${_readableError(error)}'),
            ),
          );
        });
      },
    );

    ref.listen<AsyncValue<List<SocialLinkLog>>>(
      socialLogsFutureProvider,
      (previous, next) {
        if (previous?.hasError == true && next.hasError) {
          return;
        }
        next.whenOrNull(error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('連携履歴の取得に失敗しました: ${_readableError(error)}'),
            ),
          );
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('SNSアカウント連携'),
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.refresh(socialAccountsFutureProvider.future),
              ref.refresh(socialLogsFutureProvider.future),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              Text(
                'Starlistでは各SNSと連携し、データや投稿を自動で反映できます。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              accounts.when(
                data: (items) => _SocialCardRow(accounts: items),
                loading: () => const _SocialCardSkeleton(),
                error: (err, _) => _SocialCardError(error: err.toString()),
              ),
              const SizedBox(height: 32),
              Text(
                '連携履歴',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              logs.when(
                data: (value) => _SocialLogList(logs: value),
                loading: () => const _SkeletonLogList(),
                error: (err, _) => _SocialCardError(error: err.toString()),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.help_outline),
                label: const Text('ヘルプを見る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialCardRow extends ConsumerWidget {
  const _SocialCardRow({required this.accounts});

  final List<SocialAccount> accounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;
        final children = accounts
            .map((account) => _SocialAccountCard(account: account))
            .toList();
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final child in children) ...[
                child,
                const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }
}

class _SocialAccountCard extends ConsumerStatefulWidget {
  const _SocialAccountCard({required this.account});

  final SocialAccount account;

  @override
  ConsumerState<_SocialAccountCard> createState() => _SocialAccountCardState();
}

class _SocialAccountCardState extends ConsumerState<_SocialAccountCard> {
  bool _busy = false;

  SocialLinkStatus get _status => widget.account.status;

  Future<void> _handleConnect() async {
    setState(() => _busy = true);
    final repo = ref.read(socialLinkRepositoryProvider);
    try {
      await repo.connect(widget.account.provider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${widget.account.provider.displayName} の連携を開始しました')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('連携に失敗しました: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        ref.invalidate(socialAccountsFutureProvider);
        ref.invalidate(socialLogsFutureProvider);
      }
    }
  }

  Future<void> _handleDisconnect() async {
    setState(() => _busy = true);
    final repo = ref.read(socialLinkRepositoryProvider);
    try {
      await repo.disconnect(widget.account.provider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('連携を解除しました')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('解除に失敗しました: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        ref.invalidate(socialAccountsFutureProvider);
        ref.invalidate(socialLogsFutureProvider);
      }
    }
  }

  Future<void> _handleRefreshTokens() async {
    setState(() => _busy = true);
    final repo = ref.read(socialLinkRepositoryProvider);
    try {
      await repo.refreshTokens(provider: widget.account.provider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.account.provider.displayName} を再認証しました'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('再認証に失敗しました: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        ref.invalidate(socialAccountsFutureProvider);
        ref.invalidate(socialLogsFutureProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusStyle = widget.account.status.style(colorScheme);
    final button = () {
      if (_status == SocialLinkStatus.connected) {
        return OutlinedButton(
          onPressed: _busy ? null : _handleDisconnect,
          child: const Text('連携解除'),
        );
      }
      if (_status == SocialLinkStatus.expired) {
        return FilledButton(
          onPressed: _busy ? null : _handleRefreshTokens,
          style: FilledButton.styleFrom(
            backgroundColor: widget.account.provider.brandColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('再認証する'),
        );
      }
      return FilledButton(
        onPressed: _busy ? null : _handleConnect,
        style: FilledButton.styleFrom(
          backgroundColor: widget.account.provider.brandColor,
          foregroundColor: Colors.white,
        ),
        child: Text(widget.account.provider.connectLabel),
      );
    }();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: statusStyle.borderColor ?? Colors.transparent,
          width: statusStyle.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    widget.account.provider.brandColor.withOpacity(0.12),
                child: Icon(widget.account.provider.icon,
                    color: widget.account.provider.brandColor),
              ),
              const SizedBox(width: 12),
              Text(
                widget.account.provider.displayName,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              statusStyle.badge,
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: widget.account.displayName != null
                ? Text(
                    widget.account.displayName!,
                    key: ValueKey(widget.account.displayName),
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
               : Text(
                    '未連携',
                    key: const ValueKey('disconnected'),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 16),
          button,
          if (widget.account.expiresAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'トークン期限: ${_formatDate(widget.account.expiresAt!)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }
}

String _readableError(Object error) {
  if (error is SocialLinkApiException) {
    return '${error.message} (code: ${error.statusCode})';
  }
  return error.toString();
}

class _SocialCardSkeleton extends StatelessWidget {
  const _SocialCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final placeholder = Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.shade200,
          ),
        );
        if (constraints.maxWidth < 640) {
          return Column(
            children: [
              placeholder,
              const SizedBox(height: 12),
              placeholder,
              const SizedBox(height: 12),
              placeholder,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: placeholder),
            const SizedBox(width: 16),
            Expanded(child: placeholder),
            const SizedBox(width: 16),
            Expanded(child: placeholder),
          ],
        );
      },
    );
  }
}

class _SocialCardError extends StatelessWidget {
  const _SocialCardError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.error.withOpacity(0.08),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '連携情報の取得に失敗しました: $error',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLogList extends StatelessWidget {
  const _SocialLogList({required this.logs});

  final List<SocialLinkLog> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off,
                color: Colors.grey.shade400, size: 36),
            const SizedBox(height: 8),
            Text('連携履歴がまだありません', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final log = logs[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: log.provider.brandColor.withOpacity(0.12),
              child: Icon(log.provider.icon, color: log.provider.brandColor),
            ),
            title: Text(
              '${log.provider.displayName} : ${log.action.label}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              log.message != null
                  ? '${log.timestamp}\n${log.message}'
                  : log.timestamp,
            ),
          );
        },
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.day.toString().padLeft(2, '0')}';
}

class _SkeletonLogList extends StatelessWidget {
  const _SkeletonLogList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
          ),
        ),
      ),
    );
  }
}
