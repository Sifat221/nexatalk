import 'dart:async';
import '../models/user_model.dart';
import 'persistence_service.dart';

/// Abstract Authentication Service contract.
/// This interface decouples the UI and controllers from any specific authentication backend,
/// allowing seamless future integration with Firebase Authentication.
abstract class AuthService {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;

  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String name, String email, String password);
  Future<bool> verifyOtp(String code);
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  Future<UserModel> updateProfile({
    String? name,
    String? bio,
    String? avatarColor,
    String? phone,
    String? avatarUrl,
  });
}

/// Mock implementation of AuthService with realistic latency and persistence.
class MockAuthService implements AuthService {
  final PersistenceService _persistence;
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;
  String? _pendingSignUpEmail;
  String? _pendingSignUpName;

  MockAuthService(this._persistence) {
    _currentUser = _persistence.getSavedUser();
    // Emit initial cached state after a frame
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
    await Future.delayed(const Duration(milliseconds: 600));

    // Support any valid format email in demo mode
    final user = UserModel(
      id: 'usr_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      name: _guessNameFromEmail(email),
      email: email.trim(),
      username: email.split('@').first.toLowerCase(),
      phone: '+1 (555) 019-2834',
      bio: 'Connect simply. Chat naturally. ✨',
      avatarColor: '0xFF00E5D0',
      isOnline: true,
      lastActive: DateTime.now(),
    );

    _currentUser = user;
    await _persistence.saveUser(user);
    _authStateController.add(_currentUser);
    return user;
  }

  @override
  Future<UserModel> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _pendingSignUpName = name.trim();
    _pendingSignUpEmail = email.trim();

    // In a real OTP flow, user is created after OTP verification
    final user = UserModel(
      id: 'usr_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      name: name.trim(),
      email: email.trim(),
      username: name.toLowerCase().replaceAll(' ', '_'),
      phone: '+1 (555) 019-2834',
      bio: 'New NexaTalk Explorer ✨',
      avatarColor: '0xFF00E5D0',
      isOnline: true,
      lastActive: DateTime.now(),
    );

    return user;
  }

  @override
  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (code.length == 6) {
      final email = _pendingSignUpEmail ?? 'alex.morgan@nexatalk.app';
      final name = _pendingSignUpName ?? 'Alex Morgan';

      final user = UserModel(
        id: 'usr_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
        name: name,
        email: email,
        username: name.toLowerCase().replaceAll(' ', '_'),
        phone: '+1 (555) 019-2834',
        bio: 'Connecting simply & chatting naturally 🚀',
        avatarColor: '0xFF00E5D0',
        isOnline: true,
        lastActive: DateTime.now(),
      );

      _currentUser = user;
      await _persistence.saveUser(user);
      _authStateController.add(_currentUser);
      return true;
    }
    return false;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Simulation succeeded
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    await _persistence.saveUser(null);
    _authStateController.add(null);
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? bio,
    String? avatarColor,
    String? phone,
    String? avatarUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentUser == null) {
      throw Exception('No user is currently signed in');
    }

    final updated = _currentUser!.copyWith(
      name: name,
      bio: bio,
      avatarColor: avatarColor,
      phone: phone,
      avatarUrl: avatarUrl,
    );

    _currentUser = updated;
    await _persistence.saveUser(updated);
    _authStateController.add(_currentUser);
    return updated;
  }

  String _guessNameFromEmail(String email) {
    if (email.contains('alex')) return 'Alex Morgan';
    if (email.contains('maya')) return 'Maya Chen';
    if (email.contains('ryan')) return 'Ryan Lee';
    final raw = email.split('@').first;
    final parts = raw.split(RegExp(r'[._-]'));
    return parts.map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join(' ');
  }

  void dispose() {
    _authStateController.close();
  }
}
