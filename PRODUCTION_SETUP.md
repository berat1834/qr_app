# Production Setup Guide / Üretim Kurulum Rehberi

## 📋 Overview / Genel Bilgi

Bu rehber, QR Code uygulamasının **Google Play Store** ve **Apple App Store**'da yayınlanması için gereken tüm adımları içerir.

---

## 1️⃣ Prerequisites / Ön Koşullar

- [x] Geçerli Google Developer Account
- [x] Geçerli Apple Developer Account
- [x] Firebase Project oluşturulmuş
- [x] Backend doğrulama serveri (receipt-verifier) hazır ve deploy edilmiş
- [x] QR Code uygulamasının kodlanmış ve test edilmiş olması

---

## 2️⃣ Firebase Configuration / Firebase Ayarı

### Step 1: Firebase Project Oluşturma

1. [Firebase Console](https://console.firebase.google.com) açın
2. **New Project** → "qr-code-app" adında proje oluşturun
3. **Analytics** etkinleştirin (opsiyonel ama önerilir)

### Step 2: Flutter App Registration / Flutter Uygulamasını Kaydetme

```bash
flutterfire configure --project=qr-code-app
```

Bu komut otomatik olarak:
- `lib/firebase_options.dart` dosyasını günceller (gerçek credentials ile)
- Android konfigürasyonunu ayarlar
- iOS konfigürasyonunu ayarlar
- Gerekli dependencies'i ekler

### Step 3: Firebase Services Etkinleştirme

Firebase Console'da:
1. **Analytics** → Enable
2. **Crashlytics** (optional) → Enable
3. **Cloud Messaging** (optional) → Enable

---

## 3️⃣ Google Play Setup / Google Play Ayarı

### 3.1 Service Account JWT Oluşturma

**Google Play Console → Settings → API access**

1. "Google Cloud Project" linkine tıklayın
2. **IAM and Admin → Service Accounts** açın
3. **Create Service Account** tıklayın
4. Ayrıntıları doldurun:
   - Service account name: `qr-code-verifier`
   - Description: "QR Code App Receipt Verification"

5. Service account oluşturulduktan sonra:
   - **Keys** sekmesine gidin
   - **Add Key → Create new key**
   - **JSON** formatını seçin
   - **Create** tıklayın

6. İndirilen JSON dosyasını **`backend/receipt-verifier/.env`** olarak kaydedin:

```bash
# .env dosyası
GOOGLE_SERVICE_ACCOUNT_JSON='{"type":"service_account","project_id":"...","private_key":"...","client_email":"...","client_id":"...","auth_uri":"...","token_uri":"...","auth_provider_x509_cert_url":"...","client_x509_cert_url":"..."}'
```

### 3.2 Service Account Permissions / İzinler

Google Cloud Console'da:
1. **IAM → Edit Member**
2. Service account'u seçin
3. **Close** (zaten Editor role var, yeterli)

**Google Play Console → Settings → Users and permissions:**
1. Service account'un email'ini bulun
2. **Admin (all permissions)** rolü verin

### 3.3 In-App Products Setup / IAP Ürünleri

1. **Google Play Console → Your app → Products → In-app products**

2. Üç ürün oluşturun:

| Product ID | Type | Name | Price |
|-----------|------|------|-------|
| `premium_upgrade` | One-time | Premium Upgrade | $9.99 |
| `premium_monthly` | Subscription | Premium Monthly | $2.99/ay |
| `premium_yearly` | Subscription | Premium Yearly | $19.99/yıl |

3. Her ürün için:
   - **Ürün detaylarını doldurun** (açıklama, resim vb.)
   - **Pricing**'i ayarlayın
   - **Draft** → **Activate** yapın

### 3.4 Android App Configuration / Android Uygulaması

**Flutter app'in:**

```bash
cd android
./gradlew signedApk  # İmzalı APK oluştur
```

Veya **keystore** kullanarak:

```bash
keytool -genkey -v -keystore ~/qrcode-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias qrcode
```

`android/key.properties` config:
```properties
storeFile=/path/to/qrcode-key.jks
storePassword=your_store_password
keyAlias=qrcode
keyPassword=your_key_password
```

---

## 4️⃣ Apple App Store Setup / Apple App Store Ayarı

### 4.1 App Store Connect Shared Secret / Gizli Anahtarı

1. **App Store Connect → Users and Access → API Keys**
2. **In-App Purchase Shared Secret** → **View** veya **Generate**
3. Gizli anahtarı kopyalayın

`backend/receipt-verifier/.env`'ye ekleyin:
```bash
APPLE_SHARED_SECRET='your_shared_secret_here'
```

### 4.2 In-App Products Setup / IAP Ürünleri

1. **App Store Connect → Your app → In-App Purchases**

2. Üç ürün oluşturun (Google Play'de olduğu gibi):

| Product ID | Type | Name | Price |
|-----------|------|------|-------|
| `premium_upgrade` | Non-Consumable | Premium Upgrade | $9.99 |
| `premium_monthly` | Auto-Renewing Subscription | Premium Monthly | $2.99/ay |
| `premium_yearly` | Auto-Renewing Subscription | Premium Yearly | $19.99/yıl |

3. Her ürün için:
   - **Ürün detaylarını** doldurun (açıklama, note, kategori)
   - **Pricing and Availability** ayarlayın
   - **Status** → **Ready to Submit** yapın

### 4.3 Bundle ID Registry

1. **Certificates, Identifiers & Profiles → Identifiers**
2. Bundle ID: `com.qrscanner.professional`
3. **Capabilities** ekleyin:
   - [x] **Push Notifications** (isteğe bağlı)
   - [x] **In-App Purchase**

### 4.4 TestFlight Beta Testing (Önerilir)

1. Uygulamayı içetmeden önce **TestFlight**'da test edin
2. **Builds → Select build**
3. **Add Groups → Internal Testers**
4. Test kullanıcılarını davet edin
5. **Sandbox tester account** oluşturun:
   - **Users and Access → Testers → Sandbox Testers**
   - Email, password, country bilgisi girin
   - Uygulamada test satın alması yapabilir (Gerçek para yok!)

---

## 5️⃣ Backend Configuration / Backend Ayarı

### 5.1 Environment Variables

`backend/receipt-verifier/.env` dosyasını yapılandırın:

```bash
# Google Play
GOOGLE_SERVICE_ACCOUNT_JSON='paste_full_json_here'
PLAY_PACKAGE_NAME=com.qrscanner.professional

# Apple
APPLE_SHARED_SECRET=your_shared_secret

# Server
PORT=8080
NODE_ENV=production
LOG_LEVEL=info

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000  # 15 min
RATE_LIMIT_MAX_REQUESTS=100   # per IP+packageName
```

### 5.2 Deploy Backend

**Option 1: AWS Lambda + API Gateway**

```bash
cd backend/receipt-verifier
npm install --production
zip -r lambda-package.zip node_modules src package.json

# AWS Console → Lambda → Create function
# Upload zip, set handler to src/server.handler
# Trigger: API Gateway (REST API)
```

**Option 2: Heroku**

```bash
cd backend/receipt-verifier
heroku create qrcode-receipt-verifier
git push heroku main
heroku config:set GOOGLE_SERVICE_ACCOUNT_JSON='...'
heroku config:set APPLE_SHARED_SECRET='...'
```

**Option 3: Docker**

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY src ./src
EXPOSE 8080
CMD ["node", "src/server.js"]
```

```bash
docker build -t qrcode-verifier .
docker run -p 8080:8080 \
  -e GOOGLE_SERVICE_ACCOUNT_JSON='...' \
  -e APPLE_SHARED_SECRET='...' \
  qrcode-verifier
```

### 5.3 Test Backend Endpoints

**Terminal'den test edin:**

```bash
# Google Play Test
curl -X POST http://localhost:8080/verify/google-play \
  -H "Content-Type: application/json" \
  -d '{
    "packageName":"com.qrscanner.professional",
    "productId":"premium_upgrade",
    "purchaseToken":"test_token_12345",
    "userId":null
  }'

# Expected response: {"ok":false} (test token geçerli değil)

# Apple Test
curl -X POST http://localhost:8080/verify/app-store \
  -H "Content-Type: application/json" \
  -d '{
    "receiptData":"test_receipt_data",
    "productId":"premium_upgrade",
    "transactionId":"test_tx_id",
    "userId":null
  }'

# Expected response: {"ok":false} (test receipt geçerli değil)
```

---

## 6️⃣ Flutter app Configuration / Flutter Uygulaması Ayarı

### 6.1 Firebase Configuration

`firebase_options.dart` dosyası otomatik olarak `flutterfire configure` ile oluşturulur.

Eğer manuel oluşturmak gerekirse:
- Android: SHA1 certificate fingerprint gerekli (Google Play Console'da)
- iOS: Bundle ID ve Team ID gerekli

### 6.2 Backend URL Configuration

**Release build'de** sabit URL kullanın:

```bash
flutter build apk --dart-define=RECEIPT_VERIFIER_URL=https://your-backend-domain.com

flutter build ipa --dart-define=RECEIPT_VERIFIER_URL=https://your-backend-domain.com
```

Veya `pubspec.yaml` definesine ekleyin:

```yaml
flutter:
  environment:
    RECEIPT_VERIFIER_URL: "https://your-backend-domain.com"
```

### 6.3 Package Name Configuration

`android/app/build.gradle`:
```gradle
android {
  defaultConfig {
    applicationId "com.qrscanner.professional"
  }
}
```

`ios/Runner/Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.qrscanner.professional</string>
```

---

## 7️⃣ Testing Before Release / Yayınlanmadan Önce Test

### 7.1 Local Testing (Emulator/Simulator)

```bash
# Android Emulator
flutter run -d emulator-5554 --dart-define=RECEIPT_VERIFIER_URL=http://10.0.2.2:8080

# iOS Simulator
flutter run -d iPhone\ 15
```

### 7.2 TestFlight / Google Play Internal Testing

**Google Play:**
1. Upload APK → **Internal Testing → Add Testers**
2. Gelen test linkini aç ve test et

**Apple TestFlight:**
1. Upload IPA → **TestFlight → Add tester**
2. TestFlight uygulamasıyla test et

### 7.3 Test Scenarios

**Scenario 1: Successful Purchase**
- Payment method'u ekle
- Premium satın al
- ✅ Premium aktif olmalı
- ✅ Bulut sync'i aktif olmalı
- ✅ Analytics: purchase_success event'i log edilmeli

**Scenario 2: Failed Verification**
- Online verifikasyonu kapatarak ağ hatasını simüle et
- Premium satın almayı dene
- ✅ Hata dialog'u görülmeli: "Sunucuya erişim başarısız..."
- ✅ Analytics: purchase_failed event'i log edilmeli

**Scenario 3: Restore Purchase**
- Farklı cihazda geri yükle
- ✅ Premium aktif olmalı
- ✅ Analytics: restore_success event'i log edilmeli

**Scenario 4: Subscription Renewal**
- TestFlight/Sandbox'da abonelik satın al
- Sandbox ortamında 24 saat bekle (otomatik dönemez)
- ✅ İş mantığında yenileme kontrol edilmeli

---

## 8️⃣ Submission to Stores / Mağazalara Yayınlama

### 8.1 Google Play Console

1. **Create Release → Name it (e.g., "1.0.0")**
2. **Add APK/Bundle** → Release APK'yı upload et
3. **Release Notes** ekle (Turkish + English)
4. **Review** → Submit for Review
5. **Status**: Auto-review (tipik 24-48 saat)

### 8.2 Apple App Store

1. **App Store Connect → Prepare for Submission**
2. **Build** → Upload edilmiş IPA'yı seç
3. **App Information** → Complete all sections
4. **Pricing & Availability** → Select sales territories
5. **Submit for Review**
6. **Status**: Manual review (tipik 24-48 saat)

---

## 9️⃣ Post-Release Monitoring / Yayınlamadan Sonra İzleme

### Analytics Dashboard
- **Firebase Console → Analytics** açın
- Satın alma funnelini izle:
  - `paywall_open` → `purchase_start` → `purchase_success` ratio'su
- Hata oranlarını kontrol et:
  - `purchase_failed` events'ini analiz et
  - Common error codes'u identifiye et

### Crash Monitoring
- **Firebase Console → Crashlytics**
- Hataların trend'ini izle
- Kritik issues için remediation plan yap

### User Support
- **Email**: Kullanıcılarla doğrudan iletişim kur
- **Logs**: Backend'de doğrulama hatalarını log et
  - `/var/log/receipt-verifier.log`
  - Hatalı package_name veya product_id'leri track et

---

## 🔟 Security Best Practices / Güvenlik

### ⚠️ Never Commit to Repo:
- ❌ `.env` dosyasının contentini GitHub'a commit'leme
- ❌ `firebase_options.dart`'ın production credentials'ını
- ❌ Service account JSON'unu

### ✅ Do This:
1. **`.env` file'ını `.gitignore`'e ekle**
2. **Credentials'ı environment variables kullan**
3. **HTTPS'yi her zaman kullan** (backend URL'leri)
4. **Rate limiting** etkinleştir (backend'de)
5. **API keys'i rotate et** (Google/Apple)
6. **Server logs'ı monitor et** doğrulama başarısızlıkları için
7. **Database backup'ları al** production'dan

---

## 📚 Resources / Kaynaklar

- [Google Play Console Documentation](https://support.google.com/googleplay/android-developer)
- [Apple App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [In-App Purchase Best Practices](https://developer.google.com/android/google-play/billing/getting-started)
- [Apple In-App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

## ❓ Troubleshooting

**Q: Google Play verifikasyonu başarısız (401/403)**
- ✅ Service account'un Google Play Console'da "Admin" rol'ü var mı?
- ✅ Service account email'i Google Play Console'da authorized mı?
- ✅ JSON file'ı doğru format'ta (.env'de)?

**Q: Apple verifikasyonu Her Zaman Fail (21007)**
- ✅ Bu sandbox test durumu - normal!
- ✅ Production ortamında retry mekanizması var
- ✅ testFlightApp'te test et

**Q: Analytics events'i görülmüyor**
- ✅ Firebase Console'da Analytics enabled mı?
- ✅ Emulator/cihazda internet bağlantısı var mı?
- ✅ `logEvent()` call'ları async awaitted mi?

**Q: Backend'e bağlanamıyor (10.0.2.2)**
- ✅Emulator'da `10.0.2.2:8080` kullan (localhost değil!)
- ✅ Fiziksel cihazda backend'in IP adresini kullan
- ✅ Firewall'u kontrol et

