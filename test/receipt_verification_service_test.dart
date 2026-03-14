import 'package:flutter_test/flutter_test.dart';
import 'package:qr_app/services/receipt_verification_service.dart';

void main() {
  group('ReceiptVerificationService', () {
    group('VerificationResult', () {
      test('VerificationResult.success() creates valid result', () {
        // Arrange & Act
        final result = VerificationResult.success();

        // Assert
        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
        expect(result.errorCode, isNull);
      });

      test(
        'VerificationResult.failure() creates invalid result with error',
        () {
          // Arrange & Act
          final result = VerificationResult.failure(
            message: 'Test error',
            code: 'TEST_CODE',
          );

          // Assert
          expect(result.isValid, isFalse);
          expect(result.errorMessage, equals('Test error'));
          expect(result.errorCode, equals('TEST_CODE'));
        },
      );

      test('VerificationResult.failure() with only message', () {
        // Arrange & Act
        final result = VerificationResult.failure(message: 'Network timeout');

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errorMessage, equals('Network timeout'));
        expect(result.errorCode, isNull);
      });

      test('Valid result has no error information', () {
        // Arrange
        final result = VerificationResult.success();

        // Assert
        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
        expect(result.errorCode, isNull);
      });
    });

    group('Error codes', () {
      test('TIMEOUT error code is created correctly', () {
        // Arrange & Act
        final result = VerificationResult.failure(
          message: 'Timeout message',
          code: 'TIMEOUT',
        );

        // Assert
        expect(result.errorCode, equals('TIMEOUT'));
      });

      test('GOOGLE_PLAY_INVALID error code is created correctly', () {
        // Arrange & Act
        final result = VerificationResult.failure(
          message: 'Invalid purchase',
          code: 'GOOGLE_PLAY_INVALID',
        );

        // Assert
        expect(result.errorCode, equals('GOOGLE_PLAY_INVALID'));
      });

      test('APP_STORE_INVALID error code is created correctly', () {
        // Arrange & Act
        final result = VerificationResult.failure(
          message: 'Invalid receipt',
          code: 'APP_STORE_INVALID',
        );

        // Assert
        expect(result.errorCode, equals('APP_STORE_INVALID'));
      });
    });
  });
}
