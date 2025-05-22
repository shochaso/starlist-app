class UserAuthModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime createdAt;

  UserAuthModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    required this.createdAt,
  });

  factory UserAuthModel.fromJson(Map<String, dynamic> json) {
    return UserAuthModel(
      id: json["id"] as String,
      email: json["email"] as String,
      displayName: json["displayName"] as String?,
      photoUrl: json["photoUrl"] as String?,
      isEmailVerified: json["isEmailVerified"] as bool? ?? false,
      createdAt: DateTime.parse(json["createdAt"] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "displayName": displayName,
      "photoUrl": photoUrl,
      "isEmailVerified": isEmailVerified,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
