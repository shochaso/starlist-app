import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/image_upload_service.dart';
import '../features/auth/supabase_provider.dart';

/// 画像アップロードサービスのプロバイダー
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ImageUploadService(supabaseClient);
});

/// アップロード進捗の状態管理
final uploadProgressProvider = StateNotifierProvider<UploadProgressNotifier, Map<String, UploadProgress>>((ref) {
  return UploadProgressNotifier();
});

/// アップロード進捗の状態管理クラス
class UploadProgressNotifier extends StateNotifier<Map<String, UploadProgress>> {
  UploadProgressNotifier() : super({});

  /// アップロード開始
  void startUpload(String key, String fileName, int totalBytes) {
    state = {
      ...state,
      key: UploadProgress.start(fileName, totalBytes),
    };
  }

  /// アップロード進捗更新
  void updateProgress(String key, int bytesUploaded, int totalBytes) {
    if (state.containsKey(key)) {
      state = {
        ...state,
        key: UploadProgress.update(
          state[key]!.fileName,
          bytesUploaded,
          totalBytes,
        ),
      };
    }
  }

  /// アップロード完了
  void completeUpload(String key) {
    if (state.containsKey(key)) {
      final progress = state[key]!;
      state = {
        ...state,
        key: UploadProgress.completed(progress.fileName, progress.totalBytes),
      };
      
      // 3秒後に状態をクリア
      Future.delayed(const Duration(seconds: 3), () {
        clearProgress(key);
      });
    }
  }

  /// アップロードエラー
  void errorUpload(String key, String error) {
    if (state.containsKey(key)) {
      state = {
        ...state,
        key: UploadProgress.error(state[key]!.fileName, error),
      };
    }
  }

  /// 進捗をクリア
  void clearProgress(String key) {
    final newState = Map<String, UploadProgress>.from(state);
    newState.remove(key);
    state = newState;
  }

  /// 全ての進捗をクリア
  void clearAllProgress() {
    state = {};
  }
}

/// プロフィール画像アップロードのプロバイダー
final profileImageUploadProvider = StateNotifierProvider<ProfileImageUploadNotifier, AsyncValue<String?>>((ref) {
  final imageUploadService = ref.watch(imageUploadServiceProvider);
  final progressNotifier = ref.read(uploadProgressProvider.notifier);
  return ProfileImageUploadNotifier(imageUploadService, progressNotifier);
});

/// プロフィール画像アップロードの状態管理クラス
class ProfileImageUploadNotifier extends StateNotifier<AsyncValue<String?>> {
  final ImageUploadService _imageUploadService;
  final UploadProgressNotifier _progressNotifier;

  ProfileImageUploadNotifier(this._imageUploadService, this._progressNotifier) 
      : super(const AsyncValue.data(null));

  /// プロフィール画像をアップロード
  Future<String?> uploadProfileImage({
    required String userId,
    required File imageFile,
    String? oldImageUrl,
  }) async {
    const progressKey = 'profile_upload';
    
    try {
      state = const AsyncValue.loading();
      
      // 進捗開始
      final fileSize = await imageFile.length();
      _progressNotifier.startUpload(progressKey, 'プロフィール画像', fileSize);
      
      // 画像をアップロード
      final imageUrl = await _imageUploadService.uploadProfileImage(
        userId: userId,
        imageFile: imageFile,
      );
      
      // 古い画像を削除
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await _imageUploadService.deleteOldProfileImage(
          userId: userId,
          oldImageUrl: oldImageUrl,
        );
      }
      
      // 進捗完了
      _progressNotifier.completeUpload(progressKey);
      
      state = AsyncValue.data(imageUrl);
      return imageUrl;
    } catch (error, stackTrace) {
      _progressNotifier.errorUpload(progressKey, error.toString());
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// 状態をリセット
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// コンテンツ画像アップロードのプロバイダー
final contentImageUploadProvider = StateNotifierProvider<ContentImageUploadNotifier, AsyncValue<List<String>>>((ref) {
  final imageUploadService = ref.watch(imageUploadServiceProvider);
  final progressNotifier = ref.read(uploadProgressProvider.notifier);
  return ContentImageUploadNotifier(imageUploadService, progressNotifier);
});

/// コンテンツ画像アップロードの状態管理クラス
class ContentImageUploadNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final ImageUploadService _imageUploadService;
  final UploadProgressNotifier _progressNotifier;

  ContentImageUploadNotifier(this._imageUploadService, this._progressNotifier) 
      : super(const AsyncValue.data([]));

  /// コンテンツ画像をアップロード
  Future<List<String>> uploadContentImages({
    required String userId,
    required List<File> imageFiles,
    String? contentId,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      // 各画像の進捗を開始
      for (int i = 0; i < imageFiles.length; i++) {
        final progressKey = 'content_upload_$i';
        final fileSize = await imageFiles[i].length();
        _progressNotifier.startUpload(progressKey, '画像${i + 1}', fileSize);
      }
      
      // 画像をアップロード
      final imageUrls = await _imageUploadService.uploadContentImages(
        userId: userId,
        imageFiles: imageFiles,
        contentId: contentId,
      );
      
      // 全ての進捗を完了
      for (int i = 0; i < imageFiles.length; i++) {
        final progressKey = 'content_upload_$i';
        _progressNotifier.completeUpload(progressKey);
      }
      
      state = AsyncValue.data(imageUrls);
      return imageUrls;
    } catch (error, stackTrace) {
      // エラーの場合は全ての進捗をエラー状態に
      for (int i = 0; i < imageFiles.length; i++) {
        final progressKey = 'content_upload_$i';
        _progressNotifier.errorUpload(progressKey, error.toString());
      }
      
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }

  /// 状態をリセット
  void reset() {
    state = const AsyncValue.data([]);
  }
}

/// 画像削除のプロバイダー
final imageDeleteProvider = StateNotifierProvider<ImageDeleteNotifier, AsyncValue<bool>>((ref) {
  final imageUploadService = ref.watch(imageUploadServiceProvider);
  return ImageDeleteNotifier(imageUploadService);
});

/// 画像削除の状態管理クラス
class ImageDeleteNotifier extends StateNotifier<AsyncValue<bool>> {
  final ImageUploadService _imageUploadService;

  ImageDeleteNotifier(this._imageUploadService) : super(const AsyncValue.data(false));

  /// 画像を削除
  Future<bool> deleteImage(String imageUrl) async {
    try {
      state = const AsyncValue.loading();
      
      await _imageUploadService.deleteImage(imageUrl);
      
      state = const AsyncValue.data(true);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// 状態をリセット
  void reset() {
    state = const AsyncValue.data(false);
  }
}

/// 画像アップロード統計のプロバイダー
final imageUploadStatsProvider = Provider<ImageUploadStats>((ref) {
  final uploadProgress = ref.watch(uploadProgressProvider);
  
  final totalUploads = uploadProgress.length;
  final completedUploads = uploadProgress.values.where((p) => p.isCompleted).length;
  final errorUploads = uploadProgress.values.where((p) => p.error != null).length;
  final inProgressUploads = uploadProgress.values.where((p) => !p.isCompleted && p.error == null).length;
  
  final totalBytes = uploadProgress.values.fold<int>(0, (sum, p) => sum + p.totalBytes);
  final uploadedBytes = uploadProgress.values.fold<int>(0, (sum, p) => sum + p.bytesUploaded);
  
  final overallProgress = totalBytes > 0 ? (uploadedBytes / totalBytes) * 100 : 0.0;
  
  return ImageUploadStats(
    totalUploads: totalUploads,
    completedUploads: completedUploads,
    errorUploads: errorUploads,
    inProgressUploads: inProgressUploads,
    totalBytes: totalBytes,
    uploadedBytes: uploadedBytes,
    overallProgress: overallProgress,
  );
});

/// 画像アップロード統計
class ImageUploadStats {
  final int totalUploads;
  final int completedUploads;
  final int errorUploads;
  final int inProgressUploads;
  final int totalBytes;
  final int uploadedBytes;
  final double overallProgress;

  const ImageUploadStats({
    required this.totalUploads,
    required this.completedUploads,
    required this.errorUploads,
    required this.inProgressUploads,
    required this.totalBytes,
    required this.uploadedBytes,
    required this.overallProgress,
  });

  bool get hasUploads => totalUploads > 0;
  bool get hasActiveUploads => inProgressUploads > 0;
  bool get hasErrors => errorUploads > 0;
  bool get isAllCompleted => totalUploads > 0 && completedUploads == totalUploads;
}