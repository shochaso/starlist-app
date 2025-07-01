import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// 画像選択ウィジェット
class ImagePickerWidget extends StatefulWidget {
  final Function(File) onImageSelected;
  final Function(List<File>)? onMultipleImagesSelected;
  final String? currentImageUrl;
  final bool allowMultiple;
  final bool allowCamera;
  final double size;
  final IconData placeholderIcon;
  final String? placeholderText;
  final bool showEditIcon;
  final Color? borderColor;
  final bool isCircular;

  const ImagePickerWidget({
    Key? key,
    required this.onImageSelected,
    this.onMultipleImagesSelected,
    this.currentImageUrl,
    this.allowMultiple = false,
    this.allowCamera = true,
    this.size = 120,
    this.placeholderIcon = Icons.person,
    this.placeholderText,
    this.showEditIcon = true,
    this.borderColor,
    this.isCircular = true,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  List<File>? _selectedImages;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircular ? null : BorderRadius.circular(12),
          border: Border.all(
            color: widget.borderColor ?? Theme.of(context).dividerColor,
            width: 2,
          ),
          color: Theme.of(context).cardColor,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 画像表示部分
            _buildImageDisplay(),
            
            // 編集アイコン
            if (widget.showEditIcon)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: widget.size * 0.15,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 画像表示ウィジェット
  Widget _buildImageDisplay() {
    Widget imageWidget;

    if (_selectedImage != null) {
      // ローカル画像
      imageWidget = ClipOval(
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty) {
      // ネットワーク画像
      imageWidget = ClipOval(
        child: Image.network(
          widget.currentImageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    } else {
      // プレースホルダー
      imageWidget = _buildPlaceholder();
    }

    return widget.isCircular
        ? imageWidget
        : ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageWidget,
          );
  }

  /// プレースホルダーウィジェット
  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: widget.isCircular ? null : BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.placeholderIcon,
            size: widget.size * 0.4,
            color: Theme.of(context).hintColor,
          ),
          if (widget.placeholderText != null) ...[ 
            const SizedBox(height: 8),
            Text(
              widget.placeholderText!,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: widget.size * 0.08,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 画像ソース選択ダイアログ
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ハンドル
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // タイトル
              Text(
                widget.allowMultiple ? '画像を選択' : '画像を選択',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              
              // カメラオプション（許可されている場合）
              if (widget.allowCamera)
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  title: 'カメラで撮影',
                  subtitle: '新しい写真を撮影します',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
              
              // ギャラリーオプション
              _buildSourceOption(
                icon: Icons.photo_library,
                title: widget.allowMultiple ? 'ギャラリーから選択' : 'ギャラリーから選択',
                subtitle: widget.allowMultiple 
                    ? '複数の画像を選択できます'
                    : '既存の写真を選択します',
                onTap: () {
                  Navigator.pop(context);
                  widget.allowMultiple ? _pickMultipleImages() : _pickImageFromGallery();
                },
              ),
              
              // 削除オプション（既存画像がある場合）
              if (_selectedImage != null || (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty))
                _buildSourceOption(
                  icon: Icons.delete,
                  title: '画像を削除',
                  subtitle: '現在の画像を削除します',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// ソースオプションウィジェット
  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  /// カメラから画像を選択
  Future<void> _pickImageFromCamera() async {
    try {
      // カメラ権限をチェック
      final permission = await Permission.camera.status;
      if (permission.isDenied) {
        final result = await Permission.camera.request();
        if (result.isDenied || result.isPermanentlyDenied) {
          _showPermissionDialog('カメラ');
          return;
        }
      }

      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
        });
        widget.onImageSelected(imageFile);
      }
    } catch (e) {
      _showErrorDialog('カメラでの撮影に失敗しました: ${e.toString()}');
    }
  }

  /// ギャラリーから画像を選択
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
        });
        widget.onImageSelected(imageFile);
      }
    } catch (e) {
      _showErrorDialog('ギャラリーからの選択に失敗しました: ${e.toString()}');
    }
  }

  /// 複数画像を選択
  Future<void> _pickMultipleImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFiles.isNotEmpty) {
        final imageFiles = pickedFiles.map((file) => File(file.path)).toList();
        setState(() {
          _selectedImages = imageFiles;
        });
        
        if (widget.onMultipleImagesSelected != null) {
          widget.onMultipleImagesSelected!(imageFiles);
        } else if (imageFiles.isNotEmpty) {
          // 複数選択が許可されていない場合は最初の画像のみ使用
          setState(() {
            _selectedImage = imageFiles.first;
          });
          widget.onImageSelected(imageFiles.first);
        }
      }
    } catch (e) {
      _showErrorDialog('画像の選択に失敗しました: ${e.toString()}');
    }
  }

  /// 画像を削除
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedImages = null;
    });
    
    // 空のファイルを渡すことで削除を通知
    // 実際の削除処理は親ウィジェットで行う
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('画像を削除しました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 権限ダイアログ
  void _showPermissionDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('権限が必要です'),
        content: Text('$permissionNameへのアクセス権限が必要です。設定画面で権限を有効にしてください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('設定を開く'),
          ),
        ],
      ),
    );
  }

  /// エラーダイアログ
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}