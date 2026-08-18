import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum OCRTextType { phoneNumber, email, url, address, date, price, general }

class OCRTextInfo {
  final String text;
  final OCRTextType type;
  final String cleanedText;
  final Map<String, dynamic> metadata;
  final Rect? boundingBox;

  OCRTextInfo({
    required this.text,
    required this.type,
    required this.cleanedText,
    required this.metadata,
    this.boundingBox,
  });

  factory OCRTextInfo.fromJson(Map<String, dynamic> json) {
    return OCRTextInfo(
      text: json['text'] ?? '',
      type: OCRTextType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OCRTextType.general,
      ),
      cleanedText: json['cleanedText'] ?? '',
      metadata: json['metadata'] ?? {},
      boundingBox: json['boundingBox'] != null
          ? Rect.fromLTRB(
              json['boundingBox']['left'].toDouble(),
              json['boundingBox']['top'].toDouble(),
              json['boundingBox']['right'].toDouble(),
              json['boundingBox']['bottom'].toDouble(),
            )
          : null,
    );
  }
}

class OCRResult {
  final bool success;
  final List<OCRTextInfo> textInfos;
  final String? error;
  final String? rawText;

  OCRResult({
    required this.success,
    required this.textInfos,
    this.error,
    this.rawText,
  });
}

class OCRService {
  static const String _channelName = 'qr_app/ocr_service';
  static const MethodChannel _methodChannel = MethodChannel(_channelName);

  // Regex patterns for different text types
  static final Map<OCRTextType, RegExp> _patterns = {
    OCRTextType.phoneNumber: RegExp(
      r'(?:\+90\s?)?(?:\(0\d{3}\)\s?|\d{3}[-.\s]?)?\d{3}[-.\s]?\d{2}[-.\s]?\d{2}',
    ),
    OCRTextType.email: RegExp(
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    ),
    OCRTextType.url: RegExp(
      r'https?:\/\/(?:[-\w.])+(?:\:[0-9]+)?(?:\/(?:[\w\/_.])*(?:\?(?:[\w&=%.])*)?(?:\#(?:[\w.])*)?)?|(?:www\.)?[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}',
    ),
    OCRTextType.price: RegExp(
      r'(?:₺|TL|EUR|USD|\$|€)\s?\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?|\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?\s?(?:₺|TL|EUR|USD|\$|€)',
    ),
    OCRTextType.date: RegExp(
      r'\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}|\d{1,2}\s(?:Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s\d{4}',
    ),
  };

  /// Kameradan görüntü yakala ve OCR işlemi yap
  static Future<OCRResult> captureAndProcessImage() async {
    try {
      final result = await _methodChannel.invokeMethod(
        'captureAndProcessImage',
      );

      if (result != null && result['success'] == true) {
        final rawText = result['text'] as String? ?? '';
        final textInfos = _extractTextInfo(rawText);

        return OCRResult(success: true, textInfos: textInfos, rawText: rawText);
      } else {
        return OCRResult(
          success: false,
          textInfos: [],
          error: result?['error'] ?? 'OCR işlemi başarısız',
        );
      }
    } on PlatformException catch (e) {
      return OCRResult(
        success: false,
        textInfos: [],
        error: 'OCR hatası: ${e.message}',
      );
    }
  }

  /// Mevcut görüntü dosyasından OCR işlemi yap
  static Future<OCRResult> processImageFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await processImageBytes(bytes);
    } catch (e) {
      return OCRResult(
        success: false,
        textInfos: [],
        error: 'Dosya okuma hatası: $e',
      );
    }
  }

  /// Byte array'den OCR işlemi yap
  static Future<OCRResult> processImageBytes(Uint8List imageBytes) async {
    try {
      final result = await _methodChannel.invokeMethod('processImageBytes', {
        'imageBytes': imageBytes,
      });

      if (result != null && result['success'] == true) {
        final rawText = result['text'] as String? ?? '';
        final textInfos = _extractTextInfo(rawText);

        return OCRResult(success: true, textInfos: textInfos, rawText: rawText);
      } else {
        return OCRResult(
          success: false,
          textInfos: [],
          error: result?['error'] ?? 'OCR işlemi başarısız',
        );
      }
    } on PlatformException catch (e) {
      return OCRResult(
        success: false,
        textInfos: [],
        error: 'OCR hatası: ${e.message}',
      );
    }
  }

  /// OCR ile algılanan metinden farklı bilgi türlerini çıkar
  static List<OCRTextInfo> _extractTextInfo(String text) {
    final List<OCRTextInfo> textInfos = [];

    for (final entry in _patterns.entries) {
      final matches = entry.value.allMatches(text);

      for (final match in matches) {
        final matchedText = match.group(0) ?? '';
        final cleanedText = _cleanText(matchedText, entry.key);
        final metadata = _generateMetadata(cleanedText, entry.key);

        textInfos.add(
          OCRTextInfo(
            text: matchedText,
            type: entry.key,
            cleanedText: cleanedText,
            metadata: metadata,
          ),
        );
      }
    }

    return textInfos;
  }

  /// Metni türüne göre temizle
  static String _cleanText(String text, OCRTextType type) {
    switch (type) {
      case OCRTextType.phoneNumber:
        return text
            .replaceAll(RegExp(r'[^\d+]'), '')
            .replaceFirst(RegExp(r'^0'), '+90');
      case OCRTextType.email:
        return text.toLowerCase().trim();
      case OCRTextType.url:
        if (!text.startsWith('http')) {
          return text.startsWith('www.')
              ? 'https://$text'
              : 'https://www.$text';
        }
        return text;
      case OCRTextType.price:
        return text.replaceAll(RegExp(r'[^\d,.]'), '');
      default:
        return text.trim();
    }
  }

  /// Metin türüne göre metadata oluştur
  static Map<String, dynamic> _generateMetadata(
    String cleanedText,
    OCRTextType type,
  ) {
    switch (type) {
      case OCRTextType.phoneNumber:
        return {
          'formatted': _formatPhoneNumber(cleanedText),
          'country': cleanedText.startsWith('+90') ? 'TR' : 'Unknown',
          'actionable': true,
        };
      case OCRTextType.email:
        return {'domain': cleanedText.split('@').last, 'actionable': true};
      case OCRTextType.url:
        return {
          'domain': Uri.tryParse(cleanedText)?.host ?? '',
          'actionable': true,
        };
      case OCRTextType.price:
        return {
          'currency': _detectCurrency(cleanedText),
          'amount': _extractAmount(cleanedText),
          'actionable': false,
        };
      case OCRTextType.date:
        return {'parsed': _parseDate(cleanedText), 'actionable': false};
      default:
        return {'actionable': false};
    }
  }

  /// Telefon numarası formatla
  static String _formatPhoneNumber(String phone) {
    if (phone.startsWith('+90')) {
      phone = phone.substring(3);
    }
    if (phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6, 8)}-${phone.substring(8)}';
    }
    return phone;
  }

  /// Para birimi tespit et
  static String _detectCurrency(String priceText) {
    if (priceText.contains('₺') || priceText.contains('TL')) return 'TRY';
    if (priceText.contains('\$') || priceText.contains('USD')) return 'USD';
    if (priceText.contains('€') || priceText.contains('EUR')) return 'EUR';
    return 'TRY'; // Default
  }

  /// Fiyattan miktarı çıkar
  static double _extractAmount(String priceText) {
    final numbers = priceText.replaceAll(RegExp(r'[^\d,.]'), '');
    return double.tryParse(numbers.replaceAll(',', '.')) ?? 0.0;
  }

  /// Tarihi parse et
  static DateTime? _parseDate(String dateText) {
    // Basit tarih parse işlemi - daha kapsamlı yapılabilir
    final parts = dateText.split(RegExp(r'[\/\-\.]'));
    if (parts.length >= 3) {
      final day = int.tryParse(parts[0]) ?? 1;
      final month = int.tryParse(parts[1]) ?? 1;
      final year = int.tryParse(parts[2]) ?? DateTime.now().year;
      return DateTime(year, month, day);
    }
    return null;
  }

  /// OCR servisinin kullanılabilirlik durumunu kontrol et
  static Future<bool> isOCRAvailable() async {
    try {
      final result = await _methodChannel.invokeMethod('checkOCRAvailability');
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('OCR kullanılabilirlik kontrol hatası: ${e.message}');
      return false;
    }
  }

  /// Canlı OCR modu başlat (kamera preview'da sürekli OCR)
  static Future<bool> startLiveOCR() async {
    try {
      final result = await _methodChannel.invokeMethod('startLiveOCR');
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Canlı OCR başlatma hatası: ${e.message}');
      return false;
    }
  }

  /// Canlı OCR modunu durdur
  static Future<void> stopLiveOCR() async {
    try {
      await _methodChannel.invokeMethod('stopLiveOCR');
    } on PlatformException catch (e) {
      debugPrint('Canlı OCR durdurma hatası: ${e.message}');
    }
  }

  /// Telefon numarasını ara
  static Future<void> makePhoneCall(String phoneNumber) async {
    try {
      await _methodChannel.invokeMethod('makePhoneCall', {
        'phoneNumber': phoneNumber,
      });
    } on PlatformException catch (e) {
      debugPrint('Telefon arama hatası: ${e.message}');
    }
  }

  /// E-posta gönder
  static Future<void> sendEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    try {
      await _methodChannel.invokeMethod('sendEmail', {
        'email': email,
        'subject': subject ?? '',
        'body': body ?? '',
      });
    } on PlatformException catch (e) {
      debugPrint('E-posta gönderme hatası: ${e.message}');
    }
  }

  /// URL'yi aç
  static Future<void> openUrl(String url) async {
    try {
      await _methodChannel.invokeMethod('openUrl', {'url': url});
    } on PlatformException catch (e) {
      debugPrint('URL açma hatası: ${e.message}');
    }
  }

  /// OCR sonuçlarını panoya kopyala
  static Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      debugPrint('Panoya kopyalama hatası: $e');
    }
  }

  /// OCR geçmişini kaydet
  static Future<void> saveOCRHistory(OCRResult result) async {
    try {
      await _methodChannel.invokeMethod('saveOCRHistory', {
        'timestamp': DateTime.now().toIso8601String(),
        'rawText': result.rawText,
        'textInfos': result.textInfos
            .map(
              (info) => {
                'text': info.text,
                'type': info.type.name,
                'cleanedText': info.cleanedText,
                'metadata': info.metadata,
              },
            )
            .toList(),
      });
    } on PlatformException catch (e) {
      debugPrint('OCR geçmişi kaydetme hatası: ${e.message}');
    }
  }
}
