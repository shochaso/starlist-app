
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/core/components/service_icons.dart';

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
  late String selectedImportType;
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
    'ubereats': [
      {'id': 'orders', 'title': '注文履歴', 'subtitle': 'Uber Eatsの注文記録'},
      {'id': 'favorites', 'title': 'お気に入り店舗', 'subtitle': 'よく頼むお店・メニュー'},
      {'id': 'addresses', 'title': '配送先', 'subtitle': 'お届け先住所の管理'},
      {'id': 'receipts', 'title': '領収書', 'subtitle': '決済・領収書記録'},
    ],
    'demaecan': [
      {'id': 'orders', 'title': '注文履歴', 'subtitle': '出前館の注文記録'},
      {'id': 'favorites', 'title': 'お気に入り店舗', 'subtitle': 'リピート注文を管理'},
      {'id': 'addresses', 'title': '配送先', 'subtitle': 'お届け先住所の履歴'},
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
    return importTypesByService[widget.serviceId] ??
        [
          {'id': 'orders', 'title': '注文・食事', 'subtitle': '飲食記録データ'},
          {'id': 'preferences', 'title': '嗜好・評価', 'subtitle': 'お気に入り・評価'},
        ];
  }

  @override
  void initState() {
    super.initState();
    selectedImportType = _initialImportTypeForService(widget.serviceId);
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
            _buildHeader(isDark),
            const SizedBox(height: 24),
            _buildImportTypeSelector(isDark),
            const SizedBox(height: 24),
            _buildDataInputSection(isDark),
            const SizedBox(height: 24),
            if (showPreview) _buildPreviewSection(isDark),
            if (showConfirmation) _buildConfirmationSection(isDark),
          ],
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
          colors: [
            widget.serviceColor,
            widget.serviceColor.withOpacity(0.8),
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _headerSubtitle(),
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
    );
  }

  Widget _buildImportTypeSelector(bool isDark) {
    final types = currentImportTypes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          children: types.map((type) => _buildTypeChip(type, isDark)).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeChip(Map<String, String> type, bool isDark) {
    final isSelected = selectedImportType == type['id'];
    return FilterChip(
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type['title'] ?? '',
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.white
                      : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          if ((type['subtitle'] ?? '').isNotEmpty)
            Text(
              type['subtitle']!,
              style: TextStyle(
                color: isSelected
                    ? Colors.white70
                    : isDark
                        ? Colors.white60
                        : Colors.black54,
                fontSize: 12,
              ),
            ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            selectedImportType = type['id']!;
          });
        }
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
    final placeholder = _getPlaceholderText();
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
            height: 1.4,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildTextHelper(bool isDark) {
    return Container(
      key: const ValueKey('food-text-helper'),
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
          Icon(Icons.restaurant_menu, size: 20, color: widget.serviceColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '注文履歴やメニュー情報を貼り付けて「${_primaryActionLabel()}」を押すと、品目・価格などを自動抽出します。',
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
      key: const ValueKey('food-ocr-controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'メニューや領収書のスクリーンショットから注文情報を抽出します。',
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
      key: const ValueKey('food-url-controls'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '注文履歴ページやレシピページのURLから情報を取得します。',
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
                '検出されたデータ (${extractedContent.length}件)',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '取り込む項目を選択してください',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ...extractedContent.asMap().entries.map((entry) {
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
                      ? widget.serviceColor
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
                    activeColor: widget.serviceColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']?.toString() ?? '',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((item['info'] ?? '').toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item['info']?.toString() ?? '',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        if ((item['price'] ?? '').toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item['price']?.toString() ?? '',
                              style: TextStyle(
                                color: widget.serviceColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white54 : Colors.black54,
                    side: BorderSide(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
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
                    backgroundColor: widget.serviceColor,
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
                    backgroundColor: widget.serviceColor,
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
                    foregroundColor: widget.serviceColor,
                    side: BorderSide(color: widget.serviceColor),
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

  Widget _buildFloatingActionButton(bool isDark) {
    final bool canExecute = _isPrimaryActionEnabled && !isProcessing;
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

    await Future.delayed(const Duration(milliseconds: 900));

    final inferredType = _inferImportTypeFromUrl(uri.host);
    final sampleText = _sampleTextForService(
        widget.serviceId, inferredType ?? selectedImportType);

    setState(() {
      if (inferredType != null) {
        selectedImportType = inferredType;
      }
      _textController.text = sampleText;
      isProcessing = false;
    });

    _showSnackBar('URLから${widget.serviceName}のデータを取得しました。内容を確認してください。');
    _processData();
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
        _showErrorSnackBar('飲食データを検出できませんでした。\nフォーマットを確認してください。');
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      _showErrorSnackBar('データ解析中にエラーが発生しました: $e');
    }
  }

  List<Map<String, dynamic>> _parseContent(String text) {
    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final List<Map<String, dynamic>> items = [];

    String? currentTitle;
    String? currentInfo;
    String? currentPrice;

    for (final line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.contains(RegExp(r'(店舗|レストラン|店名)[:：]'))) {
        currentTitle =
            trimmedLine.replaceAll(RegExp(r'(店舗|レストラン|店名)[:：]'), '').trim();
      } else if (trimmedLine.contains(RegExp(r'(メニュー|料理|注文|レシピ|内容)[:：]'))) {
        currentInfo = trimmedLine
            .replaceAll(RegExp(r'(メニュー|料理|注文|レシピ|内容)[:：]'), '')
            .trim();
      } else if (trimmedLine.contains(RegExp(r'(金額|価格|合計|料金)[:：]'))) {
        currentPrice =
            trimmedLine.replaceAll(RegExp(r'(金額|価格|合計|料金)[:：]'), '').trim();
      } else if (currentTitle == null &&
          trimmedLine.length > 3 &&
          !trimmedLine.contains(':') &&
          !trimmedLine.contains('：')) {
        currentTitle = trimmedLine;
      }

      if (currentTitle != null &&
          (currentInfo != null || currentPrice != null)) {
        items.add({
          'title': currentTitle,
          'info': currentInfo ??
              _defaultInfoForService(widget.serviceId, selectedImportType),
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

    if (items.isEmpty && text.trim().isNotEmpty) {
      items.addAll(_sampleItemsForPreview());
    }

    return items;
  }

  List<Map<String, dynamic>> _sampleItemsForPreview() {
    return [
      {
        'title': 'サンプル注文',
        'info': '${widget.serviceName}で注文',
        'price': '¥1,200',
        'service': widget.serviceName,
        'type': selectedImportType,
        'confidence': 0.7,
      },
    ];
  }

  String _getPlaceholderText() {
    switch (widget.serviceId) {
      case 'ubereats':
      case 'demaecan':
      case 'delivery':
        return '''
例：
注文番号: UE-2024-0218-1234
注文日時: 2024/02/18 19:45
店舗: ピザデリバリー渋谷店
メニュー: マルゲリータL、ポテト
金額: ¥2,680
配送先: 東京都渋谷区...
配達員: 田中さん''';
      case 'cooking':
        return '''
例：
レシピ名: ほうれん草とベーコンのキッシュ
作成日: 2024/02/18
食材: ほうれん草、ベーコン、卵、チーズ
カロリー: 520kcal
メモ: 前日に下準備をすると楽''';
      case 'restaurant':
      default:
        return '''
例：
店舗: サンプルカフェ青山店
注文日時: 2024/02/18 13:20
メニュー: 日替わりランチセット
金額: ¥1,320
評価: とても美味しかった''';
    }
  }

  String _headerSubtitle() {
    switch (widget.serviceId) {
      case 'ubereats':
        return 'Uber Eatsの注文履歴・お気に入りを取り込み';
      case 'demaecan':
        return '出前館の注文や配送先を管理';
      case 'delivery':
        return 'デリバリーサービスの注文記録をまとめる';
      case 'restaurant':
        return '外食・カフェの注文やレビューを記録';
      case 'cooking':
        return '自炊レシピや食材・栄養記録を整理';
      default:
        return '飲食に関するデータを取り込み';
    }
  }

  String _defaultInfoForService(String serviceId, String importType) {
    if (serviceId == 'cooking') {
      switch (importType) {
        case 'recipes':
          return '自炊レシピ';
        case 'ingredients':
          return '使用食材';
        case 'meals':
          return '食事記録';
        case 'nutrition':
          return '栄養管理';
      }
    }
    switch (importType) {
      case 'reviews':
        return '店舗へのレビュー';
      case 'favorites':
        return 'お気に入りの店舗・メニュー';
      case 'addresses':
        return '登録済み配送先';
      case 'receipts':
        return '支払い記録';
      default:
        return '${widget.serviceName}での注文';
    }
  }

  String _sampleTextForService(String serviceId, String importType) {
    switch (serviceId) {
      case 'ubereats':
        return '''
注文番号: UE-20240218-1234
注文日時: 2024/02/18 20:05
店舗: グルメバーガー渋谷店
メニュー: クラシックバーガー + フライドポテト
金額: ¥2,180
配送先: 東京都渋谷区神南1-1-1
配達員: Sato''';
      case 'demaecan':
        return '''
注文番号: DM-20240218-4821
注文日時: 2024/02/18 19:40
店舗: 餃子の王将 渋谷店
メニュー: 餃子セット + 酢豚
金額: ¥2,560
決済方法: クレジットカード
配送先: 東京都渋谷区桜丘町2-2''';
      case 'cooking':
        switch (importType) {
          case 'recipes':
            return '''
レシピ名: 鶏むね肉のレモンバターソテー
作成日: 2024/02/18
材料:
- 鶏むね肉 1枚
- レモン 1/2個
- バター 20g
所要時間: 25分
メモ: ソースを多めに作ると美味しい''';
          case 'ingredients':
            return '''
購入日: 2024/02/18
食材: 鶏むね肉 2枚
価格: ¥420
利用予定: 2/18 夕食
メモ: 冷凍保存3日まで''';
          case 'meals':
            return '''
日時: 2024/02/18 朝食
メニュー: グリーンスムージー
栄養メモ: 野菜 + フルーツ
評価: ◎
コメント: 食欲がない朝にぴったり''';
          case 'nutrition':
            return '''
測定日: 2024/02/18
総カロリー: 1,850kcal
タンパク質: 85g
炭水化物: 210g
脂質: 60g''';
          default:
            return '''
食事記録: 2024/02/18 夕食
メニュー: サーモンソテーとサラダ
カロリー: 650kcal
コメント: ドレッシング控えめ''';
        }
      case 'restaurant':
        return '''
店舗: BISTRO Sample 表参道
来店日: 2024/02/18
注文: 牛ほほ肉の赤ワイン煮込みコース
人数: 2名
合計金額: ¥12,400
メモ: デザートがとても美味しかった''';
      case 'delivery':
      default:
        return '''
注文番号: DL-20240218-5521
注文日時: 2024/02/18 18:20
店舗: サンプルカレー吉祥寺店
メニュー: バターチキンカレー + ナン
金額: ¥1,480
備考: 玄関前に置き配''';
    }
  }

  String _urlHintForService() {
    switch (widget.serviceId) {
      case 'ubereats':
        return 'https://www.ubereats.com/jp/orders/xxxxxxxx';
      case 'demaecan':
        return 'https://account.demae-can.com/orders/detail/...';
      case 'cooking':
        return 'https://cookpad.com/recipe/...';
      case 'restaurant':
        return 'https://www.tablecheck.com/ja/shops/...';
      default:
        return 'https://example.com/orders/...';
    }
  }

  String? _inferImportTypeFromUrl(String host) {
    final lower = host.toLowerCase();
    if (lower.contains('uber')) return 'orders';
    if (lower.contains('demae') || lower.contains('demaecan')) return 'orders';
    if (lower.contains('cookpad') || lower.contains('recipe')) return 'recipes';
    if (lower.contains('tabelog') || lower.contains('tablecheck')) {
      return 'reservations';
    }
    return null;
  }

  String _initialImportTypeForService(String serviceId) {
    switch (serviceId) {
      case 'cooking':
        return 'recipes';
      default:
        return 'orders';
    }
  }

  int _estimateOriginalItemCount() {
    final lines = _textController.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .length;
    final orderCount =
        RegExp(r'(注文|order)').allMatches(_textController.text).length;
    return orderCount > 0 ? orderCount : (lines / 4).ceil();
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
}
