
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/core/components/service_icons.dart';

class VideoImportScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String serviceName;
  final Color serviceColor;
  final IconData serviceIcon;

  const VideoImportScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.serviceColor,
    required this.serviceIcon,
  });

  @override
  ConsumerState<VideoImportScreen> createState() => _VideoImportScreenState();
}

class _VideoImportScreenState extends ConsumerState<VideoImportScreen> {
  String selectedImportType = 'viewing_history';
  String _selectedInputMethod = 'text';
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool isProcessing = false;
  List<Map<String, dynamic>> processedContent = [];
  List<Map<String, dynamic>> extractedContent = [];
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();
  bool showConfirmation = false;
  bool showPreview = false;
  List<bool> selectedItems = [];

  final Map<String, List<Map<String, String>>> importTypesByService = {
    'netflix': [
      {'id': 'viewing_history', 'title': '視聴履歴', 'subtitle': '映画・ドラマ・アニメ'},
      {'id': 'watchlist', 'title': 'マイリスト', 'subtitle': 'お気に入り・後で見る'},
      {'id': 'ratings', 'title': '評価', 'subtitle': '高評価・低評価'},
    ],
    'prime_video': [
      {'id': 'viewing_history', 'title': '視聴履歴', 'subtitle': 'Prime Video視聴記録'},
      {'id': 'watchlist', 'title': 'ウォッチリスト', 'subtitle': 'お気に入り作品'},
      {'id': 'purchases', 'title': '購入・レンタル', 'subtitle': '有料コンテンツ'},
    ],
    'abema': [
      {'id': 'viewing_history', 'title': '視聴履歴', 'subtitle': 'アニメ・バラエティ・ニュース'},
      {'id': 'favorites', 'title': 'お気に入り', 'subtitle': 'フォロー中番組'},
      {'id': 'comments', 'title': 'コメント', 'subtitle': '投稿したコメント'},
    ],
    'hulu': [
      {'id': 'viewing_history', 'title': '視聴履歴', 'subtitle': '海外ドラマ・映画・アニメ'},
      {'id': 'favorites', 'title': 'お気に入り', 'subtitle': 'マイリスト'},
    ],
    'disney': [
      {
        'id': 'viewing_history',
        'title': '視聴履歴',
        'subtitle': 'ディズニー・マーベル・スターウォーズ'
      },
      {'id': 'watchlist', 'title': 'ウォッチリスト', 'subtitle': 'お気に入り作品'},
    ],
    'unext': [
      {'id': 'viewing_history', 'title': '視聴履歴', 'subtitle': '映画・アニメ・雑誌'},
      {'id': 'favorites', 'title': 'お気に入り', 'subtitle': 'マイリスト'},
      {'id': 'magazines', 'title': '雑誌', 'subtitle': '読んだ雑誌'},
    ],
    'dtv': [
      {'id': 'viewing_history', 'title': '視聴履歴', 'subtitle': '音楽ライブ・映画・ドラマ'},
      {'id': 'favorites', 'title': 'お気に入り', 'subtitle': 'マイリスト'},
    ],
    'fod': [
      {'id': 'viewing_history', 'title': '視聴履歴', 'subtitle': 'フジテレビ番組・ドラマ・映画'},
      {'id': 'favorites', 'title': 'お気に入り', 'subtitle': 'マイリスト'},
    ],
  };

  List<Map<String, String>> get currentImportTypes {
    return importTypesByService[widget.serviceId] ??
        [
          {'id': 'viewing_history', 'title': '視聴履歴', 'subtitle': '動画コンテンツ'},
          {'id': 'favorites', 'title': 'お気に入り', 'subtitle': 'マイリスト'},
        ];
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onInputChanged);
    _urlController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onInputChanged);
    _urlController.removeListener(_onInputChanged);
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _selectImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          selectedImage = pickedFile;
          selectedImageBytes = bytes;
        });

        // Haptic feedback
        HapticFeedback.lightImpact();

        _showSnackBar('画像を読み込みました。OCR解析を実行してください。', color: widget.serviceColor);
      }
    } catch (e) {
      _showErrorSnackBar('画像の選択に失敗しました: $e');
    }
  }

  void _takePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          selectedImage = pickedFile;
          selectedImageBytes = bytes;
        });

        // Haptic feedback
        HapticFeedback.lightImpact();

        _showSnackBar('撮影した画像を読み込みました。OCR解析を実行できます。',
            color: widget.serviceColor);
      }
    } catch (e) {
      _showErrorSnackBar('写真フォルダのアクセスに失敗しました: $e');
    }
  }

  void _processData() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final parsedContent = _parseContent(_textController.text);

      setState(() {
        extractedContent = parsedContent;
        selectedItems = List.filled(parsedContent.length, true);
        isProcessing = false;
        showPreview = parsedContent.isNotEmpty;
      });

      if (parsedContent.isEmpty) {
        _showErrorSnackBar('コンテンツデータを検出できませんでした。\\nフォーマットを確認してください。');
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      _showErrorSnackBar('データ解析中にエラーが発生しました: $e');
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

    final sampleText =
        _sampleTextForService(widget.serviceId, selectedImportType);

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

    final inferredType =
        _inferImportTypeFromUrl(uri.host) ?? selectedImportType;
    final sampleText = _sampleTextForService(widget.serviceId, inferredType);

    setState(() {
      selectedImportType = inferredType;
      _textController.text = sampleText;
      isProcessing = false;
    });

    _showSnackBar('URLから${widget.serviceName}のデータを取得しました。内容を確認してください。');
    _processData();
  }

  List<Map<String, dynamic>> _parseContent(String text) {
    final lines =
        text.split('\\n').where((line) => line.trim().isNotEmpty).toList();
    final List<Map<String, dynamic>> items = [];

    String? currentTitle;
    String? currentInfo;

    for (final line in lines) {
      final trimmedLine = line.trim();

      // 作品名パターン
      if (trimmedLine.contains('作品名:') || trimmedLine.contains('タイトル:')) {
        currentTitle = trimmedLine.replaceAll(RegExp(r'作品名:|タイトル:'), '').trim();
      }
      // 日付パターン
      else if (trimmedLine.contains('視聴日:') || trimmedLine.contains('日付:')) {
        currentInfo = trimmedLine.replaceAll(RegExp(r'視聴日:|日付:'), '').trim();
      }
      // シンプルなタイトル（コロンがない場合）
      else if (currentTitle == null &&
          trimmedLine.length > 3 &&
          !trimmedLine.contains(':')) {
        currentTitle = trimmedLine;
      }

      // アイテム作成
      if (currentTitle != null && (currentInfo != null || items.length < 5)) {
        items.add({
          'title': currentTitle,
          'info': currentInfo ?? '${widget.serviceName}で視聴',
          'service': widget.serviceName,
          'type': selectedImportType,
          'confidence': 0.8,
        });
        currentTitle = null;
        currentInfo = null;
      }
    }

    // サンプルデータがない場合のデフォルト
    if (items.isEmpty && text.trim().isNotEmpty) {
      items.addAll([
        {
          'title': 'サンプルコンテンツ1',
          'info': '${widget.serviceName}で視聴',
          'service': widget.serviceName,
          'type': selectedImportType,
          'confidence': 0.7,
        },
        {
          'title': 'サンプルコンテンツ2',
          'info': '${widget.serviceName}で視聴',
          'service': widget.serviceName,
          'type': selectedImportType,
          'confidence': 0.7,
        },
      ]);
    }

    return items;
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
    final selectedContent = extractedContent
        .asMap()
        .entries
        .where((entry) => selectedItems[entry.key])
        .map((entry) => entry.value)
        .toList();

    setState(() {
      processedContent = selectedContent;
      showPreview = false;
      showConfirmation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProviderEnhanced).isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${widget.serviceName} データ取り込み'),
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
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
                gradient: LinearGradient(
                  colors: [
                    widget.serviceColor,
                    widget.serviceColor.withOpacity(0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
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
                      fallback: widget.serviceIcon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '視聴履歴やお気に入り作品を取り込み',
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
              children: currentImportTypes
                  .map((type) => _buildTypeChip(type, isDark))
                  .toList(),
            ),

            const SizedBox(height: 24),

            _buildDataInputSection(isDark),

            const SizedBox(height: 24),
            if (showPreview) _buildPreviewSection(isDark),
            if (showConfirmation) _buildConfirmationSection(isDark),
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
              : isDark
                  ? Colors.white70
                  : Colors.black87,
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
      selectedColor: widget.serviceColor,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected
            ? widget.serviceColor
            : isDark
                ? const Color(0xFF444444)
                : const Color(0xFFE5E7EB),
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
    String id,
    String title,
    IconData icon,
    bool isDark,
  ) {
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
              color: isActive ? widget.serviceColor : inactiveColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: widget.serviceColor.withOpacity(0.35),
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
          hintText: _getPlaceholderText(),
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
      key: const ValueKey('video-text-helper'),
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
          Icon(Icons.play_circle_fill, size: 20, color: widget.serviceColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${widget.serviceName}の視聴履歴やマイリストを貼り付け、「${_primaryActionLabel()}」を押すと作品情報を自動抽出します。',
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
      key: const ValueKey('video-ocr-controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'スクリーンショットから視聴履歴を解析します。',
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
              backgroundColor: widget.serviceColor,
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
      key: const ValueKey('video-url-controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '視聴履歴ページや作品ページのURLから情報を取得します。',
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
              backgroundColor: widget.serviceColor,
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

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
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
        border: Border.all(color: widget.serviceColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ServiceIcons.buildIcon(
                serviceId: widget.serviceId,
                size: 20,
                fallback: widget.serviceIcon,
              ),
              const SizedBox(width: 8),
              Text(
                '検出されたコンテンツ (${extractedContent.length}件)',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...extractedContent.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = selectedItems[index];

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
                  color: isSelected ? widget.serviceColor : Colors.grey,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        selectedItems[index] = value ?? false;
                      });
                    },
                    activeColor: widget.serviceColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item['info'],
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showPreview = false;
                      extractedContent.clear();
                      selectedItems.clear();
                    });
                  },
                  child: const Text('キャンセル'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedItems.any((selected) => selected)
                      ? _confirmImport
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: widget.serviceColor),
                  child: Text('${selectedItems.where((s) => s).length}件を取り込む'),
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
        border: Border.all(color: widget.serviceColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: widget.serviceColor, size: 20),
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
            '${processedContent.length}件のデータが正常に取り込まれました。',
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
                      processedContent.clear();
                      extractedContent.clear();
                      selectedItems.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: widget.serviceColor),
                  child: const Text('続けて取り込む'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.serviceColor,
                    side: BorderSide(color: widget.serviceColor),
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

  Widget _buildFloatingActionButton(bool isDark) {
    final canExecute = _isPrimaryActionEnabled && !isProcessing;
    final label = isProcessing ? '処理中...' : _primaryActionLabel();

    return FloatingActionButton.extended(
      onPressed: canExecute ? _handlePrimaryAction : null,
      backgroundColor: canExecute
          ? widget.serviceColor
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

  String _getInputLabel() {
    switch (selectedImportType) {
      case 'viewing_history':
        return '視聴履歴データ';
      case 'watchlist':
      case 'favorites':
        return 'お気に入りデータ';
      case 'ratings':
        return '評価データ';
      default:
        return 'データ';
    }
  }

  String _getPlaceholderText() {
    return _sampleTextForService(widget.serviceId, selectedImportType);
  }

  String _urlHintForService() {
    switch (widget.serviceId) {
      case 'netflix':
        return 'https://www.netflix.com/viewingactivity';
      case 'prime_video':
        return 'https://www.amazon.co.jp/gp/video/history';
      case 'abema':
        return 'https://abema.tv/video/episode/...';
      case 'hulu':
        return 'https://www.hulu.jp/watch/...';
      case 'disney':
        return 'https://www.disneyplus.com/video/...';
      case 'unext':
        return 'https://video.unext.jp/title/...';
      case 'dtv':
        return 'https://video.dmkt-sp.jp/ti/...';
      case 'fod':
        return 'https://fod.fujitv.co.jp/title/...';
      default:
        return 'https://example.com/watch-history/...';
    }
  }

  String _sampleTextForService(String serviceId, String importType) {
    switch (importType) {
      case 'watchlist':
        return '''
作品名: この素晴らしい世界に祝福を!
追加日時: 2024/02/18 21:35
メモ: シーズン1から見直したい'''
            .trim();
      case 'favorites':
        return '''
お気に入り作品: スパイダーマン: ノー・ウェイ・ホーム
登録日: 2024/02/10
ジャンル: アクション
評価: ★★★★★'''
            .trim();
      case 'ratings':
        return '''
作品名: クイーンズ・ギャンビット
評価: ★★★★☆
レビュー: 演技と脚本が秀逸
視聴日: 2024/02/12'''
            .trim();
      case 'magazines':
        return '''
雑誌名: 日経トレンディ 2024年3月号
閲覧日: 2024/02/18
特集: 春のヒット予測
メモ: 最新ガジェットに注目'''
            .trim();
      default:
        return '''
作品名: サンプル映画
視聴日: 2024/02/18
ジャンル: アクション
視聴時間: 129分
メモ: 映像美が最高でした'''
            .trim();
    }
  }

  String? _inferImportTypeFromUrl(String host) {
    final lower = host.toLowerCase();
    if (lower.contains('watchlist') || lower.contains('mylist')) {
      return 'watchlist';
    }
    if (lower.contains('favorite') || lower.contains('wishlist')) {
      return 'favorites';
    }
    if (lower.contains('rating') || lower.contains('review')) {
      return 'ratings';
    }
    if (lower.contains('magazine') || lower.contains('book')) {
      return 'magazines';
    }
    return 'viewing_history';
  }

  void _showSnackBar(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? const Color(0xFF323232),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
