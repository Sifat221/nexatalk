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

  /// Initial mock contacts
  static List<ContactModel> get mockContacts => [
        ContactModel(
          id: 'contact_maya',
          name: 'Maya Chen',
          status: 'Product Designer at DesignCo 🎨',
          email: 'maya.chen@nexatalk.app',
          phone: '+1 (555) 234-5678',
          avatarGradientIndex: '1',
          isOnline: true,
          lastSeen: DateTime.now(),
          roleOrTag: 'Product Team',
        ),
        ContactModel(
          id: 'contact_ryan',
          name: 'Ryan Lee',
          status: 'Coffee & Code ☕💻',
          email: 'ryan.lee@nexatalk.app',
          phone: '+1 (555) 345-6789',
          avatarGradientIndex: '2',
          isOnline: true,
          lastSeen: DateTime.now(),
          roleOrTag: 'Engineering',
        ),
        ContactModel(
          id: 'contact_sophia',
          name: 'Sophia Reed',
          status: 'Focusing on the next sprint 🚀',
          email: 'sophia.reed@nexatalk.app',
          phone: '+1 (555) 456-7890',
          avatarGradientIndex: '3',
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(minutes: 18)),
          roleOrTag: 'Mobile Lead',
        ),
        ContactModel(
          id: 'contact_noah',
          name: 'Noah Carter',
          status: 'In a meeting until 3 PM 📅',
          email: 'noah.carter@nexatalk.app',
          phone: '+1 (555) 567-8901',
          avatarGradientIndex: '4',
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
          roleOrTag: 'Architecture',
        ),
        ContactModel(
          id: 'contact_ethan',
          name: 'Ethan Cole',
          status: 'Exploring UI/UX interactions ✨',
          email: 'ethan.cole@nexatalk.app',
          phone: '+1 (555) 678-9012',
          avatarGradientIndex: '1',
          isOnline: true,
          lastSeen: DateTime.now(),
          roleOrTag: 'UI Design',
        ),
        ContactModel(
          id: 'contact_olivia',
          name: 'Olivia Park',
          status: 'Connecting simply & chatting naturally 💬',
          email: 'olivia.park@nexatalk.app',
          phone: '+1 (555) 789-0123',
          avatarGradientIndex: '2',
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(hours: 3)),
          roleOrTag: 'Operations',
        ),
        ContactModel(
          id: 'contact_emma',
          name: 'Emma Wilson',
          status: 'Working on brand systems 📐',
          email: 'emma.wilson@nexatalk.app',
          phone: '+1 (555) 890-1234',
          avatarGradientIndex: '3',
          isOnline: true,
          lastSeen: DateTime.now(),
          roleOrTag: 'Brand Design',
        ),
        ContactModel(
          id: 'contact_daniel',
          name: 'Daniel Kim',
          status: 'Building fast Flutter apps ⚡',
          email: 'daniel.kim@nexatalk.app',
          phone: '+1 (555) 901-2345',
          avatarGradientIndex: '4',
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(days: 1)),
          roleOrTag: 'Full Stack',
        ),
        ContactModel(
          id: 'contact_ava',
          name: 'Ava Brooks',
          status: 'Available for quick catch-ups! 🌟',
          email: 'ava.brooks@nexatalk.app',
          phone: '+1 (555) 012-3456',
          avatarGradientIndex: '1',
          isOnline: false,
          lastSeen: DateTime.now().subtract(const Duration(days: 2)),
          roleOrTag: 'Marketing',
        ),
      ];
}
