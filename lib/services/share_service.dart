import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// Fiyat alarmı paylaşım template'leri
enum PriceAlertShareTemplate { compact, detailed }

class ShareService {
  // Genel paylaşım
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  static Future<void> shareFile(
    String filePath, {
    String? text,
    String? subject,
  }) async {
    await Share.shareXFiles([XFile(filePath)], text: text, subject: subject);
  }

  // Fiyat alarmı template şablonları
  static Future<void> sharePriceAlert({
    required String productName,
    required String barcode,
    required double? currentPrice,
    required double? targetPrice,
    PriceAlertShareTemplate template = PriceAlertShareTemplate.compact,
  }) async {
    final message = formatPriceAlertForSharing(
      productName: productName,
      barcode: barcode,
      currentPrice: currentPrice,
      targetPrice: targetPrice,
      template: template,
    );

    await shareText(message, subject: 'Fiyat Alarmı: $productName');
  }

  // Fiyat alarmı mesajını format et
  static String formatPriceAlertForSharing({
    required String productName,
    required String barcode,
    required double? currentPrice,
    required double? targetPrice,
    PriceAlertShareTemplate template = PriceAlertShareTemplate.compact,
  }) {
    final currentPriceStr = currentPrice?.toStringAsFixed(2) ?? '-';
    final targetPriceStr = targetPrice?.toStringAsFixed(2) ?? '-';

    if (template == PriceAlertShareTemplate.compact) {
      // Kısa format
      return '''
💰 $productName

Hedef: $targetPriceStr ₺
Güncel: $currentPriceStr ₺

🏷️ $barcode

QR Tarayıcı Uygulaması''';
    } else {
      // Uzun format (detailed)
      final savings = (targetPrice != null && currentPrice != null)
          ? (targetPrice - currentPrice).toStringAsFixed(2)
          : '-';
      final percentOff = (targetPrice != null && currentPrice != null)
          ? ((1 - currentPrice / targetPrice) * 100).toStringAsFixed(1)
          : '-';

      return '''
🎉 FİYAT ALARMINA ULAŞILDI!

📦 Ürün: $productName

💵 FIYAT BİLGİLERİ
├─ Hedef Fiyat: $targetPriceStr ₺
├─ Güncel Fiyat: $currentPriceStr ₺
├─ Tasarruf: $savings ₺
└─ İndirim Yüzdesi: %$percentOff

🏷️ Barkod: $barcode

---
QR Tarayıcı Uygulaması ile kontrol et:
Alarmlar 📱 → Detayı Gör → İnceleme Yap
''';
    }
  }

  // WhatsApp'a direkt paylaşım
  static Future<void> shareToWhatsApp(String text) async {
    final String whatsappUrl =
        'whatsapp://send?text=${Uri.encodeComponent(text)}';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      // WhatsApp yüklü değilse normal paylaşım
      await shareText(text);
    }
  }

  // Telegram'a direkt paylaşım
  static Future<void> shareToTelegram(String text) async {
    final String telegramUrl = 'tg://msg?text=${Uri.encodeComponent(text)}';

    if (await canLaunchUrl(Uri.parse(telegramUrl))) {
      await launchUrl(Uri.parse(telegramUrl));
    } else {
      // Telegram yüklü değilse normal paylaşım
      await shareText(text);
    }
  }

  // E-mail paylaşımı
  static Future<void> shareToEmail(
    String text, {
    String subject = 'QR Kod İçeriği',
  }) async {
    final String emailUrl =
        'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(text)}';

    if (await canLaunchUrl(Uri.parse(emailUrl))) {
      await launchUrl(Uri.parse(emailUrl));
    } else {
      // E-mail uygulaması yoksa normal paylaşım
      await shareText(text, subject: subject);
    }
  }

  // SMS paylaşımı
  static Future<void> shareToSMS(String text) async {
    final String smsUrl = 'sms:?body=${Uri.encodeComponent(text)}';

    if (await canLaunchUrl(Uri.parse(smsUrl))) {
      await launchUrl(Uri.parse(smsUrl));
    } else {
      await shareText(text);
    }
  }

  // URL'yi tarayıcıda aç
  static Future<void> openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // WiFi bilgilerini düzenle ve paylaş
  static String formatWiFiForSharing(
    String ssid,
    String password,
    String security,
  ) {
    return '''
WiFi Ağ Bilgileri:
📶 Ağ Adı: $ssid
🔒 Şifre: $password
🛡️ Güvenlik: $security

QR kodunu tarayarak otomatik bağlanabilirsiniz!
''';
  }

  // Konum bilgisini formatla
  static String formatLocationForSharing(double latitude, double longitude) {
    return '''
📍 Konum Bilgisi:
Enlem: $latitude
Boylam: $longitude

Google Maps: https://maps.google.com/?q=$latitude,$longitude
''';
  }

  // vCard (kartvizit) bilgisini formatla
  static String formatVCardForSharing(
    String name,
    String phone,
    String email,
    String company,
  ) {
    return '''
👤 Kartvizit Bilgisi:
İsim: $name
📞 Telefon: $phone
📧 E-mail: $email
🏢 Şirket: $company
''';
  }

  // Hızlı paylaşım seçenekleri göster
  static Future<void> showQuickShareOptions(
    String data,
    String type,
    BuildContext context,
  ) async {
    final String formattedContent = _formatContentForSharing(data, type);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  loc.shareTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.blue),
                title: Text(loc.shareGeneral),
                onTap: () {
                  Navigator.pop(context);
                  shareText(formattedContent);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: Text(loc.shareWhatsApp),
                onTap: () {
                  Navigator.pop(context);
                  shareToWhatsApp(formattedContent);
                },
              ),
              ListTile(
                leading: const Icon(Icons.telegram, color: Colors.blue),
                title: Text(loc.shareTelegram),
                onTap: () {
                  Navigator.pop(context);
                  shareToTelegram(formattedContent);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.red),
                title: Text(loc.shareEmail),
                onTap: () {
                  Navigator.pop(context);
                  shareToEmail(formattedContent);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.orange),
                title: Text(loc.shareSms),
                onTap: () {
                  Navigator.pop(context);
                  shareToSMS(formattedContent);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // İçeriği formatla
  static String _formatContentForSharing(String content, String type) {
    switch (type) {
      case 'WiFi':
        // WiFi formatını parse et
        if (content.startsWith('WIFI:')) {
          final regex = RegExp(r'WIFI:T:([^;]*);S:([^;]*);P:([^;]*);');
          final match = regex.firstMatch(content);
          if (match != null) {
            return formatWiFiForSharing(
              match.group(2) ?? '',
              match.group(3) ?? '',
              match.group(1) ?? '',
            );
          }
        }
        break;
      case 'Konum':
        if (content.startsWith('geo:')) {
          final coords = content.substring(4).split(',');
          if (coords.length >= 2) {
            final lat = double.tryParse(coords[0]) ?? 0.0;
            final lng = double.tryParse(coords[1]) ?? 0.0;
            return formatLocationForSharing(lat, lng);
          }
        }
        break;
      case 'Kartvizit':
        if (content.startsWith('BEGIN:VCARD')) {
          // vCard parsing için basit implementasyon
          return 'Kartvizit: $content';
        }
        break;
      default:
        return content;
    }
    return content;
  }
}
