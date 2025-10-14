import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/image_upload_provider.dart';
import '../services/image_upload_service.dart';

/// アップロード進捗表示ウィジェット
class UploadProgressWidget extends ConsumerWidget {
  final bool showDetails;
  final bool showOnlyActive;

  const UploadProgressWidget({
    super.key,
    this.showDetails = true,
    this.showOnlyActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadProgress = ref.watch(uploadProgressProvider);
    final stats = ref.watch(imageUploadStatsProvider);

    // アクティブなアップロードのみ表示する場合
    final progressToShow = showOnlyActive
        ? Map.fromEntries(uploadProgress.entries.where((entry) => 
            !entry.value.isCompleted && entry.value.error == null))
        : uploadProgress;

    if (progressToShow.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー
          Row(
            children: [
              Icon(
                Icons.cloud_upload,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'アップロード中',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (stats.hasActiveUploads)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                  ),
                ),
            ],
          ),
          
          if (showDetails) ...[ 
            const SizedBox(height: 16),
            
            // 全体の進捗
            if (stats.hasUploads)
              _buildOverallProgress(context, stats),
            
            const SizedBox(height: 12),
            
            // 個別の進捗
            ...progressToShow.entries.map((entry) => 
              _buildIndividualProgress(context, entry.value)
            ),
          ],
        ],
      ),
    );
  }

  /// 全体の進捗表示
  Widget _buildOverallProgress(BuildContext context, ImageUploadStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '全体の進捗',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            Text(
              '${stats.completedUploads}/${stats.totalUploads} 完了',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: stats.overallProgress / 100,
          backgroundColor: Theme.of(context).hintColor.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${stats.overallProgress.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${ImageUploadService.formatFileSize(stats.uploadedBytes)} / ${ImageUploadService.formatFileSize(stats.totalBytes)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 個別の進捗表示
  Widget _buildIndividualProgress(BuildContext context, UploadProgress progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getProgressColor(context, progress).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ファイル名とステータス
          Row(
            children: [
              Icon(
                _getProgressIcon(progress),
                size: 16,
                color: _getProgressColor(context, progress),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  progress.fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _getProgressText(progress),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getProgressColor(context, progress),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // 進捗バーとサイズ情報
          if (progress.error == null) ...[ 
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.percentage / 100,
              backgroundColor: Theme.of(context).hintColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(_getProgressColor(context, progress)),
              minHeight: 4,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ImageUploadService.formatFileSize(progress.bytesUploaded)} / ${ImageUploadService.formatFileSize(progress.totalBytes)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Text(
                  '${progress.percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getProgressColor(context, progress),
                  ),
                ),
              ],
            ),
          ],
          
          // エラーメッセージ
          if (progress.error != null) ...[ 
            const SizedBox(height: 4),
            Text(
              progress.error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// 進捗アイコンを取得
  IconData _getProgressIcon(UploadProgress progress) {
    if (progress.error != null) {
      return Icons.error;
    } else if (progress.isCompleted) {
      return Icons.check_circle;
    } else {
      return Icons.upload;
    }
  }

  /// 進捗色を取得
  Color _getProgressColor(BuildContext context, UploadProgress progress) {
    if (progress.error != null) {
      return Colors.red;
    } else if (progress.isCompleted) {
      return Colors.green;
    } else {
      return Theme.of(context).primaryColor;
    }
  }

  /// 進捗テキストを取得
  String _getProgressText(UploadProgress progress) {
    if (progress.error != null) {
      return 'エラー';
    } else if (progress.isCompleted) {
      return '完了';
    } else {
      return 'アップロード中';
    }
  }
}

/// ミニマルなアップロード進捗インジケーター
class UploadProgressIndicator extends ConsumerWidget {
  const UploadProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(imageUploadStatsProvider);

    if (!stats.hasActiveUploads) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: stats.overallProgress / 100,
              valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'アップロード中 ${stats.overallProgress.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// アップロード完了スナックバー
class UploadCompleteSnackbar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}