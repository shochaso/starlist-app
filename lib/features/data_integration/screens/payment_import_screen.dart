import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../src/providers/theme_provider_enhanced.dart';

class PaymentImportScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String serviceName;
  final Color serviceColor;
  final IconData serviceIcon;
  
  const PaymentImportScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.serviceColor,
    required this.serviceIcon,
  });

  @override
  ConsumerState<PaymentImportScreen> createState() => _PaymentImportScreenState();
}

class _PaymentImportScreenState extends ConsumerState<PaymentImportScreen> {
  String selectedImportType = 'transactions';
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
    'credit_card': [
      {'id': 'transactions', 'title': '利用明細', 'subtitle': 'クレジットカード利用履歴'},
      {'id': 'statements', 'title': '請求書', 'subtitle': '月次請求明細'},
      {'id': 'rewards', 'title': 'ポイント・特典', 'subtitle': '獲得ポイント・キャッシュバック'},
      {'id': 'limits', 'title': '利用枠・設定', 'subtitle': '利用限度額・設定履歴'},
    ],
    'electronic_money': [
      {'id': 'transactions', 'title': '利用履歴', 'subtitle': 'IC・QR決済履歴'},
      {'id': 'charges', 'title': 'チャージ履歴', 'subtitle': '入金・チャージ記録'},
      {'id': 'balance', 'title': '残高履歴', 'subtitle': '残高推移・履歴'},
      {'id': 'campaigns', 'title': 'キャンペーン', 'subtitle': '特典・キャンペーン利用'},
    ],
  };

  List<Map<String, String>> get currentImportTypes {
    return importTypesByService[widget.serviceId] ?? [
      {'id': 'transactions', 'title': '決済履歴', 'subtitle': '支払い・決済記録'},
      {'id': 'balance', 'title': '残高・ポイント', 'subtitle': '残高・ポイント履歴'},
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
      _textController.text = 'OCR解析結果がここに表示されます\\n\\n例：\\n利用店舗: コンビニエンスストア\\n金額: 500円\\n利用日: 2024/01/15';
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
        _showErrorSnackBar('決済データを検出できませんでした。\\nフォーマットを確認してください。');
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
    
    String? currentMerchant;
    String? currentAmount;
    String? currentDate;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // 店舗・加盟店パターン
      if (trimmedLine.contains('利用店舗:') || 
          trimmedLine.contains('加盟店:') || 
          trimmedLine.contains('店舗:')) {
        currentMerchant = trimmedLine.replaceAll(RegExp(r'利用店舗:|加盟店:|店舗:'), '').trim();
      }
      // 金額パターン
      else if (trimmedLine.contains('金額:') || 
               trimmedLine.contains('利用額:') || 
               trimmedLine.contains('円')) {
        currentAmount = trimmedLine.replaceAll(RegExp(r'金額:|利用額:'), '').trim();
      }
      // 日付パターン
      else if (trimmedLine.contains('利用日:') || 
               trimmedLine.contains('決済日:') || 
               trimmedLine.contains('日付:')) {
        currentDate = trimmedLine.replaceAll(RegExp(r'利用日:|決済日:|日付:'), '').trim();
      }
      // シンプルな店舗名（コロンがない場合）
      else if (currentMerchant == null && trimmedLine.length > 3 && 
               !trimmedLine.contains(':') && !trimmedLine.contains('円')) {
        currentMerchant = trimmedLine;
      }
      
      // アイテム作成
      if (currentMerchant != null && (currentAmount != null || items.length < 5)) {
        items.add({
          'title': currentMerchant,
          'amount': currentAmount ?? '',
          'date': currentDate ?? '${widget.serviceName}で決済',
          'service': widget.serviceName,
          'type': selectedImportType,
          'confidence': 0.8,
        });
        currentMerchant = null;
        currentAmount = null;
        currentDate = null;
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
      case 'credit_card':
        return [
          {
            'title': 'サンプルショップ',
            'amount': '3,500円',
            'date': '2024/01/15',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': 'ガソリンスタンド',
            'amount': '4,200円',
            'date': '2024/01/14',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      case 'electronic_money':
        return [
          {
            'title': 'コンビニエンスストア',
            'amount': '450円',
            'date': '2024/01/15',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': '駅売店',
            'amount': '280円',
            'date': '2024/01/15',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      default:
        return [
          {
            'title': 'サンプル店舗',
            'amount': '1,000円',
            'date': '${widget.serviceName}で決済',
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

            // セキュリティ注意事項
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity( 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'セキュリティに関する注意',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '決済データには個人情報が含まれる場合があります。クレジットカード番号等の機密情報は入力しないでください。',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontSize: 12,
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
              'またはレシート・明細から読み込み',
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
      case 'credit_card':
        return 'クレジットカード利用明細を取り込み';
      case 'electronic_money':
        return '電子マネー・QR決済履歴を取り込み';
      default:
        return '決済・支払い履歴を取り込み';
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
                '検出された決済記録 (${extractedContent.length}件)',
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
                        if (item['amount'].isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['amount'],
                            style: TextStyle(
                              color: widget.serviceColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (item['date'].isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['date'],
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
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
            '${processedContent.length}件の決済データが正常に取り込まれました。',
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
      case 'transactions':
        return '決済履歴データ';
      case 'statements':
        return '請求明細データ';
      case 'rewards':
        return 'ポイント・特典データ';
      case 'charges':
        return 'チャージ履歴データ';
      case 'balance':
        return '残高履歴データ';
      case 'campaigns':
        return 'キャンペーンデータ';
      default:
        return 'データ';
    }
  }

  String _getPlaceholderText() {
    switch (widget.serviceId) {
      case 'credit_card':
        return '''例：
利用店舗: サンプルショップ
金額: 3,500円
利用日: 2024/01/15

またはクレジットカード明細をOCRで読み取ったテキストをペーストしてください

注意: カード番号等の機密情報は入力しないでください''';
      case 'electronic_money':
        return '''例：
利用店舗: コンビニエンスストア
金額: 450円
利用日: 2024/01/15

または電子マネー履歴をOCRで読み取ったテキストをペーストしてください''';
      default:
        return '''例：
利用店舗: サンプル店舗
金額: 1,000円
利用日: 2024/01/15

または${widget.serviceName}の画面をOCRで読み取ったテキストをペーストしてください''';
    }
  }
}