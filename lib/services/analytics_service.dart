import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  // Varsayılan olarak kapalıdır; prod/dev build'de dart-define ile açılabilir.
  static const bool _enabled = bool.fromEnvironment(
    'ENABLE_FIREBASE_ANALYTICS',
    defaultValue: false,
  );

  static FirebaseAnalytics? get _analytics {
    if (!_enabled || Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseAnalytics.instance;
  }

  static Future<void> _logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    final analytics = _analytics;
    if (analytics == null) {
      return;
    }

    await analytics.logEvent(name: name, parameters: parameters);
  }

  // Paywall görüntüleme
  static Future<void> logPaywallOpen({required String screen}) async {
    await _logEvent('paywall_open', parameters: {'screen': screen});
  }

  // Satın alma başlangıcı
  static Future<void> logPurchaseStart({
    required String productId,
    required String productType,
  }) async {
    await _logEvent(
      'purchase_start',
      parameters: {'product_id': productId, 'product_type': productType},
    );
  }

  // Başarılı satın alma (backend verification sonrası)
  static Future<void> logPurchaseSuccess({
    required String productId,
    required String productType,
  }) async {
    await _logEvent(
      'purchase_success',
      parameters: {'product_id': productId, 'product_type': productType},
    );
  }

  // Başarısız satın alma (doğrulama hatasını da log et)
  static Future<void> logPurchaseFailed({
    required String productId,
    required String errorCode,
    required String errorMessage,
  }) async {
    await _logEvent(
      'purchase_failed',
      parameters: {
        'product_id': productId,
        'error_code': errorCode,
        'error_message': errorMessage,
      },
    );
  }

  // Satın alma iptal edildi
  static Future<void> logPurchaseCanceled({required String productId}) async {
    await _logEvent('purchase_canceled', parameters: {'product_id': productId});
  }

  // Geri yükleme başlangıcı
  static Future<void> logRestoreStart() async {
    await _logEvent('restore_start');
  }

  // Başarılı geri yükleme
  static Future<void> logRestoreSuccess({required int restoreCount}) async {
    await _logEvent(
      'restore_success',
      parameters: {'restore_count': restoreCount},
    );
  }

  // Başarısız geri yükleme
  static Future<void> logRestoreFailed({required String errorCode}) async {
    await _logEvent('restore_failed', parameters: {'error_code': errorCode});
  }

  // Bulut senkronizasyon başlangıcı
  static Future<void> logSyncStart() async {
    await _logEvent('sync_start');
  }

  // Başarılı bulut senkronizasyon
  static Future<void> logSyncSuccess({required int itemCount}) async {
    await _logEvent('sync_success', parameters: {'item_count': itemCount});
  }

  // Başarısız bulut senkronizasyon
  static Future<void> logSyncFailed({required String errorCode}) async {
    await _logEvent('sync_failed', parameters: {'error_code': errorCode});
  }

  // Custom event - debug/tracking amaçlı
  static Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _logEvent(name, parameters: parameters);
  }
}
