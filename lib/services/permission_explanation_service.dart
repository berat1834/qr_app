import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// İzin şeffaflığı servisi - Kullanıcılara izinlerin neden gerekli olduğunu açıklar
class PermissionExplanationService {
  /// Kamera izni açıklaması ve isteği
  static Future<bool> requestCameraPermissionWithExplanation(
    BuildContext context,
  ) async {
    // Önce mevcut izin durumunu kontrol et
    final PermissionStatus currentStatus = await Permission.camera.status;

    // Eğer izin zaten verilmişse, direkt true döndür
    if (currentStatus.isGranted) {
      return true;
    }

    // Eğer izin kalıcı olarak reddedilmişse, ayarlara yönlendir
    if (currentStatus.isPermanentlyDenied) {
      return await _showPermanentlyDeniedDialog(context);
    }

    // İzin açıklama dialogunu göster
    final bool shouldRequest = await _showCameraPermissionExplanation(context);

    if (!shouldRequest) {
      return false;
    }

    // İzin iste
    final PermissionStatus newStatus = await Permission.camera.request();

    if (newStatus.isGranted) {
      return true;
    } else if (newStatus.isPermanentlyDenied) {
      return await _showPermanentlyDeniedDialog(context);
    } else {
      // İzin reddedildi
      if (context.mounted) {
        _showPermissionDeniedDialog(context);
      }
      return false;
    }
  }

  /// Kamera izni açıklama dialogu
  static Future<bool> _showCameraPermissionExplanation(
    BuildContext context,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.camera_alt, color: Colors.blue, size: 28),
                  SizedBox(width: 12),
                  Text('Kamera İzni'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Neden Kamera İzni Gerekli?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '🔍 QR kodları taramak için kamera erişimi gereklidir.\n'
                          '📱 Uygulama sadece QR kod tanımak için kamerayı kullanır.\n'
                          '🚫 Hiçbir fotoğraf veya video kaydedilmez.\n'
                          '🔒 Kişisel gizliliğiniz korunur.',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Verileriniz güvendedir',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.settings, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bu izni istediğiniz zaman cihaz ayarlarından geri alabilirsiniz.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
                  label: const Text('İzin Verme'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('İzin Ver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Kalıcı olarak reddedilen izin dialogu
  static Future<bool> _showPermanentlyDeniedDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.settings, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Text('İzin Gerekli'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Manuel İzin Ayarı Gerekli',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Kamera izni daha önce kalıcı olarak reddedilmiş.\n\n'
                          'QR kod tarayabilmek için:\n'
                          '1. Ayarlar > Uygulamalar\n'
                          '2. QR App > İzinler\n'
                          '3. Kamera izni açın',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
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
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    await openAppSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Ayarlara Git'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// İzin reddedildi dialogu
  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('İzin Reddedildi'),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'QR Tarama Yapılamıyor',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kamera izni olmadan QR kod tarama özelliğini kullanamıyoruz.\n\n'
                  'İsterseniz daha sonra tekrar deneyebilir veya cihaz ayarlarından manuel olarak izin verebilirsiniz.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check),
              label: const Text('Anladım'),
              style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
            ),
          ],
        );
      },
    );
  }

  /// Galeri izni açıklaması
  static Future<bool> requestGalleryPermissionWithExplanation(
    BuildContext context,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.photo_library, color: Colors.purple, size: 28),
                  SizedBox(width: 12),
                  Text('Galeri Erişimi'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.purple.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Neden Galeri Erişimi?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '📷 Galerinizden QR kod içeren resimleri seçebilmek için.\n'
                          '🔍 Seçtiğiniz resimden QR kod okumak için.\n'
                          '🔒 Sadece seçtiğiniz resim işlenir, diğer fotoğraflarınıza erişilmez.',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
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
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Devam Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
