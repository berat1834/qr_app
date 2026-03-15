# 📱 QR Kod Uygulaması

Flutter ile geliştirilmiş, kapsamlı test coverage'a sahip profesyonel QR kod okuyucu ve oluşturucu uygulama.

## ✨ Özellikler

- 📷 **QR Kod Tarama** - Gelişmiş tarayıcı ile her türlü QR kod
- ✏️ **QR Kod Oluşturma** - WiFi, URL, vCard, Konum ve daha fazlası
- 📚 **Geçmiş Yönetimi** - Taranan ve oluşturulan kodların takibi
- ⭐ **Favoriler** - Sık kullanılan QR kodları kaydetme
- 🎨 **Özelleştirilebilir Temalar** - Açık/Koyu mod + renk seçenekleri
- 🔒 **Güvenlik Kontrolleri** - URL güvenlik analizi
- 📤 **Paylaşım Özellikleri** - WhatsApp, Telegram, E-mail, SMS

## 🧪 Test Coverage

**Toplam Test Sayısı:** 132 ✅

- Widget Tests: 8
- Unit Tests: 18
- Integration Tests: 12
- Service Tests: 94

**Test Kuralları:** Detaylı bilgi için [TESTING_GUIDELINES.md](TESTING_GUIDELINES.md) dosyasına bakın.

## 📁 Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── screens/                     # Ekranlar (9 aktif ekran)
│   ├── simple_home_screen.dart
│   ├── enhanced_qr_scanner_screen.dart
│   ├── enhanced_qr_generator_screen.dart
│   ├── history_screen.dart
│   ├── favorites_screen.dart
│   └── ...
├── services/                    # İş mantığı ve servisler
│   ├── history_service.dart
│   ├── favorites_service.dart
│   ├── security_service.dart
│   └── ...
├── providers/                   # State yönetimi (Provider)
│   └── enhanced_theme_provider.dart
└── utils/                       # Yardımcı fonksiyonlar
    └── qr_helpers.dart          # QR parse/generate işlemleri

test/
├── widget_test.dart
├── unit_test.dart
├── integration_test.dart
└── *_service_test.dart
```

## 🚀 Başlangıç

### Gereksinimler

- Flutter SDK (≥3.0.0)
- Dart SDK (≥3.0.0)

### Kurulum

```bash
# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run

# Testleri çalıştır
flutter test
```

## 🧪 Test Disiplini

Bu projede **zorunlu test yazma kuralları** uygulanır:

✅ **KURAL 1:** Her service için unit test yazılmalı  
✅ **KURAL 2:** Her ekran için smoke test yazılmalı

Detaylar: [TESTING_GUIDELINES.md](TESTING_GUIDELINES.md)

## 📚 Dokümantasyon

- [Flutter Kavramları](docs/Flutter_Kavramlari.md)
- [QR Kod Dersleri](docs/Flutter_QR_Kod_Dersleri.md)
- [Kod Örnekleri](docs/Kod_Ornekleri.md)
- [Test Kuralları](TESTING_GUIDELINES.md) ⭐
<<<<<<< HEAD
=======
>>>>>>> fe1c515 (Goodbye 2025, thanks for the lessons.)

## 🛠️ Kullanılan Teknolojiler

- **Flutter** - UI Framework
- **Provider** - State Management
- **SharedPreferences** - Yerel veri saklama
- **mobile_scanner** - QR kod tarama
- **qr_flutter** - QR kod oluşturma
- **share_plus** - İçerik paylaşımı
- **url_launcher** - URL/Link açma

## 📊 Kod Kalitesi

- ✅ Refactor edilmiş temiz kod
- ✅ Duplicate kod yok
- ✅ 132 test (tümü geçiyor)
- ✅ Modüler yapı
- ✅ Dokümante edilmiş

## 📝 Lisans

Bu proje MIT lisansı altındadır.
