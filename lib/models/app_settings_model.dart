/// User application preferences and settings.
class AppSettingsModel {
  final bool notificationsEnabled;
  final bool hapticsEnabled;
  final bool soundEffectsEnabled;
  final bool oledMode;
  final bool readReceipts;
  final String language;
  final String chatWallpaper; // 'midnight', 'cyber_cyan', 'deep_space'

  const AppSettingsModel({
    this.notificationsEnabled = true,
    this.hapticsEnabled = true,
    this.soundEffectsEnabled = true,
    this.oledMode = false,
    this.readReceipts = true,
    this.language = 'English (US)',
    this.chatWallpaper = 'midnight',
  });

  AppSettingsModel copyWith({
    bool? notificationsEnabled,
    bool? hapticsEnabled,
    bool? soundEffectsEnabled,
    bool? oledMode,
    bool? readReceipts,
    String? language,
    String? chatWallpaper,
  }) {
    return AppSettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      oledMode: oledMode ?? this.oledMode,
      readReceipts: readReceipts ?? this.readReceipts,
      language: language ?? this.language,
      chatWallpaper: chatWallpaper ?? this.chatWallpaper,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'hapticsEnabled': hapticsEnabled,
      'soundEffectsEnabled': soundEffectsEnabled,
      'oledMode': oledMode,
      'readReceipts': readReceipts,
      'language': language,
      'chatWallpaper': chatWallpaper,
    };
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      soundEffectsEnabled: json['soundEffectsEnabled'] as bool? ?? true,
      oledMode: json['oledMode'] as bool? ?? false,
      readReceipts: json['readReceipts'] as bool? ?? true,
      language: json['language'] as String? ?? 'English (US)',
      chatWallpaper: json['chatWallpaper'] as String? ?? 'midnight',
    );
  }
}
