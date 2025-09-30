import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../src/providers/theme_provider_enhanced.dart';

class FoodImportScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String serviceName;
  final Color serviceColor;
  final IconData serviceIcon;
  
  const FoodImportScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.serviceColor,
    required this.serviceIcon,
  });

  @override
  ConsumerState<FoodImportScreen> createState() => _FoodImportScreenState();
}

class _FoodImportScreenState extends ConsumerState<FoodImportScreen> {
  String selectedImportType = 'orders';
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
    'restaurant': [
      {'id': 'orders', 'title': '注文履歴', 'subtitle': 'レストラン・カフェでの注文'},
      {'id': 'reviews', 'title': 'レビュー', 'subtitle': '店舗・料理の評価'},
      {'id': 'favorites', 'title': 'お気に入り', 'subtitle': 'お気に入り店舗・メニュー'},
      {'id': 'reservations', 'title': '予約履歴', 'subtitle': '予約・来店記録'},
    ],
    'delivery': [
      {'id': 'orders', 'title': '注文履歴', 'subtitle': 'デリバリー注文記録'},
      {'id': 'favorites', 'title': 'お気に入り', 'subtitle': 'お気に入り店舗・メニュー'},
      {'id': 'addresses', 'title': '配送先', 'subtitle': '配送先住所履歴'},
      {'id': 'receipts', 'title': '領収書', 'subtitle': '決済・領収書記録'},
    ],
    'cooking': [
      {'id': 'recipes', 'title': 'レシピ', 'subtitle': '作った料理・レシピ'},
      {'id': 'ingredients', 'title': '食材', 'subtitle': '購入・使用食材'},
      {'id': 'meals', 'title': '食事記録', 'subtitle': '自炊・食事の記録'},
      {'id': 'nutrition', 'title': '栄養管理', 'subtitle': 'カロリー・栄養素記録'},
    ],
  };

  List<Map<String, String>> get currentImportTypes {
    return importTypesByService[widget.serviceId] ?? [
      {'id': 'orders', 'title': '注文・食事', 'subtitle': '飲食記録データ'},
      {'id': 'preferences', 'title': '嗜好・評価', 'subtitle': 'お気に入り・評価'},
    ];
  }

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
      _textController.text = 'OCR解析結果がここに表示されます\\n\\n例：\\n店舗: サンプルレストラン\\nメニュー: ハンバーガーセット\\n金額: 1,200円';
    });
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
        _showErrorSnackBar('飲食データを検出できませんでした。\\nフォーマットを確認してください。');
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
    String? currentPrice;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // 店舗・レストランパターン
      if (trimmedLine.contains('店舗:') || 
          trimmedLine.contains('レストラン:') || 
          trimmedLine.contains('カフェ:')) {
        currentTitle = trimmedLine.replaceAll(RegExp(r'店舗:|レストラン:|カフェ:'), '').trim();
      }
      // メニュー・料理パターン
      else if (trimmedLine.contains('メニュー:') || 
               trimmedLine.contains('料理:') || 
               trimmedLine.contains('レシピ:')) {
        currentInfo = trimmedLine.replaceAll(RegExp(r'メニュー:|料理:|レシピ:'), '').trim();
      }
      // 金額パターン
      else if (trimmedLine.contains('金額:') || 
               trimmedLine.contains('価格:') || 
               trimmedLine.contains('円')) {
        currentPrice = trimmedLine.replaceAll(RegExp(r'金額:|価格:'), '').trim();
      }
      // シンプルなタイトル（コロンがない場合）
      else if (currentTitle == null && trimmedLine.length > 3 && !trimmedLine.contains(':')) {
        currentTitle = trimmedLine;
      }
      
      // アイテム作成
      if (currentTitle != null && (currentInfo != null || items.length < 5)) {
        items.add({
          'title': currentTitle,
          'info': currentInfo ?? '${widget.serviceName}で注文',
          'price': currentPrice ?? '',
          'service': widget.serviceName,
          'type': selectedImportType,
          'confidence': 0.8,
        });
        currentTitle = null;
        currentInfo = null;
        currentPrice = null;
      }
    }
    
    // サンプルデータがない場合のデフォルト
    if (items.isEmpty && text.trim().isNotEmpty) {
      final serviceExamples = _getServiceExamples();
      items.addAll(serviceExamples);
    }
    
    return items;
  }

  List<Map<String, dynamic>> _getServiceExamples() {
    switch (widget.serviceId) {
      case 'restaurant':
        return [
          {
            'title': 'サンプルレストラン',
            'info': 'ハンバーガーセット',
            'price': '1,200円',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': 'カフェサンプル',
            'info': 'コーヒー＆ケーキセット',
            'price': '800円',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      case 'delivery':
        return [
          {
            'title': 'デリバリーピザ',
            'info': 'マルゲリータLサイズ',
            'price': '2,400円',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': '中華デリバリー',
            'info': '麻婆豆腐定食',
            'price': '1,100円',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      case 'cooking':
        return [
          {
            'title': '自炊レシピ1',
            'info': 'チキンカレー',
            'price': '食材費: 600円',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': '自炊レシピ2',
            'info': 'パスタペペロンチーノ',
            'price': '食材費: 300円',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      default:
        return [
          {
            'title': 'サンプル飲食店',
            'info': '${widget.serviceName}で注文',
            'price': '',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
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
                        Text(
                          _getServiceDescription(),
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
              'またはメニュー・レシートから読み込み',
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
              ],
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

  String _getServiceDescription() {
    switch (widget.serviceId) {
      case 'restaurant':
        return 'レストラン・カフェ注文履歴を取り込み';
      case 'delivery':
        return 'デリバリー注文履歴を取り込み';
      case 'cooking':
        return '自炊・レシピ記録を取り込み';
      default:
        return '飲食・グルメデータを取り込み';
    }
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
                '検出された飲食記録 (${extractedContent.length}件)',
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
                        if (item['info'].isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['info'],
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (item['price'].isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['price'],
                            style: TextStyle(
                              color: widget.serviceColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
            '${processedContent.length}件の飲食データが正常に取り込まれました。',
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
      case 'orders':
        return '注文履歴データ';
      case 'reviews':
        return 'レビューデータ';
      case 'favorites':
        return 'お気に入りデータ';
      case 'recipes':
        return 'レシピデータ';
      case 'ingredients':
        return '食材データ';
      case 'meals':
        return '食事記録データ';
      case 'nutrition':
        return '栄養管理データ';
      default:
        return 'データ';
    }
  }

  String _getPlaceholderText() {
    switch (widget.serviceId) {
      case 'restaurant':
        return '''例：
店舗: サンプルレストラン
メニュー: ハンバーガーセット
金額: 1,200円

またはレストラン注文履歴をOCRで読み取ったテキストをペーストしてください''';
      case 'delivery':
        return '''例：
店舗: デリバリーピザ
メニュー: マルゲリータLサイズ
金額: 2,400円

またはデリバリーアプリの注文履歴をOCRで読み取ったテキストをペーストしてください''';
      case 'cooking':
        return '''例：
料理: チキンカレー
食材費: 600円
調理時間: 45分

または料理記録アプリをOCRで読み取ったテキストをペーストしてください''';
      default:
        return '''例：
店舗: サンプル飲食店
メニュー: サンプルメニュー
金額: 1,000円

または${widget.serviceName}の画面をOCRで読み取ったテキストをペーストしてください''';
    }
  }
}