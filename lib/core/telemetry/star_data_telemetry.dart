import '../../features/star_data/domain/category.dart';

abstract class StarDataTelemetry {
  void recordView({
    required String username,
    required StarDataCategory? category,
  });

  void recordPaywallUnlock({required String username});

  void recordInteractionLike({required String username});

  void recordInteractionComment({required String username});
}

class NoopStarDataTelemetry implements StarDataTelemetry {
  const NoopStarDataTelemetry();

  @override
  void recordView({
    required String username,
    required StarDataCategory? category,
  }) {}

  @override
  void recordPaywallUnlock({required String username}) {}

  @override
  void recordInteractionLike({required String username}) {}

  @override
  void recordInteractionComment({required String username}) {}
}
