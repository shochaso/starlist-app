import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/services/amazon_purchase_parser.dart';

class ShoppingImportScreen extends ConsumerStatefulWidget {
  const ShoppingImportScreen({super.key});

  @override
  ConsumerState<ShoppingImportScreen> createState() => _ShoppingImportScreenState();
}

class _ShoppingImportScreenState extends ConsumerState<ShoppingImportScreen>
    with TickerProviderStateMixin {
  String selectedImportType = 'amazon'; // amazon, rakuten, yahoo, other
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isProcessing = false;
  List<Map<String, dynamic>> processedPurchases = [];
  List<AmazonPurchaseItem> extractedPurchases = [];
  File? selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool showConfirmation = false;
  bool showPreview = false;
  List<bool> selectedItems = [];

  // ショッピング取り込みタイプ
  final List<Map<String, dynamic>> importTypes = [
    {
      'id': 'amazon',
      'title': 'Amazon',
      'subtitle': 'Amazon購入履歴・注文履歴',
      'icon': Icons.shopping_bag,
      'color': const Color(0xFFFF9900), // Amazon orange
      'description': 'Amazonでの購入履歴、注文履歴、欲しいものリストを記録します',
    },
    {
      'id': 'rakuten',
      'title': '楽天市場',
      'subtitle': '楽天での購入履歴',
      'icon': Icons.store,
      'color': const Color(0xFFBF0000), // Rakuten red
      'description': '楽天市場での購入履歴、お気に入り商品を記録します',
    },
    {
      'id': 'yahoo',
      'title': 'Yahoo!ショッピング',
      'subtitle': 'Yahoo!での購入履歴',
      'icon': Icons.shopping_cart,
      'color': const Color(0xFF7B0099), // Yahoo purple
      'description': 'Yahoo!ショッピングでの購入履歴を記録します',
    },
    {
      'id': 'mercari',
      'title': 'メルカリ',
      'subtitle': 'フリマアプリでの取引',
      'icon': Icons.handshake,
      'color': const Color(0xFFFF5722), // Mercari orange
      'description': 'メルカリでの購入・販売履歴を記録します',
    },
    {
      'id': 'other',
      'title': 'その他のEC',
      'subtitle': 'その他のオンラインショップ',
      'icon': Icons.language,
      'color': const Color(0xFF607D8B), // Blue grey
      'description': 'その他のECサイトでの購入履歴を記録します',
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
          'ショッピングデータ取り込み',
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
          colors: [Color(0xFFFF9900), Color(0xFFFF7700)],
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
                  Icons.shopping_bag,
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
                      'ショッピングデータ取り込み',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ECサイトでの購入履歴を記録',
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
          '取り込みサービスを選択',
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
          ? const Color(0xFFFF9900)
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
      case 'amazon':
        return '例：\n注文番号: 123-4567890-1234567\n商品名: iPhone 15 Pro Max 256GB\n価格: ¥159,800\n注文日: 2024/01/15\n配送状況: 配送済み\n\nまたはAmazonの注文履歴をOCRで読み取ったテキストをペーストしてください';
      case 'rakuten':
        return '例：\n注文番号: 202401150001\n商品名: Nintendo Switch 本体\n価格: ¥32,978\n注文日: 2024/01/15\nショップ: 楽天ブックス\n\nまたは楽天市場の購入履歴をOCRで読み取ったテキストをペーストしてください';
      case 'yahoo':
        return '例：\n注文番号: Y2024011500001\n商品名: ワイヤレスイヤホン\n価格: ¥12,800\n注文日: 2024/01/15\nストア: Yahoo!ショッピング\n\nまたはYahoo!ショッピングの注文履歴をOCRで読み取ったテキストをペーストしてください';
      case 'mercari':
        return '例：\n取引タイプ: 購入\n商品名: ヴィンテージTシャツ\n価格: ¥3,500\n取引日: 2024/01/15\n出品者: メルカリユーザー123\n\nまたはメルカリの取引履歴をOCRで読み取ったテキストをペーストしてください';
      case 'other':
        return '例：\nサイト名: 公式オンラインストア\n商品名: スニーカー\n価格: ¥15,400\n注文日: 2024/01/15\n注文番号: ORD-2024-001\n\nまたは他のECサイトの注文履歴をOCRで読み取ったテキストをペーストしてください';
      default:
        return 'ショッピング関連のデータを入力してください';
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
          color: const Color(0xFFFF9900),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_cart,
                color: Color(0xFFFF9900),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '検出された商品 (${extractedPurchases.length}件)',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '検出率: ${((extractedPurchases.length / _estimateOriginalItemCount()) * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: extractedPurchases.length >= (_estimateOriginalItemCount() * 0.9) 
                      ? Colors.green 
                      : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '取り込む商品を選択してください',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ...extractedPurchases.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = selectedItems[index];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC))
                    : (isDark ? const Color(0xFF404040) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFFFF9900)
                      : (isDark ? const Color(0xFF525252) : const Color(0xFFE2E8F0)),
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
                    activeColor: const Color(0xFFFF9900),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              item.price,
                              style: const TextStyle(
                                color: Color(0xFFFF9900),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (item.orderDate != 'N/A') ...[
                              Text(
                                item.orderDate,
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getConfidenceColor(item.confidence).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${(item.confidence * 100).toInt()}%',
                                style: TextStyle(
                                  color: _getConfidenceColor(item.confidence),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
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
                      extractedPurchases.clear();
                      selectedItems.clear();
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
                  onPressed: selectedItems.any((selected) => selected) ? _confirmImport : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9900),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('${selectedItems.where((s) => s).length}件を取り込む'),
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
          color: const Color(0xFFFF9900),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFF9900),
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
            '${processedPurchases.length}件の購入データが正常に取り込まれました。',
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
                      processedPurchases.clear();
                      extractedPurchases.clear();
                      selectedItems.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9900),
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
                    foregroundColor: const Color(0xFFFF9900),
                    side: const BorderSide(color: Color(0xFFFF9900)),
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9900)),
          ),
          const SizedBox(height: 16),
          Text(
            'ショッピングデータを解析中...',
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
          ? const Color(0xFFFF9900)
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

    // 実際のデータ解析処理
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Amazon購入データをパース
      final parsedItems = AmazonPurchaseParser.parseText(_textController.text);
      
      setState(() {
        extractedPurchases = parsedItems;
        selectedItems = List.filled(parsedItems.length, true); // デフォルトで全選択
        isProcessing = false;
        showPreview = parsedItems.isNotEmpty;
      });

      if (parsedItems.isEmpty) {
        _showErrorSnackBar('商品データを検出できませんでした。\n形式を確認してください。');
      } else {
        final detectionRate = (parsedItems.length / _estimateOriginalItemCount()) * 100;
        debugPrint('検出率: ${detectionRate.toStringAsFixed(1)}%');
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      _showErrorSnackBar('データ解析中にエラーが発生しました: $e');
    }
  }

  int _estimateOriginalItemCount() {
    // 行数や「お届け済み」の出現回数から推定
    final lines = _textController.text.split('\n').where((line) => line.trim().isNotEmpty).length;
    final deliveryCount = RegExp(r'お?届け済み|受取済み').allMatches(_textController.text).length;
    return deliveryCount > 0 ? deliveryCount : (lines / 3).ceil();
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
    final selectedPurchases = extractedPurchases
        .asMap()
        .entries
        .where((entry) => selectedItems[entry.key])
        .map((entry) => entry.value.toMap())
        .toList();

    setState(() {
      processedPurchases = selectedPurchases;
      showPreview = false;
      showConfirmation = true;
    });
  }
}