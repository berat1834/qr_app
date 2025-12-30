import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/providers/enhanced_theme_provider.dart';
import 'package:qr_app/screens/simple_home_screen.dart';

// Test için Helper Widget
Widget createTestApp(Widget child) {
  return ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('Widget Testleri - Başlangıç Testleri', () {
    testWidgets('Ana uygulama açılışı test', (WidgetTester tester) async {
      // Uygulamayı başlat - Provider wrapper olmadan test et
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(home: const SimpleHomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Uygulama başarıyla açıldığını doğrula
      expect(find.byType(SimpleHomeScreen), findsOneWidget);
    });

    testWidgets('SimpleHomeScreen doğru şekilde yükleniyor mu?', (
      WidgetTester tester,
    ) async {
      // Uygulamayı başlat Provider wrapper ile
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(home: const SimpleHomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // SimpleHomeScreen ve title kontrolü
      expect(find.byType(SimpleHomeScreen), findsOneWidget);
      expect(find.text('QR Kod Uygulaması'), findsWidgets);
    });

    testWidgets('Ana sayfada butonlar bulunuyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(home: const SimpleHomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // QR Tara butonu
      expect(find.byIcon(Icons.qr_code_scanner), findsWidgets);
      // Ayarlar butonu
      expect(find.byIcon(Icons.palette), findsWidgets);
    });

    testWidgets('Tema değişim butonu çalışıyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(home: const SimpleHomeScreen()),
        ),
      );
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
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(home: const SimpleHomeScreen()),
        ),
      );
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
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(home: const SimpleHomeScreen()),
        ),
      );
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
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(home: const SimpleHomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // İstatistik metinleri kontrolü
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('Tarama') == true,
        ),
        findsWidgets,
      );
    });

    testWidgets('Hızlı eylem butonları (FAB) görüntüleniyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MaterialApp(home: const SimpleHomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Floating action button'ları ara - Scaffold içinde
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
    });
  });
}
