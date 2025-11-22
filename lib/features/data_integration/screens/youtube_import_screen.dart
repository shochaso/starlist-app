import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:starlist_app/providers/user_provider.dart';
import '../../data_integration/workflows/youtube_import_workflow.dart';
import '../widgets/youtube_extracted_result_card.dart';
import '../widgets/youtube_image_upload_card.dart';
import '../widgets/youtube_ocr_result_card.dart';

class YouTubeImportScreen extends ConsumerStatefulWidget {
  const YouTubeImportScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  ConsumerState<YouTubeImportScreen> createState() =>
      _YouTubeImportScreenState();
}

class _YouTubeImportScreenState extends ConsumerState<YouTubeImportScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _imageError;

  @override
  Widget build(BuildContext context) {
    ref.listen(youtubeImportWorkflowProvider, (previous, next) {
      if (previous?.uploadCompleted == false && next.uploadCompleted) {
        _showSnackBar('選択した動画を保存しました。');
      }
      if (previous?.publishCompleted == false && next.publishCompleted) {
        _showSnackBar('公開設定を更新しました。');
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        _showSnackBar(next.errorMessage!, isError: true);
      }
    });

    final workflow = ref.watch(youtubeImportWorkflowProvider);
    final workflowNotifier = ref.read(youtubeImportWorkflowProvider.notifier);

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YoutubeImageUploadCard(
            onPickImage: _pickImage,
            onClearImage: _clearImage,
            isProcessing: workflow.isOcrRunning,
            imageBytes: _selectedImageBytes,
            fileName: _selectedImage?.name,
            errorMessage: _imageError,
          ),
          const SizedBox(height: 8),
          YoutubeOcrResultCard(
            rawText: workflow.rawText,
            onTextChanged: workflowNotifier.updateRawText,
            onRunOcr: () {
              if (_selectedImageBytes == null) return;
              workflowNotifier.runOcr(
                imageBytes: _selectedImageBytes!,
                mimeType: _selectedImage?.mimeType ?? 'image/jpeg',
              );
            },
            isRunning: workflow.isOcrRunning,
            isImageSelected: _selectedImageBytes != null,
          ),
          const SizedBox(height: 8),
          YoutubeExtractedResultCard(
            items: workflow.items,
            isLinkEnriching: workflow.isLinkEnriching,
            isUploading: workflow.isUploading,
            isPublishing: workflow.isPublishing,
            uploadCompleted: workflow.uploadCompleted,
            publishCompleted: workflow.publishCompleted,
            enrichProgress: workflow.enrichProgress,
            enrichTotal: workflow.enrichTotal,
            onToggleSelected: workflowNotifier.toggleSelect,
            onTogglePublic: workflowNotifier.togglePublic,
            onRemove: workflowNotifier.removeItem,
            onUpload: () async {
              final user = ref.read(currentUserProvider);
              if (user.id.isEmpty) {
                _showSnackBar('保存にはログインが必要です', isError: true);
                return;
              }
              await workflowNotifier.saveSelected();
            },
            onPublish: () async {
              final user = ref.read(currentUserProvider);
              if (user.id.isEmpty) {
                _showSnackBar('公開にはログインが必要です', isError: true);
                return;
              }
              await workflowNotifier.publishSelected();
            },
            onViewList: () => _openMyList(context),
            onSelectAll: () => workflowNotifier.selectAll(true),
            onClearSelection: () => workflowNotifier.selectAll(false),
          ),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube データ取り込み'),
      ),
      body: content,
    );
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 2048,
        maxWidth: 2048,
        imageQuality: 90,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
        _imageError = null;
      });
    } catch (error) {
      setState(() => _imageError = '画像の選択に失敗しました: $error');
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
    });
  }

  void _openMyList(BuildContext context) {
    if (!mounted) return;
    context.go('/mypage');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final context = this.context;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}
