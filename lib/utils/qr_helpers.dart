/// QR Kod İşlemleri - Parser, Generator, Validator
/// Tüm QR kod türlerinin oluşturulması, ayrıştırılması ve işlenmesi
library;

class QRCodeUtils {
  // ============= QR TÜRÜ TESPİTİ =============

  /// QR kod türünü tespit et
  static String detectQRType(String content) {
    final normalized = content.trim().replaceAll(
      RegExp(r'[\u0000-\u001F\s]+'),
      '',
    );

    if (content.startsWith('http://') || content.startsWith('https://')) {
      return 'URL';
    } else if (content.startsWith('WIFI:')) {
      return 'WiFi';
    } else if (content.startsWith('tel:')) {
      return 'Telefon';
    } else if (content.startsWith('mailto:')) {
      return 'E-mail';
    } else if (content.startsWith('sms:')) {
      return 'SMS';
    } else if (content.startsWith('geo:')) {
      return 'Konum';
    } else if (content.startsWith('BEGIN:VCARD')) {
      return 'Kartvizit';
    } else if (content.startsWith('BEGIN:VEVENT')) {
      return 'Etkinlik';
    } else if (content.startsWith('MECARD:')) {
      return 'Kartvizit';
    } else if (RegExp(r'^\d{8,14}$').hasMatch(normalized)) {
      return 'Barkod';
    } else {
      return 'Metin';
    }
  }

  /// Alias: determineQRType (geriye uyumluluk)
  static String determineQRType(String data) => detectQRType(data);

  // ============= WiFi QR İŞLEMLERİ =============

  /// WiFi QR kodu oluştur
  static String createWiFiQR({
    required String ssid,
    required String password,
    required String security, // WPA, WEP, nopass
    bool hidden = false,
  }) {
    return 'WIFI:T:$security;S:$ssid;P:$password;H:${hidden ? 'true' : 'false'};;';
  }

  /// Alias: generateWiFiQR (geriye uyumluluk)
  static String generateWiFiQR({
    required String ssid,
    required String password,
    required String security,
  }) {
    return createWiFiQR(ssid: ssid, password: password, security: security);
  }

  /// WiFi QR kodunu parse et
  static Map<String, String>? parseWiFiQR(String content) {
    if (!content.startsWith('WIFI:')) return null;

    final Map<String, String> result = {};
    final String data = content.substring(5); // "WIFI:" kısmını çıkar

    // T:WPA;S:NetworkName;P:password;H:false;;
    final RegExp regex = RegExp(r'([TSPH]):([^;]*);');
    final Iterable<RegExpMatch> matches = regex.allMatches(data);

    for (final match in matches) {
      final String key = match.group(1)!;
      final String value = match.group(2)!;

      switch (key) {
        case 'T':
          result['security'] = value;
          break;
        case 'S':
          result['ssid'] = value;
          break;
        case 'P':
          result['password'] = value;
          break;
        case 'H':
          result['hidden'] = value;
          break;
      }
    }

    return result;
  }

  // ============= vCard (KARTVİZİT) QR İŞLEMLERİ =============

  /// vCard (Kartvizit) QR kodu oluştur - Detaylı versiyon
  static String createVCardQR({
    required String firstName,
    required String lastName,
    String? organization,
    String? phone,
    String? email,
    String? url,
    String? address,
  }) {
    final StringBuffer vcard = StringBuffer();
    vcard.writeln('BEGIN:VCARD');
    vcard.writeln('VERSION:3.0');
    vcard.writeln('FN:$firstName $lastName');
    vcard.writeln('N:$lastName;$firstName;;;');

    if (organization != null && organization.isNotEmpty) {
      vcard.writeln('ORG:$organization');
    }
    if (phone != null && phone.isNotEmpty) {
      vcard.writeln('TEL:$phone');
    }
    if (email != null && email.isNotEmpty) {
      vcard.writeln('EMAIL:$email');
    }
    if (url != null && url.isNotEmpty) {
      vcard.writeln('URL:$url');
    }
    if (address != null && address.isNotEmpty) {
      vcard.writeln('ADR:;;$address;;;;');
    }

    vcard.writeln('END:VCARD');
    return vcard.toString();
  }

  /// vCard QR kodu oluştur - Basit versiyon
  static String generateVCardQR({
    required String name,
    String? phone,
    String? email,
    String? organization,
    String? url,
  }) {
    final List<String> lines = ['BEGIN:VCARD', 'VERSION:3.0'];

    if (name.isNotEmpty) lines.add('FN:$name');
    if (phone != null && phone.isNotEmpty) lines.add('TEL:$phone');
    if (email != null && email.isNotEmpty) lines.add('EMAIL:$email');
    if (organization != null && organization.isNotEmpty) {
      lines.add('ORG:$organization');
    }
    if (url != null && url.isNotEmpty) lines.add('URL:$url');

    lines.add('END:VCARD');

    return lines.join('\n');
  }

  /// vCard bilgilerini parse et
  static Map<String, String>? parseVCardQR(String content) {
    if (!content.startsWith('BEGIN:VCARD')) return null;

    final Map<String, String> result = {};
    final List<String> lines = content.split('\n');

    for (final line in lines) {
      if (line.contains(':')) {
        final List<String> parts = line.split(':');
        if (parts.length >= 2) {
          final String key = parts[0].trim();
          final String value = parts.sublist(1).join(':').trim();

          switch (key) {
            case 'FN':
              result['fullName'] = value;
              result['name'] = value;
              break;
            case 'ORG':
              result['organization'] = value;
              break;
            case 'TEL':
              result['phone'] = value;
              break;
            case 'EMAIL':
              result['email'] = value;
              break;
            case 'URL':
              result['url'] = value;
              break;
          }
        }
      }
    }

    return result;
  }

  // ============= KONUM QR İŞLEMLERİ =============

  /// Konum QR kodu oluştur
  static String createLocationQR({
    required double latitude,
    required double longitude,
    double? altitude,
  }) {
    if (altitude != null) {
      return 'geo:$latitude,$longitude,$altitude';
    } else {
      return 'geo:$latitude,$longitude';
    }
  }

  /// Alias: generateLocationQR
  static String generateLocationQR({
    required double latitude,
    required double longitude,
  }) {
    return createLocationQR(latitude: latitude, longitude: longitude);
  }

  /// Konum QR kodunu parse et
  static Map<String, double>? parseLocationQR(String content) {
    if (!content.startsWith('geo:')) return null;

    final String data = content.substring(4); // "geo:" kısmını çıkar
    final List<String> parts = data.split(',');

    if (parts.length >= 2) {
      try {
        final double latitude = double.parse(parts[0]);
        final double longitude = double.parse(parts[1]);
        final Map<String, double> result = {
          'latitude': latitude,
          'longitude': longitude,
        };

        if (parts.length >= 3) {
          result['altitude'] = double.parse(parts[2]);
        }

        return result;
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  // ============= E-MAİL QR İŞLEMLERİ =============

  /// E-mail QR kodu oluştur
  static String createEmailQR({
    required String email,
    String? subject,
    String? body,
  }) {
    final StringBuffer emailQR = StringBuffer();
    emailQR.write('mailto:$email');

    final List<String> params = [];
    if (subject != null && subject.isNotEmpty) {
      params.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body != null && body.isNotEmpty) {
      params.add('body=${Uri.encodeComponent(body)}');
    }

    if (params.isNotEmpty) {
      emailQR.write('?${params.join('&')}');
    }

    return emailQR.toString();
  }

  // ============= SMS QR İŞLEMLERİ =============

  /// SMS QR kodu oluştur
  static String createSMSQR({required String phoneNumber, String? message}) {
    if (message != null && message.isNotEmpty) {
      return 'sms:$phoneNumber?body=${Uri.encodeComponent(message)}';
    } else {
      return 'sms:$phoneNumber';
    }
  }

  // ============= DOĞRULAMA VE KONTROL =============

  /// QR kod verisi geçerli mi kontrol et
  static bool isValidQRData(String data) {
    return data.trim().isNotEmpty;
  }

  /// QR kod içeriğini kısalt (önizleme için)
  static String truncateQRData(String data, {int maxLength = 50}) {
    if (data.length <= maxLength) return data;
    return '${data.substring(0, maxLength)}...';
  }
}
