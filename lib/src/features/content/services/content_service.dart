import "../models/content_model.dart";

abstract class ContentService {
  Future<List<ContentModel>> getContents({int page = 1, int limit = 20});
  Future<ContentModel> getContentById(String id);
  Future<ContentModel> createContent(ContentModel content);
  Future<ContentModel> updateContent(String id, ContentModel content);
  Future<void> deleteContent(String id);
  Future<void> likeContent(String id);
  Future<void> unlikeContent(String id);
  Future<void> shareContent(String id);
}

class ContentServiceImpl implements ContentService {
  @override
  Future<List<ContentModel>> getContents({int page = 1, int limit = 20}) async {
    // TODO: Implement content fetching
    throw UnimplementedError();
  }

  @override
  Future<ContentModel> getContentById(String id) async {
    // TODO: Implement content fetching by ID
    throw UnimplementedError();
  }

  @override
  Future<ContentModel> createContent(ContentModel content) async {
    // TODO: Implement content creation
    throw UnimplementedError();
  }

  @override
  Future<ContentModel> updateContent(String id, ContentModel content) async {
    // TODO: Implement content update
    throw UnimplementedError();
  }

  @override
  Future<void> deleteContent(String id) async {
    // TODO: Implement content deletion
    throw UnimplementedError();
  }

  @override
  Future<void> likeContent(String id) async {
    // TODO: Implement content liking
    throw UnimplementedError();
  }

  @override
  Future<void> unlikeContent(String id) async {
    // TODO: Implement content unliking
    throw UnimplementedError();
  }

  @override
  Future<void> shareContent(String id) async {
    // TODO: Implement content sharing
    throw UnimplementedError();
  }
}
