import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // テキストコントローラー
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  
  // プロフィール画像
  String? _selectedAvatarPath;
  String? _selectedCoverPath;
  
  // カテゴリ・タグ設定
  List<String> _selectedCategories = [];
  List<String> _selectedTags = [];
  final TextEditingController _tagController = TextEditingController();
  
  // プライバシー設定
  bool _isProfilePublic = true;
  bool _allowDirectMessages = true;
  bool _showOnlineStatus = true;
  bool _allowNotifications = true;
  
  // カテゴリオプション
  final List<String> _availableCategories = [
    'テクノロジー・ガジェット',
    '料理・グルメ',
    'ゲーム・エンタメ',
    'ファッション・美容',
    'ビジネス・投資',
    '旅行・写真',
    'アニメ・マンガ',
    'フィットネス・健康',
    'プログラミング・IT',
    'DIY・ハンドメイド',
    '音楽・楽器',
    'ペット・動物',
    '教育・学習',
    'アート・デザイン',
    'スポーツ',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // 現在のユーザー情報を取得して初期化
    _nameController = TextEditingController(text: 'スターユーザー'); // 実際のユーザー情報から取得
    _bioController = TextEditingController(text: 'よろしくお願いします！');
    _emailController = TextEditingController(text: 'star@example.com');
    _phoneController = TextEditingController(text: '');
    _websiteController = TextEditingController(text: '');
    _locationController = TextEditingController(text: '東京都');
    
    _selectedCategories = ['テクノロジー・ガジェット'];
    _selectedTags = ['Flutter', 'プログラミング', 'レビュー'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'プロフィール編集',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _saveProfile(),
            child: const Text(
              '保存',
              style: TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // プロフィール画像セクション
                _buildImageSection(),
                
                const SizedBox(height: 32),
                
                // 基本情報セクション
                _buildSection(
                  '基本情報',
                  [
                    _buildTextFormField(
                      controller: _nameController,
                      label: '表示名',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '表示名を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _bioController,
                      label: '自己紹介',
                      icon: Icons.description,
                      maxLines: 4,
                      maxLength: 200,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _locationController,
                      label: '所在地',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _websiteController,
                      label: 'ウェブサイト',
                      icon: Icons.language,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 連絡先情報セクション
                _buildSection(
                  '連絡先情報',
                  [
                    _buildTextFormField(
                      controller: _emailController,
                      label: 'メールアドレス',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) {
                            return '有効なメールアドレスを入力してください';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _phoneController,
                      label: '電話番号',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // カテゴリ選択セクション
                _buildCategorySection(),
                
                const SizedBox(height: 24),
                
                // タグ設定セクション
                _buildTagSection(),
                
                const SizedBox(height: 24),
                
                // プライバシー設定セクション
                _buildPrivacySection(),
                
                const SizedBox(height: 32),
                
                // 危険な操作セクション
                _buildDangerZone(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildImageSection() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'プロフィール画像',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // アバター画像
              GestureDetector(
                onTap: () => _selectAvatar(),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _selectedAvatarPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            _selectedAvatarPath!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'プロフィール写真',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '推奨サイズ: 400x400px',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF888888) : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _selectAvatar(),
                      icon: const Icon(Icons.upload, size: 16),
                      label: const Text('変更'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
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

  Widget _buildSection(String title, List<Widget> children) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4ECDC4)),
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.black54,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF333333) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'カテゴリ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '最大3つまで選択できます',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF888888) : Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableCategories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return GestureDetector(
                onTap: () => _toggleCategory(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4ECDC4) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4ECDC4) : (isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSection() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'タグ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'あなたに関連するキーワードを追加',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF888888) : Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'タグを入力',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.black38,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF444444) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4ECDC4)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (value) => _addTag(value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addTag(_tagController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('追加'),
                  ),
                ],
              ),
              if (_selectedTags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withOpacity( 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4ECDC4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeTag(tag),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      'プライバシー設定',
      [
        _buildSwitchItem(
          'プロフィール公開',
          'プロフィールを他のユーザーに公開する',
          _isProfilePublic,
          (value) => setState(() => _isProfilePublic = value),
        ),
        const SizedBox(height: 16),
        _buildSwitchItem(
          'ダイレクトメッセージ',
          'フォロワーからのメッセージを受け取る',
          _allowDirectMessages,
          (value) => setState(() => _allowDirectMessages = value),
        ),
        const SizedBox(height: 16),
        _buildSwitchItem(
          'オンライン状態表示',
          'オンライン状態を他のユーザーに表示する',
          _showOnlineStatus,
          (value) => setState(() => _showOnlineStatus = value),
        ),
        const SizedBox(height: 16),
        _buildSwitchItem(
          '通知を許可',
          'フォローやいいねの通知を受け取る',
          _allowNotifications,
          (value) => setState(() => _allowNotifications = value),
        ),
      ],
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, bool value, Function(bool) onChanged) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF888888) : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4ECDC4),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity( 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Color(0xFFFF6B6B), size: 20),
              SizedBox(width: 8),
              Text(
                '危険な操作',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showDeleteAccountDialog(),
            icon: const Icon(Icons.delete_forever, color: Color(0xFFFF6B6B)),
            label: const Text(
              'アカウントを削除',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF6B6B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else if (_selectedCategories.length < 3) {
        _selectedCategories.add(category);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('カテゴリは最大3つまで選択できます'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
    });
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_selectedTags.contains(tag) && _selectedTags.length < 10) {
      setState(() {
        _selectedTags.add(tag);
        _tagController.clear();
      });
    } else if (_selectedTags.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('タグは最大10個まで追加できます'),
          backgroundColor: Color(0xFFFF6B6B),
        ),
      );
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _selectAvatar() {
    // 画像選択の実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('画像選択機能は実装予定です'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final themeMode = ref.read(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        title: const Text(
          'アカウント削除',
          style: TextStyle(color: Color(0xFFFF6B6B)),
        ),
        content: Text(
          'アカウントを削除すると、すべてのデータが永久に失われます。\nこの操作は元に戻せません。\n\n本当に削除しますか？',
          style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('アカウント削除処理を開始しました'),
                  backgroundColor: Color(0xFFFF6B6B),
                ),
              );
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // プロフィール保存処理
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('プロフィールを保存しました'),
          backgroundColor: Color(0xFF4ECDC4),
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildBottomNavigationBar() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity( 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomNavItem(Icons.home, 'ホーム', () {
                Navigator.popUntil(context, (route) => route.isFirst);
              }),
              _buildBottomNavItem(Icons.search, '検索', () {
                Navigator.popUntil(context, (route) => route.isFirst);
              }),
              _buildBottomNavItem(Icons.notifications, '通知', () {
                Navigator.popUntil(context, (route) => route.isFirst);
              }),
              _buildBottomNavItem(Icons.star, 'マイリスト', () {
                Navigator.popUntil(context, (route) => route.isFirst);
              }),
              _buildBottomNavItem(Icons.person, 'マイページ', null, isSelected: true),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomNavItem(IconData icon, String label, VoidCallback? onTap, {bool isSelected = false}) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected 
                    ? const Color(0xFF4ECDC4) 
                    : (isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? const Color(0xFF4ECDC4) 
                      : (isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}