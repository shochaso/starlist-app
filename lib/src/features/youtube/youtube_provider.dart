import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_integration/models/youtube_video.dart';
import '../data_integration/repositories/youtube_repository.dart';

/// YouTubeリポジトリのプロバイダー
final youtubeRepositoryProvider = StateProvider<YouTubeRepository?>((ref) => null);

/// YouTubeの検索クエリを管理するプロバイダー
final youtubeSearchQueryProvider = StateProvider<String>((ref) => '');

/// 検索結果を提供するプロバイダー
final youtubeSearchResultsProvider = FutureProvider<List<YouTubeVideo>>((ref) async {
  final repository = ref.watch(youtubeRepositoryProvider);
  final query = ref.watch(youtubeSearchQueryProvider);
  
  if (repository == null || query.isEmpty) {
    return [];
  }
  
  return await repository.searchVideos(query);
});

/// YouTubeプロバイダークラス
class YouTubeProvider extends ChangeNotifier {
  final YouTubeRepository _repository;
  
  List<YouTubeVideo> _searchResults = [];
  List<YouTubeVideo> get searchResults => _searchResults;
  
  YouTubeVideo? _currentVideo;
  YouTubeVideo? get currentVideo => _currentVideo;
  
  List<YouTubeVideo> _channelVideos = [];
  List<YouTubeVideo> get channelVideos => _channelVideos;
  
  List<YouTubeVideo> _relatedVideos = [];
  List<YouTubeVideo> get relatedVideos => _relatedVideos;
  
  List<YouTubeVideo> _popularVideos = [];
  List<YouTubeVideo> get popularVideos => _popularVideos;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  YouTubeProvider(this._repository);
  
  /// 動画を検索
  Future<void> searchVideos(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _searchResults = await _repository.searchVideos(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 動画の詳細情報を読み込む
  Future<void> loadVideoDetails(String videoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final video = await _repository.getVideoDetails(videoId);
      _currentVideo = video;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// チャンネルの動画を読み込む
  Future<void> loadChannelVideos(String channelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _channelVideos = await _repository.getChannelVideos(channelId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 関連動画を読み込む
  Future<void> loadRelatedVideos(String videoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _relatedVideos = await _repository.getRelatedVideos(videoId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 人気動画を読み込む
  Future<void> loadPopularVideos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _popularVideos = await _repository.getPopularVideos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 