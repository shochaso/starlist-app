import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/content_consumption_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../content/domain/services/content_service.dart';
import '../../../../core/errors/app_exceptions.dart';

/// 検索ビューモデルクラス
class DiscoverViewModel extends StateNotifier<DiscoverViewState> {
  /// コンテンツサービス
  final ContentService _contentService;

  /// コンストラクタ
  DiscoverViewModel(this._contentService) : super(DiscoverViewState.initial());

  /// トレンドコンテンツを読み込む
  Future<void> loadTrendingContent({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(
          isLoadingTrends: true,
          trendingError: null,
        );
      } else if (state.isLoadingTrends) {
        return;
      }

      final trends = await _contentService.getTrendingContent(limit: 10);

      state = state.copyWith(
        trendingContents: trends,
        isLoadingTrends: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingTrends: false,
        trendingError: e.toString(),
      );
    }
  }

  /// 人気のスターを読み込む
  Future<void> loadPopularStars() async {
    try {
      state = state.copyWith(
        isLoadingStars: true,
        starsError: null,
      );

      // 実際のアプリでは人気のスターを取得するAPIを呼び出す
      // ここではダミーデータを使用
      await Future.delayed(const Duration(seconds: 1));
      final stars = _getDummyStars();

      state = state.copyWith(
        popularStars: stars,
        isLoadingStars: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingStars: false,
        starsError: e.toString(),
      );
    }
  }

  /// コンテンツを検索
  Future<void> searchContent({
    required String query,
    ContentType? contentType,
    bool refresh = false,
  }) async {
    try {
      // 検索クエリが空の場合は何もしない
      if (query.trim().isEmpty) {
        state = state.copyWith(
          searchResults: [],
          isLoadingSearch: false,
          searchError: null,
          currentQuery: '',
        );
        return;
      }

      state = state.copyWith(
        isLoadingSearch: true,
        searchError: null,
        currentQuery: query,
      );

      final results = await _contentService.searchContent(
        query: query,
        contentType: contentType,
        limit: 20,
      );

      state = state.copyWith(
        searchResults: results,
        isLoadingSearch: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSearch: false,
        searchError: e.toString(),
      );
    }
  }

  /// スターを検索
  Future<void> searchStars(String query) async {
    try {
      // 検索クエリが空の場合は何もしない
      if (query.trim().isEmpty) {
        state = state.copyWith(
          starSearchResults: [],
          isLoadingStarSearch: false,
          starSearchError: null,
        );
        return;
      }

      state = state.copyWith(
        isLoadingStarSearch: true,
        starSearchError: null,
      );

      // 実際のアプリではスターを検索するAPIを呼び出す
      // ここではダミーデータをフィルタリング
      await Future.delayed(const Duration(milliseconds: 500));
      final allStars = _getDummyStars();
      final results = allStars.where((star) {
        return star.displayName.toLowerCase().contains(query.toLowerCase()) ||
            (star.username?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();

      state = state.copyWith(
        starSearchResults: results,
        isLoadingStarSearch: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingStarSearch: false,
        starSearchError: e.toString(),
      );
    }
  }

  /// 検索履歴を追加
  void addSearchHistory(String query) {
    if (query.trim().isEmpty) return;
    
    // 既存の履歴から同じクエリを削除
    final updatedHistory = state.searchHistory
        .where((item) => item.toLowerCase() != query.toLowerCase())
        .toList();
    
    // 新しいクエリを先頭に追加
    updatedHistory.insert(0, query);
    
    // 履歴は最大10件まで
    if (updatedHistory.length > 10) {
      updatedHistory.removeLast();
    }
    
    state = state.copyWith(searchHistory: updatedHistory);
  }

  /// 検索履歴を削除
  void removeSearchHistory(String query) {
    final updatedHistory = state.searchHistory
        .where((item) => item != query)
        .toList();
    
    state = state.copyWith(searchHistory: updatedHistory);
  }

  /// 検索履歴をクリア
  void clearSearchHistory() {
    state = state.copyWith(searchHistory: []);
  }

  /// ダミースターデータを取得
  List<UserModel> _getDummyStars() {
    return [
      UserModel(
        id: '1',
        username: 'yamada_taro',
        displayName: '山田太郎',
        email: 'yamada@example.com',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        bio: 'ゲーム実況者 / YouTuber / 毎日配信中',
        userType: UserType.star,
        isVerified: true,
        followerCount: 125000,
        followingCount: 350,
        contentCount: 1200,
      ),
      UserModel(
        id: '2',
        username: 'tanaka_hanako',
        displayName: '田中花子',
        email: 'tanaka@example.com',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
        bio: 'ファッションモデル / インフルエンサー / 美容情報発信中',
        userType: UserType.star,
        isVerified: true,
        followerCount: 89000,
        followingCount: 420,
        contentCount: 850,
      ),
      UserModel(
        id: '3',
        username: 'sato_kenji',
        displayName: '佐藤健二',
        email: 'sato@example.com',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
        bio: 'テックブロガー / プログラマー / 技術書著者',
        userType: UserType.star,
        isVerified: false,
        followerCount: 45000,
        followingCount: 210,
        contentCount: 320,
      ),
      UserModel(
        id: '4',
        username: 'suzuki_ai',
        displayName: '鈴木愛',
        email: 'suzuki@example.com',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
        bio: 'フードブロガー / レシピ開発 / 料理研究家',
        userType: UserType.star,
        isVerified: true,
        followerCount: 67000,
        followingCount: 180,
        contentCount: 750,
      ),
      UserModel(
        id: '5',
        username: 'takahashi_yuki',
        displayName: '高橋ユキ',
        email: 'takahashi@example.com',
        profileImageUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
        bio: 'アーティスト / イラストレーター / デザイナー',
        userType: UserType.star,
        isVerified: false,
        followerCount: 38000,
        followingCount: 290,
        contentCount: 420,
      ),
    ];
  }
}

/// 検索ビュー状態クラス
class DiscoverViewState {
  /// トレンドコンテンツ
  final List<ContentConsumptionModel> trendingContents;
  
  /// 人気のスター
  final List<UserModel> popularStars;
  
  /// 検索結果（コンテンツ）
  final List<ContentConsumptionModel> searchResults;
  
  /// 検索結果（スター）
  final List<UserModel> starSearchResults;
  
  /// 検索履歴
  final List<String> searchHistory;
  
  /// 現在の検索クエリ
  final String currentQuery;
  
  /// トレンド読み込み中かどうか
  final bool isLoadingTrends;
  
  /// スター読み込み中かどうか
  final bool isLoadingStars;
  
  /// 検索読み込み中かどうか
  final bool isLoadingSearch;
  
  /// スター検索読み込み中かどうか
  final bool isLoadingStarSearch;
  
  /// トレンドエラー
  final String? trendingError;
  
  /// スターエラー
  final String? starsError;
  
  /// 検索エラー
  final String? searchError;
  
  /// スター検索エラー
  final String? starSearchError;

  /// コンストラクタ
  const DiscoverViewState({
    required this.trendingContents,
    required this.popularStars,
    required this.searchResults,
    required this.starSearchResults,
    required this.searchHistory,
    required this.currentQuery,
    required this.isLoadingTrends,
    required this.isLoadingStars,
    required this.isLoadingSearch,
    required this.isLoadingStarSearch,
    this.trendingError,
    this.starsError,
    this.searchError,
    this.starSearchError,
  });

  /// 初期状態を作成
  factory DiscoverViewState.initial() {
    return const DiscoverViewState(
      trendingContents: [],
      popularStars: [],
      searchResults: [],
      starSearchResults: [],
      searchHistory: [],
      currentQuery: '',
      isLoadingTrends: false,
      isLoadingStars: false,
      isLoadingSearch: false,
      isLoadingStarSearch: false,
    );
  }

  /// 新しい状態をコピーして作成
  DiscoverViewState copyWith({
    List<ContentConsumptionModel>? trendingContents,
    List<UserModel>? popularStars,
    List<ContentConsumptionModel>? searchResults,
    List<UserModel>? starSearchResults,
    List<String>? searchHistory,
    String? currentQuery,
    bool? isLoadingTrends,
    bool? isLoadingStars,
    bool? isLoadingSearch,
    bool? isLoadingStarSearch,
    String? trendingError,
    String? starsError,
    String? searchError,
    String? starSearchError,
  }) {
    return DiscoverViewState(
      trendingContents: trendingContents ?? this.trendingContents,
      popularStars: popularStars ?? this.popularStars,
      searchResults: searchResults ?? this.searchResults,
      starSearchResults: starSearchResults ?? this.starSearchResults,
      searchHistory: searchHistory ?? this.searchHistory,
      currentQuery: currentQuery ?? this.currentQuery,
      isLoadingTrends: isLoadingTrends ?? this.isLoadingTrends,
      isLoadingStars: isLoadingStars ?? this.isLoadingStars,
      isLoadingSearch: isLoadingSearch ?? this.isLoadingSearch,
      isLoadingStarSearch: isLoadingStarSearch ?? this.isLoadingStarSearch,
      trendingError: trendingError,
      starsError: starsError,
      searchError: searchError,
      starSearchError: starSearchError,
    );
  }
}

/// 検索ビューモデルプロバイダー
final discoverViewModelProvider = StateNotifierProvider<DiscoverViewModel, DiscoverViewState>((ref) {
  final contentService = ref.watch(contentServiceProvider);
  return DiscoverViewModel(contentService);
});
