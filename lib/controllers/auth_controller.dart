import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';

/// State controller managing authentication lifecycle, provider sign-in, and UI feedback.
class AuthController extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  int _otpCountdown = 60;
  Timer? _otpTimer;
  StreamSubscription<UserModel?>? _authSubscription;

  AuthController(this._authService) {
    _currentUser = _authService.currentUser;
    _authSubscription = _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  int get otpCountdown => _otpCountdown;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signIn(email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final auth = _authService;
      if (auth is FirebaseAuthService) {
        final user = await auth.signInWithGoogle();
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Google Sign-In is unavailable in offline mock mode.');
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> appleSignIn() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final auth = _authService;
      if (auth is FirebaseAuthService) {
        final user = await auth.signInWithApple();
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Apple Sign-In is unavailable in offline mock mode.');
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }


  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(name, email, password);
      _isLoading = false;
      startOtpCountdown();
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  void startOtpCountdown() {
    _otpCountdown = 60;
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCountdown > 0) {
        _otpCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> sendPhoneOtp(
    String phoneNumber, {
    required Function(String) onCodeSent,
    Function(String)? onError,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final auth = _authService;
    if (auth is FirebaseAuthService) {
      await auth.sendPhoneOtp(
        phoneNumber,
        onCodeSent: (verificationId) {
          _isLoading = false;
          startOtpCountdown();
          notifyListeners();
          onCodeSent(verificationId);
        },
        onVerificationFailed: (e) {
          _isLoading = false;
          _errorMessage = _getFriendlyErrorMessage(e);
          notifyListeners();
          if (onError != null) onError(_errorMessage!);
        },
      );
    } else {
      _isLoading = false;
      startOtpCountdown();
      notifyListeners();
      onCodeSent('demo_verif_id');
    }
  }

  Future<bool> verifyOtp(String code, {String? phoneNumber}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.verifyOtp(code);
      if (success) {
        _currentUser = _authService.currentUser;
      }
      _isLoading = false;
      if (!success) {
        _errorMessage = 'Invalid verification code. Please try again.';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordReset(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? avatarColor,
    String? phone,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _authService.updateProfile(
        name: name,
        bio: bio,
        avatarColor: avatarColor,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      _currentUser = updated;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getFriendlyErrorMessage(e);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  String _getFriendlyErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user registered with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'The email address is improperly formatted.';
        case 'weak-password':
          return 'The password is too weak. Choose a stronger password.';
        case 'invalid-verification-code':
          return 'Invalid SMS code. Please check and re-enter.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check your credentials.';
        case 'operation-not-allowed':
          return 'This sign-in provider is not enabled in Firebase Console yet.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'network-request-failed':
          return 'Network connection error. Check your internet.';
        default:
          return error.message ?? 'Authentication error occurred.';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
