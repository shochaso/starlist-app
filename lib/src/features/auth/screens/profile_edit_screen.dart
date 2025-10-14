import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../providers/user_provider.dart';
import '../validators/auth_validators.dart';
import '../../../widgets/image_picker_widget.dart';
import '../../../widgets/upload_progress_widget.dart';
import '../../../providers/image_upload_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  void _loadUserData() async {
    final userAsync = ref.read(userProvider);
    
    userAsync.when(
      data: (user) {
        if (user != null) {
          setState(() {
            _displayNameController.text = user.displayName ?? '';
            _usernameController.text = user.username ?? '';
            _bioController.text = user.bio ?? '';
          });
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }
  
  void _onImageSelected(File imageFile) {
    setState(() {
      _profileImage = imageFile;
    });
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final userNotifier = ref.read(userProvider.notifier);
      final userState = ref.read(userProvider);
      
      if (userState.value == null) {
        throw Exception('ユーザープロファイルが見つかりません');
      }
      
      final user = userState.value!;
      
      // プロフィール画像のアップロード
      String? imageUrl;
      if (_profileImage != null) {
        try {
          final profileImageUpload = ref.read(profileImageUploadProvider.notifier);
          imageUrl = await profileImageUpload.uploadProfileImage(
            userId: user.id,
            imageFile: _profileImage!,
            oldImageUrl: user.profileImageUrl,
          );
        } catch (e) {
          throw Exception('画像のアップロードに失敗しました: ${e.toString()}');
        }
      }
      
      // ユーザー名の更新
      if (_usernameController.text != user.username) {
        await userNotifier.updateUsername(user.id, _usernameController.text.trim());
      }
      
      // 表示名の更新
      if (_displayNameController.text != user.displayName) {
        await userNotifier.updateDisplayName(user.id, _displayNameController.text.trim());
      }
      
      // バイオの更新
      if (_bioController.text != user.bio) {
        await userNotifier.updateBio(user.id, _bioController.text.trim());
      }
      
      // 画像URLの更新
      if (imageUrl != null && imageUrl != user.profileImageUrl) {
        await userNotifier.updateProfileImage(user.id, imageUrl);
      }
      
      if (mounted) {
        // 成功メッセージを表示し、前の画面に戻る
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールを更新しました'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'プロフィールの更新に失敗しました: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('ユーザープロファイルが見つかりません'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // アップロード進捗表示
                  const UploadProgressIndicator(),
                  
                  // エラーメッセージ
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  
                  // プロフィール画像
                  Center(
                    child: ImagePickerWidget(
                      onImageSelected: _onImageSelected,
                      currentImageUrl: user.profileImageUrl,
                      size: 120,
                      placeholderIcon: Icons.person,
                      placeholderText: '画像を選択',
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 表示名入力
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: '表示名',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    validator: AuthValidators.validateDisplayName,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  // ユーザー名入力
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'ユーザー名（英数字とアンダースコアのみ）',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: AuthValidators.validateUsername,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  // 自己紹介入力
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: '自己紹介',
                      prefixIcon: Icon(Icons.short_text),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),
                  
                  // 保存ボタン
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text('プロフィールを保存'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }
} 