import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Paywall görüntüleme
  static Future<void> logPaywallOpen({required String screen}) async {
    await _analytics.logEvent(
      name: 'paywall_open',
      parameters: {'screen': screen},
    );
  }

  // Satın alma başlangıcı
  static Future<void> logPurchaseStart({
    required String productId,
    required String productType,
  }) async {
    await _analytics.logEvent(
      name: 'purchase_start',
      parameters: {
        'product_id': productId,
        'product_type': productType, // 'upgrade', 'monthly', 'yearly'
      },
    );
  }

  // Başarılı satın alma (backend verification sonrası)
  static Future<void> logPurchaseSuccess({
    required String productId,
    required String productType,
  }) async {
    await _analytics.logEvent(
      name: 'purchase_success',
      parameters: {'product_id': productId, 'product_type': productType},
    );
  }

  // Başarısız satın alma (doğrulama hatasını da log et)
  static Future<void> logPurchaseFailed({
    required String productId,
    required String errorCode,
    required String errorMessage,
  }) async {
    await _analytics.logEvent(
      name: 'purchase_failed',
      parameters: {
        'product_id': productId,
        'error_code': errorCode,
        'error_message': errorMessage,
      },
    );
  }

  // Satın alma iptal edildi
  static Future<void> logPurchaseCanceled({required String productId}) async {
    await _analytics.logEvent(
      name: 'purchase_canceled',
      parameters: {'product_id': productId},
    );
  }

  // Geri yükleme başlangıcı
  static Future<void> logRestoreStart() async {
    await _analytics.logEvent(name: 'restore_start');
  }

  // Başarılı geri yükleme
  static Future<void> logRestoreSuccess({required int restoreCount}) async {
    await _analytics.logEvent(
      name: 'restore_success',
      parameters: {'restore_count': restoreCount},
    );
  }

  // Başarısız geri yükleme
  static Future<void> logRestoreFailed({required String errorCode}) async {
    await _analytics.logEvent(
      name: 'restore_failed',
      parameters: {'error_code': errorCode},
    );
  }

  // Bulut senkronizasyon başlangıcı
  static Future<void> logSyncStart() async {
    await _analytics.logEvent(name: 'sync_start');
  }

  // Başarılı bulut senkronizasyon
  static Future<void> logSyncSuccess({required int itemCount}) async {
    await _analytics.logEvent(
      name: 'sync_success',
      parameters: {'item_count': itemCount},
    );
  }

  // Başarısız bulut senkronizasyon
  static Future<void> logSyncFailed({required String errorCode}) async {
    await _analytics.logEvent(
      name: 'sync_failed',
      parameters: {'error_code': errorCode},
    );
  }

  // Custom event - debug/tracking amaçlı
  static Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
