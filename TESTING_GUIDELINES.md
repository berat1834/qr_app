# 🧪 Test Yazma Kuralları ve Disiplini

Bu doküman, QR Kod Uygulaması için **zorunlu test yazma kurallarını** tanımlar. Her geliştirici bu kurallara uymalıdır.

---

## 📋 Temel Prensipler

### ✅ **KURAL 1: Her Service İçin Unit Test Zorunludur**

Yeni bir service veya service metodları eklerken, **mutlaka** karşılık gelen test dosyası oluşturun.

**Gereksinimler:**
- [ ] Tüm public metodlar test edilmeli
- [ ] CRUD operasyonları (Create, Read, Update, Delete) test edilmeli
- [ ] Edge case'ler test edilmeli:
  - Boş veri
  - Null değerler
  - Hatalı formatlar
  - Sınır değerler (max/min)
- [ ] Hata senaryoları test edilmeli

**Örnekler:**
```dart
// ✅ İYİ: favorites_service_test.dart (37 test)
test('Yeni favori ekle', () { ... });
test('Aynı veri iki kez ekle - hata ver', () { ... });
test('Maksimum 50 favori sınırı', () { ... });

// ❌ KÖTÜ: Test yok
```

**Mevcut Örnekler:**
- `test/history_service_test.dart` → 36 test
- `test/favorites_service_test.dart` → 37 test
- `test/security_service_test.dart` → 40 test
- `test/share_service_test.dart` → 47 test

---

### ✅ **KURAL 2: Her Ekran İçin Smoke Test Zorunludur**

Yeni bir ekran (screen/widget) eklerken, **en az** temel render testleri yazın.

**Minimum Gereksinimler:**
- [ ] Ekran hata vermeden render oluyor mu?
- [ ] Kritik UI elemanları görünüyor mu? (Butonlar, başlıklar)
- [ ] AppBar/Scaffold mevcut mu?

**Örnekler:**
```dart
// ✅ İYİ: Basit smoke test
testWidgets('SimpleHomeScreen yüklenir', (tester) async {
  await tester.pumpWidget(createTestApp());
  expect(find.byType(SimpleHomeScreen), findsOneWidget);
  expect(find.byType(AppBar), findsOneWidget);
});

// ❌ KÖTÜ: Test yok
```

**Mevcut Örnekler:**
- `test/widget_test.dart` → 8 widget testi
- `test/integration_test.dart` → 12 navigasyon testi

---

## 🎯 Test Kategorileri

### 1️⃣ **Unit Tests** (lib/services/, lib/utils/)
**Ne test edilir:**
- Service metodları
- Utility fonksiyonları
- İş mantığı (business logic)
- Veri dönüşümleri

**Dosya adı formatı:** `{service_name}_test.dart`

**Örnek:**
```
lib/services/favorites_service.dart
→ test/favorites_service_test.dart
```

---

### 2️⃣ **Widget Tests** (lib/screens/, lib/widgets/)
**Ne test edilir:**
- UI bileşenleri
- Widget render
- Buton etkileşimleri
- State değişimleri

**Dosya adı formatı:** `widget_test.dart` veya `{screen_name}_test.dart`

**Örnek:**
```dart
testWidgets('Tema değiştirme butonu çalışır', (tester) async {
  await tester.tap(find.byIcon(Icons.dark_mode));
  await tester.pump();
  expect(themeProvider.isDarkMode, true);
});
```

---

### 3️⃣ **Integration Tests** (Ekranlar arası akış)
**Ne test edilir:**
- Navigasyon akışları
- Ekranlar arası veri aktarımı
- Kullanıcı senaryoları (user journeys)

**Dosya adı:** `integration_test.dart`

**Örnek:**
```dart
testWidgets('Ana ekrandan QR tarama ekranına git', (tester) async {
  await tester.tap(find.text('QR Tara'));
  await tester.pumpAndSettle();
  expect(find.byType(EnhancedQRScannerScreen), findsOneWidget);
});
```

---

## 📝 Kod Ekleme Checklist

Yeni kod eklerken bu kontrolü yapın:

### **Yeni Service Eklerken:**
- [ ] Service dosyası oluşturdum (`lib/services/my_service.dart`)
- [ ] Test dosyası oluşturdum (`test/my_service_test.dart`)
- [ ] Tüm public metodlar için test yazdım
- [ ] Edge case'leri test ettim
- [ ] `flutter test` komutu başarılı

### **Yeni Ekran Eklerken:**
- [ ] Screen dosyası oluşturdum (`lib/screens/my_screen.dart`)
- [ ] Smoke test ekledim (`test/widget_test.dart` veya ayrı dosya)
- [ ] Render testi geçiyor
- [ ] Kritik butonlar test edildi
- [ ] `flutter test` komutu başarılı

### **Kod Değiştirirken (Refactoring):**
- [ ] Değişiklik öncesi tüm testler geçiyordu
- [ ] Değişiklik sonrası tüm testler geçiyor
- [ ] Yeni eklenen kod test edildi
- [ ] Gereksiz testler temizlendi

---

## 🚀 Test Komutları

### Tüm Testleri Çalıştır:
```bash
flutter test
```

### Belirli Bir Test Dosyasını Çalıştır:
```bash
flutter test test/favorites_service_test.dart
```

### Test Coverage Raporu:
```bash
flutter test --coverage
```

### Testleri Watch Modunda Çalıştır:
```bash
flutter test --watch
```

---

## 📊 Mevcut Test Durumu

**Toplam Test Sayısı:** 132 ✅

| Dosya | Test Sayısı | Kategori |
|-------|-------------|----------|
| widget_test.dart | 8 | Widget |
| unit_test.dart | 18 | Unit |
| integration_test.dart | 12 | Integration |
| history_service_test.dart | 36 | Service |
| favorites_service_test.dart | 37 | Service |
| security_service_test.dart | 40 | Service |
| share_service_test.dart | 47 | Service |

---

## 🎓 Test Yazma Best Practices

### ✅ İyi Test Özellikleri:
1. **Bağımsız:** Testler birbirinden etkilenmemeli
2. **Hızlı:** Testler hızlı çalışmalı (< 1 saniye/test)
3. **Tekrarlanabilir:** Her çalıştırmada aynı sonucu vermeli
4. **Açıklayıcı:** Test adı ne test ettiğini açıkça belirtmeli
5. **İzole:** Mock/stub kullanarak dış bağımlılıkları izole edin

### ❌ Kötü Test Özellikleri:
- Gerçek network çağrıları yapan testler
- Rastgele başarısız olan testler (flaky tests)
- Çok uzun süren testler
- Birden fazla şeyi test eden testler
- Belirsiz test adları ("test1", "test2")

---

## 🔧 Mock ve Stub Kullanımı

**Service testlerinde SharedPreferences mock:**
```dart
setUp(() {
  SharedPreferences.setMockInitialValues({});
});
```

**Widget testlerinde Provider mock:**
```dart
Widget createTestApp() {
  return ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: MaterialApp(home: MyWidget()),
  );
}
```

---

## 📈 Test Coverage Hedefleri

**Minimum Kabul Edilebilir Coverage:**
- Services: **80%+**
- Utils: **80%+**
- Widgets/Screens: **60%+** (smoke tests)
- Genel Proje: **70%+**

**Mevcut Coverage:**
- Services: ✅ %85+
- Utils: ✅ %90+ (qr_helpers tamamen test edildi)
- Widgets: ✅ %60+

---

## ⚠️ Test Yazmamanın Riskleri

1. **Refactoring Korkusu:** Kod değiştirmeye korkar hale gelirsiniz
2. **Regresyon Hataları:** Eski özellikleri bozarsınız
3. **Yavaş Geliştirme:** Manuel test sürekli zaman alır
4. **Güven Kaybı:** Kodunuzun çalıştığından emin olamazsınız
5. **Teknik Borç:** Sonradan test eklemek çok daha zor

---

## ✨ Test Yazmanın Faydaları

1. **Güvenle Refactor:** Kodu rahatça düzenleyebilirsiniz
2. **Hızlı Feedback:** Hataları hemen yakalarsınız
3. **Dokümantasyon:** Testler kodun nasıl kullanılacağını gösterir
4. **Daha İyi Tasarım:** Test yazılabilir kod = iyi tasarım
5. **Uzun Vadede Zaman Tasarrufu:** Manuel test yerine otomatik

---

## 🎯 Örnek Test Şablonları

### Service Test Şablonu:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_app/services/my_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MyService - Temel İşlemler', () {
    test('Veri ekleme başarılı', () async {
      await MyService.addItem('test');
      final items = await MyService.getItems();
      expect(items.length, 1);
    });

    test('Boş veri ekle - hata ver', () {
      expect(() => MyService.addItem(''), throwsException);
    });
  });
}
```

### Widget Test Şablonu:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/screens/my_screen.dart';
import 'package:qr_app/providers/enhanced_theme_provider.dart';

void main() {
  Widget createTestApp() {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MaterialApp(home: MyScreen()),
    );
  }

  testWidgets('MyScreen render testi', (tester) async {
    await tester.pumpWidget(createTestApp());
    
    expect(find.byType(MyScreen), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
```

---

## 🔄 Sürekli İyileştirme

Bu döküman yaşayan bir dokümandır. Yeni test pattern'leri ve best practice'ler keşfettikçe güncellenmelidir.

**Son Güncelleme:** 30 Aralık 2025  
**Versiyon:** 1.0

---

## 📚 Ek Kaynaklar

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Widget Testing Best Practices](https://docs.flutter.dev/cookbook/testing/widget/introduction)

---

**Unutmayın:** Testler yazmak zaman kaybı değil, **zaman yatırımıdır**! 🚀
