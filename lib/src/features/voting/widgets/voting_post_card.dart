import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/voting_models.dart';
import '../providers/voting_providers.dart';
import '../../../features/auth/providers/user_provider.dart';

/// 投票投稿カードウィジェット
class VotingPostCard extends ConsumerStatefulWidget {
  final VotingPost post;
  final bool showResults;
  final VoidCallback? onVoteCompleted;

  const VotingPostCard({
    Key? key,
    required this.post,
    this.showResults = false,
    this.onVoteCompleted,
  }) : super(key: key);

  @override
  ConsumerState<VotingPostCard> createState() => _VotingPostCardState();
}

class _VotingPostCardState extends ConsumerState<VotingPostCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  VoteOption? _selectedOption;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final theme = Theme.of(context);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        final userVoteAsync = ref.watch(userVoteForPostProvider(
          UserVoteQuery(userId: user.id, votingPostId: widget.post.id),
        ));

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 12),
                if (widget.post.description != null) ...[
                  Text(
                    widget.post.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                userVoteAsync.when(
                  data: (userVote) => _buildVotingSection(
                    context,
                    user.id,
                    userVote,
                  ),
                  loading: () => _buildLoadingVoteSection(),
                  error: (error, _) => _buildErrorVoteSection(),
                ),
                const SizedBox(height: 12),
                _buildFooter(theme),
              ],
            ),
          ),
        );
      },
      loading: () => _buildLoadingCard(),
      error: (error, _) => _buildErrorCard(),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.post.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars,
                size: 16,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.post.votingCost} スターP',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVotingSection(BuildContext context, String userId, Vote? userVote) {
    final hasVoted = userVote != null;
    final canVote = widget.post.canVote && !hasVoted;

    if (hasVoted || widget.showResults) {
      return _buildResultsSection(userVote?.selectedOption);
    }

    if (!widget.post.canVote) {
      return _buildExpiredSection();
    }

    return _buildVoteOptionsSection(context, userId, canVote);
  }

  Widget _buildVoteOptionsSection(BuildContext context, String userId, bool canVote) {
    return Column(
      children: [
        _buildVoteOption(
          context,
          userId,
          VoteOption.A,
          widget.post.optionA,
          widget.post.optionAImageUrl,
          canVote,
        ),
        const SizedBox(height: 12),
        _buildVoteOption(
          context,
          userId,
          VoteOption.B,
          widget.post.optionB,
          widget.post.optionBImageUrl,
          canVote,
        ),
      ],
    );
  }

  Widget _buildVoteOption(
    BuildContext context,
    String userId,
    VoteOption option,
    String text,
    String? imageUrl,
    bool canVote,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedOption == option;
    final isVoting = _isVoting && isSelected;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: InkWell(
            onTap: canVote && !_isVoting ? () => _handleVote(userId, option) : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected 
                      ? theme.primaryColor 
                      : theme.dividerColor,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected 
                    ? theme.primaryColor.withOpacity(0.05)
                    : null,
              ),
              child: Row(
                children: [
                  if (imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: theme.dividerColor,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                  if (isVoting) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsSection(VoteOption? userVote) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        _buildResultBar(
          theme,
          widget.post.optionA,
          widget.post.optionAVotes,
          widget.post.optionAPercentage,
          VoteOption.A,
          userVote,
        ),
        const SizedBox(height: 12),
        _buildResultBar(
          theme,
          widget.post.optionB,
          widget.post.optionBVotes,
          widget.post.optionBPercentage,
          VoteOption.B,
          userVote,
        ),
      ],
    );
  }

  Widget _buildResultBar(
    ThemeData theme,
    String text,
    int votes,
    double percentage,
    VoteOption option,
    VoteOption? userVote,
  ) {
    final isUserChoice = userVote == option;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isUserChoice ? theme.primaryColor : theme.dividerColor,
          width: isUserChoice ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isUserChoice ? FontWeight.bold : null,
                  ),
                ),
              ),
              if (isUserChoice)
                Icon(
                  Icons.check_circle,
                  color: theme.primaryColor,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: theme.dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUserChoice ? theme.primaryColor : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$votes票',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.access_time,
            color: Colors.grey,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            '投票期間が終了しました',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.how_to_vote,
              size: 16,
              color: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.post.totalVotes}票',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        if (widget.post.expiresAt != null) ...[
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTimeRemaining(widget.post.timeRemaining),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatTimeRemaining(Duration? duration) {
    if (duration == null) return '無期限';
    if (duration == Duration.zero) return '期限切れ';
    
    if (duration.inDays > 0) {
      return '残り${duration.inDays}日';
    } else if (duration.inHours > 0) {
      return '残り${duration.inHours}時間';
    } else {
      return '残り${duration.inMinutes}分';
    }
  }

  Widget _buildLoadingVoteSection() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorVoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          '投票情報の読み込みに失敗しました',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return const Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'エラーが発生しました',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Future<void> _handleVote(String userId, VoteOption option) async {
    if (_isVoting) return;

    setState(() {
      _selectedOption = option;
      _isVoting = true;
    });

    _animationController.forward();

    final voteNotifier = ref.read(voteActionProvider);
    await voteNotifier.castVote(userId, widget.post.id, option);

    final voteState = ref.read(voteActionProvider);
    
    await _animationController.reverse();

    setState(() {
      _isVoting = false;
      _selectedOption = null;
    });

    if (mounted) {
      voteState.when(
        data: (result) {
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: result.success ? Colors.green : Colors.red,
              ),
            );
            
            if (result.success) {
              widget.onVoteCompleted?.call();
              // プロバイダーを無効化してデータを再取得
              ref.invalidate(userVoteForPostProvider);
              ref.invalidate(userStarPointBalanceProvider);
            }
          }
        },
        loading: () {},
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }
}