import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 会員種別の定義
enum MembershipType {
  free('無料プラン', 0),
  light('ライトプラン', 980),
  standard('スタンダードプラン', 1980),
  premium('プレミアムプラン', 2980);

  const MembershipType(this.displayName, this.monthlyPrice);
  
  final String displayName;
  final int monthlyPrice;
}

/// 会員プランの詳細データ
class MembershipPlan {
  final MembershipType type;
  final String title;
  final String description;
  final List<String> features;
  final List<String> restrictions;
  final bool isPopular;

  const MembershipPlan({
    required this.type,
    required this.title,
    required this.description,
    required this.features,
    required this.restrictions,
    this.isPopular = false,
  });
}

/// 現在のユーザーの会員種別を管理するプロバイダー
class MembershipNotifier extends StateNotifier<MembershipType> {
  MembershipNotifier() : super(MembershipType.free);

  /// 会員プランを変更
  void changeMembership(MembershipType newType) {
    state = newType;
  }

  /// 特定の機能にアクセス可能かチェック
  bool canAccess(MembershipType requiredLevel) {
    return state.index >= requiredLevel.index;
  }

  /// 基本コンテンツにアクセス可能か
  bool get canAccessBasicContent => canAccess(MembershipType.light);

  /// プレミアムコンテンツにアクセス可能か
  bool get canAccessPremiumContent => canAccess(MembershipType.standard);

  /// ダウンロード機能が使用可能か
  bool get canDownload => canAccess(MembershipType.premium);

  /// 広告なし視聴が可能か
  bool get isAdFree => canAccess(MembershipType.light);
}

/// 会員種別プロバイダー
final membershipProvider = StateNotifierProvider<MembershipNotifier, MembershipType>((ref) {
  return MembershipNotifier();
});

/// 会員プラン一覧プロバイダー
final membershipPlansProvider = Provider<List<MembershipPlan>>((ref) {
  return [
    const MembershipPlan(
      type: MembershipType.free,
      title: '無料プラン',
      description: '基本機能をお試しいただけます',
      features: [
        '基本的なスター情報の閲覧',
        '限定的なデータ閲覧（月5回まで）',
        '基本的なフォロー機能',
        '広告付きコンテンツ',
      ],
      restrictions: [
        '詳細データは制限あり',
        '月間閲覧制限あり',
        '広告が表示されます',
        'ダウンロード機能なし',
      ],
    ),
    const MembershipPlan(
      type: MembershipType.light,
      title: 'ライトプラン',
      description: '気軽に楽しめるエントリープラン',
      features: [
        '全スターの基本データ閲覧',
        '月間50回まで詳細データ閲覧',
        '広告なし体験',
        'お気に入りリスト（30個まで）',
        'コメント機能',
      ],
      restrictions: [
        'プレミアムコンテンツは制限',
        'ダウンロード機能なし',
        '高画質動画なし',
      ],
      isPopular: true,
    ),
    const MembershipPlan(
      type: MembershipType.standard,
      title: 'スタンダードプラン',
      description: '充実した機能で楽しめる人気プラン',
      features: [
        '全機能無制限利用',
        'プレミアムコンテンツ閲覧',
        '高画質動画・画像',
        'お気に入りリスト無制限',
        'DM機能（基本）',
        '優先サポート',
      ],
      restrictions: [
        'ダウンロード機能なし',
        '限定イベントは一部制限',
      ],
    ),
    const MembershipPlan(
      type: MembershipType.premium,
      title: 'プレミアムプラン',
      description: '最上級の体験をお楽しみください',
      features: [
        '全機能完全無制限',
        'プレミアム限定コンテンツ',
        'データダウンロード機能',
        '4K高画質動画',
        'DM機能（無制限）',
        '限定イベント参加',
        '専用カスタマーサポート',
        '先行配信・情報',
      ],
      restrictions: [],
    ),
  ];
});

/// 現在の会員プラン詳細を取得するプロバイダー
final currentMembershipPlanProvider = Provider<MembershipPlan>((ref) {
  final currentType = ref.watch(membershipProvider);
  final plans = ref.watch(membershipPlansProvider);
  
  return plans.firstWhere((plan) => plan.type == currentType);
});

/// アクセス制御用のヘルパープロバイダー
final accessControlProvider = Provider<MembershipNotifier>((ref) {
  return ref.read(membershipProvider.notifier);
});