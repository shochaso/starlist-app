import "package:flutter/foundation.dart";
import "../models/content_model.dart";
import "../services/content_service.dart";

class ContentProvider extends ChangeNotifier {
  final ContentService _contentService;
  List<ContentModel> _contents = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  ContentProvider(this._contentService);

  List<ContentModel> get contents => _contents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadContents({bool refresh = false}) async {
    if (_isLoading || (!refresh && !_hasMore)) return;

    try {
      _isLoading = true;
      _error = null;
      if (refresh) {
        _currentPage = 1;
        _contents = [];
        _hasMore = true;
      }
      notifyListeners();

      final newContents = await _contentService.getContents(
        page: _currentPage,
      );

      _contents.addAll(newContents);
      _hasMore = newContents.isNotEmpty;
      _currentPage++;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadContents(refresh: true);
  }

  Future<void> likeContent(String id) async {
    try {
      await _contentService.likeContent(id);
      final index = _contents.indexWhere((c) => c.id == id);
      if (index != -1) {
        final content = _contents[index];
        _contents[index] = ContentModel(
          id: content.id,
          title: content.title,
          description: content.description,
          type: content.type,
          url: content.url,
          authorId: content.authorId,
          authorName: content.authorName,
          createdAt: content.createdAt,
          updatedAt: content.updatedAt,
          metadata: content.metadata,
          isPublished: content.isPublished,
          likes: content.likes + 1,
          comments: content.comments,
          shares: content.shares,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> unlikeContent(String id) async {
    try {
      await _contentService.unlikeContent(id);
      final index = _contents.indexWhere((c) => c.id == id);
      if (index != -1) {
        final content = _contents[index];
        _contents[index] = ContentModel(
          id: content.id,
          title: content.title,
          description: content.description,
          type: content.type,
          url: content.url,
          authorId: content.authorId,
          authorName: content.authorName,
          createdAt: content.createdAt,
          updatedAt: content.updatedAt,
          metadata: content.metadata,
          isPublished: content.isPublished,
          likes: content.likes - 1,
          comments: content.comments,
          shares: content.shares,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
