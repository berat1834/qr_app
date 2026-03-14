import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'analytics_service.dart';
import 'receipt_verification_service.dart';

class PremiumPurchaseService {
  static const Set<String> _productIds = {
    'premium_upgrade',
    'premium_monthly',
    'premium_yearly',
  };

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

    // Web platformunda in-app purchase çalışmaz
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
    if (!_initialized) return false;
    if (!_isStoreAvailable) return false;
    if (_iap == null) return false;

    if (_products.isEmpty) {
      await _queryProducts();
    }

    if (_products.isEmpty) return false;

    final product = _pickPreferredProduct(_products);
    if (product == null) return false;

    final purchaseParam = PurchaseParam(productDetails: product);

    // Log analytics: Satın alma başlangıcı
    await AnalyticsService.logPurchaseStart(
      productId: product.id,
      productType: _getProductType(product.id),
    );

    // Subscription ürünleri için buyNonConsumable yerine buyConsumable kullanılmaz.
    // Uygulamada tek premium erişim anahtarı için non-consumable akışını baz alıyoruz.
    return _iap!.buyNonConsumable(purchaseParam: purchaseParam);
  }

  static ProductDetails? _pickPreferredProduct(List<ProductDetails> products) {
    const preferredOrder = [
      'premium_upgrade',
      'premium_yearly',
      'premium_monthly',
    ];

    for (final id in preferredOrder) {
      final match = products.where((p) => p.id == id).toList();
      if (match.isNotEmpty) return match.first;
    }

    return products.isNotEmpty ? products.first : null;
  }

  static Future<void> restorePurchases() async {
    if (!_initialized || !_isStoreAvailable) return;
    if (_iap == null) return;

    // Log analytics: Geri yükleme başlangıcı
    await AnalyticsService.logRestoreStart();

    await _iap!.restorePurchases();
  }

  static Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final result = await ReceiptVerificationService.verifyPurchase(
            purchaseDetails,
          );
          if (result.isValid) {
            // Log analytics: Başarılı satın alma
            await AnalyticsService.logPurchaseSuccess(
              productId: purchaseDetails.productID,
              productType: _getProductType(purchaseDetails.productID),
            );
            _onEntitlementChanged?.call(true);
          } else {
            // Log analytics: Başarısız satın alma
            await AnalyticsService.logPurchaseFailed(
              productId: purchaseDetails.productID,
              errorCode: result.errorCode ?? 'UNKNOWN',
              errorMessage: result.errorMessage ?? 'Bilinmeyen hata',
            );
            // Hata callback'i çağır
            _onVerificationError?.call({
              'message': result.errorMessage ?? 'Bilinmeyen hata',
              'code': result.errorCode ?? 'UNKNOWN',
            });
          }
          break;
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          // Log analytics: Hata durumu
          await AnalyticsService.logPurchaseFailed(
            productId: purchaseDetails.productID,
            errorCode: 'PURCHASE_ERROR',
            errorMessage: purchaseDetails.error?.message ?? 'Bilinmeyen hata',
          );
          break;
        case PurchaseStatus.canceled:
          // Log analytics: İptal edildi
          await AnalyticsService.logPurchaseCanceled(
            productId: purchaseDetails.productID,
          );
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _iap?.completePurchase(purchaseDetails);
      }
    }
  }

  static Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _initialized = false;
  }

  static String _getProductType(String productId) {
    if (productId.contains('monthly')) return 'monthly';
    if (productId.contains('yearly')) return 'yearly';
    return 'upgrade';
  }
}
