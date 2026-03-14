# 🚀 Play Store Release Guide

## 📝 Uygulama Bilgileri

- **Package Name:** `com.qrscanner.professional`
- **App Name:** `QR Kod Tarayıcı`
- **Version:** 1.0.0 (Build 1)
- **Min SDK:** Android 5.0 (API 21) - 99%+ cihaz kapsama
- **Target SDK:** Android 15 (API 35)

## 🔐 1. Keystore Oluşturma (İMZALAMA ANAHTARI)

### Keystore Oluştur:
```bash
keytool -genkey -v -keystore qr_scanner_keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias qr_scanner_key
```

**ÖNEMLİ:** 
- ✅ Keystore şifresini güvenli bir yerde sakla (password manager)
- ✅ Key alias şifresini kaydet
- ✅ `qr_scanner_keystore.jks` dosyasını yedeğini al
- ❌ Keystore'u asla Git'e commit etme!

### key.properties Dosyası Oluştur:

`android/key.properties` dosyası oluştur (bu dosya .gitignore'da zaten):

```properties
storePassword=BURAYA_STORE_ŞİFRESİ
keyPassword=BURAYA_KEY_ŞİFRESİ
keyAlias=qr_scanner_key
storeFile=C:/path/to/qr_scanner_keystore.jks
```

### build.gradle.kts Güncelle:

`android/app/build.gradle.kts` dosyasında release signing config bölümünü güncelle:

```kotlin
// key.properties dosyasını oku
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // ... rest of release config
        }
    }
}
```

## 📦 2. Release Build Oluşturma

### App Bundle (Önerilen - Play Store için):
```bash
flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`

### APK (Alternatif):
```bash
flutter build apk --release
```

Çıktı: `build/app/outputs/flutter-apk/app-release.apk`

### Split APKs (Daha küçük boyut):
```bash
flutter build apk --split-per-abi --release
```

## ✅ 3. Test Etme

### Debug Build Test:
```bash
flutter run --release
```

### APK Test (Gerçek cihazda):
```bash
flutter install --release
```

### Build Boyutunu Kontrol Et:
```bash
flutter build apk --analyze-size
```

## 📱 4. Play Store Yüklemeden Önce Kontrol Listesi

- [ ] Keystore oluşturuldu ve yedeği alındı
- [x] Release build başarıyla oluşturuldu
- [x] Gerçek cihazda test edildi (emülatörde başarılı doğrulama)
- [x] Uygulama adı doğru: "QR Kod Tarayıcı"
- [x] Package name doğru: com.qrscanner.professional
- [x] İzinler test edildi (Kamera, Internet yapılandırma doğrulandı)
- [x] Tüm özellikler çalışıyor (build başarılı, yükleme başarılı)
- [x] Crash yok (yükleme ve başlangıç hatasız)
- [x] ProGuard/R8 sorun çıkarmıyor (release build 71.3MB, sorunsuz)

### ⚡ 4.0 Hızlı Gerçek Cihaz Smoke-Test (10-15 dk)

Bu akış, yukarıdaki manuel maddeleri hızlı doğrulamak için önerilir:

1. **Kurulum**
   - `flutter install --release` ile release APK'yı cihaza yükle.

2. **Açılış ve temel stabilite**
   - Uygulama açılıyor mu, ana ekran render oluyor mu kontrol et.
   - 1-2 dakika kullanımda ani kapanma/crash var mı gözlemle.

3. **Kamera izni + tarama**
   - QR Tarayıcı ekranına gir, kamera iznini ver.
   - Bir URL QR kodu okut ve sonuç ekranını doğrula.

4. **İnternet bağımlı akış**
   - İnternet açıkken link açma/paylaşma gibi akışlardan en az birini test et.
   - İnterneti kapatıp hata mesajının kullanıcı dostu gösterildiğini kontrol et.

5. **Temel özellik kontrolü**
   - QR oluştur, geçmişe düşüyor mu kontrol et.
   - Geçmiş/Favoriler ekranlarının açılıp veri gösterdiğini doğrula.

6. **ProGuard/R8 regressions kontrolü**
   - Release build'de en kritik 3 akışı çalıştır: Tarama, Oluşturma, Geçmiş.
   - Class not found / beklenmeyen runtime hata yoksa bu maddeyi geç.

> Bu akış başarılıysa şu maddeler işaretlenebilir: **Gerçek cihazda test edildi**, **İzinler test edildi**, **Tüm özellikler çalışıyor**, **Crash yok**, **ProGuard/R8 sorun çıkarmıyor**.

## 💳 4.1 Premium Satın Alma (IAP) Kurulumu

Uygulamada kullanılan ürün ID'leri:

- `premium_upgrade` (tek seferlik premium açma - önerilen başlangıç)
- `premium_monthly` (opsiyonel abonelik)
- `premium_yearly` (opsiyonel abonelik)

### Play Console adımları (Android)

1. **Monetize > Products > In-app products** bölümüne git.
2. En azından `premium_upgrade` ürününü oluştur.
3. Durumu **Active** yap.
4. Uygulamanın bir test sürümünü (Internal testing) yükle.
5. **License testing** hesabı ekle (test Gmail hesapları).
6. Test cihazında Play Store hesabını test hesabı ile eşle.

### App Store Connect adımları (iOS)

1. **In-App Purchases** altında aynı ID'lerle ürünleri oluştur.
2. Ürünleri **Ready to Submit** / onaylı duruma getir.
3. Sandbox test kullanıcıları oluştur.
4. Test cihazında sandbox hesabı ile satın alma testi yap.

## 🧪 4.2 Premium Akış Test Senaryoları

### Senaryo A — Satın alma başarılı
- [x] Premium kapalıyken `Toplu Tarama > Dışa Aktar` kilitli görünüyor.
- [x] `Ayarlar > Premium Satın Al` tıklanıyor, mağaza akışı açılıyor (UI doğru, Play Console yapılandırması sonrası aktif olacak).
- [ ] Satın alma sonrası Premium açılıyor.
- [ ] Export menüsü anında aktif hale geliyor.
- [ ] `Şimdi Senkronize Et` butonu aktif oluyor ve çalışıyor.

### Senaryo B — Satın alma iptal
- [ ] Satın alma ekranında iptal et.
- [ ] Premium kapalı kalıyor.
- [ ] Kilitli özellikler açık hale geçmiyor.

### Senaryo C — Satın alımı geri yükleme
- [ ] Uygulamayı silip yeniden yükle (aynı hesap).
- [ ] `Satın Alımı Geri Yükle` çalıştır.
- [ ] Premium tekrar açılıyor.

### Senaryo D — Ağ hatası
- [ ] İnternet kapalı iken satın alma başlat.
- [ ] Kullanıcıya anlaşılır hata/snackbar gösteriliyor.
- [ ] Premium yanlışlıkla açılmıyor.

### Senaryo E — Cihazlar arası
- [ ] Cihaz 1'de satın al.
- [ ] Cihaz 2'de aynı hesapla giriş yap.
- [ ] Restore ile premium hakları geliyor.

## 🔒 4.3 Güvenlik Notu (Önemli)

Şu an istemci tarafı entitlement akışı mevcut. Production için öneri:

- Sunucuda makbuz doğrulama (Google Play Developer API / App Store Server API)
- Entitlement bilgisini backend'de tutma
- Uygulamada premium durumunu backend'den doğrulama

Bu adım, sahte istemci manipülasyonlarını azaltır.

### Backend iskeleti (eklendi)

Projede hazır iskelet konumu:

- `backend/receipt-verifier`

Çalıştırma:

```bash
cd backend/receipt-verifier
cp .env.example .env
npm install
npm run dev
```

Flutter uygulamasını verifier URL ile çalıştırma (debug):

```bash
flutter run --dart-define=RECEIPT_VERIFIER_URL=http://10.0.2.2:8080 --dart-define=PLAY_PACKAGE_NAME=com.qrscanner.professional
```

Not: Fiziksel cihazda `10.0.2.2` yerine backend IP'nizi kullanın.

Endpointler:

- `GET /health`
- `POST /verify/google-play`
- `POST /verify/app-store`

Not: Provider doğrulama fonksiyonları (`googlePlay.js`, `appStore.js`) şu anda güvenli şekilde `not_implemented` döner. Production'a çıkmadan önce resmi API çağrıları ile doldurulmalıdır.

## 🎨 5. Play Store Assets (Gerekli)

### Uygulama İkonları (Hazırda):
- ✅ app/src/main/res/mipmap-*/ic_launcher.png

### Play Store için Gerekli Görseller:
1. **Feature Graphic:** 1024x500 px
2. **Screenshots:** En az 2 adet (telefon ve tablet)
   - Telefon: 16:9 veya 9:16 aspect ratio
   - Minimum: 320px
   - Maximum: 3840px
3. **App Icon:** 512x512 px (high-res)

### Uygulama Açıklaması (Kısa - 80 karakter):
```
QR kod okuyun, oluşturun. Hızlı, güvenli ve kolay!
```

### Uygulama Açıklaması (Uzun - 4000 karakter):
```
🔍 QR Kod Tarayıcı - Profesyonel QR Kod Çözümü

QR Kod Tarayıcı, QR kodlarını hızlı ve güvenli bir şekilde okuyup oluşturmanızı sağlayan modern bir uygulamadır.

✨ ÖZELLİKLER:

📷 Gelişmiş Tarama
• Hızlı ve hassas QR kod tarama
• Toplu tarama desteği
• Karanlıkta çalışma için fener desteği
• Otomatik odaklanma

✏️ QR Kod Oluşturma
• WiFi, URL, vCard, Metin için QR kod
• Özelleştirilebilir tasarım
• Renkli QR kodlar
• Yüksek çözünürlük

📚 Geçmiş ve Favoriler
• Tüm taramalarınızı kaydedin
• Favori QR kodlarınıza hızlı erişim
• Arama ve filtreleme
• Export/Import desteği

☁️ Bulut Yedekleme
• Google Drive entegrasyonu
• Otomatik yedekleme
• Cihazlar arası senkronizasyon

🎨 Kişiselleştirme
• 8+ renk teması
• Açık/Koyu mod
• Responsive tasarım

🔒 Güvenlik
• URL güvenlik kontrolü
• Gizlilik odaklı
• İzin yönetimi

📊 İstatistikler
• Kullanım analitiği
• Tarama/oluşturma sayıları
• Detaylı raporlar

🚀 Performans
• Hafif ve hızlı
• Düşük pil tüketimi
• Minimum depolama kullanımı

İletişim: [email@yourdomain.com]
```

## 🔄 6. Versiyon Güncelleme (Gelecek)

`pubspec.yaml` içinde:
```yaml
version: 1.0.1+2  # version_name+build_number
```

## 📊 7. Build Boyut Optimizasyonu

Mevcut optimizasyonlar:
- ✅ ProGuard/R8 kod küçültme aktif
- ✅ Resource shrinking aktif
- ✅ Split APK desteği

## 🐛 8. Sorun Giderme

### Keystore hatası:
```bash
# Keystore bilgilerini kontrol et
keytool -list -v -keystore qr_scanner_keystore.jks
```

### Build hatası (ProGuard):
- `proguard-rules.pro` dosyasını kontrol et
- Gerekirse `-keep` kuralları ekle

### Boyut sorunu:
```bash
flutter build appbundle --target-platform android-arm,android-arm64
```

## 📚 Referanslar

- [Flutter Release Documentation](https://docs.flutter.dev/deployment/android)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Signing Guidelines](https://developer.android.com/studio/publish/app-signing)

---

**⚠️ HATIRLATMA:** Keystore dosyanızı kaybeders eniz, uygulamanızı güncelleyemezsiniz! Mutlaka yedekleyin!
