import 'package:flutter/foundation.dart';

@immutable
class StarDataCategories {
  const StarDataCategories._();

  static const List<StarDataCategory?> filters = [
    null, // all
    StarDataCategory.youtube,
    StarDataCategory.shopping,
    StarDataCategory.music,
    StarDataCategory.food,
    StarDataCategory.anime,
    StarDataCategory.other,
  ];
}

enum StarDataCategory {
  youtube('YouTube'),
  shopping('ショッピング'),
  music('音楽'),
  food('フード'),
  anime('アニメ'),
  other('その他');

  const StarDataCategory(this.displayLabel);

  final String displayLabel;

  String get apiValue => switch (this) {
        StarDataCategory.youtube => 'youtube',
        StarDataCategory.shopping => 'shopping',
        StarDataCategory.music => 'music',
        StarDataCategory.food => 'food',
        StarDataCategory.anime => 'anime',
        StarDataCategory.other => 'other',
      };

  static StarDataCategory? maybeFrom(String? value) {
    if (value == null || value.isEmpty || value == 'all') {
      return null;
    }
    return StarDataCategory.values.firstWhere(
      (category) => category.apiValue == value,
      orElse: () => StarDataCategory.other,
    );
  }
}

extension StarDataCategoryDisplay on StarDataCategory? {
  String get label => this == null ? 'すべて' : this!.displayLabel;
}
