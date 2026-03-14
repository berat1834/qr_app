import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

/// Doğrulama sonucunu temsil eden sınıf
class VerificationResult {
  final bool isValid;
  final String? errorMessage;
  final String? errorCode;

  VerificationResult({
    required this.isValid,
    this.errorMessage,
    this.errorCode,
  });

  factory VerificationResult.success() => VerificationResult(isValid: true);

  factory VerificationResult.failure({required String message, String? code}) =>
      VerificationResult(
        isValid: false,
        errorMessage: message,
        errorCode: code,
      );
}

class ReceiptVerificationService {
  static const String _backendBaseUrl = String.fromEnvironment(
    'RECEIPT_VERIFIER_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String _playPackageName = String.fromEnvironment(
    'PLAY_PACKAGE_NAME',
    defaultValue: 'com.qrscanner.professional',
  );

  static Future<VerificationResult> verifyPurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return await _verifyGooglePlay(purchaseDetails);
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return await _verifyAppStore(purchaseDetails);
      }

      return VerificationResult.failure(
        message: 'Desteklenmeyen platform',
        code: 'PLATFORM_NOT_SUPPORTED',
      );
    } on TimeoutException {
      return VerificationResult.failure(
        message:
            'Sunucuya erişim zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.',
        code: 'TIMEOUT',
      );
    } catch (e) {
      return VerificationResult.failure(
        message: 'Doğrulama sırasında bir hata oluştu: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  static Future<VerificationResult> _verifyGooglePlay(
    PurchaseDetails purchaseDetails,
  ) async {
    try {
      final payload = {
        'packageName': _playPackageName,
        'productId': purchaseDetails.productID,
        'purchaseToken':
            purchaseDetails.verificationData.serverVerificationData,
        'userId': null,
      };

      final response = await http
          .post(
            Uri.parse('$_backendBaseUrl/verify/google-play'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['ok'] == true) {
          return VerificationResult.success();
        }
        return VerificationResult.failure(
          message:
              data['error'] ??
              'Satın alma Google Play tarafından doğrulanamadı',
          code: 'GOOGLE_PLAY_INVALID',
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return VerificationResult.failure(
          message:
              'Doğrulama sunucusu ile iletişim kurulamadı (yetkilendirme).',
          code: 'VERIFICATION_SERVER_AUTH_ERROR',
        );
      } else {
        return VerificationResult.failure(
          message:
              'Doğrulama sunucusu görüntülenemiyor. Lütfen daha sonra tekrar deneyin.',
          code: 'VERIFICATION_SERVER_ERROR',
        );
      }
    } on TimeoutException {
      return VerificationResult.failure(
        message:
            'Sunucuya erişim zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.',
        code: 'TIMEOUT',
      );
    } catch (e) {
      return VerificationResult.failure(
        message: 'Doğrulama sırasında bir hata oluştu: $e',
        code: 'GOOGLE_PLAY_ERROR',
      );
    }
  }

  static Future<VerificationResult> _verifyAppStore(
    PurchaseDetails purchaseDetails,
  ) async {
    try {
      final payload = {
        'receiptData': purchaseDetails.verificationData.serverVerificationData,
        'productId': purchaseDetails.productID,
        'transactionId': purchaseDetails.purchaseID,
        'userId': null,
      };

      final response = await http
          .post(
            Uri.parse('$_backendBaseUrl/verify/app-store'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['ok'] == true) {
          return VerificationResult.success();
        }
        return VerificationResult.failure(
          message:
              data['error'] ?? 'Satın alma App Store tarafından doğrulanamadı',
          code: 'APP_STORE_INVALID',
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return VerificationResult.failure(
          message:
              'Doğrulama sunucusu ile iletişim kurulamadı (yetkilendirme).',
          code: 'VERIFICATION_SERVER_AUTH_ERROR',
        );
      } else {
        return VerificationResult.failure(
          message:
              'Doğrulama sunucusu görüntülenemiyor. Lütfen daha sonra tekrar deneyin.',
          code: 'VERIFICATION_SERVER_ERROR',
        );
      }
    } on TimeoutException {
      return VerificationResult.failure(
        message:
            'Sunucuya erişim zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.',
        code: 'TIMEOUT',
      );
    } catch (e) {
      return VerificationResult.failure(
        message: 'Doğrulama sırasında bir hata oluştu: $e',
        code: 'APP_STORE_ERROR',
      );
    }
  }
}
