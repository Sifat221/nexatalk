import 'package:flutter/foundation.dart';
import '../models/app_settings_model.dart';
import '../services/persistence_service.dart';

/// State controller managing app settings, theme modes, haptics, and notifications.
class SettingsController extends ChangeNotifier {
  final PersistenceService _persistence;
  late AppSettingsModel _settings;

  SettingsController(this._persistence) {
    _settings = _persistence.getSavedSettings();
  }

  AppSettingsModel get settings => _settings;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get hapticsEnabled => _settings.hapticsEnabled;
  bool get soundEffectsEnabled => _settings.soundEffectsEnabled;
  bool get oledMode => _settings.oledMode;
  bool get readReceipts => _settings.readReceipts;
  String get language => _settings.language;
  String get chatWallpaper => _settings.chatWallpaper;

  Future<void> toggleNotifications(bool value) async {
    _settings = _settings.copyWith(notificationsEnabled: value);
    notifyListeners();
    await _persistence.saveSettings(_settings);
  }

  Future<void> toggleHaptics(bool value) async {
    _settings = _settings.copyWith(hapticsEnabled: value);
    notifyListeners();
    await _persistence.saveSettings(_settings);
  }

  Future<void> toggleSoundEffects(bool value) async {
    _settings = _settings.copyWith(soundEffectsEnabled: value);
    notifyListeners();
    await _persistence.saveSettings(_settings);
  }

  Future<void> toggleOledMode(bool value) async {
    _settings = _settings.copyWith(oledMode: value);
    notifyListeners();
    await _persistence.saveSettings(_settings);
  }

  Future<void> toggleReadReceipts(bool value) async {
    _settings = _settings.copyWith(readReceipts: value);
    notifyListeners();
    await _persistence.saveSettings(_settings);
  }

  Future<void> setLanguage(String lang) async {
    _settings = _settings.copyWith(language: lang);
    notifyListeners();
    await _persistence.saveSettings(_settings);
  }

  Future<void> setChatWallpaper(String wallpaper) async {
    _settings = _settings.copyWith(chatWallpaper: wallpaper);
    notifyListeners();
    await _persistence.saveSettings(_settings);
  }
}
