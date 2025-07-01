import 'simple_youtube_service.dart';
import 'simple_youtube_setup.dart';
import '../daily_pick/models/daily_pick_models.dart';

/// YouTuber履歴をStarlistに簡単インポートするツール
class YouTubeHistoryImporter {
  
  /// YouTuberの動画履歴をStarlistの「毎日ピック」にインポート
  static Future<ImportResult> importYouTuberHistory({
    required String starId,
    required String channelId,
    int maxVideos = 50,
  }) async {
    try {
      print('📺 YouTuber履歴インポート開始...');
      
      // 1. APIキー設定チェック
      if (!SimpleYouTubeSetup.isSetupComplete()) {
        return ImportResult.error('APIキーが設定されていません');
      }
      
      SimpleYouTubeService.apiKey = SimpleYouTubeSetup.myApiKey;
      
      // 2. チャンネル情報取得
      print('📊 チャンネル情報を取得中...');
      final channel = await SimpleYouTubeService.getChannel(channelId);
      if (channel == null) {
        return ImportResult.error('チャンネル情報を取得できませんでした');
      }
      
      // 3. 動画履歴取得
      print('🎬 動画履歴を取得中...');
      final videos = await SimpleYouTubeService.getChannelVideos(channelId);
      if (videos.isEmpty) {
        return ImportResult.error('動画が見つかりませんでした');
      }
      
      // 4. 動画を毎日ピックアイテムに変換
      print('🔄 動画を毎日ピックに変換中...');
      final dailyPickItems = <DailyPickItem>[];
      int successCount = 0;
      int errorCount = 0;
      
      for (int i = 0; i < videos.length && i < maxVideos; i++) {
        try {
          final video = videos[i];
          final dailyPickItem = _convertVideoToDailyPick(starId, video);
          dailyPickItems.add(dailyPickItem);
          successCount++;
          
          // 進捗表示
          if ((i + 1) % 10 == 0) {
            print('📈 進捗: ${i + 1}/${videos.length}件処理完了');
          }
          
        } catch (e) {
          print('❌ 動画変換エラー: $e');
          errorCount++;
        }
      }
      
      print('✅ インポート完了！');
      print('📊 成功: $successCount件、エラー: $errorCount件');
      
      return ImportResult.success(
        channelInfo: channel,
        importedItems: dailyPickItems,
        successCount: successCount,
        errorCount: errorCount,
      );
      
    } catch (e) {
      print('💥 インポート処理エラー: $e');
      return ImportResult.error('インポート処理でエラーが発生しました: $e');
    }
  }
  
  /// YouTube動画を毎日ピックアイテムに変換
  static DailyPickItem _convertVideoToDailyPick(String starId, YouTubeVideo video) {
    return DailyPickItem(
      id: 'youtube_${video.id}',
      starId: starId,
      title: video.title,
      description: _createDescription(video),
      type: DailyPickType.video,
      status: DailyPickStatus.published,
      thumbnailUrl: video.imageUrl,
      contentUrl: video.youtubeUrl,
      tags: _createTags(video),
      viewCount: video.viewCount,
      likeCount: video.likeCount,
      commentCount: 0, // YouTubeからは取得困難
      scheduledAt: video.publishedAt,
      publishedAt: video.publishedAt,
      expiresAt: null, // 期限なし
      isPremiumContent: false,
      requiredStarPoints: 0, // 無料
      metadata: {
        'source': 'youtube',
        'youtube_video_id': video.id,
        'youtube_channel': video.channelName,
        'import_date': DateTime.now().toIso8601String(),
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// 動画の説明文を作成
  static String _createDescription(YouTubeVideo video) {
    final description = StringBuffer();
    
    description.writeln('📺 YouTube動画');
    description.writeln('👀 ${video.viewCountText}');
    description.writeln('📅 ${video.publishedText}');
    
    if (video.likeCount > 0) {
      description.writeln('👍 ${video.likeCount}いいね');
    }
    
    if (video.description.isNotEmpty) {
      description.writeln();
      // 説明文は最初の200文字まで
      final shortDescription = video.description.length > 200 
          ? '${video.description.substring(0, 200)}...'
          : video.description;
      description.writeln(shortDescription);
    }
    
    return description.toString();
  }
  
  /// タグを作成
  static List<String> _createTags(YouTubeVideo video) {
    final tags = <String>['YouTube', 'インポート'];
    
    // チャンネル名をタグに追加
    if (video.channelName.isNotEmpty) {
      tags.add(video.channelName);
    }
    
    // 再生回数に基づくタグ
    if (video.viewCount >= 1000000) {
      tags.add('人気動画');
    } else if (video.viewCount >= 100000) {
      tags.add('注目動画');
    }
    
    // 公開日に基づくタグ
    final daysSincePublished = DateTime.now().difference(video.publishedAt).inDays;
    if (daysSincePublished <= 7) {
      tags.add('新着');
    } else if (daysSincePublished <= 30) {
      tags.add('最近');
    }
    
    return tags;
  }
  
  /// 複数YouTuberの履歴を一括インポート
  static Future<BatchImportResult> batchImportYouTubers(
    Map<String, String> starIdToChannelId,
  ) async {
    final results = <String, ImportResult>{};
    int totalSuccess = 0;
    int totalErrors = 0;
    
    print('🚀 一括インポート開始: ${starIdToChannelId.length}チャンネル');
    
    for (final entry in starIdToChannelId.entries) {
      final starId = entry.key;
      final channelId = entry.value;
      
      print('📺 $starId のインポート開始...');
      
      final result = await importYouTuberHistory(
        starId: starId,
        channelId: channelId,
        maxVideos: 20, // 一括処理では制限
      );
      
      results[starId] = result;
      
      if (result.success) {
        totalSuccess += result.successCount;
        totalErrors += result.errorCount;
        print('✅ $starId: ${result.successCount}件インポート完了');
      } else {
        totalErrors++;
        print('❌ $starId: ${result.message}');
      }
      
      // APIレート制限対策（1秒待機）
      await Future.delayed(const Duration(seconds: 1));
    }
    
    print('🎉 一括インポート完了！');
    print('📊 総成功件数: $totalSuccess、総エラー件数: $totalErrors');
    
    return BatchImportResult(
      results: results,
      totalSuccess: totalSuccess,
      totalErrors: totalErrors,
    );
  }
}

/// インポート結果
class ImportResult {
  final bool success;
  final String message;
  final YouTubeChannel? channelInfo;
  final List<DailyPickItem>? importedItems;
  final int successCount;
  final int errorCount;
  
  ImportResult({
    required this.success,
    required this.message,
    this.channelInfo,
    this.importedItems,
    this.successCount = 0,
    this.errorCount = 0,
  });
  
  factory ImportResult.success({
    required YouTubeChannel channelInfo,
    required List<DailyPickItem> importedItems,
    required int successCount,
    required int errorCount,
  }) {
    return ImportResult(
      success: true,
      message: '$successCount件のアイテムをインポートしました',
      channelInfo: channelInfo,
      importedItems: importedItems,
      successCount: successCount,
      errorCount: errorCount,
    );
  }
  
  factory ImportResult.error(String errorMessage) {
    return ImportResult(
      success: false,
      message: errorMessage,
    );
  }
}

/// 一括インポート結果
class BatchImportResult {
  final Map<String, ImportResult> results;
  final int totalSuccess;
  final int totalErrors;
  
  BatchImportResult({
    required this.results,
    required this.totalSuccess,
    required this.totalErrors,
  });
  
  /// 成功した結果のみ取得
  List<ImportResult> get successfulResults {
    return results.values.where((result) => result.success).toList();
  }
  
  /// 失敗した結果のみ取得  
  List<ImportResult> get failedResults {
    return results.values.where((result) => !result.success).toList();
  }
  
  /// 成功率
  double get successRate {
    if (results.isEmpty) return 0.0;
    return successfulResults.length / results.length;
  }
}