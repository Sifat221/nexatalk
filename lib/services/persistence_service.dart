import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings_model.dart';
import '../models/conversation_model.dart';
import '../models/user_model.dart';

/// Handles local persistence using SharedPreferences.
class PersistenceService {
  static const String _keyOnboardingComplete = 'nexatalk_onboarding_complete';
  static const String _keyAuthUser = 'nexatalk_auth_user';
  static const String _keySettings = 'nexatalk_settings';
  static const String _keyConversations = 'nexatalk_conversations';

  final SharedPreferences _prefs;

  PersistenceService(this._prefs);

  static Future<PersistenceService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PersistenceService(prefs);
  }

  // --- Onboarding ---
  bool isOnboardingComplete() {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_keyOnboardingComplete, complete);
  }

  // --- Auth User ---
  UserModel? getSavedUser() {
    final raw = _prefs.getString(_keyAuthUser);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel? user) async {
    if (user == null) {
      await _prefs.remove(_keyAuthUser);
    } else {
      await _prefs.setString(_keyAuthUser, jsonEncode(user.toJson()));
    }
  }

  // --- Settings ---
  AppSettingsModel getSavedSettings() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null) return const AppSettingsModel();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettingsModel.fromJson(json);
    } catch (_) {
      return const AppSettingsModel();
    }
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    await _prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  // --- Conversations Cache ---
  List<ConversationModel>? getSavedConversations() {
    final raw = _prefs.getString(_keyConversations);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final convs = list.map((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList();
      return convs.where((c) =>
        !c.participant.id.startsWith('contact_') &&
        c.participant.id != 'contact_maya' &&
        c.participant.name != 'Maya Chen' &&
        c.participant.email != 'maya.chen@nexatalk.app'
      ).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveConversations(List<ConversationModel> conversations) async {
    final clean = conversations.where((c) =>
      !c.participant.id.startsWith('contact_') &&
      c.participant.id != 'contact_maya' &&
      c.participant.name != 'Maya Chen' &&
      c.participant.email != 'maya.chen@nexatalk.app'
    ).toList();
    final raw = jsonEncode(clean.map((c) => c.toJson()).toList());
    await _prefs.setString(_keyConversations, raw);
  }

  static const String _keyAccessToken = 'nexatalk_access_token';
  static const String _keyRefreshToken = 'nexatalk_refresh_token';

  // --- Tokens ---
  String? getAccessToken() => _prefs.getString(_keyAccessToken);
  String? getRefreshToken() => _prefs.getString(_keyRefreshToken);

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _prefs.setString(_keyAccessToken, accessToken);
    await _prefs.setString(_keyRefreshToken, refreshToken);
  }

  Future<void> clearTokens() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
  }

  // --- Clear / Reset ---
  Future<void> clearSession() async {
    await _prefs.remove(_keyAuthUser);
    await _prefs.remove(_keyConversations);
    await clearTokens();
  }

  Future<void> cleanLegacyDemoState() async {
    final savedUser = getSavedUser();
    if (savedUser != null &&
        (savedUser.email == 'alex.morgan@nexatalk.app' ||
         savedUser.email == 'maya.chen@nexatalk.app' ||
         savedUser.id.startsWith('contact_') ||
         savedUser.name == 'Alex Morgan' ||
         savedUser.name == 'Maya Chen')) {
      await _prefs.remove(_keyAuthUser);
    }

    final raw = _prefs.getString(_keyConversations);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        final convs = list.map((e) => ConversationModel.fromJson(e as Map<String, dynamic>)).toList();
        final clean = convs.where((c) =>
          !c.participant.id.startsWith('contact_') &&
          c.participant.id != 'contact_maya' &&
          c.participant.name != 'Maya Chen' &&
          c.participant.email != 'maya.chen@nexatalk.app'
        ).toList();

        if (clean.isEmpty) {
          await _prefs.remove(_keyConversations);
        } else if (clean.length != convs.length) {
          await saveConversations(clean);
        }
      } catch (_) {
        await _prefs.remove(_keyConversations);
      }
    }
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
