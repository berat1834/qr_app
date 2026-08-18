# Production Hazirlik Durumu (2026-04-19)

Bu dokuman, bugune kadar yapilanlari ve yayina cikmadan once tamamlanacak maddeleri takip etmek icin olusturuldu.

## 1) Bugun Tamamlananlar

- Emulator uzerinde gorsel dogrulama tamamlandi:
  - Home ekrani: Ingilizce metinler dogrulandi.
  - Home ekrani: Premium kartinin kaldirildigi dogrulandi.
  - Settings ekrani: Ingilizce metinler dogrulandi.
  - Premium ekrani: Ingilizce metinler dogrulandi.
  - Favorites ekrani: Ingilizce metinler dogrulandi.
  - Rate App akisi: Emulator ortaminda beklenen sekilde (Play Store yok) davranis gozlemlendi.

- Ekran goruntusu alma sorunu cozuldu:
  - Sorunlu yontem: `adb exec-out screencap -p > file.png` (PowerShell encoding bozulmasi)
  - Dogru yontem: `adb shell screencap -p /sdcard/x.png` + `adb pull`

- Onboarding bypass dogrulama icin kontrol edildi ve test akisinda ana ekrana gecis saglandi.

## 2) Objektif Teknik Tespitler

### AdMob (Kritik)
- Android manifestte test App ID gorunuyor.
- Manifestte AdMob meta-data bolgesindeki bozuk/fazla satir temizlendi.
- Android manifest AdMob App ID alani placeholder yapisina gecirildi (`${ADMOB_APP_ID}`).
- Android Gradle tarafina `ADMOB_APP_ID` icin property/env fallback eklendi.
- Reklam unit IDleri varsayilan olarak test IDye dusuyor.
- Kodda release modda production ID yoksa reklam gostermeme guvenligi var (olumlu).

### IAP ve Receipt Verification
- Kod tabaninda providerlar artik not_implemented degil; Google Play ve Apple verify akislari uygulanmis gorunuyor.
- Uygulama satin alma dogrulamasini backend uzerinden yapiyor.
- Buna ragmen endpoint auth sertlestirmesi ve production env dogrulamasi zorunlu.

### Release Konfigurasyonu
- `RECEIPT_VERIFIER_URL` release icin zorunlu kabul edilmeli.
- `PLAY_PACKAGE_NAME` production degeri ile sabitlenmeli.

### Privacy Policy ve Store Compliance
- Uygulama icinde privacy policy linki var.
- Play Console listingte de gecerli privacy policy URL olmasi zorunlu.

### Price Comparison
- Serviste cache var ancak kodda mock/temsil verisi notlari oldugu icin production entegrasyonu netlestirilmeli.

## 3) Siradaki Isler (Oncelik Sirasi)

1. Manifest ve AdMob production gecisi
   - Test App ID -> Gercek App ID
   - Bozuk manifest satirinin temizlenmesi
   - Build define ile gercek banner/native unit ID verilmesi

2. IAP backend hardening
   - Verifier endpointlerine auth katmani ekleme (API key veya imzali istek)
   - Production env degerlerini dogrulama
   - Gercek satin alma ile e2e test

3. Release pipeline garantileri
   - `RECEIPT_VERIFIER_URL` zorunlu degilse build fail
   - Production package/config tutarliligi

4. Store compliance
   - Privacy policy URL kontrolu (app + Play Console)
   - Data Safety formu ve izin beyanlari

5. Final go/no-go smoke test
   - Scan/Create/Favorites/Settings/Premium/Restore/Ads/Rate App/Crash kontrol listesi

## 4) Bugunden Sonraki Hedef

Ilk teknik adim olarak Android manifestteki AdMob bolgesi temizlenecek ve production ID gecisine uygun hale getirilecek.
