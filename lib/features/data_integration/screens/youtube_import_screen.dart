import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../config/environment_config.dart';
import '../utils/image_preprocessor.dart';
import '../../../src/core/components/service_icons.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/services/youtube_ocr_parser_v6.dart';
import '../../../providers/youtube_history_provider.dart';
import '../../../providers/user_provider.dart';

class YouTubeImportScreen extends ConsumerStatefulWidget {
  const YouTubeImportScreen({super.key});

  @override
  ConsumerState<YouTubeImportScreen> createState() =>
      _YouTubeImportScreenState();
}

class _YouTubeImportScreenState extends ConsumerState<YouTubeImportScreen>
    with TickerProviderStateMixin {
  String selectedImportType = 'history'; // history, channel, playlist, search
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isProcessing = false;
  List<Map<String, dynamic>> processedVideos = [];
  final List<Map<String, dynamic>> extractedVideos = [];
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();
  bool showConfirmation = false;

  // YouTube取り込みタイプ
  final List<Map<String, dynamic>> importTypes = [
    {
      'id': 'history',
      'title': '視聴履歴',
      'subtitle': 'YouTube視聴履歴の取り込み',
      'icon': Icons.history,
      'color': const Color(0xFFFF0000),
      'description': 'YouTubeの視聴履歴を手動入力またはOCRで取り込みます',
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
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ServiceIcons.buildIcon(
                serviceId: 'youtube',
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'YouTube データ取り込み',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 取り込みタイプ選択
              _buildImportTypeSelection(),
              const SizedBox(height: 24),

              // 選択されたタイプの入力フォーム
              _buildInputForm(),

              // 抽出結果の確認画面
              if (showConfirmation && extractedVideos.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildConfirmationScreen(),
              ],

              // 処理結果
              if (processedVideos.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildProcessingResults(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportTypeSelection() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: importTypes.length,
          itemBuilder: (context, index) {
            final type = importTypes[index];
            final isSelected = selectedImportType == type['id'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedImportType = type['id'];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (type['color'] as Color).withOpacity(0.1)
                      : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? (type['color'] as Color)
                        : (isDark
                            ? const Color(0xFF333333)
                            : const Color(0xFFE5E7EB)),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.black)
                          .withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (type['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          type['icon'] as IconData,
                          color: type['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        type['title'],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type['subtitle'],
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.black54,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInputForm() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;
    final selectedType =
        importTypes.firstWhere((type) => type['id'] == selectedImportType);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (selectedType['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    selectedType['icon'] as IconData,
                    color: selectedType['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedType['title'],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        selectedType['description'],
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // URL入力（チャンネルの場合のみ）
            if (selectedImportType == 'channel') ...[
              Text(
                'URL',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF444444)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: TextField(
                  controller: _urlController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: selectedImportType == 'channel'
                        ? 'https://www.youtube.com/channel/...'
                        : 'https://www.youtube.com/playlist?list=...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.link,
                      color: isDark ? Colors.grey[500] : Colors.black38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // テキスト入力エリア
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
              height: 240,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF444444)
                      : const Color(0xFFE5E7EB),
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

            // 画像選択（視聴履歴のみ）
            if (selectedImportType == 'history') ...[
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
              if (selectedImageBytes != null) ...[
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF444444)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      selectedImageBytes!,
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
                      label: Text(selectedImageBytes == null ? '画像を選択' : '画像を変更'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF444444)
                            : const Color(0xFFF1F5F9),
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  if (selectedImageBytes != null) ...[
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.text_fields, size: 18),
                        label: Text(isProcessing ? '解析中...' : '画像を解析'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
            ],

            // アクションボタン
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final clipboardData =
                          await Clipboard.getData('text/plain');
                      if (clipboardData?.text != null) {
                        _textController.text = clipboardData!.text!;
                      }
                    },
                    icon: const Icon(Icons.content_paste, size: 18),
                    label: const Text('ペースト'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF444444)
                          : const Color(0xFFF1F5F9),
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : _processYouTubeData,
                    icon: isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.upload, size: 18),
                    label: Text(isProcessing ? '処理中...' : 'データを取り込む'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingResults() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '取り込み完了',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${processedVideos.length}件のデータが正常に取り込まれました',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // データ確認の注意書き
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'データの確認をお願いします',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'OCRで読み取ったデータに誤りがないか、投稿前に必ずご確認ください。必要に応じて修正・削除を行ってください。',
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.black54,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 取り込まれたデータのプレビュー
            ...processedVideos.take(3).map((video) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF444444)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      // サムネイル
                      Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF333333)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              // サムネイル画像（実際の実装ではNetwork.imageを使用）
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: const Color(0xFFFF0000).withOpacity(0.1),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Color(0xFFFF0000),
                                  size: 24,
                                ),
                              ),
                              // 再生時間表示
                              if (video['duration'] != null)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      video['duration'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // タイトル（クリック可能）
                            GestureDetector(
                              onTap: () {
                                // 動画URLを開く（実際の実装では url_launcher を使用）
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('動画を開く: ${video['title']}'),
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              },
                              child: Text(
                                video['title'] ?? 'タイトル不明',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              video['channel'] ?? 'チャンネル不明',
                              style: TextStyle(
                                color:
                                    isDark ? Colors.grey[400] : Colors.black54,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (video['watchDate'] != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '視聴日: ${video['watchDate']}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.black38,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // 詳細ボタン
                      IconButton(
                        onPressed: () {
                          _showVideoDetails(video);
                        },
                        icon: Icon(
                          Icons.info_outline,
                          color: isDark ? Colors.grey[400] : Colors.black54,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                )),

            if (processedVideos.length > 3) ...[
              const SizedBox(height: 12),
              Text(
                '他 ${processedVideos.length - 3}件のデータ',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getInputLabel() {
    switch (selectedImportType) {
      case 'history':
        return '視聴履歴データ';
      case 'channel':
        return 'チャンネル情報';
      case 'playlist':
        return 'プレイリスト情報';
      case 'search':
        return '検索履歴';
      default:
        return 'データ';
    }
  }

  String _getPlaceholderText() {
    switch (selectedImportType) {
      case 'history':
        return 'YouTubeの視聴履歴テキストをペーストしてください（OCR結果のままでOK）';
      case 'channel':
        return 'チャンネル情報をテキストで入力してください（名称・説明・登録者など）';
      case 'playlist':
        return 'プレイリスト情報をテキストで入力してください';
      case 'search':
        return '検索履歴テキストを入力してください（キーワード＋日時など任意）';
      default:
        return 'データを入力してください';
    }
  }

  Future<void> _processYouTubeData() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('データを入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // OCR処理前の重要な注意事項を表示
    final shouldProceed = await _showOCRWarningDialog();
    if (!shouldProceed) return;

    setState(() {
      isProcessing = true;
    });

    try {
      // 入力されたテキストを解析
      final videos = await _parseExtractedText(_textController.text);

      if (videos.isEmpty) {
        setState(() {
          isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('動画情報を抽出できませんでした。入力形式を確認してください。'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        isProcessing = false;
        extractedVideos.clear();
        extractedVideos.addAll(videos
            .map((video) => {
                  ...video,
                  'isSelected': true, // デフォルトで選択状態
                  'isPublic': false, // デフォルトで非公開
                })
            .toList());
        showConfirmation = true;
      });

      // OCR取得結果を手入力の視聴履歴に追加（既存の履歴がある場合は上部に追加）
      final parsedVideos = videos.map((v) => VideoData(
        title: v['title'] ?? '',
        channel: v['channel'] ?? '',
        duration: v['duration'],
        viewedAt: v['watchDate'],
        viewCount: v['viewCount'],
        confidence: v['confidence'] ?? 0.9,
      )).toList();
      _updateYouTubeHistoryProviderFromVideoData(parsedVideos);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${videos.length}件の動画情報を抽出しました！内容を確認してください。'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('データの解析に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _generateSampleData() {
    switch (selectedImportType) {
      case 'history':
        return [
          {
            'title': 'iPhone 15 Pro Max 詳細レビュー',
            'channel': 'テックレビューアー田中',
            'duration': '25:30',
            'watchDate': '2024/01/15',
          },
          {
            'title': 'Flutter 3.0 新機能解説',
            'channel': 'プログラミング講師伊藤',
            'duration': '32:15',
            'watchDate': '2024/01/14',
          },
          {
            'title': '簡単チキンカレーの作り方',
            'channel': '料理研究家佐藤',
            'duration': '12:45',
            'watchDate': '2024/01/13',
          },
        ];
      case 'channel':
        return [
          {
            'title': 'テックレビューアー田中',
            'channel': 'テクノロジー・ガジェット',
            'subscribers': '24.5万人',
          },
          {
            'title': '料理研究家佐藤',
            'channel': '料理・グルメ',
            'subscribers': '18.3万人',
          },
        ];
      default:
        return [
          {
            'title': 'サンプルデータ1',
            'channel': 'サンプルチャンネル',
          },
          {
            'title': 'サンプルデータ2',
            'channel': 'サンプルチャンネル2',
          },
        ];
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          selectedImage = image;
          selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('画像の選択に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processImageOCR() async {
    if (selectedImageBytes == null) return;

    String _detectMime(Uint8List data) {
      if (data.length >= 4 &&
          data[0] == 0x89 &&
          data[1] == 0x50 &&
          data[2] == 0x4E &&
          data[3] == 0x47) {
        return 'image/png';
      }
      if (data.length >= 2 && data[0] == 0xFF && data[1] == 0xD8) {
        return 'image/jpeg';
      }
      if (data.length >= 4 &&
          data[0] == 0x47 &&
          data[1] == 0x49 &&
          data[2] == 0x46) {
        return 'image/gif';
      }
      return 'application/octet-stream';
    }

    // OCR処理前の重要な注意事項を表示
    final shouldProceed = await _showOCRWarningDialog();
    if (!shouldProceed) return;

    setState(() {
      isProcessing = true;
    });

    try {
      // Cloud Run APIを呼び出してOCR処理
      const apiBase = EnvironmentConfig.docAiApiBase;
      if (apiBase.isEmpty) {
        throw Exception('API_BASEが設定されていません。環境変数を確認してください。');
      }

      final normalizedBytes = await prepareImageForDocAi(selectedImageBytes!);
      final base64Image = base64Encode(normalizedBytes);
      final sanitizedMimeType = _detectMime(normalizedBytes); // 変換後の実際のMIMEタイプを検出
      final originalMime = _detectMime(selectedImageBytes!);
      debugPrint(
        '[DocAI] sending payload (converted=$sanitizedMimeType, bytes=${normalizedBytes.length}, original=$originalMime)',
      );
      final response = await http.post(
        Uri.parse('$apiBase/ocr/process'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mimeType': sanitizedMimeType,
          'contentBase64': base64Image,
          'originalMimeType': originalMime,
        }),
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final serverError = errorBody['error'] ?? 'unknown';
        final detailInfo = errorBody['details'] ?? errorBody['badRequest'];
        throw Exception(
          'Cloud Run OCR error: $serverError'
          '${detailInfo != null ? ' | details: $detailInfo' : ''}',
        );
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final extractedText = (result['text'] as String? ?? '').trim();
      
      if (extractedText.isEmpty) {
        throw Exception('OCR結果が空でした。');
      }

      // 抽出されたテキストをテキストエリアに設定
      _textController.text = extractedText;

      final parsedVideos = YouTubeOCRParserV6.parseOCRText(extractedText);

      // 抽出されたデータを既存の形式に変換
      final videos = parsedVideos
          .map((video) => {
                'title': video.title,
                'channel': video.channel,
                'duration': video.duration,
                'watchDate': video.viewedAt,
                'thumbnail': _generateThumbnailUrl(video.title),
                'videoUrl': _generateVideoUrl(video.title),
                'confidence': video.confidence,
              })
          .toList();

      setState(() {
        isProcessing = false;
        extractedVideos.clear();
        extractedVideos.addAll(videos
            .map((video) => {
                  ...video,
                  'isSelected': true, // デフォルトで選択状態
                  'isPublic': false, // デフォルトで非公開
                })
            .toList());
        showConfirmation = true;
      });

      // YouTube履歴プロバイダーを更新
      _updateYouTubeHistoryProviderFromVideoData(parsedVideos);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('画像から${videos.length}件の動画情報を抽出しました！内容を確認してください。'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('画像の解析に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _parseExtractedText(String text) async {
    try {
      final parsedVideos = YouTubeOCRParserV6.parseOCRText(text);

      // 抽出されたデータを既存の形式に変換
      return parsedVideos
          .map((video) => {
                'title': video.title,
                'channel': video.channel ?? 'Unknown',
                'duration': video.duration ?? '',
                'watchDate': video.viewedAt ?? '',
                'viewCount': video.viewCount ?? '',
                'thumbnail': _generateThumbnailUrl(video.title),
                'videoUrl': _generateVideoUrl(video.title),
                'confidence': video.confidence,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> _parseExtractedTextFallback(String text) {
    print('=== FALLBACK PARSER START ===');
    print('Input text length: ${text.length}');

    final videos = <Map<String, dynamic>>[];
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    print('Processing ${lines.length} lines');

    // シンプルで確実な解析：実際のログパターンに基づく
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // パターン1: 視聴回数行（「・」で区切られたチャンネル・視聴回数）
      if (line.contains('・') &&
          (line.contains('万回視聴') || line.contains('万 回視聴'))) {
        print('Found channel-viewcount line: $line');

        final parts = line.split('・');
        if (parts.length >= 2) {
          final channel = parts[0].trim();
          final viewCount = parts[1].trim();

          // タイトルを前の行から取得
          String? title;
          if (i > 0) {
            title = lines[i - 1];
            // タイトルが複数行に分かれている場合を考慮
            if (i > 1 &&
                !_isSystemText(lines[i - 2]) &&
                lines[i - 2].length > 10) {
              title = '${lines[i - 2]}$title';
            }
          }

          if (title != null && title.length > 5) {
            videos.add({
              'title': title,
              'channel': channel,
              'viewCount': viewCount,
              'duration': '',
              'watchDate': '',
              'thumbnail': _generateThumbnailUrl(title),
              'videoUrl': _generateVideoUrl(title),
              'confidence': 0.95,
            });
            print('✓ Added video: "$title" by "$channel" ($viewCount)');
          }
        }
      }

      // パターン2: 単独の視聴回数行（前の行がチャンネル名）
      else if ((line.contains('万回視聴') ||
              line.contains('万 回視聴') ||
              line.endsWith('回視聴')) &&
          !line.contains('・')) {
        print('Found standalone viewcount line: $line');

        if (i > 0) {
          final channel = lines[i - 1];
          String? title;

          // タイトルを前々行から取得
          if (i > 1) {
            title = lines[i - 2];
            // タイトルが複数行の場合
            if (i > 2 &&
                !_isSystemText(lines[i - 3]) &&
                lines[i - 3].length > 10) {
              title = '${lines[i - 3]}$title';
            }
          }

          if (title != null && title.length > 5 && !_isSystemText(channel)) {
            videos.add({
              'title': title,
              'channel': channel,
              'viewCount': line,
              'duration': '',
              'watchDate': '',
              'thumbnail': _generateThumbnailUrl(title),
              'videoUrl': _generateVideoUrl(title),
              'confidence': 0.9,
            });
            print('✓ Added video: "$title" by "$channel" ($line)');
          }
        }
      }
    }

    print('=== FALLBACK PARSER END ===');
    print('Extracted ${videos.length} videos');

    return videos;
  }

  String _mergeTitleLines(String title1, String title2) {
    // タイトル行を適切に結合
    if (title1.endsWith('】') || title1.endsWith('！') || title1.endsWith('？')) {
      return title1; // 完結している場合はそのまま
    }
    return '$title1$title2'; // 続きとして結合
  }

  bool _isNumberedLine(String line) {
    return line.startsWith('①') ||
        line.startsWith('②') ||
        line.startsWith('③') ||
        line.startsWith('④') ||
        line.startsWith('⑤') ||
        line.startsWith('⑥') ||
        line.startsWith('⑦') ||
        line.startsWith('⑧') ||
        line.startsWith('⑨') ||
        line.startsWith('⑩');
  }

  String? _extractTitleFromLine(String line) {
    if (line.contains('題名：')) {
      return line.split('題名：')[1].trim();
    } else if (line.contains('題名【')) {
      return line.split('題名')[1].trim();
    }
    return null;
  }

  String? _extractChannelFromLine(String line) {
    String channel = '';
    if (line.contains('投稿者：')) {
      channel = line.split('投稿者：')[1].trim();
    } else if (line.contains('投稿者；')) {
      channel = line.split('投稿者；')[1].trim();
    }

    // 視聴回数部分を除去
    if (channel.contains('・')) {
      channel = channel.split('・')[0].trim();
    }

    return channel.isNotEmpty ? channel : null;
  }

  String? _extractViewCountFromLine(String line) {
    final regex = RegExp(r'(\d+(?:\.\d+)?万回視聴|\d+回視聴)');
    final match = regex.firstMatch(line);
    return match?.group(1);
  }

  List<Map<String, dynamic>> _parseExtractedTextLegacy(String text) {
    final videos = <Map<String, dynamic>>[];
    final lines = text.split('\n');

    String? currentTitle;
    String? currentChannel;
    String? currentDuration;
    String? currentWatchDate;
    String? currentViews;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // パターン1: 「万回視聴」「万 回視聴」を含む行は視聴回数
      if (line.contains('万回視聴') || line.contains('万 回視聴')) {
        currentViews = line;

        // 視聴回数の前の行がチャンネル名
        if (i > 0 && currentTitle != null) {
          currentChannel = lines[i - 1].trim();

          // ビデオ情報が揃ったら追加
          if (currentChannel.isNotEmpty && !_isSystemText(currentChannel)) {
            videos.add({
              'title': currentTitle,
              'channel': _cleanChannelName(currentChannel),
              'viewCount': currentViews,
              'duration': currentDuration ?? '',
              'watchDate': currentWatchDate ?? '',
              'thumbnail': _generateThumbnailUrl(currentTitle),
              'videoUrl': _generateVideoUrl(currentTitle),
              'confidence': 0.8,
            });
          }
        }

        // リセット
        currentTitle = null;
        currentChannel = null;
        currentViews = null;
      }
      // パターン2: 特殊文字を除外してタイトル候補を判定
      else if (!_isSystemText(line) &&
          line.length > 5 &&
          currentTitle == null &&
          !line.contains('•')) {
        currentTitle = line;
      }
      // YouTube履歴の一般的なパターンを解析（フォールバック）
      // パターン3: 動画タイトル行
      else if (!line.contains('•') &&
          !line.contains('前') &&
          !line.contains('時間') &&
          !line.contains(':') &&
          currentViews == null) {
        // 前のビデオを保存
        if (currentTitle != null && currentChannel != null) {
          videos.add({
            'title': currentTitle,
            'channel': currentChannel,
            'duration': currentDuration ?? '',
            'watchDate': currentWatchDate ?? '',
            'thumbnail': _generateThumbnailUrl(currentTitle),
            'videoUrl': _generateVideoUrl(currentTitle),
            'confidence': 0.7,
          });
        }

        currentTitle = line;
        currentChannel = null;
        currentDuration = null;
        currentWatchDate = null;
      }
      // パターン4: チャンネル名行
      else if (currentTitle != null &&
          currentChannel == null &&
          !line.contains('•') &&
          currentViews == null) {
        currentChannel = line;
      }
      // パターン5: 時間情報行（"3日前 • 45:30"のような形式）
      else if (line.contains('•')) {
        final parts = line.split('•');
        if (parts.length >= 2) {
          currentWatchDate = parts[0].trim();
          currentDuration = parts[1].trim();
        }
      }
      // パターン6: 旧形式のサポート（動画タイトル:, チャンネル:）
      else if (line.startsWith('動画タイトル:')) {
        if (currentTitle != null && currentChannel != null) {
          videos.add({
            'title': currentTitle,
            'channel': currentChannel,
            'duration': currentDuration ?? '',
            'watchDate': currentWatchDate ?? '',
            'thumbnail': _generateThumbnailUrl(currentTitle),
            'videoUrl': _generateVideoUrl(currentTitle),
            'confidence': 0.7,
          });
        }
        currentTitle = line.substring('動画タイトル:'.length).trim();
        currentChannel = null;
        currentDuration = null;
        currentWatchDate = null;
      } else if (line.startsWith('チャンネル:') && currentTitle != null) {
        currentChannel = line.substring('チャンネル:'.length).trim();
      } else if (line.startsWith('視聴日:') && currentTitle != null) {
        currentWatchDate = line.substring('視聴日:'.length).trim();
      } else if (line.startsWith('視聴時間:') && currentTitle != null) {
        currentDuration = line.substring('視聴時間:'.length).trim();
      }
    }

    // 最後のビデオを追加
    if (currentTitle != null && currentChannel != null) {
      videos.add({
        'title': currentTitle,
        'channel': currentChannel,
        'duration': currentDuration ?? '',
        'watchDate': currentWatchDate ?? '',
        'thumbnail': _generateThumbnailUrl(currentTitle),
        'videoUrl': _generateVideoUrl(currentTitle),
        'confidence': 0.7,
      });
    }

    return videos;
  }

  String _cleanChannelName(String channel) {
    // チャンネル名から余分な記号を除去
    return channel
        .replaceAll('・', '')
        .replaceAll('「', '')
        .replaceAll('」', '')
        .replaceAll('【', '')
        .replaceAll('】', '')
        .trim();
  }

  String _generateThumbnailUrl(String title) {
    // 実際の実装では、タイトルからYouTube検索APIを使用してサムネイルを取得
    // ここではプレースホルダー画像を返す
    return 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg';
  }

  String _generateVideoUrl(String title) {
    // 実際の実装では、タイトルからYouTube検索APIを使用して動画URLを取得
    // ここではサンプルURLを返す
    return 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
  }

  void _showVideoDetails(Map<String, dynamic> video) {
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '動画詳細',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('タイトル', video['title'] ?? 'タイトル不明', isDark),
                const SizedBox(height: 12),
                _buildDetailRow('チャンネル', video['channel'] ?? 'チャンネル不明', isDark),
                if (video['duration'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow('再生時間', video['duration'], isDark),
                ],
                if (video['watchDate'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow('視聴日', video['watchDate'], isDark),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('サムネイル画像をクリップボードにコピーしました'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                        icon: const Icon(Icons.image, size: 16),
                        label: const Text('サムネイル'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF444444)
                              : const Color(0xFFF1F5F9),
                          foregroundColor:
                              isDark ? Colors.white : Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('動画URLをクリップボードにコピーしました'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('動画URL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF0000),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '閉じる',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationScreen() {
    final themeState = ref.watch(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '抽出結果を確認',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${extractedVideos.length}件の動画が見つかりました。内容を確認して取り込む動画を選択してください。',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 全体操作ボタン
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        for (int i = 0; i < extractedVideos.length; i++) {
                          extractedVideos[i]['isSelected'] = true;
                        }
                      });
                    },
                    icon: const Icon(Icons.select_all, size: 16),
                    label: const Text('全て選択'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF444444)
                          : const Color(0xFFF1F5F9),
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        for (int i = 0; i < extractedVideos.length; i++) {
                          extractedVideos[i]['isSelected'] = false;
                        }
                      });
                    },
                    icon: const Icon(Icons.deselect, size: 16),
                    label: const Text('全て解除'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF444444)
                          : const Color(0xFFF1F5F9),
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 動画リスト
            ...extractedVideos.asMap().entries.map((entry) {
              final index = entry.key;
              final video = entry.value;
              final isSelected = video['isSelected'] ?? false;
              final isPublic = video['isPublic'] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFF8FAFC))
                      : (isDark
                              ? const Color(0xFF333333)
                              : const Color(0xFFE5E7EB))
                          .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : (isDark
                            ? const Color(0xFF444444)
                            : const Color(0xFFE5E7EB)),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // 選択チェックボックス
                          Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                extractedVideos[index]['isSelected'] =
                                    value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF8B5CF6),
                          ),
                          const SizedBox(width: 12),

                          // サムネイル
                          Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF333333)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: const Color(0xFFFF0000)
                                        .withOpacity(0.1),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Color(0xFFFF0000),
                                      size: 24,
                                    ),
                                  ),
                                  if (video['duration'] != null &&
                                      video['duration'].isNotEmpty)
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          video['duration'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 動画情報
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video['title'] ?? 'タイトル不明',
                                  style: TextStyle(
                                    color: isSelected
                                        ? (isDark
                                            ? Colors.white
                                            : Colors.black87)
                                        : (isDark
                                            ? Colors.grey[500]
                                            : Colors.black45),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  video['channel'] ?? 'チャンネル不明',
                                  style: TextStyle(
                                    color: isSelected
                                        ? (isDark
                                            ? Colors.grey[400]
                                            : Colors.black54)
                                        : (isDark
                                            ? Colors.grey[600]
                                            : Colors.black38),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (video['watchDate'] != null &&
                                    video['watchDate'].isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        video['watchDate'],
                                        style: TextStyle(
                                          color: isSelected
                                              ? (isDark
                                                  ? Colors.grey[500]
                                                  : Colors.black38)
                                              : (isDark
                                                  ? Colors.grey[600]
                                                  : Colors.black26),
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (video['confidence'] != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: _getConfidenceColor(
                                                video['confidence']),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${(video['confidence'] * 100).toInt()}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          // 削除ボタン
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: Colors.red,
                            onPressed: () {
                              setState(() {
                                extractedVideos.removeAt(index);
                                if (extractedVideos.isEmpty) {
                                  showConfirmation = false;
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('動画を削除しました'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            tooltip: '削除',
                          ),
                        ],
                      ),

                      // 公開設定（選択されている場合のみ表示）
                      if (isSelected) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF333333)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPublic ? Icons.public : Icons.lock,
                                color: isPublic
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF6B7280),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '公開設定',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: isPublic,
                                onChanged: (bool value) {
                                  setState(() {
                                    extractedVideos[index]['isPublic'] = value;
                                  });
                                },
                                thumbColor: MaterialStateProperty.resolveWith<Color?>(
                                  (states) => states.contains(MaterialState.selected)
                                      ? const Color(0xFF10B981)
                                      : null,
                                ),
                                inactiveThumbColor: const Color(0xFF6B7280),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // 確定ボタン
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showConfirmation = false;
                        extractedVideos.clear();
                      });
                    },
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('キャンセル'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF444444)
                          : const Color(0xFFF1F5F9),
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmAndImportVideos(),
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text(
                        '選択した動画を取り込む (${extractedVideos.where((v) => v['isSelected'] == true).length}件)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAndImportVideos() {
    final selectedVideos =
        extractedVideos.where((v) => v['isSelected'] == true).toList();

    if (selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('取り込む動画を選択してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      processedVideos = selectedVideos;
      showConfirmation = false;
      extractedVideos.clear();
    });

    // YouTube履歴プロバイダーを更新
    _updateYouTubeHistoryProvider(selectedVideos);

    final publicCount =
        selectedVideos.where((v) => (v['isPublic'] ?? false) == true).length;
    final privateCount = selectedVideos.length - publicCount;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$publicCount件の動画を取り込みました（非公開: $privateCount件）'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  bool _isSystemText(String text) {
    // システムテキストや不要な行を除外
    final systemPatterns = [
      '登録チャンネル',
      'マイページ',
      '：',
      '+',
      '？',
    ];

    return systemPatterns.any((pattern) => text == pattern);
  }

  // YouTube履歴プロバイダーを更新（Map形式から）
  void _updateYouTubeHistoryProvider(List<Map<String, dynamic>> videos) {
    if (videos.isEmpty) {
      return;
    }

    final sessionId = 'import_${DateTime.now().millisecondsSinceEpoch}';
    final importTime = DateTime.now();
    final currentUser = ref.read(currentUserProvider);

    final historyItems = videos
        .map((video) => YouTubeHistoryItem(
              title: video['title'] ?? '',
              channel: video['channel'] ?? '',
              duration: video['duration'],
              uploadTime: video['watchDate'],
              viewCount: video['viewCount'],
              addedAt: importTime,
              sessionId: sessionId,
              starName: currentUser.name.isNotEmpty ? currentUser.name : null,
              starGenre: currentUser.starCategory,
              isPublished: video['isPublic'] == true,
            ))
        .toList();

    ref.read(youtubeHistoryProvider.notifier).addHistory(historyItems);
  }

  // YouTube履歴プロバイダーを更新（VideoData形式から）
  void _updateYouTubeHistoryProviderFromVideoData(List<VideoData> videos) {
    if (videos.isEmpty) {
      return;
    }

    final sessionId = 'import_${DateTime.now().millisecondsSinceEpoch}';
    final importTime = DateTime.now();
    final currentUser = ref.read(currentUserProvider);

    final historyItems = videos
        .map((video) => YouTubeHistoryItem(
              title: video.title,
              channel: video.channel ?? '',
              duration: video.duration,
              uploadTime: video.viewedAt,
              viewCount: video.viewCount,
              addedAt: importTime,
              sessionId: sessionId,
              starName: currentUser.name.isNotEmpty ? currentUser.name : null,
              starGenre: currentUser.starCategory,
              isPublished: false,
            ))
        .toList();

    ref.read(youtubeHistoryProvider.notifier).addHistory(historyItems);
  }

  // OCR処理前の重要な注意事項を表示
  Future<bool> _showOCRWarningDialog() async {
    final themeState = ref.read(themeProviderEnhanced);
    final isDark = themeState.isDarkMode;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              title: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '重要な注意事項',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OCR機能について',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'OCR（光学文字認識）は技術の性質上、読み取りエラーが発生する可能性があります。',
                            style: TextStyle(
                              color: isDark ? Colors.grey[300] : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '免責事項',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• 取り込んだデータは必ずご自身で内容を確認してください。\n• データの修正・削除は投稿前に行ってください。\n• 誤った選択により動画が公開された場合、当サービスでは責任を負いかねます。',
                            style: TextStyle(
                              color: isDark ? Colors.grey[300] : Colors.black54,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '上記の内容を理解し、データの確認を行うことに同意いただける場合のみ、続行してください。',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.black54,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('理解して続行'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
