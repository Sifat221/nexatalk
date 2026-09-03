import 'package:flutter_test/flutter_test.dart';
import 'package:nexatalk/controllers/auth_controller.dart';
import 'package:nexatalk/services/auth_service.dart';
import 'package:nexatalk/services/persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Service & Controller Unit Tests', () {
    late PersistenceService persistence;
    late AuthService authService;
    late AuthController authController;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      persistence = PersistenceService(prefs);
      authService = MockAuthService(persistence);
      authController = AuthController(authService);
    });

    tearDown(() {
      authController.dispose();
    });

    test('Initial state has no authenticated user', () {
      expect(authController.currentUser, isNull);
      expect(authController.isAuthenticated, false);
      expect(authController.isLoading, false);
    });

    test('Sign in succeeds and updates state and persistence', () async {
      final success = await authController.signIn('alex.morgan@nexatalk.app', 'password123');

      expect(success, true);
      expect(authController.isAuthenticated, true);
      expect(authController.currentUser?.email, 'alex.morgan@nexatalk.app');
      expect(authController.currentUser?.name, 'Alex Morgan');

      // Check persistence
      final saved = persistence.getSavedUser();
      expect(saved?.email, 'alex.morgan@nexatalk.app');
    });

    test('Sign out clears user from controller and persistence', () async {
      await authController.signIn('alex.morgan@nexatalk.app', 'password123');
      expect(authController.isAuthenticated, true);

      await authController.signOut();
      expect(authController.isAuthenticated, false);
      expect(authController.currentUser, isNull);
      expect(persistence.getSavedUser(), isNull);
    });

    test('Sign up and OTP verification completes registration', () async {
      final signUpSuccess = await authController.signUp('Sarah Jenkins', 'sarah@nexatalk.app', 'pass1234');
      expect(signUpSuccess, true);

      final verifySuccess = await authController.verifyOtp('123456');
      expect(verifySuccess, true);
      expect(authController.isAuthenticated, true);
      expect(authController.currentUser?.name, 'Sarah Jenkins');
    });

    test('Update profile alters name and bio', () async {
      await authController.signIn('alex@nexatalk.app', 'pass123');
      await authController.updateProfile(
        name: 'Alex M. Morgan',
        bio: 'Updated Bio Message',
      );

      expect(authController.currentUser?.name, 'Alex M. Morgan');
      expect(authController.currentUser?.bio, 'Updated Bio Message');
    });
  });
}
