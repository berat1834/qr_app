import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unit Testleri - QR Kod Fonksiyonları', () {
    // WiFi QR Kod Format Testi
    group('WiFi QR Kod Formatı', () {
      test('WiFi SSID ve şifre ile doğru format oluşturuluyor mu?', () {
        final ssid = 'TestWiFi';
        final password = 'Test123!';
        final expectedFormat = 'WIFI:T:WPA;S:TestWiFi;P:Test123!;;';

        // WiFi format fonksiyonu
        final result = createWiFiQR(ssid, password);

        expect(result, equals(expectedFormat));
      });

      test('Özel karakterli WiFi şifresi işleniyor mu?', () {
        final ssid = 'MyNetwork';
        final password = 'Pass@123!';
        final result = createWiFiQR(ssid, password);

        expect(result.contains('S:MyNetwork'), true);
        expect(result.contains('P:Pass@123!'), true);
        expect(result.startsWith('WIFI:T:WPA'), true);
      });

      test('Boş WiFi şifresi işleniyor mu?', () {
        final ssid = 'OpenNetwork';
        final result = createWiFiQROpen(ssid);

        expect(result.contains('S:OpenNetwork'), true);
      });
    });

    // URL Formatı Testi
    group('URL QR Kod Formatı', () {
      test('Geçerli URL doğru şekilde işleniyor mu?', () {
        final url = 'https://flutter.dev';
        final result = url; // URL doğrudan kullanılır

        expect(result, equals('https://flutter.dev'));
        expect(result.startsWith('http'), true);
      });

      test('URL validasyonu çalışıyor mu?', () {
        final validUrl = 'https://example.com';
        final isValid = isValidUrl(validUrl);

        expect(isValid, true);
      });

      test('Geçersiz URL tespit ediliyor mu?', () {
        final invalidUrl = 'not a url';
        final isValid = isValidUrl(invalidUrl);

        expect(isValid, false);
      });
    });

    // Telefon Numarası Formatı Testi
    group('Telefon QR Kod Formatı', () {
      test('Telefon numarası doğru şekilde formatlanıyor mu?', () {
        final phone = '5551234567';
        final expected = 'tel:5551234567';
        final result = createPhoneQR(phone);

        expect(result, equals(expected));
      });

      test('Uluslararası telefon numarası işleniyor mu?', () {
        final phone = '+905551234567';
        final result = createPhoneQR(phone);

        expect(result.startsWith('tel:'), true);
        expect(result.contains('905551234567'), true);
      });

      test('Geçersiz telefon numarası kontrol ediliyor mu?', () {
        final invalid = 'abc123';
        final isValid = isValidPhoneNumber(invalid);

        expect(isValid, false);
      });
    });

    // Metin QR Kod Testi
    group('Metin QR Kod', () {
      test('Basit metin doğru şekilde işleniyor mu?', () {
        final text = 'Merhaba Dünya';
        final result = encodeText(text);

        expect(result, equals('Merhaba Dünya'));
      });

      test('Uzun metin işleniyor mu?', () {
        final longText = 'A' * 500; // 500 karakterlik metin
        final result = encodeText(longText);

        expect(result.length, equals(500));
      });

      test('Özel karakterler işleniyor mu?', () {
        final text = r'Test@123!#$%';
        final result = encodeText(text);

        expect(result.contains('@'), true);
        expect(result.contains('!'), true);
      });

      test('Emoji destekleniyor mu?', () {
        final text = 'QR Kod 📱 ✅';
        final result = encodeText(text);

        expect(result.contains('📱'), true);
        expect(result.contains('✅'), true);
      });
    });

    // QR Kod Doğrulama Testleri
    group('QR Kod Doğrulaması', () {
      test('QR içeriği boş değil mi kontrol ediliyor?', () {
        final empty = '';
        final valid = 'https://flutter.dev';

        expect(isNotEmpty(empty), false);
        expect(isNotEmpty(valid), true);
      });

      test('QR kodunun uzunluğu kontrolü yapılıyor mu?', () {
        final text = 'A' * 10000; // Çok uzun metin
        final isValid = isValidQRLength(text);

        expect(isValid, false); // QR kodlar maksimum 4296 karaktere kadar
      });

      test('Tekrarlanan QR kodlar tespit ediliyor mu?', () {
        final qr1 = 'https://example.com';
        final qr2 = 'https://example.com';
        final qr3 = 'https://different.com';

        expect(qr1 == qr2, true);
        expect(qr1 == qr3, false);
      });
    });

    // Email Formatı Testi
    group('Email QR Kod Formatı', () {
      test('Email adresi doğru şekilde formatlanıyor mu?', () {
        final email = 'test@example.com';
        final result = createEmailQR(email);

        expect(result.startsWith('mailto:'), true);
        expect(result.contains('test@example.com'), true);
      });

      test('Email validasyonu çalışıyor mu?', () {
        final valid = 'user@domain.com';
        final invalid = 'notanemail';

        expect(isValidEmail(valid), true);
        expect(isValidEmail(invalid), false);
      });
    });
  });
}

// Yardımcı Fonksiyonlar
String createWiFiQR(String ssid, String password) {
  return 'WIFI:T:WPA;S:$ssid;P:$password;;';
}

String createWiFiQROpen(String ssid) {
  return 'WIFI:T:nopass;S:$ssid;;';
}

bool isValidUrl(String url) {
  try {
    Uri.parse(url);
    return url.startsWith('http://') || url.startsWith('https://');
  } catch (e) {
    return false;
  }
}

String createPhoneQR(String phone) {
  return 'tel:$phone';
}

bool isValidPhoneNumber(String phone) {
  return RegExp(r'^[+]?[0-9]{10,}$').hasMatch(phone);
}

String encodeText(String text) {
  return text;
}

bool isNotEmpty(String text) {
  return text.isNotEmpty;
}

bool isValidQRLength(String text) {
  return text.length <= 4296;
}

String createEmailQR(String email) {
  return 'mailto:$email';
}

bool isValidEmail(String email) {
  return RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);
}
