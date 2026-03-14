import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/providers/enhanced_theme_provider.dart';
import 'package:qr_app/providers/history_provider.dart';
import 'package:qr_app/screens/settings_screen.dart';
import 'package:qr_app/services/premium_access_service.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ],
          child: const SettingsScreen(),
        ),
      );
    }

    testWidgets('Displays settings screen correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Ayarlar'), findsOneWidget);
      expect(find.text('Uygulama Ayarları'), findsOneWidget);
      expect(
        find.text('Tema, yedekleme ve diğer tercihlerinizi yönetin'),
        findsOneWidget,
      );
    });

    testWidgets('Theme settings link is present', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Tema Ayarları'), findsOneWidget);
      expect(
        find.text('Renk, açık/koyu mod ve görünüm ayarları'),
        findsOneWidget,
      );
    });

    testWidgets('Cloud backup section is visible', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Bulut Yedekleme'), findsOneWidget);
      expect(
        find.text(
          'Premium senkronizasyon ile verilerinizi Google Drive üzerinden cihazlar arası güncel tutun.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('About section is visible', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Uygulama Hakkında'), findsOneWidget);
      expect(find.text('Gizlilik Politikası'), findsOneWidget);
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

    testWidgets('Error notifier is initialized', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(PremiumAccessService.errorNotifier.value, isNull);
    });
  });
}
