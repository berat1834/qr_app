import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_purchase_service.dart';

/// Doğrulama hatasını temsil eden sınıf
class VerificationError {
  final String message;
  final String code;

  VerificationError({required this.message, required this.code});
}

class PremiumAccessService {
  static const String _premiumEnabledKey = 'premium_enabled';
  static const String _premiumEntitlementKey = 'premium_purchase_entitled';
  static final ValueNotifier<bool> premiumNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<VerificationError?> errorNotifier =
      ValueNotifier<VerificationError?>(null);

  static Future<void> initialize() async {
    await PremiumPurchaseService.initialize(
      onEntitlementChanged: (enabled) async {
        await setPurchasedEntitlement(enabled);
      },
      onVerificationError: (error) {
        errorNotifier.value = VerificationError(
          message: error['message'] as String,
          code: error['code'] as String,
        );
      },
    );
    await refreshPremiumState();
  }

  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();

    if (kDebugMode) {
      final debugOverride = prefs.getBool(_premiumEnabledKey) ?? false;
      if (debugOverride) {
        return true;
      }
    }

    return prefs.getBool(_premiumEntitlementKey) ?? false;
  }

  static Future<void> setPremium(bool enabled) async {
    if (!kDebugMode) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumEnabledKey, enabled);
    await refreshPremiumState();
  }

  static Future<void> setPurchasedEntitlement(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumEntitlementKey, enabled);
    await refreshPremiumState();
  }

  static Future<void> refreshPremiumState() async {
    premiumNotifier.value = await isPremium();
  }

  static Future<bool> purchasePremium() async {
    return PremiumPurchaseService.buyPremium();
  }

  static Future<void> restorePurchases() async {
    await PremiumPurchaseService.restorePurchases();
  }

  static bool isStoreAvailable() {
    return PremiumPurchaseService.isStoreAvailable;
  }
}
