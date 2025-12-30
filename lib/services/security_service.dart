import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// URL güvenlik kontrol servisi - Zararlı linkleri tespit eder
class SecurityService {
  // Zararlı URL desenleri listesi (gerçek projede daha kapsamlı olacak)
  static final List<String> _dangerousPatterns = [
    // Bilinen phishing desenleri
    'phishing',
    'scam',
    'malware',
    'suspicious',
    'hack',
    'virus',
    'trojan',
    // Şüpheli domain uzantıları
    '.tk',
    '.ml',
    '.ga',
    '.cf',
    '.pw',
    '.xyz',
    // URL shortener servisleri (dikkatli kullanım gerekir)
    'bit.ly',
    'tinyurl',
    't.co',
    'goo.gl',
    'ow.ly',
    'is.gd',
    'buff.ly',
    // Localhost ve local network
    'localhost',
    '127.0.0.1',
    '192.168.',
    '10.0.',
    '172.16.',
    // Şüpheli path desenleri
    '/admin',
    '/login.php',
    '/credential',
  ];

  // Güvenli domain listesi
  static final List<String> _trustedDomains = [
    'google.com',
    'youtube.com',
    'facebook.com',
    'twitter.com',
    'instagram.com',
    'linkedin.com',
    'github.com',
    'flutter.dev',
    'dart.dev',
    'microsoft.com',
    'apple.com',
    'amazon.com',
    'wikipedia.org',
  ];

  /// URL güvenlik kontrolü yap
  static SecurityResult checkUrlSecurity(String url) {
    try {
      final Uri uri = Uri.parse(url.toLowerCase());
      final String domain = uri.host;
      final String fullUrl = url.toLowerCase();
      final String path = uri.path.toLowerCase();

      // 1. HTTP kontrolü (en yüksek öncelik - güvenlik tehdidi)
      if (uri.scheme == 'http') {
        return SecurityResult(
          isSafe: false,
          riskLevel: RiskLevel.high,
          message: 'HTTPS kullanmayan siteler güvenli değildir!',
          recommendation: SecurityAction.warn,
          details:
              'HTTP bağlantıları şifrelenmez. Kişisel bilgi girmemeye dikkat edin.',
        );
      }

      // 2. Localhost ve local network kontrolü (yüksek risk)
      if (_isLocalOrPrivateNetwork(domain)) {
        return SecurityResult(
          isSafe: false,
          riskLevel: RiskLevel.high,
          message: 'Yerel ağ adresi tespit edildi!',
          recommendation: SecurityAction.block,
          details: 'Localhost veya özel ağ adresleri güvenli olmayabilir.',
        );
      }

      // 3. URL shortener kontrolü (orta-yüksek risk)
      if (_isUrlShortener(fullUrl)) {
        return SecurityResult(
          isSafe: false,
          riskLevel: RiskLevel.high,
          message: 'URL kısaltıcı tespit edildi!',
          recommendation: SecurityAction.warn,
          details: 'Kısaltılmış URL\'ler gerçek hedefi gizler. Dikkatli olun.',
        );
      }

      // 4. Güvenli domain kontrolü (öncelikli - path kontrolünden önce)
      for (String trustedDomain in _trustedDomains) {
        if (domain == trustedDomain || domain.endsWith('.$trustedDomain')) {
          return SecurityResult(
            isSafe: true,
            riskLevel: RiskLevel.safe,
            message: 'Bu site güvenilir listede yer alıyor.',
            recommendation: SecurityAction.proceed,
          );
        }
      }

      // 5. Zararlı desen kontrolü (domain + path)
      for (String pattern in _dangerousPatterns) {
        if (fullUrl.contains(pattern) ||
            domain.contains(pattern) ||
            path.contains(pattern)) {
          return SecurityResult(
            isSafe: false,
            riskLevel: RiskLevel.high,
            message: 'Şüpheli içerik tespit edildi!',
            recommendation: SecurityAction.block,
            details: 'Zararlı desen bulundu: $pattern',
          );
        }
      }

      // 6. Genel bilinmeyen site uyarısı
      return SecurityResult(
        isSafe: null, // Belirsiz
        riskLevel: RiskLevel.medium,
        message: 'Bu sitenin güvenlik durumu belirsiz.',
        recommendation: SecurityAction.warn,
        details:
            'Bilinmeyen site. Dikkatli olun ve kişisel bilgileri paylaşmaktan kaçının.',
      );
    } catch (e) {
      return SecurityResult(
        isSafe: false,
        riskLevel: RiskLevel.high,
        message: 'URL formatı geçersiz.',
        recommendation: SecurityAction.block,
        details: 'Hatalı URL formatı: $e',
      );
    }
  }

  /// Localhost veya özel ağ kontrolü
  static bool _isLocalOrPrivateNetwork(String domain) {
    return domain == 'localhost' ||
        domain.startsWith('127.') ||
        domain.startsWith('192.168.') ||
        domain.startsWith('10.') ||
        domain.startsWith('172.16.') ||
        domain.startsWith('172.17.') ||
        domain.startsWith('172.18.') ||
        domain.startsWith('172.19.') ||
        domain.startsWith('172.20.') ||
        domain.startsWith('172.21.') ||
        domain.startsWith('172.22.') ||
        domain.startsWith('172.23.') ||
        domain.startsWith('172.24.') ||
        domain.startsWith('172.25.') ||
        domain.startsWith('172.26.') ||
        domain.startsWith('172.27.') ||
        domain.startsWith('172.28.') ||
        domain.startsWith('172.29.') ||
        domain.startsWith('172.30.') ||
        domain.startsWith('172.31.');
  }

  /// URL kısaltıcı kontrolü
  static bool _isUrlShortener(String url) {
    final Uri uri = Uri.parse(url.toLowerCase());
    final String domain = uri.host;

    final urlShorteners = [
      'bit.ly',
      'tinyurl.com',
      't.co',
      'goo.gl',
      'ow.ly',
      'is.gd',
      'buff.ly',
      'short.link',
      'tiny.cc',
    ];

    return urlShorteners.any(
      (shortener) => domain == shortener || domain.endsWith('.$shortener'),
    );
  }

  /// Güvenlik uyarısı dialogu göster
  static Future<bool> showSecurityWarning(
    BuildContext context,
    String url,
    SecurityResult securityResult,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    _getRiskIcon(securityResult.riskLevel),
                    color: _getRiskColor(securityResult.riskLevel),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('Güvenlik Uyarısı'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getRiskColor(
                        securityResult.riskLevel,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          securityResult.message,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (securityResult.details != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            securityResult.details!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'URL:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(
                      url,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Bu uyarıyı dikkate alarak devam etmek istediğinizden emin misiniz?',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.cancel),
                  label: const Text('İptal'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.open_in_browser),
                  label: Text(
                    securityResult.riskLevel == RiskLevel.high
                        ? 'Risk Alarak Devam Et'
                        : 'Dikkatli Devam Et',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getRiskColor(securityResult.riskLevel),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Güvenli URL açma işlemi
  static Future<void> openUrlSafely(BuildContext context, String url) async {
    // Güvenlik kontrolü yap
    final securityResult = checkUrlSecurity(url);

    bool shouldProceed = true;

    // Yüksek risk veya orta risk durumunda uyarı göster
    if (securityResult.riskLevel == RiskLevel.high ||
        securityResult.riskLevel == RiskLevel.medium) {
      shouldProceed = await showSecurityWarning(context, url, securityResult);
    }

    if (shouldProceed) {
      try {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);

          // Başarılı açıldıysa kullanıcıya bilgi ver
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Site tarayıcıda açıldı. Güvenliğiniz için dikkatli olun.',
                ),
                backgroundColor: Colors.green[600],
                action: SnackBarAction(
                  label: 'Tamam',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        } else {
          throw Exception('URL açılamadı');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('URL açılamadı: $e'),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      }
    }
  }

  // Risk seviyesine göre ikon
  static IconData _getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.safe:
        return Icons.verified_user;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.dangerous;
    }
  }

  // Risk seviyesine göre renk
  static Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.safe:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }
}

/// Güvenlik sonucu sınıfı
class SecurityResult {
  final bool? isSafe; // null = belirsiz
  final RiskLevel riskLevel;
  final String message;
  final SecurityAction recommendation;
  final String? details;

  SecurityResult({
    required this.isSafe,
    required this.riskLevel,
    required this.message,
    required this.recommendation,
    this.details,
  });
}

/// Risk seviyeleri
enum RiskLevel {
  safe, // Güvenli
  medium, // Orta risk
  high, // Yüksek risk
}

/// Güvenlik aksiyonları
enum SecurityAction {
  proceed, // Devam et
  warn, // Uyar
  block, // Engelle
}
