enum UserType {
  star,
  fan,
}

class User {
  final String id;
  final String name;
  final String email;
  final UserType type;
  final String? profileImageUrl;
  final List<String>? platforms;
  final List<String>? genres;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.profileImageUrl,
    this.platforms,
    this.genres,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.${json['type']}',
      ),
      profileImageUrl: json['profileImageUrl'],
      platforms: json['platforms'] != null
          ? List<String>.from(json['platforms'])
          : null,
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type.toString().split('.').last,
      'profileImageUrl': profileImageUrl,
      'platforms': platforms,
      'genres': genres,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 