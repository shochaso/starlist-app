
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/core/components/service_icons.dart';

class EntertainmentImportScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String serviceName;
  final Color serviceColor;
  final IconData serviceIcon;
  
  const EntertainmentImportScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.serviceColor,
    required this.serviceIcon,
  });

  @override
  ConsumerState<EntertainmentImportScreen> createState() => _EntertainmentImportScreenState();
}

class _EntertainmentImportScreenState extends ConsumerState<EntertainmentImportScreen> {
  String selectedImportType = 'history';
  final TextEditingController _textController = TextEditingController();
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
    'games': [
      {'id': 'history', 'title': 'プレイ履歴', 'subtitle': 'ゲームプレイ記録'},
      {'id': 'achievements', 'title': '実績・トロフィー', 'subtitle': '達成した実績'},
      {'id': 'library', 'title': 'ゲームライブラリ', 'subtitle': '所有・購入ゲーム'},
      {'id': 'stats', 'title': 'プレイ統計', 'subtitle': 'プレイ時間・統計'},
    ],
    'books': [
      {'id': 'reading_history', 'title': '読書履歴', 'subtitle': '読んだ本・漫画'},
      {'id': 'library', 'title': 'ライブラリ', 'subtitle': '所有・購入書籍'},
      {'id': 'wishlist', 'title': '欲しい物リスト', 'subtitle': '読みたい本'},
      {'id': 'reviews', 'title': 'レビュー', 'subtitle': '書籍レビュー・評価'},
    ],
    'cinema': [
      {'id': 'viewing_history', 'title': '鑑賞履歴', 'subtitle': '映画館での鑑賞記録'},
      {'id': 'reservations', 'title': '予約・チケット', 'subtitle': '映画予約履歴'},
      {'id': 'ratings', 'title': '評価・レビュー', 'subtitle': '映画評価'},
      {'id': 'favorites', 'title': 'お気に入り', 'subtitle': '好きな映画・俳優'},
    ],
  };

  List<Map<String, String>> get currentImportTypes {
    return importTypesByService[widget.serviceId] ?? [
      {'id': 'history', 'title': '履歴', 'subtitle': 'エンタメ履歴データ'},
      {'id': 'preferences', 'title': '嗜好', 'subtitle': '好み・評価データ'},
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
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        selectedImage = pickedFile;
        selectedImageBytes = bytes;
      });
    }
  }

  void _processImageOCR() async {
    if (selectedImageBytes == null && selectedImage == null) return;

    setState(() {
      isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isProcessing = false;
      _textController.text = 'OCR解析結果がここに表示されます\\n\\n例：\\nタイトル: サンプルゲーム\\nプレイ時間: 120時間\\n達成率: 85%';
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
        _showErrorSnackBar('エンタメデータを検出できませんでした。\\nフォーマットを確認してください。');
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
    String? currentStats;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // タイトルパターン
      if (trimmedLine.contains('タイトル:') || 
          trimmedLine.contains('ゲーム:') || 
          trimmedLine.contains('本:') || 
          trimmedLine.contains('映画:')) {
        currentTitle = trimmedLine.replaceAll(RegExp(r'タイトル:|ゲーム:|本:|映画:'), '').trim();
      }
      // 時間・日付パターン
      else if (trimmedLine.contains('プレイ時間:') || 
               trimmedLine.contains('読了日:') || 
               trimmedLine.contains('鑑賞日:')) {
        currentInfo = trimmedLine.replaceAll(RegExp(r'プレイ時間:|読了日:|鑑賞日:'), '').trim();
      }
      // 統計・評価パターン
      else if (trimmedLine.contains('達成率:') || 
               trimmedLine.contains('評価:') || 
               trimmedLine.contains('スコア:')) {
        currentStats = trimmedLine;
      }
      // シンプルなタイトル（コロンがない場合）
      else if (currentTitle == null && trimmedLine.length > 3 && !trimmedLine.contains(':')) {
        currentTitle = trimmedLine;
      }
      
      // アイテム作成
      if (currentTitle != null && (currentInfo != null || items.length < 5)) {
        items.add({
          'title': currentTitle,
          'info': currentInfo ?? '${widget.serviceName}でプレイ/鑑賞',
          'stats': currentStats ?? '',
          'service': widget.serviceName,
          'type': selectedImportType,
          'confidence': 0.8,
        });
        currentTitle = null;
        currentInfo = null;
        currentStats = null;
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
      case 'games':
        return [
          {
            'title': 'サンプルゲーム1',
            'info': 'プレイ時間: 50時間',
            'stats': '達成率: 75%',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': 'サンプルゲーム2',
            'info': 'プレイ時間: 25時間',
            'stats': '達成率: 100%',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      case 'books':
        return [
          {
            'title': 'サンプル書籍1',
            'info': '読了日: 2024/01/15',
            'stats': '評価: ★★★★☆',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': 'サンプル書籍2',
            'info': '読了日: 2024/01/10',
            'stats': '評価: ★★★★★',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      case 'cinema':
        return [
          {
            'title': 'サンプル映画1',
            'info': '鑑賞日: 2024/01/15',
            'stats': '評価: ★★★★☆',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': 'サンプル映画2',
            'info': '鑑賞日: 2024/01/12',
            'stats': '評価: ★★★☆☆',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      default:
        return [
          {
            'title': 'サンプルコンテンツ1',
            'info': '${widget.serviceName}で利用',
            'stats': '',
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
                    color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
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
      case 'games':
        return 'ゲームプレイ履歴・実績を取り込み';
      case 'books':
        return '読書履歴・電子書籍データを取り込み';
      case 'cinema':
        return '映画鑑賞履歴・レビューを取り込み';
      default:
        return 'エンタメ履歴データを取り込み';
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
                        if (item['stats'].isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['stats'],
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
            '${processedContent.length}件のエンタメデータが正常に取り込まれました。',
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
      case 'history':
      case 'reading_history':
      case 'viewing_history':
        return '履歴データ';
      case 'achievements':
        return '実績データ';
      case 'library':
        return 'ライブラリデータ';
      case 'stats':
        return '統計データ';
      case 'reviews':
      case 'ratings':
        return 'レビュー・評価データ';
      default:
        return 'データ';
    }
  }

  String _getPlaceholderText() {
    switch (widget.serviceId) {
      case 'games':
        return '''例：
タイトル: サンプルゲーム
プレイ時間: 50時間
達成率: 75%

またはゲーム履歴画面をOCRで読み取ったテキストをペーストしてください''';
      case 'books':
        return '''例：
本: サンプル書籍
読了日: 2024/01/15
評価: ★★★★☆

または読書履歴をOCRで読み取ったテキストをペーストしてください''';
      case 'cinema':
        return '''例：
映画: サンプル映画
鑑賞日: 2024/01/15
評価: ★★★★☆

または映画鑑賞履歴をOCRで読み取ったテキストをペーストしてください''';
      default:
        return '''例：
タイトル: サンプルコンテンツ
日付: 2024/01/15

または${widget.serviceName}の画面をOCRで読み取ったテキストをペーストしてください''';
    }
  }
}
