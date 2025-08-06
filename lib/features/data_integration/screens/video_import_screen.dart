import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../src/providers/theme_provider_enhanced.dart';

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
  final TextEditingController _textController = TextEditingController();
  bool isProcessing = false;
  List<Map<String, dynamic>> processedContent = [];
  List<Map<String, dynamic>> extractedContent = [];
  File? selectedImage;
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
      {'id': 'viewing_history', 'title': '視聴履歴', 'subtitle': 'ディズニー・マーベル・スターウォーズ'},
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
    return importTypesByService[widget.serviceId] ?? [
      {'id': 'viewing_history', 'title': '視聴履歴', 'subtitle': '動画コンテンツ'},
      {'id': 'favorites', 'title': 'お気に入り', 'subtitle': 'マイリスト'},
    ];
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
        
        // Haptic feedback
        HapticFeedback.lightImpact();
        
        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画像が選択されました'),
            backgroundColor: widget.serviceColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('画像の選択に失敗しました: $e');
    }
  }

  void _openPhotoLibrary() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
        
        // Haptic feedback
        HapticFeedback.lightImpact();
        
        // Info message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画像を選択しました。手動でデータを入力してください。'),
            backgroundColor: widget.serviceColor,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '了解',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
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

  List<Map<String, dynamic>> _parseContent(String text) {
    final lines = text.split('\\n').where((line) => line.trim().isNotEmpty).toList();
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
      else if (currentTitle == null && trimmedLine.length > 3 && !trimmedLine.contains(':')) {
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
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${widget.serviceName} データ取り込み'),
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
                gradient: LinearGradient(
                  colors: [widget.serviceColor, widget.serviceColor.withOpacity( 0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.serviceIcon,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
              children: currentImportTypes.map((type) => _buildTypeChip(type, isDark)).toList(),
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

            // 画像選択
            Text(
              '写真フォルダから画像を選択',
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
            // 写真フォルダアクセスボタン（iPhone/Android対応）
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openPhotoLibrary,
                icon: Platform.isIOS 
                    ? const Icon(Icons.photo_library, size: 20)
                    : const Icon(Icons.photo, size: 20),
                label: Text(
                  Platform.isIOS 
                      ? 'フォトライブラリを開く'
                      : 'ギャラリーを開く',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.serviceColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 説明テキスト
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.serviceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.serviceColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: widget.serviceColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '画像を選択後、上記のテキストエリアに手動でデータを入力してください。',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 取り込みボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing ? null : _processData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.serviceColor,
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
      selectedColor: widget.serviceColor,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected 
            ? widget.serviceColor
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
        border: Border.all(color: widget.serviceColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.serviceIcon, color: widget.serviceColor, size: 20),
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
                    ? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC))
                    : (isDark ? const Color(0xFF404040).withOpacity( 0.3) : const Color(0xFFF1F5F9)),
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
          }).toList(),
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
                  onPressed: selectedItems.any((selected) => selected) ? _confirmImport : null,
                  style: ElevatedButton.styleFrom(backgroundColor: widget.serviceColor),
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
                  style: ElevatedButton.styleFrom(backgroundColor: widget.serviceColor),
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
    return '''例：
作品名: サンプル映画
視聴日: 2024/01/15
ジャンル: アクション

写真フォルダから画像を選択し、手動でデータを入力してください''';
  }
}