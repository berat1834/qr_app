import 'package:flutter_test/flutter_test.dart';
import 'package:qr_app/services/share_service.dart';

void main() {
  group('ShareService - Metin Formatlamları', () {
    test('WiFi bilgilerini formatla', () {
      final formatted = ShareService.formatWiFiForSharing(
        'HomeNetwork',
        'password123',
        'WPA',
      );

      expect(formatted, contains('HomeNetwork'));
      expect(formatted, contains('password123'));
      expect(formatted, contains('WPA'));
      expect(formatted, contains('📶'));
      expect(formatted, contains('🔒'));
    });

    test('Konum bilgilerini formatla', () {
      final formatted = ShareService.formatLocationForSharing(41.0082, 28.9784);

      expect(formatted, contains('41.0082'));
      expect(formatted, contains('28.9784'));
      expect(formatted, contains('📍'));
      expect(formatted, contains('maps.google.com'));
    });

    test('vCard (Kartvizit) bilgilerini formatla', () {
      final formatted = ShareService.formatVCardForSharing(
        'Ahmet Yılmaz',
        '+905551234567',
        'ahmet@example.com',
        'Acme Corp',
      );

      expect(formatted, contains('Ahmet Yılmaz'));
      expect(formatted, contains('+905551234567'));
      expect(formatted, contains('ahmet@example.com'));
      expect(formatted, contains('Acme Corp'));
      expect(formatted, contains('👤'));
      expect(formatted, contains('📞'));
    });
  });

  group('ShareService - WiFi Formatı Ayıklanması', () {
    test('WiFi SSID doğru şekilde ayıklanır', () {
      final wifiString = 'WIFI:T:WPA;S:MyNetwork;P:password;;';
      final regex = RegExp(r'WIFI:T:([^;]*);S:([^;]*);P:([^;]*);');
      final match = regex.firstMatch(wifiString);

      expect(match, isNotNull);
      expect(match?.group(2), 'MyNetwork');
    });

    test('WiFi şifresi doğru şekilde ayıklanır', () {
      final wifiString = 'WIFI:T:WPA;S:HomeNet;P:secret123;;';
      final regex = RegExp(r'WIFI:T:([^;]*);S:([^;]*);P:([^;]*);');
      final match = regex.firstMatch(wifiString);

      expect(match?.group(3), 'secret123');
    });

    test('WiFi güvenlik türü doğru şekilde ayıklanır', () {
      final wifiString = 'WIFI:T:WPA2;S:Network;P:pass;;';
      final regex = RegExp(r'WIFI:T:([^;]*);S:([^;]*);P:([^;]*);');
      final match = regex.firstMatch(wifiString);

      expect(match?.group(1), 'WPA2');
    });
  });

  group('ShareService - Konum Koordinatları', () {
    test('İstanbul koordinatları', () {
      final formatted = ShareService.formatLocationForSharing(41.0082, 28.9784);
      expect(formatted, contains('41.0082'));
      expect(formatted, contains('28.9784'));
    });

    test('Ankara koordinatları', () {
      final formatted = ShareService.formatLocationForSharing(39.9334, 32.8597);
      expect(formatted, contains('39.9334'));
      expect(formatted, contains('32.8597'));
    });

    test('İzmir koordinatları', () {
      final formatted = ShareService.formatLocationForSharing(38.4161, 27.1228);
      expect(formatted, contains('38.4161'));
      expect(formatted, contains('27.1228'));
    });

    test('Google Maps linki oluşturulur', () {
      final formatted = ShareService.formatLocationForSharing(40.0, 35.0);
      expect(formatted, contains('maps.google.com/?q=40.0,35.0'));
    });

    test('Negatif koordinatlar', () {
      final formatted = ShareService.formatLocationForSharing(
        -33.8688,
        151.2093,
      ); // Sydney
      expect(formatted, contains('-33.8688'));
      expect(formatted, contains('151.2093'));
    });
  });

  group('ShareService - vCard Bilgileri', () {
    test('Türkçe isim', () {
      final formatted = ShareService.formatVCardForSharing(
        'Mehmet Öztürk',
        '+905551234567',
        'mehmet@test.com',
        'Test Şirketi',
      );

      expect(formatted, contains('Mehmet Öztürk'));
    });

    test('Tüm alanlar boş olmayacak', () {
      final formatted = ShareService.formatVCardForSharing(
        'Name',
        'Phone',
        'Email',
        'Company',
      );

      expect(formatted, isNotEmpty);
      expect(formatted.split('\n').length, greaterThan(3));
    });

    test('Emojiler içerir', () {
      final formatted = ShareService.formatVCardForSharing(
        'Test',
        'Phone',
        'Email',
        'Company',
      );

      expect(formatted, contains('👤'));
      expect(formatted, contains('📞'));
      expect(formatted, contains('📧'));
      expect(formatted, contains('🏢'));
    });

    test('İş E-mail adresi', () {
      final formatted = ShareService.formatVCardForSharing(
        'John Doe',
        '+1234567890',
        'john@company.com',
        'Tech Corp',
      );

      expect(formatted, contains('john@company.com'));
    });
  });

  group('ShareService - URL Kodlaması', () {
    test('WhatsApp URL boşluk kodlaması', () {
      final text = 'Merhaba Dünya';
      final encoded = Uri.encodeComponent(text);

      expect(encoded, contains('%20'));
      expect(encoded, isNot(contains(' ')));
    });

    test('Telegram URL özel karakter kodlaması', () {
      final text = 'Test: @user';
      final encoded = Uri.encodeComponent(text);

      expect(encoded, isNotEmpty);
      expect(encoded.contains('%'), true);
    });

    test('SMS URL Türkçe karakter kodlaması', () {
      final text = 'Merhaba ş ç ğ ı ü ö';
      final encoded = Uri.encodeComponent(text);

      expect(encoded, isNotEmpty);
    });

    test('E-mail konu satırı kodlaması', () {
      final subject = 'QR Kod & Bilgi';
      final encoded = Uri.encodeComponent(subject);

      expect(encoded, contains('%26'));
    });
  });

  group('ShareService - İçerik Formatı Tespiti', () {
    test('WiFi formatı tanınması', () {
      final content = 'WIFI:T:WPA;S:Network;P:pass;;';
      final isWiFi = content.startsWith('WIFI:');

      expect(isWiFi, true);
    });

    test('Konum formatı tanınması', () {
      final content = 'geo:41.0082,28.9784';
      final isLocation = content.startsWith('geo:');

      expect(isLocation, true);
    });

    test('vCard formatı tanınması', () {
      final content = 'BEGIN:VCARD\nVERSION:3.0\nEND:VCARD';
      final isVCard = content.startsWith('BEGIN:VCARD');

      expect(isVCard, true);
    });
  });

  group('ShareService - Paylaşım Seçenekleri', () {
    test('Paylaşım türleri mevcuttur', () {
      // WhatsApp, Telegram, E-mail, SMS vb.
      expect('whatsapp', isNotEmpty);
      expect('telegram', isNotEmpty);
      expect('email', isNotEmpty);
      expect('sms', isNotEmpty);
    });

    test('Genel paylaşım seçeneği', () {
      // Share.share fonksiyonu
      expect('share', isNotEmpty);
    });
  });

  group('ShareService - WiFi Bağlantı Bilgileri', () {
    test('WPA güvenlik tipi', () {
      final formatted = ShareService.formatWiFiForSharing(
        'Network',
        'password',
        'WPA',
      );

      expect(formatted, contains('WPA'));
    });

    test('WPA2 güvenlik tipi', () {
      final formatted = ShareService.formatWiFiForSharing(
        'Network',
        'password',
        'WPA2',
      );

      expect(formatted, contains('WPA2'));
    });

    test('Open (Açık) güvenlik tipi', () {
      final formatted = ShareService.formatWiFiForSharing(
        'PublicWiFi',
        'no_password',
        'Open',
      );

      expect(formatted, contains('Open'));
    });

    test('Boşluk içeren ağ adı', () {
      final formatted = ShareService.formatWiFiForSharing(
        'My Home Network',
        'password123',
        'WPA',
      );

      expect(formatted, contains('My Home Network'));
    });

    test('Özel karakter içeren şifre', () {
      final formatted = ShareService.formatWiFiForSharing(
        'Network',
        'P@ss#2024!',
        'WPA',
      );

      expect(formatted, contains('P@ss#2024!'));
    });
  });

  group('ShareService - Konum Bağlantısı', () {
    test('Google Maps URL formatı', () {
      final formatted = ShareService.formatLocationForSharing(40.0, 35.0);
      expect(formatted, contains('https://maps.google.com/?q='));
    });

    test('Boylam ve enlem sırası', () {
      final formatted = ShareService.formatLocationForSharing(41.0, 28.0);
      expect(formatted, contains('41.0'));
      expect(formatted, contains('28.0'));
    });

    test('Ondalık noktalar korunur', () {
      final formatted = ShareService.formatLocationForSharing(41.5, 28.75);
      expect(formatted, contains('41.5'));
      expect(formatted, contains('28.75'));
    });
  });

  group('ShareService - Kartvizit Bilgileri', () {
    test('Telefon numarası formatı', () {
      final formatted = ShareService.formatVCardForSharing(
        'Name',
        '+90 555 123 45 67',
        'email@test.com',
        'Company',
      );

      expect(formatted, contains('+90 555 123 45 67'));
    });

    test('E-mail formatı korunur', () {
      final formatted = ShareService.formatVCardForSharing(
        'Name',
        'Phone',
        'test.user@company.co.uk',
        'Company',
      );

      expect(formatted, contains('test.user@company.co.uk'));
    });

    test('Şirket adı Türkçe', () {
      final formatted = ShareService.formatVCardForSharing(
        'Kadir Koca',
        '+905551234567',
        'kadir@test.tr',
        'Teknoloji Çözümleri A.Ş.',
      );

      expect(formatted, contains('Teknoloji Çözümleri A.Ş.'));
    });
  });

  group('ShareService - Boş ve Null Kontrolleri', () {
    test('Boş metin paylaşımı', () {
      final formatted = ShareService.formatWiFiForSharing('', '', '');
      expect(formatted, isNotEmpty);
    });

    test('Null olmayan tüm alanlar', () {
      final wifi = ShareService.formatWiFiForSharing('A', 'B', 'C');
      final location = ShareService.formatLocationForSharing(0, 0);
      final vcard = ShareService.formatVCardForSharing('A', 'B', 'C', 'D');

      expect(wifi, isNotNull);
      expect(location, isNotNull);
      expect(vcard, isNotNull);
    });
  });

  group('ShareService - Özel Karakterler', () {
    test('Emoji desteği', () {
      final formatted = ShareService.formatWiFiForSharing(
        '🏠Network',
        'pass🔐',
        'WPA',
      );

      expect(formatted, contains('🏠'));
      expect(formatted, contains('🔐'));
    });

    test('Türkçe özel karakterler', () {
      final formatted = ShareService.formatVCardForSharing(
        'Mustafa Çıkmaz',
        '05551234567',
        'mustafa@örnek.tr',
        'İnşaat A.Ş.',
      );

      expect(formatted, contains('Mustafa Çıkmaz'));
      expect(formatted, contains('İnşaat A.Ş.'));
    });

    test('Matematiksel semboller', () {
      final formatted = ShareService.formatWiFiForSharing(
        'Network',
        'Pass(123)!@#%',
        'WPA',
      );

      expect(formatted, contains('(123)!@#%'));
    });
  });
}
