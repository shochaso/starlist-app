import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../src/providers/theme_provider_enhanced.dart';
import '../../../src/services/app_usage_parser.dart';

class AppUsageImportScreen extends ConsumerStatefulWidget {
  const AppUsageImportScreen({super.key});

  @override
  ConsumerState<AppUsageImportScreen> createState() => _AppUsageImportScreenState();
}

class _AppUsageImportScreenState extends ConsumerState<AppUsageImportScreen>
    with TickerProviderStateMixin {
  String selectedImportType = 'screen_time'; // screen_time, app_store, social_media, games
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isProcessing = false;
  List<Map<String, dynamic>> processedApps = [];
  List<AppUsageItem> extractedApps = [];
  bool showPreview = false;
  List<bool> selectedApps = [];
  File? selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool showConfirmation = false;

  // アプリ使用履歴取り込みタイプ
  final List<Map<String, dynamic>> importTypes = [
    {
      'id': 'screen_time',
      'title': 'スクリーンタイム',
      'subtitle': 'iOS/Androidスクリーンタイム',
      'icon': Icons.phone_android,
      'color': const Color(0xFF2196F3), // Blue
      'description': 'iPhone・Androidのスクリーンタイム機能で記録されたアプリ使用時間を記録します',
    },
    {
      'id': 'app_store',
      'title': 'アプリストア',
      'subtitle': 'ダウンロード・購入履歴',
      'icon': Icons.apps,
      'color': const Color(0xFF4CAF50), // Green
      'description': 'App Store・Google Playでのアプリダウンロード・購入履歴を記録します',
    },
    {
      'id': 'social_media',
      'title': 'SNS・メッセージ',
      'subtitle': 'SNSアプリの使用状況',
      'icon': Icons.chat,
      'color': const Color(0xFF9C27B0), // Purple
      'description': 'Twitter、Instagram、LINEなどのSNSアプリの使用時間や投稿数を記録します',
    },
    {
      'id': 'games',
      'title': 'ゲーム',
      'subtitle': 'ゲームアプリのプレイ時間',
      'icon': Icons.games,
      'color': const Color(0xFFFF9800), // Orange
      'description': 'スマホゲームのプレイ時間、課金履歴、達成度などを記録します',
    },
    {
      'id': 'productivity',
      'title': '仕事・勉強',
      'subtitle': '生産性アプリの使用履歴',
      'icon': Icons.work,
      'color': const Color(0xFF607D8B), // Blue grey
      'description': 'Slack、Notion、勉強アプリなどの使用時間や作業記録を残します',
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
          'アプリ使用履歴取り込み',
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
          colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
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
                  Icons.phone_android,
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
                      'アプリ使用履歴取り込み',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'スマホ・アプリの使用状況を記録',
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
          '記録タイプを選択',
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
              _buildInputMethodTab('スクショ撮影', Icons.camera_alt, isDark, false),
              const SizedBox(width: 12),
              _buildInputMethodTab('画像選択', Icons.photo_library, isDark, false),
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
                  'スクショ撮影',
                  Icons.camera_alt,
                  () => _takePhoto(),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  '画像を選択',
                  Icons.photo_library,
                  () => _selectImage(),
                  isDark,
                ),
              ),
            ],
          ),
          
          if (selectedImage != null) ...[
            const SizedBox(height: 16),
            _buildImagePreview(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildInputMethodTab(String title, IconData icon, bool isDark, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive 
          ? const Color(0xFF2196F3)
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
      case 'screen_time':
        return '例：\nアプリ名: Instagram\n使用時間: 2時間 30分\n日付: 2024/01/15\n起動回数: 15回\n最長使用時間: 45分\n\nまたはスクリーンタイム画面を撮影してOCRで読み取ります';
      case 'app_store':
        return '例：\nアプリ名: Spotify\nダウンロード日: 2024/01/15\nカテゴリ: ミュージック\n価格: 無料（アプリ内購入あり）\n評価: 4.8\n\nまたはApp Storeの購入履歴を撮影してOCRで読み取ります';
      case 'social_media':
        return '例：\nアプリ名: Twitter\n使用時間: 1時間 15分\n投稿数: 3件\nいいね数: 12件\n日付: 2024/01/15\n\nまたはSNSアプリの使用統計を撮影してOCRで読み取ります';
      case 'games':
        return '例：\nゲーム名: パズドラ\nプレイ時間: 45分\nレベル: 285\n課金額: ¥500\n日付: 2024/01/15\n\nまたはゲームの統計画面を撮影してOCRで読み取ります';
      case 'productivity':
        return '例：\nアプリ名: Notion\n使用時間: 3時間 20分\nページ作成数: 5件\nタスク完了数: 8件\n日付: 2024/01/15\n\nまたは生産性アプリの統計を撮影してOCRで読み取ります';
      default:
        return 'アプリの使用履歴に関するデータを入力してください';
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

  Widget _buildImagePreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              selectedImage!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'スクリーンショットが選択されました',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'OCR解析の準備完了',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedImage = null;
              });
            },
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white60 : Colors.black54,
              size: 20,
            ),
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
        border: Border.all(
          color: const Color(0xFF2196F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2196F3),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '記録完了',
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
            '${processedApps.length}件のアプリ使用データが正常に記録されました。',
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
                      _textController.clear();
                      processedApps.clear();
                      selectedImage = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('続けて記録'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3)),
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
          ),
          const SizedBox(height: 16),
          Text(
            selectedImage != null ? 'スクリーンショットをOCR解析中...' : 'データを処理中...',
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
    final hasData = _textController.text.trim().isNotEmpty || selectedImage != null;
    
    return FloatingActionButton.extended(
      onPressed: hasData && !isProcessing ? _processData : null,
      backgroundColor: hasData && !isProcessing
          ? const Color(0xFF2196F3)
          : (isDark ? const Color(0xFF404040) : Colors.grey[300]),
      foregroundColor: hasData && !isProcessing
          ? Colors.white
          : (isDark ? Colors.white38 : Colors.black38),
      label: const Text('データを記録'),
      icon: isProcessing 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.save),
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
    if (_textController.text.trim().isEmpty && selectedImage == null) return;

    setState(() {
      isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // アプリ使用履歴データを解析
      final parsedApps = AppUsageParser.parseUsageText(_textController.text);
      
      setState(() {
        extractedApps = parsedApps;
        selectedApps = List.filled(parsedApps.length, true); // デフォルトで全選択
        isProcessing = false;
        showPreview = parsedApps.isNotEmpty;
      });

      if (parsedApps.isEmpty) {
        _showErrorSnackBar('アプリ使用データを検出できませんでした。\nフォーマットを確認してください。');
      } else {
        debugPrint('検出されたアプリ数: ${parsedApps.length} ($selectedImportType)');
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      _showErrorSnackBar('データ解析中にエラーが発生しました: $e');
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
    final selectedUsageApps = extractedApps
        .asMap()
        .entries
        .where((entry) => selectedApps[entry.key])
        .map((entry) => entry.value.toMap())
        .toList();

    setState(() {
      processedApps = selectedUsageApps;
      showPreview = false;
      showConfirmation = true;
    });
  }
}