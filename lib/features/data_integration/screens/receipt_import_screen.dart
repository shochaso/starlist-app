import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../providers/theme_provider.dart';
import '../../../services/receipt_ocr_parser.dart';

class ReceiptImportScreen extends ConsumerStatefulWidget {
  const ReceiptImportScreen({super.key});

  @override
  ConsumerState<ReceiptImportScreen> createState() => _ReceiptImportScreenState();
}

class _ReceiptImportScreenState extends ConsumerState<ReceiptImportScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isProcessing = false;
  List<ReceiptItem> extractedItems = [];
  Receipt? processedReceipt;
  File? selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool showConfirmation = false;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
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
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'レシート データ取り込み',
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
              // 入力フォーム
              _buildInputForm(),
              
              // 抽出結果の確認画面
              if (showConfirmation && extractedItems.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildConfirmationScreen(),
              ],
              
              // 処理結果
              if (processedReceipt != null) ...[
                const SizedBox(height: 24),
                _buildProcessingResults(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;

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
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt,
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
                        'レシート読み取り',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'レシートの写真を撮影またはアップロードして商品情報を自動抽出します',
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

            // 画像選択
            Text(
              'レシート画像',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (selectedImage != null) ...[
              Container(
                height: 300,
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
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('写真を撮る'),
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('ギャラリーから選択'),
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
              ],
            ),
            
            if (selectedImage != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : _processReceiptOCR,
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
                  label: Text(isProcessing ? '解析中...' : 'レシートを解析'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
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

            const SizedBox(height: 20),

            // テキスト入力エリア（手動入力用）
            Text(
              'または手動でデータを入力',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 180,
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
                  hintText: '''例：
購入日: 2024/01/15
店舗: セブンイレブン渋谷店

商品:
おにぎり（ツナマヨ） ¥150
コーヒー（ブラック） ¥120
チョコレート ¥200

合計: ¥470''',
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

            // アクションボタン
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final clipboardData = await Clipboard.getData('text/plain');
                      if (clipboardData?.text != null) {
                        _textController.text = clipboardData!.text!;
                      }
                    },
                    icon: const Icon(Icons.content_paste, size: 18),
                    label: const Text('ペースト'),
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
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : _processReceiptData,
                    icon: isProcessing 
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.upload, size: 18),
                    label: Text(isProcessing ? '処理中...' : 'データを取り込む'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
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

  Widget _buildConfirmationScreen() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;

    // カテゴリ別にアイテムをグループ化
    final groupedItems = <String, List<ReceiptItem>>{};
    for (final item in extractedItems) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

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
                        '${extractedItems.length}個の商品が見つかりました。取り込む商品を選択してください。',
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
                        for (final item in extractedItems) {
                          item.isSelected = true;
                        }
                      });
                    },
                    icon: const Icon(Icons.select_all, size: 16),
                    label: const Text('全て選択'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF444444) : const Color(0xFFF1F5F9),
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
                        for (final item in extractedItems) {
                          item.isSelected = false;
                        }
                      });
                    },
                    icon: const Icon(Icons.deselect, size: 16),
                    label: const Text('全て解除'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF444444) : const Color(0xFFF1F5F9),
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

            // カテゴリ別商品リスト
            ...groupedItems.entries.map((entry) {
              final category = entry.key;
              final items = entry.value;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // カテゴリヘッダー
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          color: _getCategoryColor(category),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: TextStyle(
                            color: _getCategoryColor(category),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${items.length}件',
                          style: TextStyle(
                            color: _getCategoryColor(category),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 商品リスト
                  ...items.map((item) {
                    final index = extractedItems.indexOf(item);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: item.isSelected 
                            ? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC))
                            : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.isSelected 
                              ? _getCategoryColor(category)
                              : (isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB)),
                          width: item.isSelected ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // 選択チェックボックス
                            Checkbox(
                              value: item.isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  item.isSelected = value ?? false;
                                });
                              },
                              activeColor: _getCategoryColor(category),
                            ),
                            const SizedBox(width: 12),
                            
                            // 商品情報
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      color: item.isSelected 
                                          ? (isDark ? Colors.white : Colors.black87)
                                          : (isDark ? Colors.grey[500] : Colors.black45),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (item.price != null)
                                        Text(
                                          '¥${item.price!.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: item.isSelected 
                                                ? const Color(0xFF10B981)
                                                : (isDark ? Colors.grey[600] : Colors.black38),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (item.quantity != null && item.quantity! > 1) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '× ${item.quantity}',
                                          style: TextStyle(
                                            color: item.isSelected 
                                                ? (isDark ? Colors.grey[400] : Colors.black54)
                                                : (isDark ? Colors.grey[600] : Colors.black38),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      // 信頼度表示
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getConfidenceColor(item.confidence),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${(item.confidence * 100).toInt()}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 16),
                ],
              );
            }),

            // 確定ボタン
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showConfirmation = false;
                        extractedItems.clear();
                      });
                    },
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('キャンセル'),
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
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmAndImportItems(),
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text('選択した商品を取り込む (${extractedItems.where((item) => item.isSelected).length}件)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
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
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;

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
                        'レシートデータが正常に取り込まれました',
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
            
            // レシート情報サマリー
            if (processedReceipt != null) ...[
              _buildReceiptSummary(),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSummary() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    final receipt = processedReceipt!;
    final selectedItems = receipt.items.where((item) => item.isSelected).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 基本情報
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (receipt.storeName != null)
                _buildSummaryRow('店舗名', receipt.storeName!, isDark),
              if (receipt.purchaseDate != null)
                _buildSummaryRow('購入日', 
                  '${receipt.purchaseDate!.year}/${receipt.purchaseDate!.month}/${receipt.purchaseDate!.day}', 
                  isDark),
              _buildSummaryRow('取り込み商品数', '${selectedItems.length}件', isDark),
              if (receipt.totalAmount != null)
                _buildSummaryRow('合計金額', '¥${receipt.totalAmount!.toStringAsFixed(0)}', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
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

  Future<void> _processReceiptOCR() async {
    if (selectedImage == null) return;

    setState(() {
      isProcessing = true;
    });

    try {
      const apiKey = 'YOUR_GOOGLE_API_KEY'; // TODO: 実際のAPIキーに置き換える
      
      final imageBytes = await selectedImage!.readAsBytes();
      final ocrParser = ReceiptOCRParser(apiKey: apiKey);
      final receipt = await ocrParser.parseReceiptImage(imageBytes);
      
      _textController.text = receipt.items.map((item) => 
        '${item.name} ¥${item.price?.toStringAsFixed(0) ?? "0"} (${item.category})'
      ).join('\n');

      setState(() {
        isProcessing = false;
        extractedItems = receipt.items;
        showConfirmation = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('レシートから${receipt.items.length}個の商品を抽出しました！'),
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
          content: Text('レシートの解析に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processReceiptData() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('データを入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    // 手動入力データの解析（簡易版）
    final items = _parseManualInput(_textController.text);
    
    setState(() {
      isProcessing = false;
      extractedItems = items;
      showConfirmation = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${items.length}個の商品情報を抽出しました！'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  List<ReceiptItem> _parseManualInput(String text) {
    final items = <ReceiptItem>[];
    final lines = text.split('\n');
    
    for (final line in lines) {
      final priceMatch = RegExp(r'¥(\d+)').firstMatch(line);
      if (priceMatch != null) {
        final price = double.tryParse(priceMatch.group(1)!);
        final itemName = line.substring(0, priceMatch.start).trim();
        
        if (itemName.isNotEmpty && price != null) {
          items.add(ReceiptItem(
            name: itemName,
            price: price,
            category: 'その他',
            confidence: 0.6,
          ));
        }
      }
    }
    
    return items;
  }

  void _confirmAndImportItems() {
    final selectedItems = extractedItems.where((item) => item.isSelected).toList();
    
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('取り込む商品を選択してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      processedReceipt = Receipt(
        items: selectedItems,
        purchaseDate: DateTime.now(),
        totalAmount: selectedItems.fold<double>(0.0, (sum, item) => sum + (item.price ?? 0.0)),
      );
      showConfirmation = false;
      extractedItems.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedItems.length}個の商品を取り込みました！'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '食品・飲料':
        return const Color(0xFFFF6B6B);
      case 'ファッション':
        return const Color(0xFF4ECDC4);
      case '美容・ヘルスケア':
        return const Color(0xFFFFE66D);
      case '家電・PC':
        return const Color(0xFF4D96FF);
      case '本・文具':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '食品・飲料':
        return Icons.restaurant;
      case 'ファッション':
        return Icons.checkroom;
      case '美容・ヘルスケア':
        return Icons.spa;
      case '家電・PC':
        return Icons.devices;
      case '本・文具':
        return Icons.book;
      default:
        return Icons.category;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}