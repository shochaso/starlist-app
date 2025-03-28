import 'package:flutter/foundation.dart';

/// 会員プランの種類を表す列挙型
enum MembershipTier {
  free,       // 無料ユーザー
  light,      // ライトプラン
  standard,   // スタンダードプラン
  premium,    // プレミアムプラン
}

/// パッケージタイプを表す列挙型
enum PackageType {
  single,     // 単一スター
  bundle,     // バンドル（複数スター固定セット）
  category,   // カテゴリー別（同カテゴリーの複数スター）
  custom,     // カスタム（ユーザー選択の複数スター）
}

/// 会員制度モデル
class Membership {
  final String id;
  final String userId;
  final MembershipTier tier;
  final bool isYearlySubscription;
  final PackageType packageType;
  final String? starId;              // 単一スターの場合
  final List<String>? starIds;       // 複数スターの場合
  final String? categoryId;          // カテゴリー別パッケージの場合
  final int? maxStarsInPackage;      // パッケージに含められる最大スター数
  final double basePrice;            // 基本価格
  final double actualPrice;          // 割引適用後の実際の価格
  final double discountRate;         // 割引率
  final bool hasSilverTicket;        // シルバーチケット特典の有無
  final int silverTicketCount;       // 付与されるシルバーチケット数
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Membership({
    required this.id,
    required this.userId,
    required this.tier,
    required this.isYearlySubscription,
    required this.packageType,
    this.starId,
    this.starIds,
    this.categoryId,
    this.maxStarsInPackage,
    required this.basePrice,
    required this.actualPrice,
    required this.discountRate,
    required this.hasSilverTicket,
    required this.silverTicketCount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
          (packageType == PackageType.single && starId != null) ||
          (packageType == PackageType.bundle && starIds != null) ||
          (packageType == PackageType.category && categoryId != null) ||
          (packageType == PackageType.custom && starIds != null),
          'Invalid package configuration'
        );

  /// JSONからMembershipオブジェクトを作成するファクトリメソッド
  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tier: MembershipTier.values.firstWhere(
        (e) => e.toString() == 'MembershipTier.${json['tier']}',
        orElse: () => MembershipTier.free,
      ),
      isYearlySubscription: json['isYearlySubscription'] as bool,
      packageType: PackageType.values.firstWhere(
        (e) => e.toString() == 'PackageType.${json['packageType']}',
        orElse: () => PackageType.single,
      ),
      starId: json['starId'] as String?,
      starIds: json['starIds'] != null 
          ? List<String>.from(json['starIds'] as List)
          : null,
      categoryId: json['categoryId'] as String?,
      maxStarsInPackage: json['maxStarsInPackage'] as int?,
      basePrice: (json['basePrice'] as num).toDouble(),
      actualPrice: (json['actualPrice'] as num).toDouble(),
      discountRate: (json['discountRate'] as num).toDouble(),
      hasSilverTicket: json['hasSilverTicket'] as bool,
      silverTicketCount: json['silverTicketCount'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// MembershipオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tier': tier.toString().split('.').last,
      'isYearlySubscription': isYearlySubscription,
      'packageType': packageType.toString().split('.').last,
      'starId': starId,
      'starIds': starIds,
      'categoryId': categoryId,
      'maxStarsInPackage': maxStarsInPackage,
      'basePrice': basePrice,
      'actualPrice': actualPrice,
      'discountRate': discountRate,
      'hasSilverTicket': hasSilverTicket,
      'silverTicketCount': silverTicketCount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// コピーメソッド
  Membership copyWith({
    String? id,
    String? userId,
    MembershipTier? tier,
    bool? isYearlySubscription,
    PackageType? packageType,
    String? starId,
    List<String>? starIds,
    String? categoryId,
    int? maxStarsInPackage,
    double? basePrice,
    double? actualPrice,
    double? discountRate,
    bool? hasSilverTicket,
    int? silverTicketCount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Membership(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      isYearlySubscription: isYearlySubscription ?? this.isYearlySubscription,
      packageType: packageType ?? this.packageType,
      starId: starId ?? this.starId,
      starIds: starIds ?? this.starIds,
      categoryId: categoryId ?? this.categoryId,
      maxStarsInPackage: maxStarsInPackage ?? this.maxStarsInPackage,
      basePrice: basePrice ?? this.basePrice,
      actualPrice: actualPrice ?? this.actualPrice,
      discountRate: discountRate ?? this.discountRate,
      hasSilverTicket: hasSilverTicket ?? this.hasSilverTicket,
      silverTicketCount: silverTicketCount ?? this.silverTicketCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Membership &&
      other.id == id &&
      other.userId == userId &&
      other.tier == tier &&
      other.isYearlySubscription == isYearlySubscription &&
      other.packageType == packageType &&
      other.starId == starId &&
      listEquals(other.starIds, starIds) &&
      other.categoryId == categoryId &&
      other.maxStarsInPackage == maxStarsInPackage &&
      other.basePrice == basePrice &&
      other.actualPrice == actualPrice &&
      other.discountRate == discountRate &&
      other.hasSilverTicket == hasSilverTicket &&
      other.silverTicketCount == silverTicketCount &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.isActive == isActive &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      tier.hashCode ^
      isYearlySubscription.hashCode ^
      packageType.hashCode ^
      starId.hashCode ^
      starIds.hashCode ^
      categoryId.hashCode ^
      maxStarsInPackage.hashCode ^
      basePrice.hashCode ^
      actualPrice.hashCode ^
      discountRate.hashCode ^
      hasSilverTicket.hashCode ^
      silverTicketCount.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}

/// 会員プランの詳細情報を表すクラス
class MembershipPlan {
  final MembershipTier tier;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final bool includesSilverTicket;
  final int silverTicketCount;
  
  const MembershipPlan({
    required this.tier,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.includesSilverTicket,
    required this.silverTicketCount,
  });
  
  /// 事前定義された会員プラン
  static const MembershipPlan free = MembershipPlan(
    tier: MembershipTier.free,
    name: '無料プラン',
    description: '基本的な機能を利用できる無料プラン',
    monthlyPrice: 0,
    yearlyPrice: 0,
    features: [
      '基本的なコンテンツの閲覧',
      '毎日1枚のブロンズチケット',
      '限定コンテンツの一部閲覧（広告あり）',
    ],
    includesSilverTicket: false,
    silverTicketCount: 0,
  );
  
  static const MembershipPlan light = MembershipPlan(
    tier: MembershipTier.light,
    name: 'ライトプラン',
    description: 'お手頃価格で基本的な特典を利用できるプラン',
    monthlyPrice: 500,
    yearlyPrice: 5100, // 15%割引
    features: [
      '無料プランのすべての機能',
      '限定コンテンツの閲覧（広告あり）',
      '毎月3枚のシルバーチケット',
    ],
    includesSilverTicket: true,
    silverTicketCount: 3,
  );
  
  static const MembershipPlan standard = MembershipPlan(
    tier: MembershipTier.standard,
    name: 'スタンダードプラン',
    description: '人気の標準プラン、多くの特典を利用可能',
    monthlyPrice: 1000,
    yearlyPrice: 10200, // 15%割引
    features: [
      'ライトプランのすべての機能',
      'すべての限定コンテンツの閲覧（広告なし）',
      '毎月5枚のシルバーチケット',
      'コメント機能の利用',
    ],
    includesSilverTicket: true,
    silverTicketCount: 5,
  );
  
  static const MembershipPlan premium = MembershipPlan(
    tier: MembershipTier.premium,
    name: 'プレミアムプラン',
    description: '最上位プラン、すべての特典を利用可能',
    monthlyPrice: 2000,
    yearlyPrice: 20400, // 15%割引
    features: [
      'スタンダードプランのすべての機能',
      'プレミアム限定コンテンツの閲覧',
      '毎月10枚のシルバーチケット',
      'スターとの優先コミュニケーション',
      'プレミアムバッジの表示',
    ],
    includesSilverTicket: true,
    silverTicketCount: 10,
  );
  
  /// 会員プランのリスト
  static const List<MembershipPlan> plans = [
    free,
    light,
    standard,
    premium,
  ];
  
  /// 指定された会員層のプランを取得
  static MembershipPlan getPlan(MembershipTier tier) {
    return plans.firstWhere(
      (plan) => plan.tier == tier,
      orElse: () => free,
    );
  }
}

/// 複数スター割引パッケージの詳細情報を表すクラス
class PackageDiscount {
  final PackageType type;
  final int minStars;
  final int maxStars;
  final double discountRate;
  
  const PackageDiscount({
    required this.type,
    required this.minStars,
    required this.maxStars,
    required this.discountRate,
  });
  
  /// 事前定義された割引パッケージ
  static const List<PackageDiscount> discounts = [
    // バンドルパッケージの割引
    PackageDiscount(
      type: PackageType.bundle,
      minStars: 2,
      maxStars: 3,
      discountRate: 0.10, // 10%割引
    ),
    PackageDiscount(
      type: PackageType.bundle,
      minStars: 4,
      maxStars: 5,
      discountRate: 0.15, // 15%割引
    ),
    PackageDiscount(
      type: PackageType.bundle,
      minStars: 6,
      maxStars: 10,
      discountRate: 0.20, // 20%割引
    ),
    
    // カテゴリー別パッケージの割引
    PackageDiscount(
      type: PackageType.category,
      minStars: 2,
      maxStars: 5,
      discountRate: 0.15, // 15%割引
    ),
    PackageDiscount(
      type: PackageType.category,
      minStars: 6,
      maxStars: 10,
      discountRate: 0.25, // 25%割引
    ),
    
    // カスタムパッケージの割引
    PackageDiscount(
      type: PackageType.custom,
      minStars: 2,
      maxStars: 3,
      discountRate: 0.05, // 5%割引
    ),
    PackageDiscount(
      type: PackageType.custom,
      minStars: 4,
      maxStars: 6,
      discountRate: 0.10, // 10%割引
    ),
    PackageDiscount(
      type: PackageType.custom,
      minStars: 7,
      maxStars: 10,
      discountRate: 0.15, // 15%割引
    ),
  ];
  
  /// 指定されたパッケージタイプとスター数に基づいて割引率を計算
  static double calculateDiscountRate(PackageType type, int starCount) {
    if (type == PackageType.single || starCount <= 1) {
      return 0.0; // 単一スターの場合は割引なし
    }
    
    // 該当する割引を検索
    for (final discount in discounts) {
      if (discount.type == type && 
          starCount >= discount.minStars && 
          starCount <= discount.maxStars) {
        return discount.discountRate;
      }
    }
    
    // 該当する割引がない場合
    return 0.0;
  }
}
