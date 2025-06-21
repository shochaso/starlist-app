import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/content_consumption_model.dart';
import '../providers/content_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/supabase_provider.dart';

class ContentEditScreen extends ConsumerStatefulWidget {
  final ContentConsumption? content;
  final ContentCategory? initialCategory;

  const ContentEditScreen({
    Key? key,
    this.content,
    this.initialCategory,
  }) : super(key: key);

  @override
  _ContentEditScreenState createState() => _ContentEditScreenState();
}

class _ContentEditScreenState extends ConsumerState<ContentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late ContentCategory _selectedCategory;
  late PrivacyLevel _selectedPrivacyLevel;
  
  final List<File> _images = [];
  final List<String> _existingImageUrls = [];
  final List<String> _tags = [];
  
  // タグ入力用
  final TextEditingController _tagController = TextEditingController();
  
  // 購入関連の入力
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _storeController = TextEditingController();
  DateTime? _purchaseDate;
  
  // 位置情報関連
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    
    _isEditMode = widget.content != null;
    _titleController = TextEditingController(text: widget.content?.title ?? '');
    _descriptionController = TextEditingController(text: widget.content?.description ?? '');
    
    _selectedCategory = widget.content?.category ?? 
                        widget.initialCategory ?? 
                        ContentCategory.youtube;
    
    _selectedPrivacyLevel = widget.content?.privacyLevel ?? PrivacyLevel.public;
    
    // 既存の画像URLを設定
    if (widget.content?.imageUrls != null) {
      _existingImageUrls.addAll(widget.content!.imageUrls!);
    }
    
    // タグを設定
    if (widget.content?.tags != null) {
      _tags.addAll(widget.content!.tags!);
    }
    
    // 購入関連情報の設定
    if (widget.content?.price != null) {
      _priceController.text = widget.content!.price.toString();
    }
    
    if (widget.content?.contentData['store'] != null) {
      _storeController.text = widget.content!.contentData['store'];
    }
    
    _purchaseDate = widget.content?.purchaseDate;
    
    // 位置情報の設定
    if (widget.content?.location != null) {
      final location = widget.content!.location!;
      _placeNameController.text = location.placeName ?? '';
      _addressController.text = location.address ?? '';
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _storeController.dispose();
    _placeNameController.dispose();
    _addressController.dispose();
    _tagController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var image in pickedFiles) {
          _images.add(File(image.path));
        }
      });
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }
  
  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }
  
  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }
  
  Map<String, dynamic> _buildContentData() {
    final data = <String, dynamic>{};
    
    switch (_selectedCategory) {
      case ContentCategory.purchase:
        data['store'] = _storeController.text;
        break;
      case ContentCategory.food:
        // 食べ物関連のデータ
        break;
      case ContentCategory.location:
        // 位置情報関連のデータは別途処理
        break;
      case ContentCategory.youtube:
        // YouTube関連のデータは既に設定されている前提
        if (widget.content?.contentData['video_id'] != null) {
          data['video_id'] = widget.content!.contentData['video_id'];
        }
        if (widget.content?.contentData['thumbnail_url'] != null) {
          data['thumbnail_url'] = widget.content!.contentData['thumbnail_url'];
        }
        break;
      case ContentCategory.music:
        // 音楽関連のデータ
        break;
      case ContentCategory.book:
        // 書籍関連のデータ
        break;
      default:
        break;
    }
    
    return data;
  }
  
  Future<void> _saveContent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final userAsync = ref.read(currentUserProvider);
      final userId = userAsync?.id;
      
      if (userId == null) {
        throw Exception('ログインが必要です');
      }
      
      final contentData = _buildContentData();
      
      // TODO: 画像アップロード機能を実装
      // アップロードした画像のURL配列
      List<String> uploadedImageUrls = [];
      //for (final image in _images) {
      //  final url = await uploadContentImage(image, userId);
      //  uploadedImageUrls.add(url);
      //}
      
      final allImageUrls = [..._existingImageUrls, ...uploadedImageUrls];
      
      // 位置情報の設定
      GeoLocation? location;
      if (_selectedCategory == ContentCategory.food || 
          _selectedCategory == ContentCategory.location) {
        if (_placeNameController.text.isNotEmpty || _addressController.text.isNotEmpty) {
          location = GeoLocation(
            latitude: 0.0, // TODO: 実際の位置情報を取得
            longitude: 0.0,
            placeName: _placeNameController.text.isEmpty ? null : _placeNameController.text,
            address: _addressController.text.isEmpty ? null : _addressController.text,
          );
        }
      }
      
      // 金額の解析
      int? price;
      if (_priceController.text.isNotEmpty) {
        price = int.tryParse(_priceController.text);
      }
      
      if (_isEditMode && widget.content != null) {
        // 既存コンテンツの更新
        final updatedContent = widget.content!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          category: _selectedCategory,
          contentData: contentData,
          privacyLevel: _selectedPrivacyLevel,
          imageUrls: allImageUrls.isEmpty ? null : allImageUrls,
          tags: _tags.isEmpty ? null : _tags,
          location: location,
          price: price,
          purchaseDate: _purchaseDate,
          updatedAt: DateTime.now(),
        );
        
        final contentProviderNotifier = ref.read(contentProvider(userId).notifier);
        await contentProviderNotifier.updateContent(updatedContent);
      } else {
        // 新規コンテンツの作成
        final newContent = ContentConsumption(
          id: '', // リポジトリでIDが生成される
          userId: userId,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          category: _selectedCategory,
          contentData: contentData,
          privacyLevel: _selectedPrivacyLevel,
          imageUrls: allImageUrls.isEmpty ? null : allImageUrls,
          tags: _tags.isEmpty ? null : _tags,
          location: location,
          price: price,
          purchaseDate: _purchaseDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final contentProviderNotifier = ref.read(contentProvider(userId).notifier);
        await contentProviderNotifier.createContent(newContent);
      }
      
      if (mounted) {
        // 成功メッセージを表示し、前の画面に戻る
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'コンテンツを更新しました' : 'コンテンツを作成しました'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'コンテンツの保存に失敗しました: ${e.toString()}';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'コンテンツを編集' : '新規コンテンツ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveContent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              
              // カテゴリー選択
              DropdownButtonFormField<ContentCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'カテゴリ',
                  border: OutlineInputBorder(),
                ),
                items: ContentCategory.values.map((category) {
                  return DropdownMenuItem<ContentCategory>(
                    value: category,
                    child: Text(_getCategoryLabel(category)),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // タイトル入力
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              
              // 説明入力
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              
              // プライバシー設定
              DropdownButtonFormField<PrivacyLevel>(
                value: _selectedPrivacyLevel,
                decoration: const InputDecoration(
                  labelText: 'プライバシー設定',
                  border: OutlineInputBorder(),
                ),
                items: PrivacyLevel.values.map((level) {
                  return DropdownMenuItem<PrivacyLevel>(
                    value: level,
                    child: Text(_getPrivacyLevelLabel(level)),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPrivacyLevel = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // カテゴリ別の入力項目
              _buildCategorySpecificFields(),
              
              // 画像追加
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('画像', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  // 既存の画像表示
                  if (_existingImageUrls.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _existingImageUrls.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(_existingImageUrls[index]),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _removeExistingImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  
                  // 新しく選択した画像の表示
                  if (_images.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(_images[index]),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // 画像追加ボタン
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('画像を追加'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // タグ入力
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('タグ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  // タグチップの表示
                  Wrap(
                    spacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeTag(tag),
                      );
                    }).toList(),
                  ),
                  
                  // タグ追加フィールド
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: '新しいタグを追加',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_isLoading,
                          onFieldSubmitted: (value) {
                            _addTag(value.trim());
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _isLoading ? null : () {
                          _addTag(_tagController.text.trim());
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 保存ボタン
              ElevatedButton(
                onPressed: _isLoading ? null : _saveContent,
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
                    : Text(_isEditMode ? 'コンテンツを更新' : 'コンテンツを作成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // カテゴリに応じた入力フィールドを表示
  Widget _buildCategorySpecificFields() {
    switch (_selectedCategory) {
      case ContentCategory.purchase:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('購入情報', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // 金額入力
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '金額',
                prefixText: '¥',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            
            // ストア入力
            TextFormField(
              controller: _storeController,
              decoration: const InputDecoration(
                labelText: 'ショップ/ストア',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            
            // 購入日選択
            InkWell(
              onTap: _isLoading ? null : _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '購入日',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _purchaseDate != null
                      ? '${_purchaseDate!.year}/${_purchaseDate!.month}/${_purchaseDate!.day}'
                      : '日付を選択',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      
      case ContentCategory.food:
      case ContentCategory.location:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('場所情報', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // 場所名入力
            TextFormField(
              controller: _placeNameController,
              decoration: const InputDecoration(
                labelText: '場所の名前',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            
            // 住所入力
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '住所',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            
            // TODO: 地図や位置情報の選択機能を追加
          ],
        );
      
      default:
        return const SizedBox.shrink();
    }
  }
  
  String _getCategoryLabel(ContentCategory category) {
    switch (category) {
      case ContentCategory.youtube:
        return 'YouTube';
      case ContentCategory.book:
        return '本';
      case ContentCategory.purchase:
        return '購入';
      case ContentCategory.food:
        return '食事';
      case ContentCategory.location:
        return '場所';
      case ContentCategory.music:
        return '音楽';
      case ContentCategory.other:
        return 'その他';
    }
  }
  
  String _getPrivacyLevelLabel(PrivacyLevel level) {
    switch (level) {
      case PrivacyLevel.public:
        return '公開';
      case PrivacyLevel.followers:
        return 'フォロワーのみ';
      case PrivacyLevel.private:
        return '非公開';
      case PrivacyLevel.premium:
        return 'プレミアム会員のみ';
    }
  }
} 