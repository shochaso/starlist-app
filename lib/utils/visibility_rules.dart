library visibility_rules;

import 'dart:math' as math;

const List<String> _tierOrder = ['free', 'light', 'standard', 'premium'];
const Set<String> _allowedCategories = {
  'youtube',
  'music',
  'shopping',
  'books',
  'apps',
  'food',
};

bool canViewPost({
  required String viewMode,
  required String category,
  required String fanTier,
  required String postVisibility,
}) {
  if (viewMode == 'star') return true;
  if (!_allowedCategories.contains(category)) return false;
  if (category == 'youtube') return true;

  final fanIndex = _tierOrder.indexOf(fanTier);
  final visibilityIndex = _tierOrder.indexOf(postVisibility);
  if (fanIndex == -1 || visibilityIndex == -1) {
    return false;
  }
  return fanIndex >= visibilityIndex;
}

int peekLimitFor({
  required int totalItems,
  required int flaggedVisible,
  int maxPercent = 20,
}) {
  if (totalItems <= 0 || flaggedVisible <= 0) {
    return 0;
  }
  final allowed = ((totalItems * maxPercent) / 100).ceil();
  final limited = math.min(allowed, flaggedVisible);
  return math.max(limited, 0);
}

bool canViewItem({
  required bool itemVisible,
  required bool canViewPostResult,
  required int totalVisibleItems,
  required int peekLimit,
}) {
  if (canViewPostResult) return true;
  if (!itemVisible || peekLimit <= 0) return false;
  return totalVisibleItems < peekLimit;
}
