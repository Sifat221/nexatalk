/// Represents the authenticated current user.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String username;
  final String? phone;
  final String bio;
  final String avatarColor;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime lastActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.phone,
    this.bio = 'Connect simply. Chat naturally. ✨',
    this.avatarColor = '0xFF00E5D0',
    this.avatarUrl,
    this.isOnline = true,
    required this.lastActive,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    String? phone,
    String? bio,
    String? avatarColor,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarColor: avatarColor ?? this.avatarColor,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'bio': bio,
      'avatarColor': avatarColor,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastActive': lastActive.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final nameVal = json['name'] ?? json['displayName'] ?? 'Alex Morgan';
    return UserModel(
      id: json['id'] as String? ?? 'user_1',
      name: nameVal as String,
      email: json['email'] as String? ?? 'alex@nexatalk.com',
      username: json['username'] as String? ?? 'alex_morgan',
      phone: json['phone'] as String?,
      bio: json['bio'] as String? ?? 'Connect simply. Chat naturally. ✨',
      avatarColor: json['avatarColor'] as String? ?? '0xFF00E5D0',
      avatarUrl: json['avatarUrl'] as String?,
      isOnline: json['isOnline'] as bool? ?? true,
      lastActive: json['lastActive'] != null
          ? (DateTime.tryParse(json['lastActive'] as String) ?? DateTime.now())
          : (json['lastSeenAt'] != null
              ? (DateTime.tryParse(json['lastSeenAt'] as String) ?? DateTime.now())
              : DateTime.now()),
    );
  }

  /// Demo default user
  static UserModel get demoUser => UserModel(
        id: 'usr_me_001',
        name: 'Alex Morgan',
        email: 'alex.morgan@nexatalk.app',
        username: 'alex_morgan',
        phone: '+1 (555) 019-2834',
        bio: 'Designing the future of communication ✨',
        avatarColor: '0xFF00E5D0',
        isOnline: true,
        lastActive: DateTime.now(),
      );
}
