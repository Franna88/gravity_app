class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profileImageUrl;
  final int points;
  final List<String> rewardHistory;
  final List<String> activityHistory;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImageUrl,
    required this.points,
    required this.rewardHistory,
    required this.activityHistory,
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      points: json['points'] as int,
      rewardHistory: List<String>.from(json['rewardHistory'] ?? []),
      activityHistory: List<String>.from(json['activityHistory'] ?? []),
      createdAt: (json['createdAt'] != null)
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLoginAt: (json['lastLoginAt'] != null)
          ? DateTime.parse(json['lastLoginAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'points': points,
      'rewardHistory': rewardHistory,
      'activityHistory': activityHistory,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    int? points,
    List<String>? rewardHistory,
    List<String>? activityHistory,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      points: points ?? this.points,
      rewardHistory: rewardHistory ?? this.rewardHistory,
      activityHistory: activityHistory ?? this.activityHistory,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
} 