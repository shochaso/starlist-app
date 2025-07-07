import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/services/spotify_playlist_parser.dart';
import '../../../src/services/spotify_history_parser.dart';

class YouTubeMusicImportScreen extends ConsumerStatefulWidget {
  const YouTubeMusicImportScreen({super.key});

  @override
  ConsumerState<YouTubeMusicImportScreen> createState() => _YouTubeMusicImportScreenState();
}

class _YouTubeMusicImportScreenState extends ConsumerState<YouTubeMusicImportScreen> {
  String selectedImportType = 'listening_history';
  final TextEditingController _textController = TextEditingController();
  bool isProcessing = false;
  List<Map<String, dynamic>> processedTracks = [];
  List<SpotifyTrack> extractedTracks = [];
  File? selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool showConfirmation = false;
  bool showPreview = false;
  List<bool> selectedTracks = [];

  final List<Map<String, String>> importTypes = [
    {
      'id': 'listening_history',
      'title': '再生履歴',
      'subtitle': '最近聴いた楽曲',
      'icon': 'Icons.history',
    },
    {
      'id': 'playlist',
      'title': 'プレイリスト',
      'subtitle': 'お気に入りプレイリスト',
      'icon': 'Icons.playlist_play',
    },
    {
      'id': 'liked_songs',
      'title': 'お気に入り',
      'subtitle': '高評価した楽曲',
      'icon': 'Icons.favorite',
    },
    {
      'id': 'artist',
      'title': 'アーティスト',
      'subtitle': 'フォロー中のアーティスト',
      'icon': 'Icons.person',
    },
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void _processImageOCR() async {
    if (selectedImage == null) return;

    setState(() {
      isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isProcessing = false;
      // OCR処理結果をテキストフィールドに設定
      _textController.text = 'OCR解析結果がここに表示されます';
      // TODO: OCR処理を実装
    });
  }

  void _processData() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      List<SpotifyTrack> parsedTracks = [];
      
      // YouTube Musicは基本的にSpotifyと同じ形式で処理
      switch (selectedImportType) {
        case 'listening_history':
          final historyItems = SpotifyHistoryParser.parseHistoryText(_textController.text);
          parsedTracks = historyItems.cast<SpotifyTrack>();
          break;
        case 'playlist':
        case 'liked_songs':
          parsedTracks = SpotifyPlaylistParser.parsePlaylistText(_textController.text);
          break;
        case 'artist':
        default:
          parsedTracks = SpotifyPlaylistParser.parsePlaylistText(_textController.text);
          break;
      }
      
      setState(() {
        extractedTracks = parsedTracks;
        selectedTracks = List.filled(parsedTracks.length, true);
        isProcessing = false;
        showPreview = parsedTracks.isNotEmpty;
      });

      if (parsedTracks.isEmpty) {
        _showErrorSnackBar('楽曲データを検出できませんでした。\nフォーマットを確認してください。');
      } else {
        debugPrint('YouTube Music - 検出された楽曲数: ${parsedTracks.length} ($selectedImportType)');
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      _showErrorSnackBar('データ解析中にエラーが発生しました: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _confirmImport() {
    final selectedMusicTracks = extractedTracks
        .asMap()
        .entries
        .where((entry) => selectedTracks[entry.key])
        .map((entry) => entry.value.toMap())
        .toList();

    setState(() {
      processedTracks = selectedMusicTracks;
      showPreview = false;
      showConfirmation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProviderEnhanced).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('YouTube Music データ取り込み'),
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFCC0000)], // YouTube Music レッド
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YouTube Music',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '音楽の再生履歴やプレイリストを取り込み',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // インポートタイプ選択
            Text(
              'データの種類を選択',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: importTypes.map((type) => _buildTypeChip(type, isDark)).toList(),
            ),

            const SizedBox(height: 24),

            // テキスト入力
            Text(
              _getInputLabel(),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                ),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: _getPlaceholderText(),
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.black38,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 画像選択（再生履歴のみ）
            if (selectedImportType == 'listening_history') ...[
              const SizedBox(height: 20),
              Text(
                'またはスクリーンショットから読み込み',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (selectedImage != null) ...[
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image, size: 18),
                      label: Text(selectedImage == null ? '画像を選択' : '画像を変更'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF444444) : const Color(0xFFF1F5F9),
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  if (selectedImage != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isProcessing ? null : _processImageOCR,
                        icon: isProcessing 
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.text_fields, size: 18),
                        label: Text(isProcessing ? '解析中...' : '画像を解析'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF0000),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 24),

            // 取り込みボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _processData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isProcessing
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
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
                          Text('データを解析中...'),
                        ],
                      )
                    : const Text(
                        'データを取り込む',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
            if (showPreview) _buildPreviewSection(isDark),
            if (showConfirmation) _buildConfirmationSection(isDark),
            if (isProcessing) _buildProcessingSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(Map<String, String> type, bool isDark) {
    final isSelected = selectedImportType == type['id'];
    return FilterChip(
      label: Text(
        type['title']!,
        style: TextStyle(
          color: isSelected 
              ? Colors.white 
              : isDark ? Colors.white70 : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          selectedImportType = type['id']!;
        });
      },
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      selectedColor: const Color(0xFFFF0000),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected 
            ? const Color(0xFFFF0000)
            : isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
      ),
    );
  }

  Widget _buildPreviewSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF0000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.music_note,
                color: Color(0xFFFF0000),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '検出された楽曲 (${extractedTracks.length}曲)',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    final allSelected = selectedTracks.every((s) => s);
                    selectedTracks = List.filled(selectedTracks.length, !allSelected);
                  });
                },
                icon: Icon(
                  selectedTracks.every((s) => s) 
                      ? Icons.check_box 
                      : Icons.check_box_outline_blank,
                  color: const Color(0xFFFF0000),
                  size: 20,
                ),
                tooltip: '全選択/全解除',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '取り込む楽曲を選択してください',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: extractedTracks.length,
              itemBuilder: (context, index) {
                final track = extractedTracks[index];
                final isSelected = selectedTracks[index];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC))
                        : (isDark ? const Color(0xFF404040).withValues(alpha: 0.3) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFFFF0000)
                          : (isDark ? const Color(0xFF525252) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            selectedTracks[index] = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFFFF0000),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              track.artist,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showPreview = false;
                      extractedTracks.clear();
                      selectedTracks.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white54 : Colors.black54,
                    side: BorderSide(color: isDark ? Colors.white54 : Colors.black54),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('キャンセル'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedTracks.any((selected) => selected) ? _confirmImport : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('${selectedTracks.where((s) => s).length}曲を取り込む'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF0000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFF0000),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '取り込み完了',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${processedTracks.length}件の音楽データが正常に取り込まれました。',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showConfirmation = false;
                      showPreview = false;
                      _textController.clear();
                      processedTracks.clear();
                      extractedTracks.clear();
                      selectedTracks.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('続けて取り込む'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF0000),
                    side: const BorderSide(color: Color(0xFFFF0000)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('完了'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF0000),
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
          ),
          const SizedBox(height: 16),
          Text(
            'YouTube Musicデータを解析しています...',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'しばらくお待ちください',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getInputLabel() {
    switch (selectedImportType) {
      case 'listening_history':
        return '再生履歴データ';
      case 'playlist':
        return 'プレイリスト情報';
      case 'liked_songs':
        return 'お気に入り楽曲';
      case 'artist':
        return 'アーティスト情報';
      default:
        return 'データ';
    }
  }

  String _getPlaceholderText() {
    switch (selectedImportType) {
      case 'listening_history':
        return '例：\nあいみょん\nアーティスト・2曲を再生済み\n\nマリーゴールド\nあいみょん\n\n空の青さを知る人よ\nあいみょん\n\nまたはYouTube Musicの再生履歴画面をOCRで読み取ったテキストをペーストしてください';
      case 'playlist':
        return '例：\nプレイリスト: お気に入りJ-POP\n1. マリーゴールド - あいみょん\n2. 空の青さを知る人よ - あいみょん\n3. 夜に駆ける - YOASOBI\n\nまたはプレイリスト画面をOCRで読み取ったテキストをペーストしてください';
      case 'liked_songs':
        return '例：\n高評価した楽曲:\nマリーゴールド - あいみょん\n夜に駆ける - YOASOBI\n炎 - LiSA\n\nまたはお気に入り楽曲一覧をOCRで読み取ったテキストをペーストしてください';
      case 'artist':
        return '例：\nフォロー中のアーティスト:\nあいみょん\nYOASOBI\nLiSA\nOfficial髭男dism\n\nまたはフォロー中アーティスト一覧をOCRで読み取ったテキストをペーストしてください';
      default:
        return 'YouTube Musicからのデータを入力してください';
    }
  }
}