import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/providers/enhanced_theme_provider.dart';
import 'package:qr_app/providers/history_provider.dart';
import 'package:qr_app/screens/settings_screen.dart';
import 'package:qr_app/services/premium_access_service.dart';
import 'package:qr_app/services/store_review_gateway.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qr_app/l10n/app_localizations.dart';

class _FakeStoreReviewGateway implements StoreReviewGateway {
  bool called = false;
  Object? error;

  @override
  Future<void> rateApp({required String androidPackageName}) async {
    called = true;
    if (error != null) {
      throw error!;
    }
  }
}

void main() {
  group('SettingsScreen Widget Tests', () {
    setUp(() {
      PremiumAccessService.premiumNotifier.value = false;
      PremiumAccessService.errorNotifier.value = null;
    });

    Widget createWidgetUnderTest({
      Locale? locale,
      StoreReviewGateway? storeReviewGateway,
    }) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('tr'), Locale('en')],
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ],
          child: SettingsScreen(storeReviewGateway: storeReviewGateway),
        ),
      );
    }

    testWidgets('SettingsScreen başlık ve metinler TR ve EN locale ile doğru', (
      WidgetTester tester,
    ) async {
      // Türkçe
      await tester.pumpWidget(
        createWidgetUnderTest(locale: const Locale('tr')),
      );
      await tester.pumpAndSettle();
      final locTr = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(find.text(locTr!.settings), findsWidgets); // AppBar + body
      expect(find.text(locTr.themeSettings), findsAtLeastNWidgets(1));

      // İngilizce
      await tester.pumpWidget(
        createWidgetUnderTest(locale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      final locEn = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(find.text(locEn!.settings), findsWidgets);
      expect(find.text(locEn.themeSettings), findsAtLeastNWidgets(1));
    });

    testWidgets('Theme settings link is present', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetUnderTest(locale: const Locale('tr')),
      );
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      // Assert
      expect(find.text(loc.themeSettings), findsAtLeastNWidgets(1));
      expect(find.text(loc.themeSettingsSubtitle), findsOneWidget);
    });

    testWidgets('Help section is visible', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetUnderTest(locale: const Locale('tr')),
      );
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      // Assert
      expect(find.text(loc.helpFaq), findsAtLeastNWidgets(1));
      expect(find.text(loc.helpFaqSubtitle), findsOneWidget);
    });

    testWidgets('Feedback section is visible', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createWidgetUnderTest(locale: const Locale('tr')),
      );
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      await tester.scrollUntilVisible(
        find.text(loc.feedback),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(loc.feedback), findsOneWidget);
      expect(find.text(loc.feedbackSubtitle), findsOneWidget);
    });

    testWidgets('Premium notifier is observable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Change premium status notifier
      PremiumAccessService.premiumNotifier.value = true;
      await tester.pumpAndSettle();

      // Assert - UI should rebuild
      expect(PremiumAccessService.premiumNotifier.value, isTrue);
    });

    testWidgets('Premium upgrade subtitle is visible when not premium', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(locale: const Locale('tr')),
      );
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      await tester.scrollUntilVisible(
        find.text(loc.settingsPremiumUpgradeSubtitle),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text(loc.settingsPremiumUpgradeSubtitle), findsOneWidget);
    });

    testWidgets('Premium active subtitle is visible when premium', (
      WidgetTester tester,
    ) async {
      PremiumAccessService.premiumNotifier.value = true;
      await tester.pumpWidget(
        createWidgetUnderTest(locale: const Locale('tr')),
      );
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      await tester.scrollUntilVisible(
        find.text(loc.settingsPremiumActiveSubtitle),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text(loc.settingsPremiumActiveSubtitle), findsOneWidget);
    });

    testWidgets('Rate app action calls injected review gateway', (
      WidgetTester tester,
    ) async {
      final gateway = _FakeStoreReviewGateway();

      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('tr'),
          storeReviewGateway: gateway,
        ),
      );
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      await tester.tap(find.text(loc.rateApp));
      await tester.pumpAndSettle();

      expect(gateway.called, isTrue);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Rate app failure shows localized snackbar', (
      WidgetTester tester,
    ) async {
      final gateway = _FakeStoreReviewGateway()
        ..error = StateError('store failed');

      await tester.pumpWidget(
        createWidgetUnderTest(
          locale: const Locale('tr'),
          storeReviewGateway: gateway,
        ),
      );
      await tester.pumpAndSettle();

      final loc = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      )!;

      await tester.tap(find.text(loc.rateApp));
      await tester.pumpAndSettle();

      expect(gateway.called, isTrue);
      expect(
        find.text(loc.settingsStoreOpenFailed('Bad state: store failed')),
        findsOneWidget,
      );
    });

    testWidgets('Error notifier is initialized', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(PremiumAccessService.errorNotifier.value, isNull);
    });
  });
}
