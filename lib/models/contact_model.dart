/// Represents a contact / chat participant in NexaTalk.
class ContactModel {
  final String id;
  final String name;
  final String status;
  final String email;
  final String? phone;
  final String avatarGradientIndex; // 1, 2, 3, 4
  final bool isOnline;
  final DateTime lastSeen;
  final String roleOrTag;

  const ContactModel({
    required this.id,
    required this.name,
    required this.status,
    required this.email,
    this.phone,
    this.avatarGradientIndex = '1',
    this.isOnline = false,
    required this.lastSeen,
    this.roleOrTag = 'Contact',
  });

  ContactModel copyWith({
    String? id,
    String? name,
    String? status,
    String? email,
    String? phone,
    String? avatarGradientIndex,
    bool? isOnline,
    DateTime? lastSeen,
    String? roleOrTag,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarGradientIndex: avatarGradientIndex ?? this.avatarGradientIndex,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      roleOrTag: roleOrTag ?? this.roleOrTag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'email': email,
      'phone': phone,
      'avatarGradientIndex': avatarGradientIndex,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'roleOrTag': roleOrTag,
    };
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String? ?? 'c_0',
      name: json['name'] as String? ?? 'Contact',
      status: json['status'] as String? ?? 'Available',
      email: json['email'] as String? ?? 'contact@nexatalk.app',
      phone: json['phone'] as String?,
      avatarGradientIndex: json['avatarGradientIndex'] as String? ?? '1',
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.tryParse(json['lastSeen'] as String) ?? DateTime.now()
          : DateTime.now(),
      roleOrTag: json['roleOrTag'] as String? ?? 'Contact',
    );
  }

  /// Initial mock contacts matching reference collage screens
  static List<ContactModel> get mockContacts => [
        ContactModel(
          id: 'contact_alif',
          name: 'Alif Hasan',
          status: 'Hey! How are you?',
          email: 'alif.hasan@nexatalk.app',
          phone: '+880 1711-234567',
          avatarGradientIndex: '1',
          isOnline: true,
          lastSeen: DateTime.now(),
          roleOrTag: 'Active',
        ),
        ContactModel(
          id: 'contact_sadia',
          name: 'Sadia Islam',
          status: 'I am good, thanks!',
          email: 'sadia.islam@nexatalk.app',
          phone: '+880 1812-345678',
          avatarGradientIndex: '2',
          isOnline: true,
          lastSeen: DateTime.now(),
          roleOrTag: 'Active',
        ),
        ContactModel(
          id: 'contact_fahim',
          name: 'Fahim Ahmed',
          status: 'Check this out! :)',
          email: 'fahim.ahmed@nexatalk.app',
          phone: '+880 1913-456789',
          avatarGradientIndex: '3',
          isOnline: true,
          lastSeen: DateTime.now(),
          roleOrTag: 'Active',
        ),
        ContactModel(
          id: 'contact_tanzila',
          name: 'Tanzila Rahman',
          status: 'See you soon',
          email: 'tanzila.rahman@nexatalk.app',
          phone: '+880 1614-567890',
          avatarGradientIndex: '4',
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
          roleOrTag: 'Offline',
        ),
        ContactModel(
          id: 'contact_ashikur',
          name: 'Ashikur Rahman',
          status: 'Okay, no problem',
          email: 'ashikur.rahman@nexatalk.app',
          phone: '+880 1515-678901',
          avatarGradientIndex: '1',
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(days: 1)),
          roleOrTag: 'Offline',
        ),
        ContactModel(
          id: 'contact_mehedi',
          name: 'Mehedi Hasan',
          status: 'Thanks!',
          email: 'mehedi.hasan@nexatalk.app',
          phone: '+880 1716-789012',
          avatarGradientIndex: '2',
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(days: 2)),
          roleOrTag: 'Offline',
        ),
        ContactModel(
          id: 'contact_jannatul',
          name: 'Jannatul Ferdous',
          status: 'Available',
          email: 'jannatul.ferdous@nexatalk.app',
          phone: '+880 1817-890123',
          avatarGradientIndex: '3',
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(days: 3)),
          roleOrTag: 'Offline',
        ),
        ContactModel(
          id: 'contact_nusrat',
          name: 'Nusrat Jahan',
          status: 'Busy',
          email: 'nusrat.jahan@nexatalk.app',
          phone: '+880 1918-901234',
          avatarGradientIndex: '4',
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(days: 4)),
          roleOrTag: 'Offline',
        ),
      ];
}
