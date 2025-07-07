import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/services/spotify_playlist_parser.dart';
import '../../../src/services/spotify_history_parser.dart';

class MusicImportScreen extends ConsumerStatefulWidget {
  const MusicImportScreen({super.key});

  @override
  ConsumerState<MusicImportScreen> createState() => _MusicImportScreenState();
}

class _MusicImportScreenState extends ConsumerState<MusicImportScreen>
    with TickerProviderStateMixin {
  String selectedImportType = 'listening_history'; // listening_history, playlist, artist
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isProcessing = false;
  List<Map<String, dynamic>> processedTracks = [];
  List<SpotifyTrack> extractedTracks = [];
  File? selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool showConfirmation = false;
  bool showPreview = false;
  List<bool> selectedTracks = [];

  // 音楽取り込みタイプ
  final List<Map<String, dynamic>> importTypes = [
    {
      'id': 'listening_history',
      'title': '再生履歴',
      'subtitle': '音楽ストリーミングサービスの再生履歴',
      'icon': Icons.music_note,
      'color': const Color(0xFF1DB954), // Spotify green
      'description': 'Spotify、Apple Music、YouTube Musicなどの再生履歴を記録します',
    },
    {
      'id': 'playlist',
      'title': 'プレイリスト',
      'subtitle': 'お気に入りプレイリストの登録',
      'icon': Icons.playlist_play,
      'color': const Color(0xFF1ED760),
      'description': 'プレイリストのURLや楽曲リストを入力して記録します',
    },
    {
      'id': 'artist',
      'title': 'アーティスト',
      'subtitle': 'お気に入りアーティストの登録',
      'icon': Icons.person,
      'color': const Color(0xFF1CB854),
      'description': 'フォローしているアーティストや好きなアーティストを記録します',
    },
    {
      'id': 'concert',
      'title': 'ライブ・コンサート',
      'subtitle': '参加したライブの記録',
      'icon': Icons.event,
      'color': const Color(0xFF17A74A),
      'description': '参加したライブやコンサートの記録を残します',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '音楽データ取り込み',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 24),
              _buildImportTypeSelector(isDark),
              const SizedBox(height: 24),
              _buildDataInputSection(isDark),
              const SizedBox(height: 24),
              if (showPreview) _buildPreviewSection(isDark),
              if (showConfirmation) _buildConfirmationSection(isDark),
              if (isProcessing) _buildProcessingSection(isDark),
              const SizedBox(height: 100), // ボトムナビゲーション用のスペース
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(isDark),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1DB954), Color(0xFF1CB854)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '音楽データ取り込み',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '音楽ストリーミングサービスのデータを記録',
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
        ],
      ),
    );
  }

  Widget _buildImportTypeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '取り込みタイプを選択',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...importTypes.map((type) => _buildImportTypeCard(type, isDark)),
      ],
    );
  }

  Widget _buildImportTypeCard(Map<String, dynamic> type, bool isDark) {
    final isSelected = selectedImportType == type['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImportType = type['id'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? (isDark ? const Color(0xFF2A2A2A) : Colors.white)
            : (isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? type['color'] 
              : (isDark ? const Color(0xFF404040) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: type['color'].withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: type['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                type['icon'],
                color: type['color'],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type['title'],
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type['subtitle'],
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type['description'],
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: type['color'],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataInputSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'データ入力方法',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // タブ切り替え
          Row(
            children: [
              _buildInputMethodTab('テキスト入力', Icons.text_fields, isDark, true),
              const SizedBox(width: 12),
              _buildInputMethodTab('画像OCR', Icons.camera_alt, isDark, false),
              const SizedBox(width: 12),
              _buildInputMethodTab('URL取得', Icons.link, isDark, false),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 入力フィールド
          _buildTextInputField(isDark),
          
          const SizedBox(height: 16),
          
          // アクションボタン
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  '画像を選択',
                  Icons.photo_library,
                  () => _selectImage(),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'カメラで撮影',
                  Icons.camera_alt,
                  () => _takePhoto(),
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputMethodTab(String title, IconData icon, bool isDark, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive 
          ? const Color(0xFF1DB954)
          : (isDark ? const Color(0xFF404040) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputField(bool isDark) {
    String placeholder = _getPlaceholderText();
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: _textController,
        maxLines: 8,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  String _getPlaceholderText() {
    switch (selectedImportType) {
      case 'listening_history':
        return '例：\nBE:FIRST\nアーティスト・2曲を再生済み\n\nBoom Boom Back\nBE:FIRST\n\nGRIT\nBE:FIRST\n\nHANA Mix\n2曲を再生済み・プレイリスト・Spotify\n\n夢中\nBE:FIRST\n\nまたはSpotifyの再生履歴画面をOCRで読み取ったテキストをペーストしてください';
      case 'playlist':
        return '例：\nプレイリスト名: お気に入りJ-POP\n楽曲1: 紅蓮華 - LiSA\n楽曲2: 炎 - LiSA\n楽曲3: Pretender - Official髭男dism\n\nまたはプレイリストのURLを入力してください';
      case 'artist':
        return '例：\nアーティスト: YOASOBI\nジャンル: J-POP\nフォロー日: 2024/01/15\n\nお気に入りアーティスト: BTS, あいみょん, 米津玄師';
      case 'concert':
        return '例：\nイベント名: YOASOBI LIVE TOUR 2024\n会場: 東京ドーム\n開催日: 2024/03/15\n座席: アリーナA1\n\n参加したライブやコンサートの情報を入力してください';
      default:
        return '音楽関連のデータを入力してください';
    }
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF404040) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF525252) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
          color: const Color(0xFF1DB954),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.music_note,
                color: Color(0xFF1DB954),
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
                  color: const Color(0xFF1DB954),
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
                          ? const Color(0xFF1DB954)
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
                        activeColor: const Color(0xFF1DB954),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (track.trackNumber != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1DB954).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '#${track.trackNumber}',
                                      style: const TextStyle(
                                        color: Color(0xFF1DB954),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    track.title,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    track.artist,
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (track.duration != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    track.duration!,
                                    style: TextStyle(
                                      color: isDark ? Colors.white60 : Colors.black45,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getConfidenceColor(track.confidence).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${(track.confidence * 100).toInt()}%',
                                    style: TextStyle(
                                      color: _getConfidenceColor(track.confidence),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (track.album != null && track.album!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'アルバム: ${track.album}',
                                style: TextStyle(
                                  color: isDark ? Colors.white54 : Colors.black45,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
                    backgroundColor: const Color(0xFF1DB954),
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

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildConfirmationSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1DB954),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1DB954),
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
                    backgroundColor: const Color(0xFF1DB954),
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
                    foregroundColor: const Color(0xFF1DB954),
                    side: const BorderSide(color: Color(0xFF1DB954)),
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
          color: isDark ? const Color(0xFF404040) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
          ),
          const SizedBox(height: 16),
          Text(
            '音楽データを解析中...',
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
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDark) {
    return FloatingActionButton.extended(
      onPressed: _textController.text.trim().isNotEmpty && !isProcessing
          ? _processData
          : null,
      backgroundColor: _textController.text.trim().isNotEmpty && !isProcessing
          ? const Color(0xFF1DB954)
          : (isDark ? const Color(0xFF404040) : Colors.grey[300]),
      foregroundColor: _textController.text.trim().isNotEmpty && !isProcessing
          ? Colors.white
          : (isDark ? Colors.white38 : Colors.black38),
      label: const Text('データを取り込む'),
      icon: isProcessing 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.upload),
    );
  }

  void _selectImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
      // TODO: OCR処理を実装
    }
  }

  void _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
      // TODO: OCR処理を実装
    }
  }

  void _processData() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      List<SpotifyTrack> parsedTracks = [];
      
      // 選択されたインポートタイプに応じて適切なパーサーを使用
      switch (selectedImportType) {
        case 'listening_history':
          final historyItems = SpotifyHistoryParser.parseHistoryText(_textController.text);
          parsedTracks = historyItems.cast<SpotifyTrack>();
          break;
        case 'playlist':
          parsedTracks = SpotifyPlaylistParser.parsePlaylistText(_textController.text);
          break;
        case 'artist':
        case 'concert':
        default:
          // 汎用パーサーを使用
          parsedTracks = SpotifyPlaylistParser.parsePlaylistText(_textController.text);
          break;
      }
      
      setState(() {
        extractedTracks = parsedTracks;
        selectedTracks = List.filled(parsedTracks.length, true); // デフォルトで全選択
        isProcessing = false;
        showPreview = parsedTracks.isNotEmpty;
      });

      if (parsedTracks.isEmpty) {
        _showErrorSnackBar('楽曲データを検出できませんでした。\nフォーマットを確認してください。');
      } else {
        debugPrint('検出された楽曲数: ${parsedTracks.length} ($selectedImportType)');
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
}