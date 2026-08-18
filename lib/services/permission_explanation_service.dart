import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';

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
      if (!context.mounted) return false;
      return await _showPermanentlyDeniedDialog(context);
    }

    // İzin açıklama dialogunu göster
    if (!context.mounted) return false;
    final bool shouldRequest = await _showCameraPermissionExplanation(context);

    if (!shouldRequest) {
      return false;
    }

    // İzin iste
    final PermissionStatus newStatus = await Permission.camera.request();

    if (newStatus.isGranted) {
      return true;
    } else if (newStatus.isPermanentlyDenied) {
      if (!context.mounted) return false;
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
            final loc = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.camera_alt, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Text(loc.permCameraTitle),
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
                              loc.permCameraWhyTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.permCameraWhyContent,
                          style: const TextStyle(fontSize: 14, height: 1.4),
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
                        Expanded(
                          child: Text(
                            loc.permCameraDataSafe,
                            style: const TextStyle(
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
                          loc.permCameraSettingsNote,
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
                  label: Text(loc.permDecline),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(loc.permGrant),
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
            final loc = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.settings, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Text(loc.permSettingsTitle),
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
                              loc.permManualRequired,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.permManualContent,
                          style: const TextStyle(fontSize: 14, height: 1.4),
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
                  label: Text(loc.permCancel),
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
                  label: Text(loc.permGoToSettings),
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
        final loc = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.block, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(loc.permDeniedTitle),
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
                      loc.permDeniedScanningImpossible,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  loc.permDeniedContent,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check),
              label: Text(loc.permUnderstood),
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
            final loc = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(
                    Icons.photo_library,
                    color: Colors.purple,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(loc.permGalleryTitle),
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
                              loc.permGalleryWhyTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.permGalleryWhyContent,
                          style: const TextStyle(fontSize: 14, height: 1.4),
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
                  label: Text(loc.permCancel),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.photo_library),
                  label: Text(loc.permContinue),
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
