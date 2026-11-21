import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'analytics_service.dart';
import 'receipt_verification_service.dart';

class PremiumPurchaseService {
  /// Sadece tek seferlik premium ürünü satılır.
  /// Abonelikler sunucu tarafında doğrulanamadığı için kaldırıldı.
  static const String premiumProductId = 'premium_upgrade';
  static const Set<String> _productIds = {premiumProductId};

  static InAppPurchase? _iap;

  static StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  static List<ProductDetails> _products = [];
  static bool _isStoreAvailable = false;
  static bool _initialized = false;
  static void Function(bool enabled)? _onEntitlementChanged;
  static void Function(Map<String, String>)? _onVerificationError;

  static bool get isStoreAvailable => _isStoreAvailable;
  static List<ProductDetails> get products => List.unmodifiable(_products);

  static Future<void> initialize({
    required void Function(bool enabled) onEntitlementChanged,
    void Function(Map<String, String>)? onVerificationError,
  }) async {
    _onEntitlementChanged = onEntitlementChanged;
    _onVerificationError = onVerificationError;

    if (_initialized) return;

    if (kIsWeb) {
      _isStoreAvailable = false;
      _initialized = true;
      return;
    }

    _iap = InAppPurchase.instance;
    _isStoreAvailable = await _iap!.isAvailable();
    if (!_isStoreAvailable) {
      _initialized = true;
      return;
    }

    _purchaseSubscription = _iap!.purchaseStream.listen(
      (purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onError: (Object error) {
        debugPrint('IAP stream error: $error');
      },
      onDone: () {
        _purchaseSubscription?.cancel();
      },
    );

    await _queryProducts();
    _initialized = true;
  }

  static Future<void> _queryProducts() async {
    if (_iap == null) return;

    final response = await _iap!.queryProductDetails(_productIds);
    if (response.error != null) {
      debugPrint('Product query error: ${response.error}');
      _products = [];
      return;
    }
    _products = response.productDetails;
  }

  static Future<bool> buyPremium() async {
    if (!_initialized || !_isStoreAvailable || _iap == null) return false;

    if (_products.isEmpty) {
      await _queryProducts();
    }

    final matches = _products.where((p) => p.id == premiumProductId);
    if (matches.isEmpty) return false;
    final product = matches.first;

    await AnalyticsService.logPurchaseStart(
      productId: product.id,
      productType: 'upgrade',
    );

    return _iap!.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  static Future<void> restorePurchases() async {
    if (!_initialized || !_isStoreAvailable || _iap == null) return;

    await AnalyticsService.logRestoreStart();
    await _iap!.restorePurchases();
  }

  static Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      // Varsayılan: işlem tamamlanabilir (hata/iptal durumları için).
      // Doğrulanmamış satın almalar ASLA onaylanmaz; böylece Google
      // onaylanmayan satın almayı 3 gün içinde otomatik iade eder ve
      // kullanıcı ücret ödeyip premium alamama durumuna düşmez.
      var shouldComplete = true;

      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final result = await ReceiptVerificationService.verifyPurchase(
            purchaseDetails,
          );
          if (result.isValid) {
            await AnalyticsService.logPurchaseSuccess(
              productId: purchaseDetails.productID,
              productType: 'upgrade',
            );
            _onEntitlementChanged?.call(true);
          } else {
            shouldComplete = false;
            await AnalyticsService.logPurchaseFailed(
              productId: purchaseDetails.productID,
              errorCode: result.errorCode ?? 'UNKNOWN',
              errorMessage: result.errorMessage ?? 'Bilinmeyen hata',
            );
            _onVerificationError?.call({
              'message': result.errorMessage ?? 'Bilinmeyen hata',
              'code': result.errorCode ?? 'UNKNOWN',
            });
          }
          break;
        case PurchaseStatus.pending:
          shouldComplete = false;
          break;
        case PurchaseStatus.error:
          await AnalyticsService.logPurchaseFailed(
            productId: purchaseDetails.productID,
            errorCode: 'PURCHASE_ERROR',
            errorMessage: purchaseDetails.error?.message ?? 'Bilinmeyen hata',
          );
          break;
        case PurchaseStatus.canceled:
          await AnalyticsService.logPurchaseCanceled(
            productId: purchaseDetails.productID,
          );
          break;
      }

      if (shouldComplete && purchaseDetails.pendingCompletePurchase) {
        await _iap?.completePurchase(purchaseDetails);
      }
    }
  }

  static Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _initialized = false;
  }
}
