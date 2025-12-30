import 'package:flutter_test/flutter_test.dart';
import 'package:qr_app/services/security_service.dart';

void main() {
  group('SecurityService - URL Güvenlik Kontrolü', () {
    test('Güvenli domain - Google', () {
      final result = SecurityService.checkUrlSecurity('https://google.com');
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
      expect(result.recommendation, SecurityAction.proceed);
    });

    test('Güvenli domain - YouTube', () {
      final result = SecurityService.checkUrlSecurity(
        'https://youtube.com/watch',
      );
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('Güvenli domain - Flutter', () {
      final result = SecurityService.checkUrlSecurity('https://flutter.dev');
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('Güvenli domain - GitHub', () {
      final result = SecurityService.checkUrlSecurity('https://github.com');
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('Güvenli domain - Microsoft', () {
      final result = SecurityService.checkUrlSecurity('https://microsoft.com');
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });
  });

  group('SecurityService - Zararlı Desen Tespiti', () {
    test('Phishing deseni - zararlı olarak işaretle', () {
      final result = SecurityService.checkUrlSecurity(
        'https://phishing-site.com',
      );
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
      expect(result.recommendation, SecurityAction.block);
    });

    test('Scam deseni - zararlı olarak işaretle', () {
      final result = SecurityService.checkUrlSecurity('https://scamsite.com');
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('Malware deseni - zararlı olarak işaretle', () {
      final result = SecurityService.checkUrlSecurity(
        'https://malware-download.com',
      );
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('Şüpheli domain uzantısı .tk', () {
      final result = SecurityService.checkUrlSecurity('https://example.tk');
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('Şüpheli domain uzantısı .ml', () {
      final result = SecurityService.checkUrlSecurity('https://site.ml');
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('URL shortener - bit.ly', () {
      final result = SecurityService.checkUrlSecurity('https://bit.ly/abc123');
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('URL shortener - tinyurl', () {
      final result = SecurityService.checkUrlSecurity('https://tinyurl.com/x');
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('URL shortener - t.co', () {
      final result = SecurityService.checkUrlSecurity('https://t.co/abc');
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });
  });

  group('SecurityService - HTTPS vs HTTP', () {
    test('HTTP bağlantısı - yüksek risk uyarısı', () {
      final result = SecurityService.checkUrlSecurity('http://example.com');
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
      expect(result.recommendation, SecurityAction.warn);
    });

    test('HTTPS bağlantısı - güvenli', () {
      final result = SecurityService.checkUrlSecurity('https://example.com');
      expect(result.isSafe, isNull); // Belirsiz site
      expect(result.riskLevel, RiskLevel.medium);
    });

    test('HTTP ile güvenli olmayan uyarısı', () {
      final result = SecurityService.checkUrlSecurity('http://website.com');
      expect(result.message, contains('HTTPS'));
      expect(result.riskLevel, RiskLevel.high);
    });
  });

  group('SecurityService - Bilinmeyen Siteler', () {
    test('Bilinmeyen HTTPS site - belirsiz', () {
      final result = SecurityService.checkUrlSecurity(
        'https://unknownsite.com',
      );
      expect(result.isSafe, isNull);
      expect(result.riskLevel, RiskLevel.medium);
      expect(result.recommendation, SecurityAction.warn);
    });

    test('Bilinmeyen site uyarısı detaylandırılı', () {
      final result = SecurityService.checkUrlSecurity('https://newsite.com');
      expect(result.message, isNotEmpty);
      expect(result.details, isNotEmpty);
    });
  });

  group('SecurityService - Hatalı URL Formatları', () {
    test('Geçersiz URL - hata mesajı', () {
      final result = SecurityService.checkUrlSecurity('not a valid url');
      expect(result.riskLevel, RiskLevel.medium);
      expect(result.recommendation, SecurityAction.warn);
    });

    test('Boş URL', () {
      final result = SecurityService.checkUrlSecurity('');
      expect(result.riskLevel, RiskLevel.medium);
    });

    test('Sadece protokol - hatalı', () {
      final result = SecurityService.checkUrlSecurity('https://');
      expect(result.riskLevel, RiskLevel.medium);
    });
  });

  group('SecurityService - URL Büyük/Küçük Harf Duyarsızlığı', () {
    test('Büyük harfli zararlı desen', () {
      final result = SecurityService.checkUrlSecurity(
        'https://PHISHING-SITE.COM',
      );
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('Karışık harfli URL shortener', () {
      final result = SecurityService.checkUrlSecurity('https://Bit.Ly/test');
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('Büyük harfli güvenli domain', () {
      final result = SecurityService.checkUrlSecurity('https://GOOGLE.COM');
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });
  });

  group('SecurityService - Risk Seviyelerine Göre İkon ve Renk', () {
    test('Safe seviyesi ikon - verified_user', () {
      final icon = SecurityService.checkUrlSecurity('https://google.com');
      expect(icon.riskLevel, RiskLevel.safe);
    });

    test('Medium seviyesi - warning ikonu', () {
      final result = SecurityService.checkUrlSecurity(
        'https://unknown-site.org',
      );
      expect(result.riskLevel, RiskLevel.medium);
    });

    test('High seviyesi - dangerous ikonu', () {
      final result = SecurityService.checkUrlSecurity('https://phishing.com');
      expect(result.riskLevel, RiskLevel.high);
    });
  });

  group('SecurityService - SecurityResult Sınıfı', () {
    test('SecurityResult - tüm alanlar doldurulabilir', () {
      final result = SecurityResult(
        isSafe: true,
        riskLevel: RiskLevel.safe,
        message: 'Test mesajı',
        recommendation: SecurityAction.proceed,
        details: 'Detaylı bilgi',
      );

      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
      expect(result.message, 'Test mesajı');
      expect(result.recommendation, SecurityAction.proceed);
      expect(result.details, 'Detaylı bilgi');
    });

    test('SecurityResult - details null olabilir', () {
      final result = SecurityResult(
        isSafe: false,
        riskLevel: RiskLevel.high,
        message: 'Hatalı URL',
        recommendation: SecurityAction.block,
      );

      expect(result.details, isNull);
    });
  });

  group('SecurityService - Gerçek Dünya Senaryoları', () {
    test('LinkedIn güvenli domain', () {
      final result = SecurityService.checkUrlSecurity(
        'https://linkedin.com/in/profile',
      );
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('Wikipedia güvenli domain', () {
      final result = SecurityService.checkUrlSecurity(
        'https://wikipedia.org/wiki/Page',
      );
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('Amazon güvenli domain', () {
      final result = SecurityService.checkUrlSecurity(
        'https://amazon.com/product',
      );
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('Facebook güvenli domain', () {
      final result = SecurityService.checkUrlSecurity(
        'https://facebook.com/page',
      );
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('Twitter güvenli domain', () {
      final result = SecurityService.checkUrlSecurity(
        'https://twitter.com/user',
      );
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('Instagram güvenli domain', () {
      final result = SecurityService.checkUrlSecurity(
        'https://instagram.com/profile',
      );
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });
  });

  group('SecurityService - Enum Değerleri', () {
    test('RiskLevel.safe', () {
      expect(RiskLevel.safe.toString(), 'RiskLevel.safe');
    });

    test('RiskLevel.medium', () {
      expect(RiskLevel.medium.toString(), 'RiskLevel.medium');
    });

    test('RiskLevel.high', () {
      expect(RiskLevel.high.toString(), 'RiskLevel.high');
    });

    test('SecurityAction.proceed', () {
      expect(SecurityAction.proceed.toString(), 'SecurityAction.proceed');
    });

    test('SecurityAction.warn', () {
      expect(SecurityAction.warn.toString(), 'SecurityAction.warn');
    });

    test('SecurityAction.block', () {
      expect(SecurityAction.block.toString(), 'SecurityAction.block');
    });
  });

  group('SecurityService - Desen Eşleştirme Kesinliği', () {
    test('Tam kelime eşleştirme - phishing', () {
      final result = SecurityService.checkUrlSecurity(
        'https://phishing.malicious.com',
      );
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('Bölüm olarak desen - scam', () {
      final result = SecurityService.checkUrlSecurity(
        'https://scamdetection.org',
      );
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('Domain uzantısı eşleştirme', () {
      final result = SecurityService.checkUrlSecurity(
        'https://notmalicious.cf',
      );
      expect(result.isSafe, false);
      expect(result.riskLevel, RiskLevel.high);
    });
  });

  group('SecurityService - URL Parsing', () {
    test('URL host doğru şekilde ayrıştırılır', () {
      final result1 = SecurityService.checkUrlSecurity(
        'https://google.com/search',
      );
      final result2 = SecurityService.checkUrlSecurity(
        'https://youtube.com/watch?v=123',
      );

      expect(result1.isSafe, true);
      expect(result2.isSafe, true);
    });

    test('Subdomain içeren URL', () {
      final result = SecurityService.checkUrlSecurity(
        'https://mail.google.com',
      );
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });

    test('Port içeren URL - Google', () {
      final result = SecurityService.checkUrlSecurity('https://google.com:443');
      expect(result.isSafe, true);
      expect(result.riskLevel, RiskLevel.safe);
    });
  });
}
