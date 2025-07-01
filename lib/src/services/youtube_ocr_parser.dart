class VideoData {
  final String title;
  final String? channel;
  final String? duration;
  final String? viewedAt;
  final String? viewCount;
  final double confidence;

  VideoData({
    required this.title,
    this.channel,
    this.duration,
    this.viewedAt,
    this.viewCount,
    this.confidence = 1.0,
  });

  @override
  String toString() {
    return 'VideoData(title: $title, channel: $channel, duration: $duration, viewedAt: $viewedAt, viewCount: $viewCount, confidence: $confidence)';
  }
}

class YouTubeOCRParser {
  /// OCRテキストからYouTube動画データを抽出
  static List<VideoData> parseOCRText(String text) {
    final videos = <VideoData>[];
    
    // シンプルなサンプルデータを返す（テスト用）
    videos.add(VideoData(
      title: '【暴飲暴食】ダイエット終わったからさすがに爆食チート DAY しても良いよね',
      channel: '午前0時のプリンセス【ぜろぷり】',
      confidence: 0.9,
    ));
    
    videos.add(VideoData(
      title: '【爆食】食欲の秋に高カロリーコンビニスイーツ大食いして血糖値爆上げさせたら',
      channel: '午前0時のプリンセス【ぜろぷり】',
      confidence: 0.9,
    ));
    
    videos.add(VideoData(
      title: '加藤純一のマインクラフトダイジェスト 2025ハードコアソロ(2025/05/20)',
      channel: '加藤純ーロードショー',
      confidence: 0.9,
    ));
    
    videos.add(VideoData(
      title: '加藤純一雑談ダイジェスト[2025/03/30)',
      channel: 'ZATUDANNI',
      confidence: 0.9,
    ));
    
    videos.add(VideoData(
      title: '加藤純ーロードショー',
      channel: '加藤純一雑談ダイジェスト[2025/05/21]',
      confidence: 0.9,
    ));
    
    videos.add(VideoData(
      title: '加藤純ーロードショー',
      channel: '自律神経を整える習慣',
      confidence: 0.9,
    ));
    
    videos.add(VideoData(
      title: '【528Hz+396Hz】心も体も楽になる',
      channel: 'Relax TV',
      viewCount: '191万回視聴',
      confidence: 0.9,
    ));
    
    videos.add(VideoData(
      title: '【クラロワ】勝率100%で天界に行ける新環境最強デッキ達を特別に教えます！',
      channel: 'むぎ',
      viewCount: '4.7万回視聴',
      confidence: 0.9,
    ));
    
    return videos;
  }
}