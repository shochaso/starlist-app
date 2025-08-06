import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../src/providers/theme_provider_enhanced.dart';

class DigitalImportScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String serviceName;
  final Color serviceColor;
  final IconData serviceIcon;
  
  const DigitalImportScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.serviceColor,
    required this.serviceIcon,
  });

  @override
  ConsumerState<DigitalImportScreen> createState() => _DigitalImportScreenState();
}

class _DigitalImportScreenState extends ConsumerState<DigitalImportScreen> {
  String selectedImportType = 'usage';
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
    'smartphone_apps': [
      {'id': 'usage', 'title': '使用時間', 'subtitle': 'アプリ別使用時間・頻度'},
      {'id': 'downloads', 'title': 'ダウンロード履歴', 'subtitle': 'インストール・アップデート'},
      {'id': 'purchases', 'title': 'アプリ内課金', 'subtitle': '課金・購入履歴'},
      {'id': 'notifications', 'title': '通知履歴', 'subtitle': '受信した通知'},
    ],
    'web_services': [
      {'id': 'browsing', 'title': '閲覧履歴', 'subtitle': 'ウェブサイト訪問記録'},
      {'id': 'bookmarks', 'title': 'ブックマーク', 'subtitle': 'お気に入りサイト'},
      {'id': 'subscriptions', 'title': 'サブスクリプション', 'subtitle': '有料サービス契約'},
      {'id': 'accounts', 'title': 'アカウント', 'subtitle': '登録サービス一覧'},
    ],
    'game_apps': [
      {'id': 'playtime', 'title': 'プレイ時間', 'subtitle': 'ゲーム別プレイ時間'},
      {'id': 'achievements', 'title': '実績・レベル', 'subtitle': '達成した実績・レベル'},
      {'id': 'purchases', 'title': 'ゲーム内課金', 'subtitle': 'アイテム・通貨購入'},
      {'id': 'friends', 'title': 'フレンド・ギルド', 'subtitle': 'ソーシャル機能利用'},
    ],
  };

  List<Map<String, String>> get currentImportTypes {
    return importTypesByService[widget.serviceId] ?? [
      {'id': 'usage', 'title': '利用履歴', 'subtitle': 'デジタルサービス利用記録'},
      {'id': 'preferences', 'title': '設定・嗜好', 'subtitle': '設定・お気に入り'},
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
      _textController.text = 'OCR解析結果がここに表示されます\\n\\n例：\\nアプリ名: サンプルアプリ\\n使用時間: 2時間30分\\n起動回数: 15回';
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
        _showErrorSnackBar('デジタルサービスデータを検出できませんでした。\\nフォーマットを確認してください。');
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
    
    String? currentApp;
    String? currentUsage;
    String? currentStats;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // アプリ・サービス名パターン
      if (trimmedLine.contains('アプリ名:') || 
          trimmedLine.contains('サービス名:') || 
          trimmedLine.contains('サイト名:')) {
        currentApp = trimmedLine.replaceAll(RegExp(r'アプリ名:|サービス名:|サイト名:'), '').trim();
      }
      // 使用時間・頻度パターン
      else if (trimmedLine.contains('使用時間:') || 
               trimmedLine.contains('プレイ時間:') || 
               trimmedLine.contains('閲覧時間:')) {
        currentUsage = trimmedLine.replaceAll(RegExp(r'使用時間:|プレイ時間:|閲覧時間:'), '').trim();
      }
      // 統計・その他パターン
      else if (trimmedLine.contains('起動回数:') || 
               trimmedLine.contains('レベル:') || 
               trimmedLine.contains('訪問回数:')) {
        currentStats = trimmedLine;
      }
      // シンプルなアプリ名（コロンがない場合）
      else if (currentApp == null && trimmedLine.length > 3 && !trimmedLine.contains(':')) {
        currentApp = trimmedLine;
      }
      
      // アイテム作成
      if (currentApp != null && (currentUsage != null || items.length < 5)) {
        items.add({
          'title': currentApp,
          'usage': currentUsage ?? '${widget.serviceName}で利用',
          'stats': currentStats ?? '',
          'service': widget.serviceName,
          'type': selectedImportType,
          'confidence': 0.8,
        });
        currentApp = null;
        currentUsage = null;
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
      case 'smartphone_apps':
        return [
          {
            'title': 'サンプルアプリ1',
            'usage': '使用時間: 2時間30分',
            'stats': '起動回数: 15回',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': 'サンプルアプリ2',
            'usage': '使用時間: 45分',
            'stats': '起動回数: 8回',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      case 'web_services':
        return [
          {
            'title': 'サンプルサイト1',
            'usage': '閲覧時間: 1時間20分',
            'stats': '訪問回数: 12回',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': 'サンプルサイト2',
            'usage': '閲覧時間: 30分',
            'stats': '訪問回数: 5回',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      case 'game_apps':
        return [
          {
            'title': 'サンプルゲーム1',
            'usage': 'プレイ時間: 5時間15分',
            'stats': 'レベル: 25',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
          {
            'title': 'サンプルゲーム2',
            'usage': 'プレイ時間: 2時間30分',
            'stats': 'レベル: 12',
            'service': widget.serviceName,
            'type': selectedImportType,
            'confidence': 0.7,
          },
        ];
      default:
        return [
          {
            'title': 'サンプルサービス',
            'usage': '${widget.serviceName}で利用',
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

            // プライバシー注意事項
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity( 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'プライバシーについて',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'デジタル使用履歴には個人の生活パターンが含まれます。公開範囲を適切に設定してください。',
                          style: TextStyle(
                            color: Colors.blue[700],
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
              'またはスクリーンタイム画面から読み込み',
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
      case 'smartphone_apps':
        return 'スマホアプリの使用時間・履歴を取り込み';
      case 'web_services':
        return 'ウェブサービス利用履歴を取り込み';
      case 'game_apps':
        return 'ゲームアプリのプレイ履歴を取り込み';
      default:
        return 'デジタルサービス利用履歴を取り込み';
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
                '検出されたデジタル利用記録 (${extractedContent.length}件)',
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
                        if (item['usage'].isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['usage'],
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
            '${processedContent.length}件のデジタル利用データが正常に取り込まれました。',
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
      case 'usage':
      case 'browsing':
      case 'playtime':
        return '利用時間データ';
      case 'downloads':
        return 'ダウンロード履歴データ';
      case 'purchases':
        return '課金・購入データ';
      case 'notifications':
        return '通知履歴データ';
      case 'bookmarks':
        return 'ブックマークデータ';
      case 'subscriptions':
        return 'サブスクリプションデータ';
      case 'accounts':
        return 'アカウント情報データ';
      case 'achievements':
        return '実績・レベルデータ';
      case 'friends':
        return 'ソーシャル機能データ';
      default:
        return 'データ';
    }
  }

  String _getPlaceholderText() {
    switch (widget.serviceId) {
      case 'smartphone_apps':
        return '''例：
アプリ名: サンプルアプリ
使用時間: 2時間30分
起動回数: 15回

またはスクリーンタイム設定画面をOCRで読み取ったテキストをペーストしてください''';
      case 'web_services':
        return '''例：
サイト名: サンプルサイト
閲覧時間: 1時間20分
訪問回数: 12回

またはブラウザ履歴をOCRで読み取ったテキストをペーストしてください''';
      case 'game_apps':
        return '''例：
ゲーム名: サンプルゲーム
プレイ時間: 5時間15分
レベル: 25

またはゲーム内統計画面をOCRで読み取ったテキストをペーストしてください''';
      default:
        return '''例：
サービス名: サンプルサービス
使用時間: 1時間30分

または${widget.serviceName}の画面をOCRで読み取ったテキストをペーストしてください''';
    }
  }
}