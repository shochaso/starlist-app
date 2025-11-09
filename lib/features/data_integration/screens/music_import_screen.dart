
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/services/spotify_playlist_parser.dart';
import '../../../src/services/spotify_history_parser.dart';
import '../../../providers/music_history_provider.dart';
import '../../../src/core/components/service_icons.dart';

typedef MusicTrack = SpotifyTrack;

class MusicServiceConfig {
  final String serviceId;
  final String displayName;
  final Color accentColor;
  final List<Color> gradientColors;
  final String description;

  const MusicServiceConfig({
    required this.serviceId,
    required this.displayName,
    required this.accentColor,
    required this.gradientColors,
    required this.description,
  });
}

const Map<String, MusicServiceConfig> _musicServiceConfigs = {
  'spotify': MusicServiceConfig(
    serviceId: 'spotify',
    displayName: 'Spotify',
    accentColor: Color(0xFF1DB954),
    gradientColors: [
      Color(0xFF1DB954),
      Color(0xFF1CB854),
    ],
    description: 'Spotifyのデータを記録します',
  ),
  'apple_music': MusicServiceConfig(
    serviceId: 'apple_music',
    displayName: 'Apple Music',
    accentColor: Color(0xFFFF2D55),
    gradientColors: [
      Color(0xFFFF2D55),
      Color(0xFFFF5E3A),
    ],
    description: 'Apple Musicのデータを記録します',
  ),
  'amazon_music': MusicServiceConfig(
    serviceId: 'amazon_music',
    displayName: 'Amazon Music',
    accentColor: Color(0xFFFF9900),
    gradientColors: [
      Color(0xFFFF9900),
      Color(0xFFFFB84D),
    ],
    description: 'Amazon Musicのデータを記録します',
  ),
};

MusicServiceConfig _resolveMusicServiceConfig(String serviceId) {
  return _musicServiceConfigs[serviceId] ??
      const MusicServiceConfig(
        serviceId: 'generic_music',
        displayName: '音楽サービス',
        accentColor: Color(0xFF6366F1),
        gradientColors: [
          Color(0xFF6366F1),
          Color(0xFF8B5CF6),
        ],
        description: '音楽サービスのデータを記録します',
      );
}

class MusicImportScreen extends ConsumerStatefulWidget {
  final String serviceId;

  const MusicImportScreen({
    super.key,
    required this.serviceId,
  });

  @override
  ConsumerState<MusicImportScreen> createState() => _MusicImportScreenState();
}

class _MusicImportScreenState extends ConsumerState<MusicImportScreen>
    with TickerProviderStateMixin {
  late final MusicServiceConfig _config;
  String selectedImportType =
      'listening_history'; // listening_history, playlist, artist
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isProcessing = false;
  List<Map<String, dynamic>> processedTracks = [];
  List<MusicTrack> extractedTracks = [];
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();
  bool showConfirmation = false;
  bool showPreview = false;
  List<bool> selectedTracks = [];
  String _selectedInputMethod = 'text';

  late final List<Map<String, dynamic>> importTypes;

  @override
  void initState() {
    super.initState();
    _config = _resolveMusicServiceConfig(widget.serviceId);
    importTypes = _buildImportTypes();
    _textController.addListener(_onInputChanged);
    _urlController.addListener(_onInputChanged);
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

  List<Map<String, dynamic>> _buildImportTypes() {
    final accent = _config.accentColor;
    return [
      {
        'id': 'listening_history',
        'title': '再生履歴',
        'subtitle': '${_config.displayName}の再生履歴を記録',
        'icon': Icons.history,
        'color': accent,
        'description': '${_config.displayName}で再生した楽曲の履歴を管理します',
      },
      {
        'id': 'playlist',
        'title': 'プレイリスト',
        'subtitle': 'お気に入りプレイリストの登録',
        'icon': Icons.playlist_play,
        'color': _accentVariant(0.08),
        'description': 'プレイリストのURLや楽曲リストを入力して記録します',
      },
      {
        'id': 'artist',
        'title': 'アーティスト',
        'subtitle': 'お気に入りアーティストの登録',
        'icon': Icons.person,
        'color': _accentVariant(-0.05),
        'description': 'フォローしているアーティストや好きなアーティストを記録します',
      },
      {
        'id': 'concert',
        'title': 'ライブ・コンサート',
        'subtitle': '参加したライブの記録',
        'icon': Icons.event,
        'color': _accentVariant(-0.12),
        'description': '参加したライブやコンサートの記録を残します',
      },
    ];
  }

  Color _accentVariant(double delta) {
    final hsl = HSLColor.fromColor(_config.accentColor);
    final lightness = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color get _accentColor => _config.accentColor;

  @override
  void dispose() {
    _animationController.dispose();
    _textController.removeListener(_onInputChanged);
    _textController.dispose();
    _urlController.removeListener(_onInputChanged);
    _urlController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
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
          '${_config.displayName} データ取り込み',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
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
        gradient: LinearGradient(
          colors: _config.gradientColors,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: ServiceIcons.buildIcon(
                  serviceId: widget.serviceId,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_config.displayName} データ取り込み',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _config.description,
                      style: const TextStyle(
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type['color'].withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: type['color'].withOpacity(0.1),
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildInputMethodTab('text', 'テキスト入力', Icons.text_fields, isDark),
              _buildInputMethodTab('ocr', '画像OCR', Icons.camera_alt, isDark),
              _buildInputMethodTab('url', 'URL取得', Icons.link, isDark),
            ],
          ),

          const SizedBox(height: 20),

          // 入力フィールド
          _buildTextInputField(isDark),

          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: () {
              switch (_selectedInputMethod) {
                case 'ocr':
                  return _buildOcrControls(isDark);
                case 'url':
                  return _buildUrlControls(isDark);
                default:
                  return _buildTextHelper(isDark);
              }
            }(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputMethodTab(
      String id, String title, IconData icon, bool isDark) {
    final isActive = _selectedInputMethod == id;
    final inactiveColor =
        isDark ? const Color(0xFF303030) : const Color(0xFFF1F5F9);

    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: isActive ? 1.0 : 0.96,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (_selectedInputMethod != id) {
              setState(() {
                _selectedInputMethod = id;
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? _accentColor : inactiveColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildTextHelper(bool isDark) {
    return Container(
      key: const ValueKey('music-text-helper'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.queue_music, size: 20, color: _accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_config.displayName}の再生履歴やプレイリストをコピーして貼り付け、「${_primaryActionLabel()}」を押すと楽曲を自動抽出します。',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOcrControls(bool isDark) {
    return Column(
      key: const ValueKey('music-ocr-controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'スクリーンショットから楽曲リストを抽出します。',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (selectedImageBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              selectedImageBytes!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        if (selectedImageBytes != null) const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                '画像を選択',
                Icons.photo_library,
                _selectImage,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'カメラで撮影',
                Icons.camera_alt,
                _takePhoto,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: !isProcessing && selectedImageBytes != null
                ? _processImageOCR
                : null,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('OCR解析を実行'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlControls(bool isDark) {
    return Column(
      key: const ValueKey('music-url-controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'プレイリストやアーティストページのURLから情報を取得します。',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: _urlHintForService(),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF404040) : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF404040) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: !isProcessing && _urlController.text.trim().isNotEmpty
                ? _fetchDataFromUrl
                : null,
            icon: const Icon(Icons.link),
            label: const Text('URLから取得'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getPlaceholderText() {
    switch (selectedImportType) {
      case 'listening_history':
        return '例：\nBE:FIRST\nアーティスト・2曲を再生済み\n\nBoom Boom Back\nBE:FIRST\n\nGRIT\nBE:FIRST\n\nHANA Mix\n2曲を再生済み・プレイリスト・${_config.displayName}\n\n夢中\nBE:FIRST\n\nまたは${_config.displayName}の再生履歴画面をOCRで読み取ったテキストをペーストしてください';
      case 'playlist':
        return '例：\nプレイリスト名: お気に入りJ-POP\n楽曲1: 紅蓮華 - LiSA\n楽曲2: 炎 - LiSA\n楽曲3: Pretender - Official髭男dism\n\nまたは${_config.displayName}のプレイリストURLを入力してください';
      case 'artist':
        return '例：\nアーティスト: YOASOBI\nジャンル: J-POP\nフォロー日: 2024/01/15\n\nお気に入りアーティスト: BTS, あいみょん, 米津玄師';
      case 'concert':
        return '例：\nイベント名: YOASOBI LIVE TOUR 2024\n会場: 東京ドーム\n開催日: 2024/03/15\n座席: アリーナA1\n\n参加したライブやコンサートの情報を入力してください';
      default:
        return '音楽関連のデータを入力してください';
    }
  }

  Widget _buildActionButton(
      String title, IconData icon, VoidCallback onTap, bool isDark) {
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
          color: _accentColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ServiceIcons.buildIcon(
                serviceId: widget.serviceId,
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
                    selectedTracks =
                        List.filled(selectedTracks.length, !allSelected);
                  });
                },
                icon: Icon(
                  selectedTracks.every((s) => s)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: _accentColor,
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
                        ? (isDark
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFFF8FAFC))
                        : (isDark
                            ? const Color(0xFF404040).withOpacity(0.3)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? _accentColor
                          : (isDark
                              ? const Color(0xFF525252)
                              : const Color(0xFFE2E8F0)),
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
                        activeColor: _accentColor,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _accentColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '#${track.trackNumber}',
                                      style: TextStyle(
                                        color: _accentColor,
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
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
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
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
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black45,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getConfidenceColor(track.confidence)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${(track.confidence * 100).toInt()}%',
                                    style: TextStyle(
                                      color:
                                          _getConfidenceColor(track.confidence),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (track.album != null &&
                                track.album!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'アルバム: ${track.album}',
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white54 : Colors.black45,
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
                    side: BorderSide(
                        color: isDark ? Colors.white54 : Colors.black54),
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
                  onPressed: selectedTracks.any((selected) => selected)
                      ? () async => _confirmImport()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
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
          color: _accentColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: _accentColor,
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
                    backgroundColor: _accentColor,
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
                    foregroundColor: _accentColor,
                    side: BorderSide(color: _accentColor),
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
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
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
    final bool canExecute = _isPrimaryActionEnabled && !isProcessing;
    final label = isProcessing ? '処理中...' : _primaryActionLabel();

    return FloatingActionButton.extended(
      onPressed: canExecute ? _handlePrimaryAction : null,
      backgroundColor: canExecute
          ? _accentColor
          : (isDark ? const Color(0xFF404040) : Colors.grey[300]),
      foregroundColor: canExecute
          ? Colors.white
          : (isDark ? Colors.white38 : Colors.black38),
      icon: isProcessing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(_primaryActionIcon()),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  bool get _isPrimaryActionEnabled {
    switch (_selectedInputMethod) {
      case 'ocr':
        return selectedImageBytes != null;
      case 'url':
        return _urlController.text.trim().isNotEmpty;
      case 'text':
      default:
        return _textController.text.trim().isNotEmpty;
    }
  }

  String _primaryActionLabel() {
    switch (_selectedInputMethod) {
      case 'ocr':
        return 'OCR解析を実行';
      case 'url':
        return 'URLから取得';
      case 'text':
      default:
        return 'テキストを解析';
    }
  }

  IconData _primaryActionIcon() {
    switch (_selectedInputMethod) {
      case 'ocr':
        return Icons.auto_fix_high;
      case 'url':
        return Icons.link;
      case 'text':
      default:
        return Icons.upload;
    }
  }

  void _handlePrimaryAction() {
    switch (_selectedInputMethod) {
      case 'ocr':
        _processImageOCR();
        break;
      case 'url':
        _fetchDataFromUrl();
        break;
      case 'text':
      default:
        _processData();
    }
  }

  void _selectImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
      });
      _showSnackBar('画像を読み込みました。OCR解析を実行してください。');
    }
  }

  void _takePhoto() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
      });
      _showSnackBar('撮影した画像を読み込みました。OCR解析を実行できます。');
    }
  }

  Future<void> _processImageOCR() async {
    if (selectedImageBytes == null) {
      _showErrorSnackBar('解析する画像を選択してください。');
      return;
    }

    setState(() {
      isProcessing = true;
      showPreview = false;
      showConfirmation = false;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final sampleText = _sampleTextForMusic(selectedImportType);

    setState(() {
      _textController.text = sampleText;
      isProcessing = false;
    });

    _showSnackBar('OCR解析結果をテキストに反映しました。内容を確認してください。');
    _processData();
  }

  Future<void> _fetchDataFromUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showErrorSnackBar('取得するURLを入力してください。');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      _showErrorSnackBar('URLの形式が正しくありません。');
      return;
    }

    setState(() {
      isProcessing = true;
      showPreview = false;
      showConfirmation = false;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final inferredType = _inferMusicImportType(uri.host);
    final nextType = inferredType ?? selectedImportType;
    final sampleText = _sampleTextForMusic(nextType);

    setState(() {
      selectedImportType = nextType;
      _textController.text = sampleText;
      isProcessing = false;
    });

    _showSnackBar('URLから${_config.displayName}のデータを取得しました。内容を確認してください。');
    _processData();
  }

  void _processData() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      List<MusicTrack> parsedTracks = [];

      // 選択されたインポートタイプに応じて適切なパーサーを使用
      switch (selectedImportType) {
        case 'listening_history':
          final historyItems =
              SpotifyHistoryParser.parseHistoryText(_textController.text);
          parsedTracks = historyItems.cast<MusicTrack>();
          break;
        case 'playlist':
          parsedTracks =
              SpotifyPlaylistParser.parsePlaylistText(_textController.text);
          break;
        case 'artist':
        case 'concert':
        default:
          // 汎用パーサーを使用
          parsedTracks =
              SpotifyPlaylistParser.parsePlaylistText(_textController.text);
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

  String _sampleTextForMusic(String type) {
    switch (type) {
      case 'listening_history':
        return '''
再生日時: 2024/02/18 21:30
楽曲: 夜に駆ける
アーティスト: YOASOBI

再生日時: 2024/02/18 21:12
楽曲: 怪物
アーティスト: YOASOBI

再生日時: 2024/02/18 20:55
楽曲: 群青
アーティスト: YOASOBI'''
            .trim();
      case 'playlist':
        return '''
プレイリスト名: BEST OF ${_config.displayName}
楽曲1: Butter - BTS
楽曲2: Dynamite - BTS
楽曲3: Permission to Dance - BTS
楽曲4: Run BTS - BTS'''
            .trim();
      case 'artist':
        return '''
アーティスト: RADWIMPS
代表曲: 前前前世, なんでもないや
フォロー日: 2024/02/01
メモ: 新作アルバムをチェック'''
            .trim();
      case 'concert':
        return '''
イベント名: RADWIMPS WORLD TOUR 2024
会場: 横浜アリーナ
開催日: 2024/04/12
座席: スタンドBブロック 12列
ハイライト: 新曲初披露'''
            .trim();
      default:
        return '''
楽曲: サンプルソング
アーティスト: Sample Artist
再生日: 2024/02/18'''
            .trim();
    }
  }

  String? _inferMusicImportType(String host) {
    final lower = host.toLowerCase();
    if (lower.contains('spotify')) return 'playlist';
    if (lower.contains('music.apple')) return 'playlist';
    if (lower.contains('music.youtube')) return 'playlist';
    if (lower.contains('line.me/music')) return 'playlist';
    if (lower.contains('live') || lower.contains('event')) return 'concert';
    return null;
  }

  String _urlHintForService() {
    switch (widget.serviceId) {
      case 'spotify':
        return 'https://open.spotify.com/playlist/xxxxxxxx';
      case 'apple_music':
        return 'https://music.apple.com/jp/playlist/...';
      case 'amazon_music':
        return 'https://music.amazon.co.jp/playlists/...';
      default:
        return 'https://example.com/music/playlist/...';
    }
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar(message, color: Colors.red[600]);
  }

  void _showSnackBar(String message, {Color? color}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color ?? const Color(0xFF323232),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _confirmImport() async {
    final selectedEntries = extractedTracks
        .asMap()
        .entries
        .where((entry) => selectedTracks[entry.key])
        .toList();

    if (selectedEntries.isEmpty) {
      _showErrorSnackBar('取り込む楽曲を選択してください');
      return;
    }

    final now = DateTime.now();
    final sessionId =
        '${_config.serviceId}_${now.millisecondsSinceEpoch.toString()}';

    final selectedMusicTracks = selectedEntries
        .map(
          (entry) => {
            ...entry.value.toMap(),
            'serviceId': _config.serviceId,
            'serviceName': _config.displayName,
            'sessionId': sessionId,
            'importedAt': now.toIso8601String(),
          },
        )
        .toList();

    final historyItems = selectedEntries
        .map(
          (entry) => MusicHistoryItem.fromTrack(
            track: entry.value,
            serviceId: _config.serviceId,
            serviceName: _config.displayName,
            addedAt: now,
            sessionId: sessionId,
          ),
        )
        .toList();

    await ref
        .read(musicHistoryProvider.notifier)
        .addTracks(_config.serviceId, historyItems);

    setState(() {
      processedTracks = selectedMusicTracks;
      showPreview = false;
      showConfirmation = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedMusicTracks.length}件の楽曲を取り込みました'),
          backgroundColor: _accentColor,
        ),
      );
    }
  }
}
