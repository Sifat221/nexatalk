import 'dart:async';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'persistence_service.dart';

class ApiAuthService implements AuthService {
  final ApiClient apiClient;
  final PersistenceService persistence;
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  ApiAuthService({
    required this.apiClient,
    required this.persistence,
  }) {
    _currentUser = persistence.getSavedUser();
    Future.microtask(() {
      _authStateController.add(_currentUser);
    });
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> signIn(String email, String password) async {
    final response = await apiClient.post('/auth/login', body: {
      'email': email.trim(),
      'password': password,
    }, requiresAuth: false);

    final user = UserModel.fromJson(response['user']);
    final accessToken = response['accessToken'] as String;
    final refreshToken = response['refreshToken'] as String;

    await persistence.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await persistence.saveUser(user);

    _currentUser = user;
    _authStateController.add(_currentUser);
    return user;
  }

  @override
  Future<UserModel> signUp(String name, String email, String password) async {
    final username = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final response = await apiClient.post('/auth/register', body: {
      'displayName': name.trim(),
      'email': email.trim(),
      'username': username,
      'password': password,
    }, requiresAuth: false);

    final user = UserModel.fromJson(response['user']);
    final accessToken = response['accessToken'] as String;
    final refreshToken = response['refreshToken'] as String;

    await persistence.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await persistence.saveUser(user);

    _currentUser = user;
    _authStateController.add(_currentUser);
    return user;
  }

  @override
  Future<bool> verifyOtp(String code, {String? phoneNumber}) async {
    final phone = phoneNumber ?? _currentUser?.phone ?? '+15551002001';
    final response = await apiClient.post('/auth/phone/verify-otp', body: {
      'phoneNumber': phone,
      'otp': code.trim(),
    }, requiresAuth: false);

    if (response['verified'] == true) {
      if (response['user'] != null) {
        final user = UserModel.fromJson(response['user']);
        final accessToken = response['accessToken'] as String;
        final refreshToken = response['refreshToken'] as String;

        await persistence.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
        await persistence.saveUser(user);

        _currentUser = user;
        _authStateController.add(_currentUser);
      }
      return true;
    }
    return false;
  }

  Future<dynamic> sendPhoneOtp(String phoneNumber) async {
    return apiClient.post('/auth/phone/send-otp', body: {
      'phoneNumber': phoneNumber.trim(),
    }, requiresAuth: false);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await apiClient.post('/auth/forgot-password', body: {
      'email': email.trim(),
    }, requiresAuth: false);
  }

  Future<void> resetPassword(String email, String token, String newPassword) async {
    await apiClient.post('/auth/reset-password', body: {
      'email': email.trim(),
      'token': token.trim(),
      'newPassword': newPassword,
    }, requiresAuth: false);
  }

  Future<UserModel> demoLogin(String role) async {
    final response = await apiClient.post('/auth/demo-login', body: {
      'role': role,
    }, requiresAuth: false);

    final user = UserModel.fromJson(response['user']);
    final accessToken = response['accessToken'] as String;
    final refreshToken = response['refreshToken'] as String;

    await persistence.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await persistence.saveUser(user);

    _currentUser = user;
    _authStateController.add(_currentUser);
    return user;
  }

  Future<UserModel> googleSignIn(String idToken) async {
    final response = await apiClient.post('/auth/google', body: {
      'idToken': idToken,
    }, requiresAuth: false);

    final user = UserModel.fromJson(response['user']);
    final accessToken = response['accessToken'] as String;
    final refreshToken = response['refreshToken'] as String;

    await persistence.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await persistence.saveUser(user);

    _currentUser = user;
    _authStateController.add(_currentUser);
    return user;
  }

  @override
  Future<void> signOut() async {
    final refreshToken = persistence.getRefreshToken();
    try {
      if (refreshToken != null) {
        await apiClient.post('/auth/logout', body: {'refreshToken': refreshToken});
      }
    } catch (_) {}

    _currentUser = null;
    await persistence.clearSession();
    _authStateController.add(null);
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? bio,
    String? avatarColor,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['displayName'] = name;
    if (bio != null) body['bio'] = bio;
    if (phone != null) body['phone'] = phone;

    final response = await apiClient.patch('/users/me', body: body);

    final updated = UserModel.fromJson(response);
    _currentUser = updated;
    await persistence.saveUser(updated);
    _authStateController.add(_currentUser);
    return updated;
  }

  void dispose() {
    _authStateController.close();
  }
}
