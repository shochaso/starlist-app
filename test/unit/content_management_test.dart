import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_implementation/src/features/user_experience/content_management/models/content_models.dart';
import 'package:starlist_implementation/src/features/user_experience/content_management/services/content_management_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

class MockContentManagementService extends Mock implements ContentManagementService {}

void main() {
  group('コンテンツ管理システムのテスト', () {
    late ContentManagementService contentService;
    
    setUp(() {
      contentService = ContentManagementService();
    });
    
    test('コンテンツモデルが正しく作成されること', () {
      final content = Content(
        id: 'content_1',
        starId: 'star_1',
        title: 'テストコンテンツ',
        description: 'これはテスト用のコンテンツです',
        type: ContentType.post,
        status: ContentStatus.published,
        privacyLevel: PrivacyLevel.public,
        createdAt: DateTime.now(),
        publishedAt: DateTime.now(),
        viewCount: 100,
        likeCount: 50,
        metadata: {
          'tags': ['テスト', 'サンプル'],
        },
      );
      
      expect(content.id, 'content_1');
      expect(content.starId, 'star_1');
      expect(content.title, 'テストコンテンツ');
      expect(content.type, ContentType.post);
      expect(content.status, ContentStatus.published);
      expect(content.privacyLevel, PrivacyLevel.public);
      expect(content.viewCount, 100);
      expect(content.likeCount, 50);
      expect(content.metadata['tags'], contains('テスト'));
    });
    
    test('コンテンツリストが正しく取得できること', () async {
      final contents = await contentService.getContents(
        starId: 'star_1',
        status: ContentStatus.published,
        limit: 10,
        offset: 0,
      );
      
      expect(contents, isNotEmpty);
      expect(contents.length, lessThanOrEqualTo(10));
      expect(contents.first.starId, 'star_1');
      expect(contents.first.status, ContentStatus.published);
    });
    
    test('限定コンテンツが正しく管理できること', () async {
      final content = await contentService.createContent(
        starId: 'star_1',
        title: '限定コンテンツ',
        description: 'これは限定公開のコンテンツです',
        type: ContentType.exclusive,
        privacyLevel: PrivacyLevel.membersOnly,
        metadata: {
          'tags': ['限定', 'メンバー向け'],
          'requiredMembershipLevel': 'premium',
        },
      );
      
      expect(content.id, isNotEmpty);
      expect(content.title, '限定コンテンツ');
      expect(content.type, ContentType.exclusive);
      expect(content.privacyLevel, PrivacyLevel.membersOnly);
      expect(content.status, ContentStatus.draft);
      expect(content.metadata['requiredMembershipLevel'], 'premium');
      
      // 公開設定の変更
      final publishedContent = await contentService.updateContentStatus(
        contentId: content.id,
        status: ContentStatus.published,
      );
      
      expect(publishedContent.status, ContentStatus.published);
      expect(publishedContent.publishedAt, isNotNull);
    });
    
    test('公開スケジュール設定が正しく機能すること', () async {
      final scheduledTime = DateTime.now().add(const Duration(days: 1));
      
      final content = await contentService.createContent(
        starId: 'star_1',
        title: 'スケジュール公開コンテンツ',
        description: 'これは予約投稿のコンテンツです',
        type: ContentType.post,
        privacyLevel: PrivacyLevel.public,
        metadata: {
          'tags': ['予約投稿', 'スケジュール'],
        },
      );
      
      final scheduledContent = await contentService.scheduleContent(
        contentId: content.id,
        publishAt: scheduledTime,
      );
      
      expect(scheduledContent.id, content.id);
      expect(scheduledContent.status, ContentStatus.scheduled);
      expect(scheduledContent.scheduledPublishTime, scheduledTime);
    });
    
    test('プライバシーレベル設定が正しく機能すること', () async {
      final content = await contentService.createContent(
        starId: 'star_1',
        title: 'プライバシー設定テスト',
        description: 'これはプライバシー設定のテストです',
        type: ContentType.post,
        privacyLevel: PrivacyLevel.public,
      );
      
      // プライバシー設定の変更
      final updatedContent = await contentService.updateContentPrivacy(
        contentId: content.id,
        privacyLevel: PrivacyLevel.private,
        visibleToUserIds: ['user_1', 'user_2'],
      );
      
      expect(updatedContent.privacyLevel, PrivacyLevel.private);
      expect(updatedContent.visibleToUserIds, contains('user_1'));
      expect(updatedContent.visibleToUserIds, contains('user_2'));
    });
  });
}
