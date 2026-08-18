import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_app/main.dart' show QRCodeApp;
import 'package:qr_app/providers/enhanced_theme_provider.dart';
import 'package:qr_app/providers/history_provider.dart';
import 'package:qr_app/providers/locale_provider.dart';
import 'package:qr_app/screens/theme_settings_screen.dart';

void main() {
  group('Integration Smoke Tests', () {
    Future<void> pumpApp(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => HistoryProvider()),
            ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ],
          child: const QRCodeApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('App boots to a scaffold', (WidgetTester tester) async {
      await pumpApp(tester);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Theme settings page opens from palette button', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);
      final settingsButton = find.byIcon(Icons.palette);
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();
      expect(find.byType(ThemeSettingsScreen), findsOneWidget);
    });

    testWidgets('Theme toggle button is tappable', (WidgetTester tester) async {
      await pumpApp(tester);
      final darkModeButton = find.byIcon(Icons.dark_mode);
      final lightModeButton = find.byIcon(Icons.light_mode);
      final toggleButton = darkModeButton.evaluate().isNotEmpty
          ? darkModeButton
          : lightModeButton;
      expect(toggleButton, findsOneWidget);
      await tester.tap(toggleButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Primary quick action icon is present and tappable', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      final quickAction = find.byIcon(Icons.qr_code_scanner);
      expect(quickAction, findsWidgets);
      await tester.tap(quickAction.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
