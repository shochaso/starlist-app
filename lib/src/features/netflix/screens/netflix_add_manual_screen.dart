import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/netflix_providers.dart';
import '../../../data/models/netflix_models.dart';

/// Netflix手動追加画面
class NetflixAddManualScreen extends ConsumerStatefulWidget {
  const NetflixAddManualScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NetflixAddManualScreen> createState() => _NetflixAddManualScreenState();
}

class _NetflixAddManualScreenState extends ConsumerState<NetflixAddManualScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _originalTitleController;
  late TextEditingController _noteController;
  late TextEditingController _countryController;
  late TextEditingController _castController;
  late TextEditingController _genreController;
  
  NetflixContentType _contentType = NetflixContentType.movie;
  NetflixWatchStatus _watchStatus = NetflixWatchStatus.completed;
  DateTime _watchedAt = DateTime.now();
  int? _releaseYear;
  Duration? _duration;
  Duration? _watchDuration;
  int? _rating;
  int? _seasonNumber;
  int? _episodeNumber;
  
  final List<String> _genres = [];
  final List<String> _cast = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _originalTitleController = TextEditingController();
    _noteController = TextEditingController();
    _countryController = TextEditingController();
    _castController = TextEditingController();
    _genreController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _originalTitleController.dispose();
    _noteController.dispose();
    _countryController.dispose();
    _castController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(netflixViewingLoadingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          '視聴履歴を追加',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => _saveViewingHistory(),
            child: Text(
              '保存',
              style: TextStyle(
                color: isLoading ? Colors.grey : const Color(0xFFE50914),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本情報セクション
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              
              // 詳細情報セクション
              _buildDetailSection(),
              const SizedBox(height: 24),
              
              // 視聴情報セクション
              _buildViewingInfoSection(),
              const SizedBox(height: 24),
              
              // ジャンル・キャストセクション
              _buildGenreCastSection(),
              const SizedBox(height: 24),
              
              // 評価・メモセクション
              _buildRatingNoteSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// 基本情報セクション
  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: '基本情報',
      children: [
        // タイトル
        TextFormField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('タイトル *', Icons.movie),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'タイトルを入力してください';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // 原題
        TextFormField(
          controller: _originalTitleController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('原題（任意）', Icons.translate),
        ),
        const SizedBox(height: 16),
        
        // コンテンツタイプ
        DropdownButtonFormField<NetflixContentType>(
          value: _contentType,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('コンテンツタイプ', Icons.category),
          dropdownColor: const Color(0xFF1A1A1A),
          items: NetflixContentType.values.map((type) => DropdownMenuItem(
            value: type,
            child: Text(_getContentTypeDisplayName(type)),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _contentType = value);
            }
          },
        ),
        const SizedBox(height: 16),
        
        // 公開年
        TextFormField(
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('公開年', Icons.calendar_today),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final year = int.tryParse(value);
            setState(() => _releaseYear = year);
          },
        ),
      ],
    );
  }

  /// 詳細情報セクション
  Widget _buildDetailSection() {
    return _buildSection(
      title: '詳細情報',
      children: [
        // 制作国
        TextFormField(
          controller: _countryController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('制作国', Icons.flag),
        ),
        const SizedBox(height: 16),
        
        // 時間設定
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDuration(true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFFE50914), size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '総時間',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _duration != null
                            ? _formatDuration(_duration!)
                            : '選択してください',
                        style: TextStyle(
                          color: _duration != null ? Colors.white : Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDuration(false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.play_arrow, color: Color(0xFFE50914), size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '視聴時間',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _watchDuration != null
                            ? _formatDuration(_watchDuration!)
                            : '選択してください',
                        style: TextStyle(
                          color: _watchDuration != null ? Colors.white : Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // シリーズの場合のシーズン・エピソード情報
        if (_contentType == NetflixContentType.series) ...[ 
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('シーズン', Icons.tv),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final season = int.tryParse(value);
                    setState(() => _seasonNumber = season);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('エピソード', Icons.list),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final episode = int.tryParse(value);
                    setState(() => _episodeNumber = episode);
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 視聴情報セクション
  Widget _buildViewingInfoSection() {
    return _buildSection(
      title: '視聴情報',
      children: [
        // 視聴状態
        DropdownButtonFormField<NetflixWatchStatus>(
          value: _watchStatus,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('視聴状態', Icons.play_circle),
          dropdownColor: const Color(0xFF1A1A1A),
          items: NetflixWatchStatus.values.map((status) => DropdownMenuItem(
            value: status,
            child: Row(
              children: [
                Icon(
                  _getWatchStatusIcon(status),
                  color: _getWatchStatusColor(status),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(_getWatchStatusDisplayName(status)),
              ],
            ),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _watchStatus = value);
            }
          },
        ),
        const SizedBox(height: 16),
        
        // 視聴日
        GestureDetector(
          onTap: () => _selectWatchDate(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFFE50914)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '視聴日',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy年MM月dd日').format(_watchedAt),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ジャンル・キャストセクション
  Widget _buildGenreCastSection() {
    return _buildSection(
      title: 'ジャンル・キャスト',
      children: [
        // ジャンル追加
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _genreController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('ジャンルを追加', Icons.category),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addGenre(),
              icon: const Icon(Icons.add, color: Color(0xFFE50914)),
            ),
          ],
        ),
        if (_genres.isNotEmpty) ...[ 
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _genres.map((genre) => Chip(
              label: Text(genre),
              backgroundColor: const Color(0xFFE50914).withOpacity(0.2),
              labelStyle: const TextStyle(color: Color(0xFFE50914), fontSize: 12),
              deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFFE50914)),
              onDeleted: () => _removeGenre(genre),
            )).toList(),
          ),
        ],
        const SizedBox(height: 16),
        
        // キャスト追加
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _castController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('キャストを追加', Icons.person),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addCast(),
              icon: const Icon(Icons.add, color: Color(0xFFE50914)),
            ),
          ],
        ),
        if (_cast.isNotEmpty) ...[ 
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cast.map((actor) => Chip(
              label: Text(actor),
              backgroundColor: const Color(0xFF333333),
              labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
              deleteIcon: const Icon(Icons.close, size: 16, color: Colors.grey),
              onDeleted: () => _removeCast(actor),
            )).toList(),
          ),
        ],
      ],
    );
  }

  /// 評価・メモセクション
  Widget _buildRatingNoteSection() {
    return _buildSection(
      title: '評価・メモ',
      children: [
        // 評価
        const Text(
          '評価',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => setState(() => _rating = index + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  index < (_rating ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  size: 32,
                  color: const Color(0xFFE50914),
                ),
              ),
            );
          }),
        ),
        if (_rating != null) ...[ 
          const SizedBox(height: 8),
          Text(
            '$_rating / 5',
            style: const TextStyle(
              color: Color(0xFFE50914),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 16),
        
        // メモ
        TextFormField(
          controller: _noteController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('メモ・感想', Icons.note),
          maxLines: 4,
        ),
      ],
    );
  }

  /// セクションウィジェット
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  /// 入力フィールドデコレーション
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFFE50914)),
      filled: true,
      fillColor: const Color(0xFF333333),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE50914)),
      ),
    );
  }

  /// 時間選択
  Future<void> _selectDuration(bool isTotal) async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 1, minute: 30),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE50914),
              surface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (time != null) {
      final duration = Duration(hours: time.hour, minutes: time.minute);
      setState(() {
        if (isTotal) {
          _duration = duration;
        } else {
          _watchDuration = duration;
        }
      });
    }
  }

  /// 視聴日選択
  Future<void> _selectWatchDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _watchedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE50914),
              surface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() => _watchedAt = date);
    }
  }

  /// ジャンル追加
  void _addGenre() {
    final genre = _genreController.text.trim();
    if (genre.isNotEmpty && !_genres.contains(genre)) {
      setState(() {
        _genres.add(genre);
        _genreController.clear();
      });
    }
  }

  /// ジャンル削除
  void _removeGenre(String genre) {
    setState(() => _genres.remove(genre));
  }

  /// キャスト追加
  void _addCast() {
    final actor = _castController.text.trim();
    if (actor.isNotEmpty && !_cast.contains(actor)) {
      setState(() {
        _cast.add(actor);
        _castController.clear();
      });
    }
  }

  /// キャスト削除
  void _removeCast(String actor) {
    setState(() => _cast.remove(actor));
  }

  /// 視聴履歴保存
  Future<void> _saveViewingHistory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final viewingHistory = NetflixViewingHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // 実際のユーザーIDに置き換え
        title: _titleController.text,
        originalTitle: _originalTitleController.text.isNotEmpty 
            ? _originalTitleController.text 
            : null,
        contentType: _contentType,
        watchedAt: _watchedAt,
        watchStatus: _watchStatus,
        releaseYear: _releaseYear,
        duration: _duration,
        watchDuration: _watchDuration,
        rating: _rating,
        seasonNumber: _seasonNumber,
        episodeNumber: _episodeNumber,
        country: _countryController.text.isNotEmpty 
            ? _countryController.text 
            : null,
        genres: _genres,
        cast: _cast,
        note: _noteController.text.isNotEmpty 
            ? _noteController.text 
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 実際の保存処理（今後実装）
      // await ref.read(netflixViewingActionProvider).addViewingHistory(viewingHistory);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('視聴履歴を追加しました'),
            backgroundColor: Color(0xFFE50914),
          ),
        );
        Navigator.pop(context);
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

  /// 時間フォーマット
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}時間${minutes}分';
    } else {
      return '${minutes}分';
    }
  }

  /// コンテンツタイプ表示名取得
  String _getContentTypeDisplayName(NetflixContentType contentType) {
    switch (contentType) {
      case NetflixContentType.movie:
        return '映画';
      case NetflixContentType.series:
        return 'シリーズ';
      case NetflixContentType.documentary:
        return 'ドキュメンタリー';
      case NetflixContentType.anime:
        return 'アニメ';
      case NetflixContentType.standup:
        return 'スタンダップコメディ';
      case NetflixContentType.kids:
        return 'キッズ';
      case NetflixContentType.reality:
        return 'リアリティ番組';
      case NetflixContentType.other:
        return 'その他';
    }
  }

  /// 視聴状態表示名取得
  String _getWatchStatusDisplayName(NetflixWatchStatus status) {
    switch (status) {
      case NetflixWatchStatus.completed:
        return '完了';
      case NetflixWatchStatus.inProgress:
        return '視聴中';
      case NetflixWatchStatus.watchlist:
        return 'ウォッチリスト';
      case NetflixWatchStatus.stopped:
        return '中断';
    }
  }

  /// 視聴状態アイコン取得
  IconData _getWatchStatusIcon(NetflixWatchStatus status) {
    switch (status) {
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
  Color _getWatchStatusColor(NetflixWatchStatus status) {
    switch (status) {
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
}