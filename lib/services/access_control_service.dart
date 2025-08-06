import '../models/user.dart';

/// プラン別アクセス制御サービス
class AccessControlService {
  
  /// YouTube投稿閲覧可能かチェック
  static bool canViewYouTubeContent(FanPlanType? planType) {
    switch (planType) {
      case FanPlanType.free:
        return false; // 無料プランはポイント/チケット必須
      case FanPlanType.light:
      case FanPlanType.standard:
      case FanPlanType.premium:
        return true; // 有料プランは閲覧可能
      case null:
        return true; // スターは制限なし
    }
  }

  /// 指定プランでコンテンツ閲覧可能かチェック
  static bool canViewContent(FanPlanType? planType, ContentType contentType) {
    switch (contentType) {
      case ContentType.basicProfile:
        return true; // 全プラン閲覧可能
      
      case ContentType.youtubeVideos:
        return canViewYouTubeContent(planType);
      
      case ContentType.purchaseHistory:
        // 購入履歴は有料プラン以上
        return planType != FanPlanType.free;
      
      case ContentType.premiumContent:
        // 限定コンテンツはプレミアム以上
        return planType == FanPlanType.premium || planType == null;
      
      case ContentType.activities:
        // アクティビティはスタンダード以上
        return planType == FanPlanType.standard || 
               planType == FanPlanType.premium || 
               planType == null;
    }
  }

  /// ポイント消費でコンテンツ閲覧を許可
  static bool consumePointsForContent(int userPoints, ContentType contentType) {
    final requiredPoints = getRequiredPoints(contentType);
    return userPoints >= requiredPoints;
  }

  /// コンテンツ閲覧に必要なポイント数を取得
  static int getRequiredPoints(ContentType contentType) {
    switch (contentType) {
      case ContentType.youtubeVideos:
        return 10; // YouTube動画1本につき10ポイント
      case ContentType.purchaseHistory:
        return 5; // 購入履歴1件につき5ポイント
      case ContentType.premiumContent:
        return 20; // 限定コンテンツ1件につき20ポイント
      case ContentType.activities:
        return 3; // アクティビティ1件につき3ポイント
      default:
        return 0;
    }
  }

  /// チケット消費でコンテンツ閲覧を許可
  static bool consumeTicketForContent(int userTickets, ContentType contentType) {
    final requiredTickets = getRequiredTickets(contentType);
    return userTickets >= requiredTickets;
  }

  /// コンテンツ閲覧に必要なチケット数を取得
  static int getRequiredTickets(ContentType contentType) {
    switch (contentType) {
      case ContentType.youtubeVideos:
        return 1; // YouTube動画1本につき1チケット
      case ContentType.purchaseHistory:
        return 0; // チケットでは購入履歴は閲覧不可
      case ContentType.premiumContent:
        return 3; // 限定コンテンツ1件につき3チケット
      case ContentType.activities:
        return 0; // チケットではアクティビティは閲覧不可
      default:
        return 0;
    }
  }

  /// 制限理由メッセージを取得
  static String getRestrictionMessage(FanPlanType? planType, ContentType contentType) {
    if (canViewContent(planType, contentType)) {
      return '';
    }

    switch (contentType) {
      case ContentType.youtubeVideos:
        return 'YouTube投稿の閲覧には以下のいずれかが必要です：\n'
               '• ライトプラン以上への登録\n'
               '• ${getRequiredPoints(contentType)}ポイントの消費\n'
               '• ${getRequiredTickets(contentType)}チケットの消費';
      
      case ContentType.purchaseHistory:
        return '購入履歴の閲覧にはライトプラン以上への登録が必要です';
      
      case ContentType.premiumContent:
        return '限定コンテンツの閲覧にはプレミアムプランへの登録が必要です';
      
      case ContentType.activities:
        return 'アクティビティの閲覧にはスタンダードプラン以上への登録が必要です';
      
      default:
        return 'このコンテンツの閲覧には上位プランへの登録が必要です';
    }
  }
}

/// コンテンツタイプ列挙型
enum ContentType {
  basicProfile,
  youtubeVideos,
  purchaseHistory,
  premiumContent,
  activities,
}

/// ポイント・チケット管理サービス
class PointTicketService {
  // ユーザーのポイント残高（実際はSupabaseから取得）
  static int getUserPoints(String userId) {
    // ダミーデータ：実装時はSupabaseから取得
    return 50;
  }

  // ユーザーのチケット残高（実際はSupabaseから取得）
  static int getUserTickets(String userId) {
    // ダミーデータ：実装時はSupabaseから取得
    return 3;
  }

  // ポイント消費
  static Future<bool> consumePoints(String userId, int points) async {
    // 実装時はSupabaseでトランザクション処理
    final currentPoints = getUserPoints(userId);
    return currentPoints >= points;
  }

  // チケット消費
  static Future<bool> consumeTickets(String userId, int tickets) async {
    // 実装時はSupabaseでトランザクション処理
    final currentTickets = getUserTickets(userId);
    return currentTickets >= tickets;
  }
} 