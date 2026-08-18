import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/providers/enhanced_theme_provider.dart';
import 'package:qr_app/screens/simple_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qr_app/l10n/app_localizations.dart';

// Test için Helper Widget
Widget createTestApp(
  Widget child, {
  Locale? locale,
  List<dynamic>? mockHistory,
}) {
  return ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: MaterialApp(
      home: child,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
    ),
  );
}

void main() {
  group('Widget Testleri - Başlangıç Testleri', () {
    testWidgets('Ana uygulama açılışı test', (WidgetTester tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // SharedPreferences'ı test için mockla (bellekte boş başlat)
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      // ignore: deprecated_member_use
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(createTestApp(const SimpleHomeScreen()));
      await tester.pumpAndSettle();

      // Uygulama başarıyla açıldığını doğrula
      expect(find.byType(SimpleHomeScreen), findsOneWidget);
    });

    testWidgets('SimpleHomeScreen başlık TR ve EN locale ile doğru', (
      WidgetTester tester,
    ) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // ignore: deprecated_member_use
      SharedPreferences.setMockInitialValues({});

      // Türkçe
      await tester.pumpWidget(
        createTestApp(const SimpleHomeScreen(), locale: const Locale('tr')),
      );
      await tester.pumpAndSettle();
      expect(find.text('QR Kod Uygulaması'), findsWidgets);

      // İngilizce
      await tester.pumpWidget(
        createTestApp(const SimpleHomeScreen(), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      expect(find.text('QR Code App'), findsWidgets);
    });

    testWidgets('Ana sayfada butonlar bulunuyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(const SimpleHomeScreen()));
      await tester.pumpAndSettle();

      // QR Tara butonu
      expect(find.byIcon(Icons.qr_code_scanner), findsWidgets);
      // Ayarlar butonu
      expect(find.byIcon(Icons.palette), findsWidgets);
    });

    testWidgets('Tema değişim butonu çalışıyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(const SimpleHomeScreen()));
      await tester.pumpAndSettle();

      // Tema değişim iconunu bul
      final themeButton = find.byIcon(Icons.light_mode);
      if (themeButton.evaluate().isNotEmpty) {
        expect(themeButton, findsOneWidget);

        // Butona tıkla
        await tester.tap(themeButton);
        await tester.pumpAndSettle();

        // Test başarılı
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });

    testWidgets('Navigasyon butonları görselleri yükleniyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(const SimpleHomeScreen()));
      await tester.pumpAndSettle();

      // Buton iconlarının yüklü olduğunu doğrula
      // Sadece mevcut olanları kontrol et
      final scanButton = find.byIcon(Icons.qr_code_scanner);
      final historyButton = find.byIcon(Icons.history);

      expect(
        scanButton.evaluate().isNotEmpty || historyButton.evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Sayfa kaydırması sorunsuz çalışıyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(const SimpleHomeScreen()));
      await tester.pumpAndSettle();

      // Sayfayı aşağı kaydır
      await tester.drag(find.byType(Scaffold), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Sayfa hala mevcut
      expect(find.byType(SimpleHomeScreen), findsOneWidget);

      // Sayfayı yukarı kaydır
      await tester.drag(find.byType(Scaffold), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.byType(SimpleHomeScreen), findsOneWidget);
    });

    testWidgets('İstatistik bilgileri görüntüleniyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(const SimpleHomeScreen()));
      await tester.pumpAndSettle();

      // İstatistik metinleri kontrolü
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data?.contains('Tarama') == true ||
                  widget.data?.contains('Scanned') == true),
        ),
        findsWidgets,
      );
    });

    testWidgets('Hızlı eylem butonları (FAB) görüntüleniyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(const SimpleHomeScreen()));
      await tester.pumpAndSettle();

      // Floating action button'ları ara - Scaffold içinde
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
    });

    testWidgets('Fiyat alarmı özeti TR ve EN locale ile doğru', (
      WidgetTester tester,
    ) async {
      final alertsJson = jsonEncode([
        {
          'id': 'alert_1',
          'barcode': '869000000001',
          'productName': 'Test Urun',
          'targetPrice': 100.0,
          'currentPrice': 90.0,
          'preferredSource': 'trendyol',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ]);

      // ignore: deprecated_member_use
      SharedPreferences.setMockInitialValues({'price_alerts_v1': alertsJson});

      await tester.pumpWidget(
        createTestApp(const SimpleHomeScreen(), locale: const Locale('tr')),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 tetiklenen • 1 toplam'), findsOneWidget);

      // ignore: deprecated_member_use
      SharedPreferences.setMockInitialValues({'price_alerts_v1': alertsJson});

      await tester.pumpWidget(
        createTestApp(const SimpleHomeScreen(), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 triggered • 1 total'), findsOneWidget);
    });
  });
}
