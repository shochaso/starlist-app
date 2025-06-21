class PrivacySettings {
  final bool isProfilePublic;
  final bool showEmail;
  final bool showPhone;
  final bool showLocation;
  final bool allowFriendRequests;
  final bool allowMessages;
  final bool allowComments;
  final bool allowNotifications;
  final List<String> blockedUsers;
  final Map<String, dynamic> metadata;

  PrivacySettings({
    this.isProfilePublic = true,
    this.showEmail = false,
    this.showPhone = false,
    this.showLocation = false,
    this.allowFriendRequests = true,
    this.allowMessages = true,
    this.allowComments = true,
    this.allowNotifications = true,
    this.blockedUsers = const [],
    this.metadata = const {},
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      isProfilePublic: json["isProfilePublic"] as bool? ?? true,
      showEmail: json["showEmail"] as bool? ?? false,
      showPhone: json["showPhone"] as bool? ?? false,
      showLocation: json["showLocation"] as bool? ?? false,
      allowFriendRequests: json["allowFriendRequests"] as bool? ?? true,
      allowMessages: json["allowMessages"] as bool? ?? true,
      allowComments: json["allowComments"] as bool? ?? true,
      allowNotifications: json["allowNotifications"] as bool? ?? true,
      blockedUsers: List<String>.from(json["blockedUsers"] as List? ?? []),
      metadata: json["metadata"] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "isProfilePublic": isProfilePublic,
      "showEmail": showEmail,
      "showPhone": showPhone,
      "showLocation": showLocation,
      "allowFriendRequests": allowFriendRequests,
      "allowMessages": allowMessages,
      "allowComments": allowComments,
      "allowNotifications": allowNotifications,
      "blockedUsers": blockedUsers,
      "metadata": metadata,
    };
  }

  PrivacySettings copyWith({
    bool? isProfilePublic,
    bool? showEmail,
    bool? showPhone,
    bool? showLocation,
    bool? allowFriendRequests,
    bool? allowMessages,
    bool? allowComments,
    bool? allowNotifications,
    List<String>? blockedUsers,
    Map<String, dynamic>? metadata,
  }) {
    return PrivacySettings(
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      showEmail: showEmail ?? this.showEmail,
      showPhone: showPhone ?? this.showPhone,
      showLocation: showLocation ?? this.showLocation,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      allowMessages: allowMessages ?? this.allowMessages,
      allowComments: allowComments ?? this.allowComments,
      allowNotifications: allowNotifications ?? this.allowNotifications,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      metadata: metadata ?? this.metadata,
    );
  }
}
