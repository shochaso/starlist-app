import 'package:flutter/material.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/content_consumption_model.dart';

/// ホーム画面のビューモデル
/// ホーム画面の状態管理と操作を担当する
class HomeViewModel extends ChangeNotifier {
  final HomeService _homeService;
  
  UserModel? _currentUser;
  List<UserModel> _followedStars = [];
  List<ContentConsumptionModel> _recentContents = [];
  bool _isLoading = false;
  String? _error;
  
  HomeViewModel({
    required HomeService homeService,
  }) : _homeService = homeService;
  
  /// 現在のユーザー
  UserModel? get currentUser => _currentUser;
  
  /// フォロー中のスターリスト
  List<UserModel> get followedStars => _followedStars;
  
  /// 最近のコンテンツリスト
  List<ContentConsumptionModel> get recentContents => _recentContents;
  
  /// 読み込み中かどうか
  bool get isLoading => _isLoading;
  
  /// エラーメッセージ
  String? get error => _error;
  
  /// ホーム画面のデータを初期化する
  Future<void> initializeHome() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final userData = await _homeService.getCurrentUserProfile();
      _currentUser = userData;
      
      await Future.wait([
        loadFollowedStars(),
        loadRecentContents(),
      ]);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// フォロー中のスターを読み込む
  Future<void> loadFollowedStars() async {
    try {
      final stars = await _homeService.getFollowedStars();
      _followedStars = stars;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// 最近のコンテンツを読み込む
  Future<void> loadRecentContents() async {
    try {
      final contents = await _homeService.getRecentContents();
      _recentContents = contents;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// ホーム画面のデータをリフレッシュする
  Future<void> refreshHome() async {
    await initializeHome();
  }
  
  /// スターをフォローする
  Future<bool> followStar(String starId) async {
    try {
      final success = await _homeService.followStar(starId);
      
      if (success) {
        await loadFollowedStars();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// スターのフォローを解除する
  Future<bool> unfollowStar(String starId) async {
    try {
      final success = await _homeService.unfollowStar(starId);
      
      if (success) {
        await loadFollowedStars();
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

/// ホームサービスのインターフェース
/// ホーム画面のデータ取得と操作を担当する
abstract class HomeService {
  /// 現在のユーザープロフィールを取得する
  Future<UserModel> getCurrentUserProfile();
  
  /// フォロー中のスターを取得する
  Future<List<UserModel>> getFollowedStars({
    int limit = 10,
  });
  
  /// 最近のコンテンツを取得する
  Future<List<ContentConsumptionModel>> getRecentContents({
    int limit = 20,
  });
  
  /// スターをフォローする
  Future<bool> followStar(String starId);
  
  /// スターのフォローを解除する
  Future<bool> unfollowStar(String starId);
}
