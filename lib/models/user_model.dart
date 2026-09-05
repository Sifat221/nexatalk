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
    final emailVal = json['email'] as String? ?? '';
    final defaultName = emailVal.contains('@') ? emailVal.split('@').first : 'User';
    final nameVal = json['name'] ?? json['displayName'] ?? defaultName;
    final defaultUsername = emailVal.contains('@')
        ? emailVal.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase()
        : 'user';
    return UserModel(
      id: json['id'] as String? ?? '',
      name: nameVal as String,
      email: emailVal,
      username: json['username'] as String? ?? defaultUsername,
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
}
