import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/star_activity.dart';
import '../repositories/star_activity_repository.dart';

/// スターのアクティビティを提供するプロバイダー
final starActivitiesProvider = FutureProvider.family<List<StarActivity>, String>((ref, starId) async {
  final repository = ref.read(starActivityRepositoryProvider);
  return repository.getActivitiesByStarId(starId);
});

/// スターアクティビティのリポジトリ
final starActivityRepositoryProvider = Provider<StarActivityRepository>((ref) {
  return StarActivityRepository();
});

/// スターのアクティビティをタイプごとに提供するプロバイダー
final starActivitiesByTypeProvider = FutureProvider.family<List<StarActivity>, StarActivityFilter>((ref, filter) async {
  final repository = ref.read(starActivityRepositoryProvider);
  final activities = await repository.getActivitiesByStarId(filter.starId);
  
  if (filter.type != null) {
    return activities.where((activity) => activity.type == filter.type).toList();
  }
  
  return activities;
});

/// スターのアクティビティフィルター
class StarActivityFilter {
  /// スターのID
  final String starId;
  
  /// アクティビティタイプ（フィルターしない場合はnull）
  final ActivityType? type;

  StarActivityFilter({
    required this.starId,
    this.type,
  });
} 