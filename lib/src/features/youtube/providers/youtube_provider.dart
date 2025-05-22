import "package:flutter/foundation.dart";
import "package:starlist/src/features/youtube/models/youtube_video.dart";
import "package:starlist/src/features/youtube/services/youtube_service.dart";

class YouTubeProvider extends ChangeNotifier {
  final YouTubeService _youtubeService;
  List<YouTubeVideo> _searchResults = [];
  YouTubeVideo? _currentVideo;
  List<YouTubeVideo> _channelVideos = [];
  List<YouTubeVideo> _relatedVideos = [];
  List<YouTubeVideo> _popularVideos = [];
  bool _isLoading = false;
  String? _error;

  YouTubeProvider(this._youtubeService);

  List<YouTubeVideo> get searchResults => _searchResults;
  YouTubeVideo? get currentVideo => _currentVideo;
  List<YouTubeVideo> get channelVideos => _channelVideos;
  List<YouTubeVideo> get relatedVideos => _relatedVideos;
  List<YouTubeVideo> get popularVideos => _popularVideos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> searchVideos(String query, {int maxResults = 10}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _searchResults = await _youtubeService.searchVideos(query, maxResults: maxResults);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVideoDetails(String videoId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentVideo = await _youtubeService.getVideoDetails(videoId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChannelVideos(String channelId, {int maxResults = 10}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _channelVideos = await _youtubeService.getChannelVideos(channelId, maxResults: maxResults);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRelatedVideos(String videoId, {int maxResults = 10}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _relatedVideos = await _youtubeService.getRelatedVideos(videoId, maxResults: maxResults);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPopularVideos({int maxResults = 10}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _popularVideos = await _youtubeService.getPopularVideos(maxResults: maxResults);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
