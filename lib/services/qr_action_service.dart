import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/qr_helpers.dart';
import '../l10n/app_localizations.dart';
import 'security_service.dart';

class QRActionService {
  /// QR kod türüne göre otomatik işlem yap
  static Future<void> performAction(
    BuildContext context,
    String qrData,
    String qrType,
  ) async {
    switch (qrType) {
      case 'URL':
        await _openURL(context, qrData);
        break;
      case 'WiFi':
        await _showWiFiDialog(context, qrData);
        break;
      case 'Telefon':
        await _callNumber(context, qrData);
        break;
      case 'E-mail':
        await _openEmail(context, qrData);
        break;
      case 'SMS':
        await _openSMS(context, qrData);
        break;
      case 'Konum':
        await _openMaps(context, qrData);
        break;
      case 'Kartvizit':
        await _showContactDialog(context, qrData);
        break;
      case 'Etkinlik':
        await _showEventDialog(context, qrData);
        break;
      case 'MeCard':
        await _showMeCardDialog(context, qrData);
        break;
      default:
        _showTextDialog(context, qrData);
    }
  }

  /// URL'yi güvenlik kontrolü ile aç
  static Future<void> _openURL(BuildContext context, String url) async {
    // Güvenlik kontrolü ile URL aç
    await SecurityService.openUrlSafely(context, url);
  }

  /// WiFi bilgilerini göster ve bağlanma seçeneği sun
  static Future<void> _showWiFiDialog(
    BuildContext context,
    String wifiData,
  ) async {
    final wifiInfo = QRCodeUtils.parseWiFiQR(wifiData);
    if (wifiInfo == null) {
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.qrActionWifiParseError,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.wifi, color: Colors.blue),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.qrActionWifiTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                AppLocalizations.of(context)!.qrActionWifiSsid,
                wifiInfo['ssid'] ?? '',
              ),
              _buildInfoRow(
                AppLocalizations.of(context)!.qrActionWifiPassword,
                wifiInfo['password'] ?? '',
              ),
              _buildInfoRow(
                AppLocalizations.of(context)!.qrActionWifiSecurity,
                wifiInfo['security'] ?? '',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.qrActionClose),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _showWiFiInstructions(context, wifiInfo);
              },
              icon: const Icon(Icons.wifi),
              label: Text(AppLocalizations.of(context)!.qrActionWifiConnect),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  /// WiFi bağlantı talimatları
  static void _showWiFiInstructions(
    BuildContext context,
    Map<String, String> wifiInfo,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.qrActionWifiInstructionsTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.qrActionWifiInstructionsContent,
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.qrActionWifiStep1),
              Text(
                AppLocalizations.of(
                  context,
                )!.qrActionWifiStep2(wifiInfo['ssid'] ?? ''),
              ),
              Text(
                AppLocalizations.of(
                  context,
                )!.qrActionWifiStep3(wifiInfo['password'] ?? ''),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  AppLocalizations.of(
                    context,
                  )!.qrActionWifiPasswordLabel(wifiInfo['password'] ?? ''),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.commonOk),
            ),
          ],
        );
      },
    );
  }

  /// Telefon numarasını ara
  static Future<void> _callNumber(
    BuildContext context,
    String phoneData,
  ) async {
    try {
      final String phoneNumber = phoneData.startsWith('tel:')
          ? phoneData.substring(4)
          : phoneData;

      final Uri uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;
        _showErrorDialog(
          context,
          AppLocalizations.of(context)!.qrActionPhoneOpenError,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.qrActionPhoneError('$e'),
      );
    }
  }

  /// E-mail uygulamasını aç
  static Future<void> _openEmail(BuildContext context, String emailData) async {
    try {
      final Uri uri = Uri.parse(emailData);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;
        _showErrorDialog(
          context,
          AppLocalizations.of(context)!.qrActionEmailOpenError,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.qrActionEmailError('$e'),
      );
    }
  }

  /// SMS uygulamasını aç
  static Future<void> _openSMS(BuildContext context, String smsData) async {
    try {
      final Uri uri = Uri.parse(smsData);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;
        _showErrorDialog(
          context,
          AppLocalizations.of(context)!.qrActionSmsOpenError,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.qrActionSmsError('$e'),
      );
    }
  }

  /// Harita uygulamasını aç
  static Future<void> _openMaps(
    BuildContext context,
    String locationData,
  ) async {
    try {
      final location = QRCodeUtils.parseLocationQR(locationData);
      if (location == null) {
        _showErrorDialog(
          context,
          AppLocalizations.of(context)!.qrActionLocationParseError,
        );
        return;
      }

      final lat = location['latitude'];
      final lng = location['longitude'];
      final Uri uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        _showErrorDialog(
          context,
          AppLocalizations.of(context)!.qrActionMapsOpenError,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.qrActionMapsError('$e'),
      );
    }
  }

  /// Kartvizit bilgilerini göster ve rehbere ekleme seçeneği sun
  static Future<void> _showContactDialog(
    BuildContext context,
    String vCardData,
  ) async {
    final contactInfo = QRCodeUtils.parseVCardQR(vCardData);
    if (contactInfo == null) {
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.qrActionContactParseError,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.contact_page, color: Colors.orange),
              const SizedBox(width: 8),
              Text(loc.qrActionContactTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (contactInfo['name'] != null)
                _buildInfoRow(loc.qrActionContactName, contactInfo['name']!),
              if (contactInfo['phone'] != null)
                _buildInfoRow(loc.qrActionContactPhone, contactInfo['phone']!),
              if (contactInfo['email'] != null)
                _buildInfoRow(loc.qrActionContactEmail, contactInfo['email']!),
              if (contactInfo['organization'] != null)
                _buildInfoRow(
                  loc.qrActionContactOrg,
                  contactInfo['organization']!,
                ),
              if (contactInfo['url'] != null)
                _buildInfoRow(loc.qrActionContactWeb, contactInfo['url']!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.qrActionClose),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _addToContacts(context, contactInfo);
              },
              icon: const Icon(Icons.contact_phone),
              label: Text(loc.qrActionAddToContacts),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Rehbere kişi ekle
  static Future<void> _addToContacts(
    BuildContext context,
    Map<String, String> contactInfo,
  ) async {
    try {
      // vCard formatında contact oluştur
      String vCardData = 'BEGIN:VCARD\nVERSION:3.0\n';

      if (contactInfo['name'] != null) {
        vCardData += 'FN:${contactInfo['name']}\n';
      }
      if (contactInfo['phone'] != null) {
        vCardData += 'TEL:${contactInfo['phone']}\n';
      }
      if (contactInfo['email'] != null) {
        vCardData += 'EMAIL:${contactInfo['email']}\n';
      }
      if (contactInfo['organization'] != null) {
        vCardData += 'ORG:${contactInfo['organization']}\n';
      }

      vCardData += 'END:VCARD';

      // Contacts uygulamasını aç
      final Uri uri = Uri.parse('content://contacts/people/');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.qrActionContactsOpened,
              ),
            ),
          );
        }
      } else {
        // Alternatif: vCard verisini paylaş
        if (!context.mounted) return;
        _showVCardDialog(context, vCardData);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showVCardDialog(context, contactInfo.toString());
    }
  }

  /// vCard verisini göster
  static void _showVCardDialog(BuildContext context, String vCardData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(loc.qrActionVcardTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.qrActionVcardContent),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(vCardData),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.commonOk),
            ),
          ],
        );
      },
    );
  }

  /// Takvim etkinliği göster
  static Future<void> _showEventDialog(
    BuildContext context,
    String eventData,
  ) async {
    // Basit vEvent parsing
    final lines = eventData.split('\n');
    String title = '';
    String date = '';
    String description = '';

    for (final String line in lines) {
      if (line.startsWith('SUMMARY:')) {
        title = line.substring(8);
      } else if (line.startsWith('DTSTART:')) {
        date = line.substring(8);
      } else if (line.startsWith('DESCRIPTION:')) {
        description = line.substring(12);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.event, color: Colors.purple),
              const SizedBox(width: 8),
              Text(loc.qrActionEventTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                _buildInfoRow(loc.qrActionEventSummary, title),
              if (date.isNotEmpty) _buildInfoRow(loc.qrActionEventDate, date),
              if (description.isNotEmpty)
                _buildInfoRow(loc.qrActionEventDesc, description),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.qrActionClose),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _openCalendar(context, eventData);
              },
              icon: const Icon(Icons.event),
              label: Text(loc.qrActionAddToCalendar),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Takvim uygulamasını aç
  static Future<void> _openCalendar(
    BuildContext context,
    String eventData,
  ) async {
    try {
      // Google Calendar URL formatı
      final Uri uri = Uri.parse('https://calendar.google.com/');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        _showErrorDialog(
          context,
          AppLocalizations.of(context)!.qrActionCalendarOpenError,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(
        context,
        AppLocalizations.of(context)!.qrActionCalendarError('$e'),
      );
    }
  }

  /// MeCard göster
  static Future<void> _showMeCardDialog(
    BuildContext context,
    String meCardData,
  ) async {
    // MECARD parsing - Format: MECARD:N:Name;TEL:Phone;EMAIL:Email;;
    final parts = meCardData.substring(7).split(';'); // Remove "MECARD:"
    final Map<String, String> contactInfo = {};

    for (final String part in parts) {
      if (part.startsWith('N:')) {
        contactInfo['name'] = part.substring(2);
      } else if (part.startsWith('TEL:')) {
        contactInfo['phone'] = part.substring(4);
      } else if (part.startsWith('EMAIL:')) {
        contactInfo['email'] = part.substring(6);
      } else if (part.startsWith('ORG:')) {
        contactInfo['organization'] = part.substring(4);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.contacts, color: Colors.teal),
              const SizedBox(width: 8),
              Text(loc.qrActionMeCardTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (contactInfo['name'] != null)
                _buildInfoRow(loc.qrActionContactName, contactInfo['name']!),
              if (contactInfo['phone'] != null)
                _buildInfoRow(loc.qrActionContactPhone, contactInfo['phone']!),
              if (contactInfo['email'] != null)
                _buildInfoRow(loc.qrActionContactEmail, contactInfo['email']!),
              if (contactInfo['organization'] != null)
                _buildInfoRow(
                  loc.qrActionContactOrg,
                  contactInfo['organization']!,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.qrActionClose),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _addToContacts(context, contactInfo);
              },
              icon: const Icon(Icons.contact_phone),
              label: Text(loc.qrActionAddToContacts),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Düz metin göster
  static void _showTextDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.text_fields, color: Colors.green),
              const SizedBox(width: 8),
              Text(loc.qrActionTextTitle),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SelectableText(text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.qrActionClose),
            ),
          ],
        );
      },
    );
  }

  /// Hata mesajı göster
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final loc = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(loc.qrActionErrorTitle),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.commonOk),
            ),
          ],
        );
      },
    );
  }

  /// Bilgi satırı widget'ı
  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
