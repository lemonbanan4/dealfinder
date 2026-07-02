import 'package:dealfinder_app/utils/validators.dart';
import 'package:test/test.dart';

void main() {
  group('Validators.validateEmail', () {
    test('returns error string for null value', () {
      expect(Validators.validateEmail(null), 'Email is required.');
    });

    test('returns error string for empty value', () {
      expect(Validators.validateEmail(''), 'Email is required.');
    });

    test('returns error string for invalid email format', () {
      expect(
        Validators.validateEmail('test'),
        'Please enter a valid email address.',
      );
      expect(
        Validators.validateEmail('test@'),
        'Please enter a valid email address.',
      );
      expect(
        Validators.validateEmail('test@domain'),
        'Please enter a valid email address.',
      );
      expect(
        Validators.validateEmail('@domain.com'),
        'Please enter a valid email address.',
      );
    });

    test('returns null for valid email', () {
      expect(Validators.validateEmail('test@domain.com'), isNull);
      expect(Validators.validateEmail('test.name@domain.co.uk'), isNull);
    });
  });

  group('Validators.validatePassword', () {
    test('returns error string for null value', () {
      expect(Validators.validatePassword(null), 'Password is required.');
    });

    test('returns error string for empty value', () {
      expect(Validators.validatePassword(''), 'Password is required.');
    });

    test('returns error string for password less than 6 characters', () {
      expect(
        Validators.validatePassword('12345'),
        'Password must be at least 6 characters long.',
      );
    });

    test('returns null for valid password (6 characters)', () {
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('returns null for valid password (more than 6 characters)', () {
      expect(Validators.validatePassword('password123'), isNull);
    });
  });
}
