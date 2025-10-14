import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import '../models/content_model.dart';
import '../../../core/components/loading/loading_indicator.dart';
import '../repositories/content_repository.dart';
import '../../../app.dart';  // contentRepositoryProviderをインポート

// プロバイダーの定義
final contentStateProvider = StateProvider<ContentUIState>((ref) => ContentUIState.initial());

// UI状態を表すクラス
class ContentUIState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ContentUIState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  factory ContentUIState.initial() => ContentUIState();
  
  ContentUIState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ContentUIState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// コンテンツ操作のプロバイダー
final contentActionsProvider = Provider<ContentActions>((ref) {
  final repository = ref.watch(contentRepositoryProvider);
  final state = ref.watch(contentStateProvider.notifier);
  return ContentActions(repository, state);
});

// コンテンツ操作クラス
class ContentActions {
  final ContentRepository _repository;
  final StateController<ContentUIState> _state;

  ContentActions(this._repository, this._state);

  Future<void> createContent(ContentModel content) async {
    _state.state = _state.state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    
    try {
      final result = await _repository.createContent(content);
      if (result != null) {
        _state.state = _state.state.copyWith(isLoading: false, isSuccess: true);
      } else {
        _state.state = _state.state.copyWith(
          isLoading: false, 
          errorMessage: 'コンテンツの作成に失敗しました',
        );
      }
    } catch (e) {
      _state.state = _state.state.copyWith(
        isLoading: false, 
        errorMessage: '予期せぬエラーが発生しました: $e',
      );
    }
  }

  Future<void> updateContent(ContentModel content) async {
    _state.state = _state.state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    
    try {
      final result = await _repository.updateContent(content);
      if (result) {
        _state.state = _state.state.copyWith(isLoading: false, isSuccess: true);
      } else {
        _state.state = _state.state.copyWith(
          isLoading: false, 
          errorMessage: 'コンテンツの更新に失敗しました',
        );
      }
    } catch (e) {
      _state.state = _state.state.copyWith(
        isLoading: false, 
        errorMessage: '予期せぬエラーが発生しました: $e',
      );
    }
  }
}

class ContentCreateScreen extends ConsumerStatefulWidget {
  final ContentModel? initialContent;
  final bool isEditing;

  const ContentCreateScreen({
    super.key,
    this.initialContent,
    this.isEditing = false,
  });

  @override
  ConsumerState<ContentCreateScreen> createState() => _ContentCreateScreenState();
}

class _ContentCreateScreenState extends ConsumerState<ContentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  ContentTypeModel _selectedType = ContentTypeModel.text;
  bool _isPublished = true;
  final Map<String, dynamic> _metadata = {};
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.initialContent != null) {
      _titleController = TextEditingController(text: widget.initialContent!.title);
      _descriptionController = TextEditingController(text: widget.initialContent!.description);
      _urlController = TextEditingController(text: widget.initialContent!.url);
      _selectedType = widget.initialContent!.type;
      _isPublished = widget.initialContent!.isPublished;
      _metadata.addAll(widget.initialContent!.metadata);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _urlController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UIの状態を監視
    final contentState = ref.watch(contentStateProvider);
    
    // 状態変更時の処理
    ref.listen(contentStateProvider, (previous, current) {
      if (current.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(current.errorMessage!)),
        );
      } else if (current.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'コンテンツを更新しました' : 'コンテンツを作成しました'),
          ),
        );
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'コンテンツを編集' : 'コンテンツを作成'),
        actions: [
          if (!contentState.isLoading)
            TextButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('保存'),
              onPressed: _saveContent,
            ),
        ],
      ),
      body: contentState.isLoading
          ? const Center(child: LoadingIndicator(size: 32.0))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'タイトル *',
                        hintText: 'コンテンツのタイトルを入力してください',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'タイトルは必須です';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // コンテンツタイプ
                    DropdownButtonFormField<ContentTypeModel>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'コンテンツタイプ *',
                        border: OutlineInputBorder(),
                      ),
                      items: ContentTypeModel.values.map((type) {
                        String label;
                        IconData icon;

                        switch (type) {
                          case ContentTypeModel.video:
                            label = '動画';
                            icon = Icons.movie;
                            break;
                          case ContentTypeModel.image:
                            label = '画像';
                            icon = Icons.image;
                            break;
                          case ContentTypeModel.text:
                            label = 'テキスト';
                            icon = Icons.article;
                            break;
                          case ContentTypeModel.link:
                            label = 'リンク';
                            icon = Icons.link;
                            break;
                        }

                        return DropdownMenuItem<ContentTypeModel>(
                          value: type,
                          child: Row(
                            children: [
                              Icon(icon),
                              const SizedBox(width: 8),
                              Text(label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 説明
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '説明',
                        hintText: 'コンテンツの説明を入力してください',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // URL（リンクと動画の場合）
                    if (_selectedType == ContentTypeModel.link ||
                        _selectedType == ContentTypeModel.video)
                      Column(
                        children: [
                          TextFormField(
                            controller: _urlController,
                            decoration: InputDecoration(
                              labelText: _selectedType == ContentTypeModel.link
                                  ? 'リンクURL *'
                                  : '動画URL *',
                              hintText: _selectedType == ContentTypeModel.link
                                  ? 'https://example.com'
                                  : 'https://youtube.com/watch?v=...',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'URLは必須です';
                              }
                              if (!Uri.parse(value).isAbsolute) {
                                return '有効なURLを入力してください';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // 画像（画像タイプの場合）
                    if (_selectedType == ContentTypeModel.image)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.photo_library),
                                label: const Text('画像を選択'),
                                onPressed: _pickImage,
                              ),
                              const SizedBox(width: 16),
                              if (_selectedImagePath != null ||
                                  (_selectedType == ContentTypeModel.image &&
                                      _urlController.text.isNotEmpty))
                                const Text('画像が選択されています'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_selectedImagePath != null)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text('プレビュー準備中'),
                              ),
                            )
                          else if (_selectedType == ContentTypeModel.image &&
                              _urlController.text.isNotEmpty)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.network(
                                _urlController.text,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // 公開設定
                    SwitchListTile(
                      title: const Text('公開する'),
                      subtitle: const Text('ONにするとすぐに公開されます'),
                      value: _isPublished,
                      onChanged: (value) {
                        setState(() {
                          _isPublished = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 24),

                    // メタデータ（オプション）
                    ExpansionTile(
                      title: const Text('メタデータ (オプション)'),
                      children: [
                        ..._buildMetadataFields(),
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text('メタデータを追加'),
                          onTap: _addMetadataField,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 送信ボタン
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveContent,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.isEditing ? 'コンテンツを更新' : 'コンテンツを作成',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildMetadataFields() {
    return _metadata.entries.map((entry) {
      final keyController = TextEditingController(text: entry.key);
      final valueController = TextEditingController(text: entry.value.toString());

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'キー',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final oldValue = _metadata[entry.key];
                    _metadata.remove(entry.key);
                    _metadata[value] = oldValue;
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: '値',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _metadata[entry.key] = value;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _metadata.remove(entry.key);
                });
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  void _addMetadataField() {
    setState(() {
      // ユニークなキー名を生成
      final key = 'key_${_metadata.length}';
      _metadata[key] = '';
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          // TODO: 実際のアプリでは、画像をアップロードしてURLを取得する必要があります
          _urlController.text = 'https://example.com/images/${const Uuid().v4()}.jpg';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像の選択に失敗しました: $e')),
      );
    }
  }

  void _saveContent() {
    if (_formKey.currentState?.validate() ?? false) {
      // 現在のユーザーIDを取得（実際のアプリでは認証サービスから取得する）
      const String currentUserId = 'current_user_id'; // TODO: 実際のユーザーIDを使用する
      
      // 現在のタイムスタンプ
      final now = DateTime.now();
      
      // 新しいコンテンツを作成または更新
      final ContentModel content;
      
      if (widget.isEditing && widget.initialContent != null) {
        // 既存のコンテンツを更新
        content = ContentModel(
          id: widget.initialContent!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          type: _selectedType,
          url: _urlController.text,
          authorId: widget.initialContent!.authorId,
          authorName: widget.initialContent!.authorName,
          createdAt: widget.initialContent!.createdAt,
          updatedAt: now,
          metadata: _metadata,
          isPublished: _isPublished,
          likes: widget.initialContent!.likes,
          comments: widget.initialContent!.comments,
          shares: widget.initialContent!.shares,
        );
      } else {
        // 新しいコンテンツを作成
        content = ContentModel(
          id: const Uuid().v4(),
          title: _titleController.text,
          description: _descriptionController.text,
          type: _selectedType,
          url: _urlController.text,
          authorId: currentUserId,
          authorName: '現在のユーザー', // TODO: 実際のユーザー名を使用する
          createdAt: now,
          updatedAt: now,
          metadata: _metadata,
          isPublished: _isPublished,
          likes: 0,
          comments: 0,
          shares: 0,
        );
      }
      
      // Riverpodプロバイダーを使用してコンテンツを保存
      if (widget.isEditing) {
        ref.read(contentActionsProvider).updateContent(content);
      } else {
        ref.read(contentActionsProvider).createContent(content);
      }
    }
  }
} 