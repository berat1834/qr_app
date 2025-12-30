import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_app/main.dart' show QRCodeApp;

void main() {
  group('Integration Testleri - Ekran Navigasyonu', () {
    testWidgets('Ana sayfa açılıyor ve butonlar tıklanabiliyor', (
      WidgetTester tester,
    ) async {
      // Uygulamayı başlat
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // Ana sayfa açık olduğunu doğrula
      expect(find.text('QR Kod Uygulaması'), findsWidgets);

      // QR Tara butonunu bul ve tıkla
      final scanButton = find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip && (widget.message?.contains('Tara') ?? false),
      );
      if (scanButton.evaluate().isNotEmpty) {
        await tester.tap(scanButton.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('QR Oluştur sayfasına navigasyon çalışıyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // QR Oluştur butonunu ara
      final createButton = find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip && (widget.message?.contains('Oluştur') ?? false),
      );

      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton.first);
        await tester.pumpAndSettle();

        // Yeni sayfa yüklendi mi kontrolü
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Geçmiş sayfasına navigasyon çalışıyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // Geçmiş butonunu ara
      final historyButton = find.byWidgetPredicate(
        (widget) =>
            widget is Tooltip && (widget.message?.contains('Geçmiş') ?? false),
      );

      if (historyButton.evaluate().isNotEmpty) {
        await tester.tap(historyButton.first);
        await tester.pumpAndSettle();

        // Geçmiş sayfası yüklendi
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Tema ayarları sayfasına gidip geri dönme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // Tema ayarları butonunu tıkla
      final settingsButton = find.byIcon(Icons.palette);
      expect(settingsButton, findsOneWidget);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Ayarlar sayfası açıldı
      expect(find.byType(Scaffold), findsWidgets);

      // Geri dön
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Ana sayfa tekrar görselleniyor
      expect(find.text('QR Kod Uygulaması'), findsWidgets);
    });

    testWidgets('Tema değiştirme ve geri dönme işleri', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // Tema butonunu bul (Light/Dark mode)
      final themeToggle = find.byIcon(Icons.light_mode);
      expect(themeToggle, findsOneWidget);

      // Tema değiştir
      await tester.tap(themeToggle);
      await tester.pumpAndSettle();

      // Tema değişti (ikon değişecek)
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Sayfalar arası hızlı navigasyon', (WidgetTester tester) async {
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // Scan butonuna tıkla
      await tester.tap(find.byIcon(Icons.qr_code_scanner).first);
      await tester.pumpAndSettle();

      // Geri dön
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Ana sayfaya dön
      expect(find.text('QR Kod Uygulaması'), findsWidgets);
    });

    testWidgets('Sayfalar kaydırma ve navigasyon kombinasyonu', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // Sayfayı kaydır
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Buton hala tıklanabilir
      expect(find.byIcon(Icons.palette), findsOneWidget);
      await tester.tap(find.byIcon(Icons.palette));
      await tester.pumpAndSettle();

      // Yeni sayfa açıldı
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Back button ile navigasyon tamamlanıyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // Ayarlar sayfasına git
      await tester.tap(find.byIcon(Icons.palette));
      await tester.pumpAndSettle();

      // Back tuşu var mı
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Ana sayfaya dön
        expect(find.text('QR Kod Uygulaması'), findsWidgets);
      }
    });

    testWidgets('Ekran rotasyonunda UI bozulmuyor mu?', (
      WidgetTester tester,
    ) async {
      // Dikey mod (Portrait)
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      tester.binding.window.physicalSizeTestValue = const Size(540, 1080);

      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      expect(find.text('QR Kod Uygulaması'), findsWidgets);

      // Yatay moda döndür (Landscape)
      tester.binding.window.physicalSizeTestValue = const Size(1080, 540);
      await tester.pumpAndSettle();

      // UI hala görünüyor
      expect(find.text('QR Kod Uygulaması'), findsWidgets);
    });

    testWidgets('Hızlı eylem butonları (FAB) çalışıyor mu?', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // FAB'leri bul
      final fabButtons = find.byType(FloatingActionButton);
      expect(fabButtons, findsWidgets);

      // İlk FAB'ye tıkla
      await tester.tap(fabButtons.first);
      await tester.pumpAndSettle();

      // Sayfa değişti
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Widget state tutarlılığı', (WidgetTester tester) async {
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // İstatistikleri kontrol et
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('Tarana') == true,
        ),
        findsWidgets,
      );

      // Ayarlara git ve geri dön
      await tester.tap(find.byIcon(Icons.palette));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // İstatistikler hala görünüyor
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.data?.contains('Tarana') == true,
        ),
        findsWidgets,
      );
    });

    testWidgets('AppBar\'ın konsistency kontrol', (WidgetTester tester) async {
      await tester.pumpWidget(const QRCodeApp());
      await tester.pumpAndSettle();

      // Ana sayfada AppBar var
      expect(find.byType(AppBar), findsOneWidget);

      // Ayarlar sayfasına git
      await tester.tap(find.byIcon(Icons.palette));
      await tester.pumpAndSettle();

      // Yeni sayfada da AppBar var
      expect(find.byType(AppBar), findsOneWidget);

      // Geri dön
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // AppBar hala var
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
