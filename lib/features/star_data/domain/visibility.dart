enum StarDataVisibility {
  public,
  followers,
  private;

  String get displayLabel => switch (this) {
        StarDataVisibility.public => '公開',
        StarDataVisibility.followers => 'フォロワー限定',
        StarDataVisibility.private => '非公開',
      };

  static StarDataVisibility fromApi(String? value) {
    return switch (value) {
      'followers' => StarDataVisibility.followers,
      'private' => StarDataVisibility.private,
      _ => StarDataVisibility.public,
    };
  }
}
