import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class AdPlacements {
  static const String testBannerBottom =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testNativeInline =
      'ca-app-pub-3940256099942544/2247696110';

  // Production values can be injected at build time with --dart-define.
  static const String bannerBottom = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: testBannerBottom,
  );
  static const String nativeInline = String.fromEnvironment(
    'ADMOB_NATIVE_ID',
    defaultValue: testNativeInline,
  );

  static bool get hasProductionIds =>
      bannerBottom != testBannerBottom && nativeInline != testNativeInline;
  static const int nativeInsertInterval = 5;
  static const int nativeMaxInlineAds = 2;
}

class AdPolicy {
  static bool shouldShowAds({required bool isPremium}) {
    if (isPremium) return false;
    if (kIsWeb) return false;
    if (kReleaseMode && !AdPlacements.hasProductionIds) return false;

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static int nativeInlineAdSlots({
    required int itemCount,
    required bool isPremium,
  }) {
    if (!shouldShowAds(isPremium: isPremium)) return 0;
    if (itemCount < AdPlacements.nativeInsertInterval) return 0;

    final computed = itemCount ~/ AdPlacements.nativeInsertInterval;
    return math.min(computed, AdPlacements.nativeMaxInlineAds);
  }
}
