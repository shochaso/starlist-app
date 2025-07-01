import 'dart:async';

import '../models/membership_model.dart';
import '../repositories/membership_repository.dart';
import '../../payment/services/payment_service.dart';
import '../../subscription/services/subscription_service.dart';
import '../../ticket/models/ticket_model.dart';
import '../../ticket/services/ticket_service.dart';

/// 会員制度サービスのインターフェース
abstract class MembershipService {
  /// 新しい会員登録を作成
  Future<Membership> createMembership({
    required String userId,
    required MembershipTier tier,
    required bool isYearlySubscription,
    required PackageType packageType,
    String? starId,
    List<String>? starIds,
    String? categoryId,
  });
  
  /// 会員プランをアップグレード
  Future<Membership> upgradeMembership({
    required String membershipId,
    required MembershipTier newTier,
  });
  
  /// 会員プランをダウングレード
  Future<Membership> downgradeMembership({
    required String membershipId,
    required MembershipTier newTier,
  });
  
  /// 会員プランの支払い期間を変更（月額/年額）
  Future<Membership> changeMembershipPeriod({
    required String membershipId,
    required bool isYearlySubscription,
  });
  
  /// パッケージタイプを変更
  Future<Membership> changePackageType({
    required String membershipId,
    required PackageType newPackageType,
    String? starId,
    List<String>? starIds,
    String? categoryId,
  });
  
  /// 会員情報を更新
  Future<Membership> updateMembership({
    required String membershipId,
    MembershipTier? tier,
    bool? isYearlySubscription,
    PackageType? packageType,
    String? starId,
    List<String>? starIds,
    String? categoryId,
  });
  
  /// 会員登録をキャンセル
  Future<void> cancelMembership(String membershipId);
  
  /// 会員登録を更新
  Future<Membership> renewMembership(String membershipId);
  
  /// 指定されたユーザーの会員情報を取得
  Future<Membership?> getUserMembership(String userId);
  
  /// 会員プランの価格を計算
  Future<double> calculateMembershipPrice({
    required MembershipTier tier,
    required bool isYearlySubscription,
    required PackageType packageType,
    String? starId,
    List<String>? starIds,
    String? categoryId,
  });
  
  /// 会員特典としてのシルバーチケットを付与
  Future<void> grantSilverTickets(String membershipId);
  
  /// 会員プランの詳細情報を取得
  MembershipPlan getMembershipPlanDetails(MembershipTier tier);
  
  /// 複数スター割引パッケージの割引率を計算
  double calculatePackageDiscountRate(PackageType packageType, int starCount);
  
  /// 会員プランの利用可能な特典を取得
  List<String> getMembershipBenefits(MembershipTier tier);
  
  /// 会員プランの比較情報を取得
  Map<String, dynamic> compareMembershipPlans();
}

/// 会員制度サービスの実装クラス
class MembershipServiceImpl implements MembershipService {
  final MembershipRepository _membershipRepository;
  final PaymentService _paymentService;
  final SubscriptionService _subscriptionService;
  final TicketService _ticketService;
  
  MembershipServiceImpl(
    this._membershipRepository,
    this._paymentService,
    this._subscriptionService,
    this._ticketService,
  );
  
  @override
  Future<Membership> createMembership({
    required String userId,
    required MembershipTier tier,
    required bool isYearlySubscription,
    required PackageType packageType,
    String? starId,
    List<String>? starIds,
    String? categoryId,
  }) async {
    // 既存の会員情報を確認
    final existingMembership = await _membershipRepository.getMembershipByUserId(userId);
    if (existingMembership != null) {
      throw Exception('User already has an active membership');
    }
    
    // 会員プランの詳細を取得
    final plan = getMembershipPlanDetails(tier);
    
    // 基本価格を取得（月額または年額）
    double basePrice = isYearlySubscription ? plan.yearlyPrice : plan.monthlyPrice;
    
    // スター数を計算
    int starCount = 0;
    if (packageType == PackageType.single) {
      starCount = 1;
    } else if (packageType == PackageType.bundle || packageType == PackageType.custom) {
      starCount = starIds?.length ?? 0;
    } else if (packageType == PackageType.category) {
      // カテゴリー内のスター数を取得する処理（実際のアプリケーションでは実装が必要）
      starCount = 5; // 仮の値
    }
    
    // パッケージ割引率を計算
    double packageDiscountRate = calculatePackageDiscountRate(packageType, starCount);
    
    // 実際の価格を計算（割引適用後）
    double actualPrice = basePrice * (1 - packageDiscountRate);
    
    // シルバーチケット特典の有無と数を設定
    bool hasSilverTicket = plan.includesSilverTicket;
    int silverTicketCount = plan.silverTicketCount;
    
    // 年間契約の場合、追加のシルバーチケットを付与
    if (isYearlySubscription && tier != MembershipTier.free) {
      silverTicketCount += 2; // 年間契約特典として追加のシルバーチケット
    }
    
    // 会員期間を設定
    final now = DateTime.now();
    final endDate = isYearlySubscription
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));
    
    // 会員情報を作成
    final membership = Membership(
      id: '', // リポジトリで生成される
      userId: userId,
      tier: tier,
      isYearlySubscription: isYearlySubscription,
      packageType: packageType,
      starId: starId,
      starIds: starIds,
      categoryId: categoryId,
      maxStarsInPackage: packageType == PackageType.custom ? 10 : null, // カスタムパッケージの場合は上限を設定
      basePrice: basePrice,
      actualPrice: actualPrice,
      discountRate: packageDiscountRate,
      hasSilverTicket: hasSilverTicket,
      silverTicketCount: silverTicketCount,
      startDate: now,
      endDate: endDate,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    
    // 会員情報を保存
    final createdMembership = await _membershipRepository.createMembership(membership);
    
    // 無料プラン以外の場合は支払い処理を実行
    if (tier != MembershipTier.free) {
      try {
        // サブスクリプションタイプを設定
        final subscriptionType = tier == MembershipTier.light
            ? SubscriptionType.light
            : tier == MembershipTier.standard
                ? SubscriptionType.standard
                : SubscriptionType.premium;
        
        // サブスクリプション期間を設定
        final subscriptionPeriod = isYearlySubscription
            ? SubscriptionPeriod.yearly
            : SubscriptionPeriod.monthly;
        
        // 支払い処理を実行
        await _paymentService.processSubscriptionPayment(
          userId: userId,
          starId: starId,
          starIds: starIds,
          type: subscriptionType,
          period: subscriptionPeriod,
          amount: actualPrice,
          paymentMethod: PaymentMethod.creditCard, // デフォルトの支払い方法
          paymentDetails: null,
        );
        
        // シルバーチケットを付与
        if (hasSilverTicket && silverTicketCount > 0) {
          await _grantInitialSilverTickets(userId, silverTicketCount);
        }
      } catch (e) {
        // 支払い処理に失敗した場合は会員情報を削除
        await _membershipRepository.deleteMembership(createdMembership.id);
        rethrow;
      }
    } else {
      // 無料プランの場合はブロンズチケットを付与
      await _grantInitialBronzeTickets(userId);
    }
    
    return createdMembership;
  }
  
  @override
  Future<Membership> upgradeMembership({
    required String membershipId,
    required MembershipTier newTier,
  }) async {
    // 現在の会員情報を取得
    final membership = await _membershipRepository.getMembershipById(membershipId);
    if (membership == null) {
      throw Exception('Membership not found');
    }
    
    // 現在の会員層が新しい会員層より上位の場合はエラー
    if (membership.tier.index >= newTier.index) {
      throw Exception('Cannot upgrade to a lower or same tier');
    }
    
    // 新しい会員プランの詳細を取得
    final newPlan = getMembershipPlanDetails(newTier);
    
    // 基本価格を更新
    double newBasePrice = membership.isYearlySubscription
        ? newPlan.yearlyPrice
        : newPlan.monthlyPrice;
    
    // パッケージ割引率を適用
    double newActualPrice = newBasePrice * (1 - membership.discountRate);
    
    // 日割り計算（実際のアプリケーションでは実装が必要）
    // 仮の実装では日割り計算は省略
    
    // 会員情報を更新
    final updatedMembership = membership.copyWith(
      tier: newTier,
      basePrice: newBasePrice,
      actualPrice: newActualPrice,
      hasSilverTicket: newPlan.includesSilverTicket,
      silverTicketCount: newPlan.silverTicketCount,
      updatedAt: DateTime.now(),
    );
    
    // 会員情報を保存
    final savedMembership = await _membershipRepository.updateMembership(updatedMembership);
    
    // 差額の支払い処理（実際のアプリケーションでは実装が必要）
    // 仮の実装では省略
    
    // 追加のシルバーチケットを付与
    if (newPlan.includesSilverTicket && newPlan.silverTicketCount > membership.silverTicketCount) {
      final additionalTickets = newPlan.silverTicketCount - membership.silverTicketCount;
      await _grantAdditionalSilverTickets(membership.userId, additionalTickets);
    }
    
    return savedMembership;
  }
  
  @override
  Future<Membership> downgradeMembership({
    required String membershipId,
    required MembershipTier newTier,
  }) async {
    // 現在の会員情報を取得
    final membership = await _membershipRepository.getMembershipById(membershipId);
    if (membership == null) {
      throw Exception('Membership not found');
    }
    
    // 現在の会員層が新しい会員層より下位の場合はエラー
    if (membership.tier.index <= newTier.index) {
      throw Exception('Cannot downgrade to a higher or same tier');
    }
    
    // 新しい会員プランの詳細を取得
    final newPlan = getMembershipPlanDetails(newTier);
    
    // 基本価格を更新
    double newBasePrice = membership.isYearlySubscription
        ? newPlan.yearlyPrice
        : newPlan.monthlyPrice;
    
    // パッケージ割引率を適用
    double newActualPrice = newBasePrice * (1 - membership.discountRate);
    
    // 会員情報を更新
    final updatedMembership = membership.copyWith(
      tier: newTier,
      basePrice: newBasePrice,
      actualPrice: newActualPrice,
      hasSilverTicket: newPlan.includesSilverTicket,
      silverTicketCount: newPlan.silverTicketCount,
      updatedAt: DateTime.now(),
    );
    
    // 会員情報を保存
    final savedMembership = await _membershipRepository.updateMembership(updatedMembership);
    
    // 次回の請求から新しい価格を適用（実際のアプリケーションでは実装が必要）
    // 仮の実装では省略
    
    return savedMembership;
  }
  
  @override
  Future<Membership> changeMembershipPeriod({
    required String membershipId,
    required bool isYearlySubscription,
  }) async {
    // 現在の会員情報を取得
    final membership = await _membershipRepository.getMembershipById(membershipId);
    if (membership == null) {
      throw Exception('Membership not found');
    }
    
    // 既に同じ支払い期間の場合はエラー
    if (membership.isYearlySubscription == isYearlySubscription) {
      throw Exception('Membership is already on the requested period');
    }
    
    // 会員プランの詳細を取得
    final plan = getMembershipPlanDetails(membership.tier);
    
    // 基本価格を更新
    double newBasePrice = isYearlySubscription ? plan.yearlyPrice : plan.monthlyPrice;
    
    // パッケージ割引率を適用
    double newActualPrice = newBasePrice * (1 - membership.discountRate);
    
    // 会員期間を更新
    final now = DateTime.now();
    final newEndDate = isYearlySubscription
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));
    
    // シルバーチケット数を更新
    int newSilverTicketCount = plan.silverTicketCount;
    if (isYearlySubscription && membership.tier != MembershipTier.free) {
      newSilverTicketCount += 2; // 年間契約特典として追加のシルバーチケット
    }
    
    // 会員情報を更新
    final updatedMembership = membership.copyWith(
      isYearlySubscription: isYearlySubscription,
      basePrice: newBasePrice,
      actualPrice: newActualPrice,
      silverTicketCount: newSilverTicketCount,
      startDate: now,
      endDate: newEndDate,
      updatedAt: now,
    );
    
    // 会員情報を保存
    final savedMembership = await _membershipRepository.updateMembership(updatedMembership);
    
    // 支払い処理の更新（実際のアプリケーションでは実装が必要）
    // 仮の実装では省略
    
    // 年間契約に変更した場合は追加のシルバーチケットを付与
    if (isYearlySubscription && membership.tier != MembershipTier.free) {
      await _grantAdditionalSilverTickets(membership.userId, 2);
    }
    
    return savedMembership;
  }
  
  @override
  Future<Membership> changePackageType({
    required String membershipId,
    required PackageType newPackageType,
    String? starId,
    List<String>? starIds,
    String? categoryId,
  }) async {
    // 現在の会員情報を取得
    final membership = await _membershipRepository.getMembershipById(membershipId);
    if (membership == null) {
      throw Exception('Membership not found');
    }
    
    // パッケージタイプに応じた必須パラメータを確認
    if (newPackageType == PackageType.single && starId == null) {
      throw Exception('Star ID is required for single package type');
    } else if ((newPackageType == PackageType.bundle || newPackageType == PackageType.custom) && 
               (starIds == null || starIds.isEmpty)) {
      throw Exception('Star IDs are required for bundle or custom package type');
    } else if (newPackageType == PackageType.category && categoryId == null) {
      throw Exception('Category ID is required for category package type');
    }
    
    // スター数を計算
    int starCount = 0;
    if (newPackageType == PackageType.single) {
      starCount = 1;
    } else if (newPackageType == PackageType.bundle || newPackageType == PackageType.custom) {
      starCount = starIds?.length ?? 0;
    } else if (newPackageType == PackageType.category) {
      // カテゴリー内のスター数を取得する処理（実際のアプリケーションでは実装が必要）
      starCount = 5; // 仮の値
    }
    
    // 新しいパッケージ割引率を計算
    double newDiscountRate = calculatePackageDiscountRate(newPackageType, starCount);
    
    // 実際の価格を再計算
    double newActualPrice = membership.basePrice * (1 - newDiscountRate);
    
    // 会員情報を更新
    final updatedMembership = membership.copyWith(
      packageType: newPackageType,
      starId: starId,
      starIds: starIds,
      categoryId: categoryId,
      maxStarsInPackage: newPackageType == PackageType.custom ? 10 : null,
      discountRate: newDiscountRate,
      actualPrice: newActualPrice,
      updatedAt: DateTime.now(),
    );
    
    // 会員情報を保存
    return await _membershipRepository.updateMembership(updatedMembership);
  }
  
  @override
  Future<Membership> updateMembership({
    required String membershipId,
    MembershipTier? tier,
    bool? isYearlySubscription,
    PackageType? packageType,
    String? starId,
    List<String>? starIds,
    String? categoryId,
  }) async {
    // 現在の会員情報を取得
    final membership = await _membershipRepository.getMembershipById(membershipId);
    if (membership == null) {
      throw Exception('Membership not found');
    }
    
    // 更新する値を設定
    final updatedTier = tier ?? membership.tier;
    final updatedIsYearly = isYearlySubscription ?? membership.isYearlySubscription;
    final updatedPackageType = packageType ?? membership.packageType;
    final updatedStarId = starId ?? membership.starId;
    final updatedStarIds = starIds ?? membership.starIds;
    final updatedCategoryId = categoryId ?? membership.categoryId;
    
    // 会員プランの詳細を取得
    final plan = getMembershipPlanDetails(updatedTier);
    
    // 基本価格を更新
    double newBasePrice = updatedIsYearly ? plan.yearlyPrice : plan.monthlyPrice;
    
    // スター数を計算
    int starCount = 0;
    if (updatedPackageType == PackageType.single) {
      starCount = 1;
    } else if (updatedPackageType == PackageType.bundle || updatedPackageType == PackageType.custom) {
      starCount = updatedStarIds?.length ?? 0;
    } else if (updatedPackageType == PackageType.category) {
      // カテゴリー内のスター数を取得する処理（実際のアプリケーションでは実装が必要）
      starCount = 5; // 仮の値
    }
    
    // パッケージ割引率を計算
    double newDiscountRate = calculatePackageDiscountRate(updatedPackageType, starCount);
    
    // 実際の価格を計算
    double newActualPrice = newBasePrice * (1 - newDiscountRate);
    
    // シルバーチケット特典の有無と数を設定
    bool newHasSilverTicket = plan.includesSilverTicket;
    int newSilverTicketCount = plan.silverTicketCount;
    
    // 年間契約の場合、追加のシルバーチケットを付与
    if (updatedIsYearly && updatedTier != MembershipTier.free) {
      newSilverTicketCount += 2; // 年間契約特典として追加のシルバーチケット
    }
    
    // 会員期間を更新（必要に応じて）
    DateTime newEndDate = membership.endDate;
    if (updatedIsYearly != membership.isYearlySubscription) {
      final now = DateTime.now();
      newEndDate = updatedIsYearly
          ? now.add(const Duration(days: 365))
          : now.add(const Duration(days: 30));
    }
    
    // 会員情報を更新
    final updatedMembership = membership<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>