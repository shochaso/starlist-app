import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';

import '../features/content/models/content_consumption_model.dart';

/// コンテンツ共有サービスクラス
class SharingService {
  static final SharingService _instance = SharingService._internal();
  factory SharingService() => _instance;
  
  SharingService._internal();
  
  /// テキストを共有
  Future<void> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      debugPrint('テキストの共有に失敗しました: $e');
    }
  }
  
  /// URLを共有
  Future<void> shareUrl({
    required String url,
    String? subject,
    String? text,
  }) async {
    try {
      final shareText = text != null ? '$text\n$url' : url;
      await Share.share(
        shareText,
        subject: subject,
      );
    } catch (e) {
      debugPrint('URLの共有に失敗しました: $e');
    }
  }
  
  /// 画像を共有（URLから）
  Future<void> shareImageFromUrl({
    required String imageUrl,
    String? text,
    String? subject,
  }) async {
    try {
      // 画像をダウンロード
      final response = await http.get(Uri.parse(imageUrl));
      
      // 一時ファイルとして保存
      final tempDir = await getTemporaryDirectory();
      final fileName = imageUrl.split('/').last;
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      
      // 画像を共有
      await shareFiles(
        files: [filePath],
        text: text,
        subject: subject,
      );
    } catch (e) {
      debugPrint('画像の共有に失敗しました: $e');
      // 画像の共有に失敗した場合はURLだけを共有
      if (text != null) {
        await shareText(text: '$text\n$imageUrl', subject: subject);
      } else {
        await shareUrl(url: imageUrl, subject: subject);
      }
    }
  }
  
  /// ファイルを共有
  Future<void> shareFiles({
    required List<String> files,
    String? text,
    String? subject,
  }) async {
    try {
      final xFiles = files.map((path) => XFile(path)).toList();
      await Share.shareXFiles(
        xFiles,
        text: text,
        subject: subject,
      );
    } catch (e) {
      debugPrint('ファイルの共有に失敗しました: $e');
      // ファイルの共有に失敗した場合はテキストだけを共有
      if (text != null) {
        await shareText(text: text, subject: subject);
      }
    }
  }
  
  /// コンテンツ消費データを共有
  Future<void> shareContentConsumption({
    required ContentConsumption content,
    required String appUrl,
  }) async {
    // アプリのディープリンク
    final deepLink = '$appUrl/content/${content.id}';
    
    // 共有テキストを構築
    String shareText = '${content.title}\n';
    
    if (content.description != null) {
      shareText += '${content.description}\n\n';
    }
    
    // カテゴリによって共有内容を変更
    switch (content.category) {
      case ContentCategory.youtube:
        final videoId = content.contentData['video_id'] as String?;
        final thumbnailUrl = content.contentData['thumbnail_url'] as String?;
        
        if (videoId != null) {
          final youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';
          shareText += '$youtubeUrl\n\n';
          
          // サムネイルがある場合は画像として共有
          if (thumbnailUrl != null) {
            await shareImageFromUrl(
              imageUrl: thumbnailUrl,
              text: '$shareText\n$deepLink',
              subject: 'YouTubeビデオを共有します: ${content.title}',
            );
            return;
          }
        }
        break;
        
      case ContentCategory.book:
        final author = content.contentData['author'] as String?;
        final isbn = content.contentData['isbn'] as String?;
        
        if (author != null) {
          shareText += '著者: $author\n';
        }
        
        if (isbn != null) {
          shareText += 'ISBN: $isbn\n\n';
        }
        break;
        
      case ContentCategory.purchase:
        final store = content.contentData['store'] as String?;
        final productUrl = content.contentData['product_url'] as String?;
        
        if (store != null) {
          shareText += '購入店: $store\n';
        }
        
        if (content.price != null) {
          shareText += '価格: ¥${content.price}\n';
        }
        
        if (productUrl != null) {
          shareText += '$productUrl\n\n';
        }
        break;
        
      case ContentCategory.food:
        final restaurant = content.contentData['restaurant'] as String?;
        final menu = content.contentData['menu'] as String?;
        
        if (restaurant != null) {
          shareText += 'お店: $restaurant\n';
        }
        
        if (menu != null) {
          shareText += 'メニュー: $menu\n';
        }
        
        if (content.location != null) {
          shareText += '場所: ${content.location?.placeName ?? ''}\n';
          
          // 住所情報は共有しない（プライバシー保護）
          // 一般的な地図URLのみ提供（詳細な位置は表示されない）
          final lat = content.location?.latitude;
          final lng = content.location?.longitude;
          if (lat != null && lng != null) {
            // 大まかなエリアのみ表示する地図URL（ズームレベルを下げる）
            final mapUrl = 'https://www.google.com/maps?q=$lat,$lng&z=12';
            shareText += '地図: $mapUrl\n\n';
          }
        }
        break;
        
      default:
        break;
    }
    
    // アプリへのリンクを追加
    shareText += 'Starlistで確認する: $deepLink';
    
    // 共有する
    await this.shareText(
      text: shareText,
      subject: '${content.category.name}を共有します: ${content.title}',
    );
  }
  
  /// プロフィールを共有
  Future<void> shareProfile({
    required String userId,
    required String username,
    String? displayName,
    String? appUrl,
  }) async {
    final profileUrl = '$appUrl/profile/$username';
    
    String shareText = '';
    if (displayName != null) {
      shareText += '$displayName (@$username)\n\n';
    } else {
      shareText += '@$username\n\n';
    }
    
    shareText += 'Starlistでフォローする: $profileUrl';
    
    await this.shareText(
      text: shareText,
      subject: 'Starlistのプロフィールを共有',
    );
  }
} 