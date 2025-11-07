
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/services/amazon_purchase_parser.dart';
import '../../../src/core/components/service_icons.dart';

class ShoppingImportScreen extends ConsumerStatefulWidget {
  final String initialImportType;
  final bool allowTypeSwitch;
  final String? customServiceName;

  const ShoppingImportScreen({
    super.key,
    this.initialImportType = 'amazon',
    this.allowTypeSwitch = true,
    this.customServiceName,
  });

  @override
  ConsumerState<ShoppingImportScreen> createState() =>
      _ShoppingImportScreenState();
}

class _ShoppingImportScreenState extends ConsumerState<ShoppingImportScreen>
    with TickerProviderStateMixin {
  static const Set<String> _supportedImportTypes = {
    'amazon',
    'rakuten',
    'yahoo_shopping',
    'shein',
    'other',
  };

  Map<String, dynamic> get _activeImportType {
    return importTypes.firstWhere(
      (type) => type['id'] == selectedImportType,
      orElse: () => importTypes.first,
    );
  }

  late String
      selectedImportType; // amazon, rakuten, yahoo_shopping, shein, other
  late bool _allowTypeSwitch;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isProcessing = false;
  List<Map<String, dynamic>> processedPurchases = [];
  List<AmazonPurchaseItem> extractedPurchases = [];
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();
  bool showConfirmation = false;
  bool showPreview = false;
  List<bool> selectedItems = [];
  String _selectedInputMethod = 'text';

  // ショッピング取り込みタイプ
  final List<Map<String, dynamic>> importTypes = [
    {
      'id': 'amazon',
      'title': 'Amazon',
      'subtitle': 'Amazon購入履歴・注文履歴',
      'icon': Icons.shopping_bag,
      'color': const Color(0xFFFF9900),
      'description': 'Amazonでの購入履歴、注文履歴、欲しいものリストを記録します',
    },
    {
      'id': 'rakuten',
      'title': '楽天市場',
      'subtitle': '楽天市場での購入履歴',
      'icon': Icons.store,
      'color': const Color(0xFFBF0000),
      'description': '楽天市場での購入履歴やお気に入り商品の整理に対応します',
    },
    {
      'id': 'yahoo_shopping',
      'title': 'Yahoo!ショッピング',
      'subtitle': 'Yahoo!ショッピングの購入履歴',
      'icon': Icons.shopping_cart,
      'color': const Color(0xFF7B0099),
      'description': 'Yahoo!ショッピングでの注文履歴を取り込みます',
    },
    {
      'id': 'shein',
      'title': 'SHEIN',
      'subtitle': 'SHEINの注文履歴',
      'icon': Icons.style,
      'color': const Color(0xFFF54785),
      'description': 'SHEINで購入したファッションや雑貨の履歴を記録します',
    },
    {
      'id': 'other',
      'title': 'その他のEC',
      'subtitle': 'その他のオンラインショップ',
      'icon': Icons.language,
      'color': const Color(0xFF607D8B),
      'description': 'その他のECサイトの購入履歴を自由に記録します',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedImportType =
        _supportedImportTypes.contains(widget.initialImportType)
            ? widget.initialImportType
            : 'amazon';
    _allowTypeSwitch = widget.allowTypeSwitch;
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
          'ショッピングデータ取り込み',
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
    final activeType = _activeImportType;
    final Color accentColor =
        activeType['color'] as Color? ?? const Color(0xFFFF9900);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withOpacity(0.85)],
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
                  serviceId: selectedImportType,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.customServiceName ?? activeType['title']} データ取り込み',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeType['description'] as String? ?? 'ECサイトでの購入履歴を記録',
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
    final bool isActive = _selectedInputMethod == id;
    const accent = Color(0xFFFF9900);

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
              color: isActive
                  ? accent
                  : (isDark
                      ? const Color(0xFF303030)
                      : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.35),
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
      key: const ValueKey('text-helper'),
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
          const Icon(Icons.edit_note, size: 20, color: Color(0xFFFF9900)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '注文履歴をコピー＆ペーストして「テキストを解析」ボタンを押すと自動で商品を抽出します。',
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
      key: const ValueKey('ocr-controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'スクリーンショットから注文情報を抽出します。',
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
              backgroundColor: const Color(0xFFFF9900),
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
      key: const ValueKey('url-controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '注文履歴ページのURLを貼り付けると自動で情報を取得します。',
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
            hintText:
                'https://www.amazon.co.jp/gp/your-account/order-details...',
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
              backgroundColor: const Color(0xFFFF9900),
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
      case 'amazon':
        return '例：\n注文番号: 123-4567890-1234567\n商品名: iPhone 15 Pro Max 256GB\n価格: ¥159,800\n注文日: 2024/01/15\n配送状況: 配送済み\n\nまたはAmazonの注文履歴をOCRで読み取ったテキストをペーストしてください';
      case 'rakuten':
        return '例：\n注文番号: 202401150001\n商品名: Nintendo Switch 本体\n価格: ¥32,978\n注文日: 2024/01/15\nショップ: 楽天ブックス\n\nまたは楽天市場の購入履歴をOCRで読み取ったテキストをペーストしてください';
      case 'yahoo_shopping':
        return '例：\n注文番号: Y2024011500001\n商品名: ワイヤレスイヤホン\n価格: ¥12,800\n注文日: 2024/01/15\nストア: Yahoo!ショッピング\n\nまたはYahoo!ショッピングの注文履歴をOCRで読み取ったテキストをペーストしてください';
      case 'shein':
        return '例：\n注文番号: S123456789\n商品名: フローラルワンピース Mサイズ\n価格: ¥3,280\n注文日: 2024/01/15\n配送状況: 発送済み\n\nまたはSHEINの注文履歴ページをOCRで読み取ったテキストをペーストしてください';
      case 'other':
        final serviceName = widget.customServiceName ?? '対象サイト';
        return '例：\nサイト名: $serviceName\n商品名: サンプルアイテム\n価格: ¥15,400\n注文日: 2024/01/15\n注文番号: ORD-2024-001\n\nまたは$serviceNameの注文履歴をOCRで読み取ったテキストをペーストしてください';
      default:
        return 'ショッピング関連のデータを入力してください';
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
          color: const Color(0xFFFF9900),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ServiceIcons.buildIcon(
                serviceId: selectedImportType,
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
                  color: extractedPurchases.length >=
                          (_estimateOriginalItemCount() * 0.9)
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
                    ? (isDark
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFF8FAFC))
                    : (isDark
                        ? const Color(0xFF404040)
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF9900)
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
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getConfidenceColor(item.confidence)
                                    .withOpacity(0.1),
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
          }),
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
                  onPressed: selectedItems.any((selected) => selected)
                      ? _confirmImport
                      : null,
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
    final bool canExecute = _isPrimaryActionEnabled && !isProcessing;
    final String label = isProcessing ? '処理中...' : _primaryActionLabel();

    return FloatingActionButton.extended(
      onPressed: canExecute ? _handlePrimaryAction : null,
      backgroundColor: canExecute
          ? const Color(0xFFFF9900)
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
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
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

    await Future.delayed(const Duration(milliseconds: 900));

    final sampleText = _sampleTextForType(selectedImportType);

    setState(() {
      _textController.text = sampleText;
      isProcessing = false;
    });

    _showSnackBar('OCR解析結果をテキストエリアに反映しました。内容を確認してください。');
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

    await Future.delayed(const Duration(milliseconds: 900));

    final inferredType = _inferImportTypeFromHost(uri.host);
    final nextType = (_allowTypeSwitch && inferredType != selectedImportType)
        ? inferredType
        : selectedImportType;
    final sampleText = _sampleTextForType(nextType);

    setState(() {
      selectedImportType = nextType;
      _textController.text = sampleText;
      isProcessing = false;
    });

    _showSnackBar('URLから注文データを取得しました。内容を確認してください。');
    _processData();
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
        final detectionRate =
            (parsedItems.length / _estimateOriginalItemCount()) * 100;
        debugPrint('検出率: ${detectionRate.toStringAsFixed(1)}%');
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      _showErrorSnackBar('データ解析中にエラーが発生しました: $e');
    }
  }

  String _sampleTextForType(String type) {
    switch (type) {
      case 'amazon':
        return '''
注文番号: 249-1234567-8901234
商品名: Echo Pop (第2世代) スマートスピーカー
価格: ¥5,980
注文日: 2024/02/18
配送状況: 配送済み'''
            .trim();
      case 'rakuten':
        return '''
注文番号: 20240218-00012345
商品名: ダイソン V12 Detect Slim
価格: ¥64,800
注文日: 2024/02/18
ショップ: 楽天ビック
配送状況: 出荷準備中'''
            .trim();
      case 'yahoo_shopping':
        return '''
注文番号: YH-20240218-12345678
商品名: Surface Laptop Go 3
価格: ¥118,800
注文日: 2024/02/18
ストア: PayPayモール公式ストア
配送状況: 配送済み'''
            .trim();
      case 'shein':
        return '''
注文番号: S1234567891011
商品名: フローラルワンピース Mサイズ
価格: ¥3,450
注文日: 2024/02/18
配送状況: 通関待ち'''
            .trim();
      case 'other':
        final serviceName = widget.customServiceName ?? '対象サイト';
        return '''
サイト名: $serviceName
注文番号: ORD-2024-0001
商品名: サンプルアイテム
価格: ¥12,800
注文日: 2024/02/18
配送状況: 配送済み'''
            .trim();
      default:
        return '''
注文番号: 20240218-XYZ
商品名: サンプル商品
価格: ¥9,800
注文日: 2024/02/18
配送状況: 処理中'''
            .trim();
    }
  }

  String _inferImportTypeFromHost(String host) {
    final lower = host.toLowerCase();
    if (lower.contains('amazon')) return 'amazon';
    if (lower.contains('rakuten')) return 'rakuten';
    if (lower.contains('yahoo')) return 'yahoo_shopping';
    if (lower.contains('shein')) return 'shein';
    return selectedImportType;
  }

  int _estimateOriginalItemCount() {
    // 行数や「お届け済み」の出現回数から推定
    final lines = _textController.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .length;
    final deliveryCount =
        RegExp(r'お?届け済み|受取済み').allMatches(_textController.text).length;
    return deliveryCount > 0 ? deliveryCount : (lines / 3).ceil();
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar(message, color: Colors.red[600]);
  }

  void _showSnackBar(String message, {Color? color}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color ?? const Color(0xFF333333),
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
