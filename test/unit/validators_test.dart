import 'package:flutter_test/flutter_test.dart';
import 'package:nexatalk/core/utils/validators.dart';

void main() {
  group('Validators Test Suite', () {
    test('validateEmail correctly validates emails', () {
      expect(Validators.validateEmail(''), 'Please enter your email');
      expect(Validators.validateEmail(null), 'Please enter your email');
      expect(Validators.validateEmail('invalid-email'), 'Please enter a valid email address');
      expect(Validators.validateEmail('user@'), 'Please enter a valid email address');
      expect(Validators.validateEmail('alex@nexatalk.app'), isNull);
    });

    test('validatePassword correctly validates minimum length', () {
      expect(Validators.validatePassword(''), 'Please enter your password');
      expect(Validators.validatePassword(null), 'Please enter your password');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(Validators.validatePassword('secret123'), isNull);
    });

    test('validateName correctly checks minimum characters', () {
      expect(Validators.validateName(''), 'Please enter your name');
      expect(Validators.validateName(null), 'Please enter your name');
      expect(Validators.validateName('A'), 'Name must be at least 2 characters');
      expect(Validators.validateName('Alex Morgan'), isNull);
    });

    test('validateConfirmPassword checks match', () {
      expect(Validators.validateConfirmPassword('', 'secret'), 'Please confirm your password');
      expect(Validators.validateConfirmPassword('other', 'secret'), 'Passwords do not match');
      expect(Validators.validateConfirmPassword('secret', 'secret'), isNull);
    });

    test('validateOtp checks 6-digit number constraint', () {
      expect(Validators.validateOtp(''), 'Please enter the 6-digit OTP');
      expect(Validators.validateOtp('123'), 'Code must be 6 digits');
      expect(Validators.validateOtp('12345a'), 'Code must contain only digits');
      expect(Validators.validateOtp('123456'), isNull);
    });
  });
}
