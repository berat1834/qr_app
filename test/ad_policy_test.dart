import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_app/config/ad_placements.dart';

void main() {
  group('AdPolicy', () {
    late TargetPlatform? previousPlatform;

    setUp(() {
      previousPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = previousPlatform;
    });

    test('shouldShowAds returns false for premium users', () {
      expect(AdPolicy.shouldShowAds(isPremium: true), isFalse);
    });

    test('shouldShowAds returns true for non-premium mobile users', () {
      expect(AdPolicy.shouldShowAds(isPremium: false), isTrue);
    });

    test(
      'nativeInlineAdSlots returns 0 when item count is below threshold',
      () {
        expect(AdPolicy.nativeInlineAdSlots(itemCount: 4, isPremium: false), 0);
      },
    );

    test('nativeInlineAdSlots applies interval and max cap', () {
      expect(AdPolicy.nativeInlineAdSlots(itemCount: 5, isPremium: false), 1);
      expect(AdPolicy.nativeInlineAdSlots(itemCount: 10, isPremium: false), 2);
      expect(
        AdPolicy.nativeInlineAdSlots(itemCount: 30, isPremium: false),
        AdPlacements.nativeMaxInlineAds,
      );
    });

    test('nativeInlineAdSlots returns 0 for premium users', () {
      expect(AdPolicy.nativeInlineAdSlots(itemCount: 100, isPremium: true), 0);
    });
  });
}
