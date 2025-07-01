import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/netflix_providers.dart';
import '../../../data/models/netflix_models.dart';

/// Netflix視聴詳細画面
class NetflixViewingDetailScreen extends ConsumerStatefulWidget {
  final NetflixViewingHistory viewingHistory;

  const NetflixViewingDetailScreen({
    Key? key,
    required this.viewingHistory,
  }) : super(key: key);

  @override
  ConsumerState<NetflixViewingDetailScreen> createState() => _NetflixViewingDetailScreenState();
}

class _NetflixViewingDetailScreenState extends ConsumerState<NetflixViewingDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _userRating;
  String? _userNote;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _userRating = widget.viewingHistory.rating;
    _userNote = widget.viewingHistory.note;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(netflixViewingLoadingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          // App Bar with hero image
          SliverAppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 背景画像またはプレースホルダー
                  widget.viewingHistory.imageUrl != null
                      ? Image.network(
                          widget.viewingHistory.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                  
                  // グラデーション
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                  
                  // タイトル情報
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.viewingHistory.fullTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (widget.viewingHistory.releaseYear != null) ...[ 
                              Text(
                                '${widget.viewingHistory.releaseYear}年',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE50914),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.viewingHistory.contentTypeDisplayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (_isEditing)
                IconButton(
                  onPressed: isLoading ? null : () => _saveChanges(),
                  icon: isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  tooltip: '保存',
                ),
              IconButton(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                icon: Icon(
                  _isEditing ? Icons.close : Icons.edit,
                  color: Colors.white,
                ),
                tooltip: _isEditing ? 'キャンセル' : '編集',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFE50914),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: '詳細'),
                Tab(text: 'エピソード'),
                Tab(text: 'メモ'),
              ],
            ),
          ),

          // コンテンツ
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 詳細タブ
                _buildDetailTab(),
                
                // エピソードタブ
                _buildEpisodeTab(),
                
                // メモタブ
                _buildNoteTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 画像プレースホルダー
  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFF333333),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getContentTypeIcon(widget.viewingHistory.contentType),
              color: const Color(0xFFE50914),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              widget.viewingHistory.contentTypeDisplayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 詳細タブ
  Widget _buildDetailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本情報カード
          _buildBasicInfoCard(),
          const SizedBox(height: 16),
          
          // 視聴情報カード
          _buildViewingInfoCard(),
          const SizedBox(height: 16),
          
          // ジャンル・キャスト情報
          _buildGenreCastCard(),
          const SizedBox(height: 16),
          
          // 評価・レビュー
          _buildRatingCard(),
        ],
      ),
    );
  }

  /// エピソードタブ
  Widget _buildEpisodeTab() {
    if (widget.viewingHistory.contentType != NetflixContentType.series) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'シリーズではありません',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // シーズン情報
          if (widget.viewingHistory.seasonNumber != null) ...[ 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.tv,
                    color: Color(0xFFE50914),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'シーズン ${widget.viewingHistory.seasonNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.viewingHistory.episodeNumber != null) ...[ 
                    const SizedBox(width: 8),
                    Text(
                      'エピソード ${widget.viewingHistory.episodeNumber}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 進捗情報
          if (widget.viewingHistory.calculatedProgress > 0) ...[ 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '視聴進捗',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: widget.viewingHistory.calculatedProgress,
                    backgroundColor: const Color(0xFF333333),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.viewingHistory.watchDurationString,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        '${(widget.viewingHistory.calculatedProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFFE50914),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // プレースホルダー（実際のエピソードリストは今後実装）
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.list,
                    color: Colors.grey,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'エピソードリスト',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '詳細なエピソード情報は今後追加予定です',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// メモタブ
  Widget _buildNoteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 評価セクション
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '評価',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: _isEditing
                          ? () => setState(() => _userRating = index + 1)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          index < (_userRating ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          size: 32,
                          color: const Color(0xFFE50914),
                        ),
                      ),
                    );
                  }),
                ),
                if (_userRating != null) ...[ 
                  const SizedBox(height: 8),
                  Text(
                    '$_userRating / 5',
                    style: const TextStyle(
                      color: Color(0xFFE50914),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // メモセクション
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'メモ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isEditing)
                  TextField(
                    onChanged: (value) => _userNote = value,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '感想や印象に残った場面などを記録できます...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF333333),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    controller: TextEditingController(text: _userNote),
                  )
                else if (_userNote != null && _userNote!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _userNote!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          color: Colors.grey,
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'メモがありません',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '編集ボタンから感想を追加できます',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 基本情報カード
  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本情報',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // タイトル
          _buildInfoRow('タイトル', widget.viewingHistory.title),
          if (widget.viewingHistory.originalTitle != null)
            _buildInfoRow('原題', widget.viewingHistory.originalTitle!),
          
          // 公開年
          if (widget.viewingHistory.releaseYear != null)
            _buildInfoRow('公開年', '${widget.viewingHistory.releaseYear}年'),
          
          // コンテンツタイプ
          _buildInfoRow('タイプ', widget.viewingHistory.contentTypeDisplayName),
          
          // 時間
          if (widget.viewingHistory.duration != null)
            _buildInfoRow('時間', widget.viewingHistory.durationString),
          
          // 国
          if (widget.viewingHistory.country != null)
            _buildInfoRow('制作国', widget.viewingHistory.country!),
        ],
      ),
    );
  }

  /// 視聴情報カード
  Widget _buildViewingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '視聴情報',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // 視聴日
          _buildInfoRow(
            '視聴日',
            DateFormat('yyyy年MM月dd日').format(widget.viewingHistory.watchedAt),
          ),
          
          // 視聴時間
          if (widget.viewingHistory.watchDuration != null)
            _buildInfoRow('視聴時間', widget.viewingHistory.watchDurationString),
          
          // 視聴状態
          Row(
            children: [
              Icon(
                _getWatchStatusIcon(widget.viewingHistory.watchStatus),
                color: _getWatchStatusColor(widget.viewingHistory.watchStatus),
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                '視聴状態',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.viewingHistory.watchStatusDisplayName,
                style: TextStyle(
                  color: _getWatchStatusColor(widget.viewingHistory.watchStatus),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ジャンル・キャスト情報カード
  Widget _buildGenreCastCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ジャンル・キャスト',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // ジャンル
          if (widget.viewingHistory.genres.isNotEmpty) ...[ 
            const Text(
              'ジャンル',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.viewingHistory.genres.map((genre) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE50914).withOpacity(0.3)),
                ),
                child: Text(
                  genre,
                  style: const TextStyle(
                    color: Color(0xFFE50914),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // キャスト
          if (widget.viewingHistory.cast.isNotEmpty) ...[ 
            const Text(
              'キャスト',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.viewingHistory.cast.map((actor) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  actor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 評価カード
  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '評価・レビュー',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // 現在の評価
          if (_userRating != null) ...[ 
            Row(
              children: [
                const Text(
                  '評価:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (index) => Icon(
                  index < _userRating!
                      ? Icons.star
                      : Icons.star_border,
                  size: 20,
                  color: const Color(0xFFE50914),
                )),
                const SizedBox(width: 8),
                Text(
                  '$_userRating / 5',
                  style: const TextStyle(
                    color: Color(0xFFE50914),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          // 平均評価（今後の実装用プレースホルダー）
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Netflix平均評価やレビューは今後追加予定',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 情報行ウィジェット
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// コンテンツタイプアイコン取得
  IconData _getContentTypeIcon(NetflixContentType contentType) {
    switch (contentType) {
      case NetflixContentType.movie:
        return Icons.movie;
      case NetflixContentType.series:
        return Icons.tv;
      case NetflixContentType.documentary:
        return Icons.video_library;
      case NetflixContentType.anime:
        return Icons.animation;
      case NetflixContentType.standup:
        return Icons.mic;
      case NetflixContentType.kids:
        return Icons.child_care;
      case NetflixContentType.reality:
        return Icons.camera_alt;
      case NetflixContentType.other:
        return Icons.play_circle;
    }
  }

  /// 視聴状態アイコン取得
  IconData _getWatchStatusIcon(NetflixWatchStatus watchStatus) {
    switch (watchStatus) {
      case NetflixWatchStatus.completed:
        return Icons.check_circle;
      case NetflixWatchStatus.inProgress:
        return Icons.play_circle;
      case NetflixWatchStatus.watchlist:
        return Icons.bookmark;
      case NetflixWatchStatus.stopped:
        return Icons.pause_circle;
    }
  }

  /// 視聴状態色取得
  Color _getWatchStatusColor(NetflixWatchStatus watchStatus) {
    switch (watchStatus) {
      case NetflixWatchStatus.completed:
        return Colors.green;
      case NetflixWatchStatus.inProgress:
        return const Color(0xFFE50914);
      case NetflixWatchStatus.watchlist:
        return Colors.orange;
      case NetflixWatchStatus.stopped:
        return Colors.grey;
    }
  }

  /// 変更を保存
  Future<void> _saveChanges() async {
    try {
      // 実際の保存処理はここで実装
      // await ref.read(netflixViewingActionProvider).updateViewingHistory(
      //   widget.viewingHistory.copyWith(
      //     rating: _userRating,
      //     note: _userNote,
      //   ),
      // );
      
      setState(() => _isEditing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('変更を保存しました'),
            backgroundColor: Color(0xFFE50914),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}