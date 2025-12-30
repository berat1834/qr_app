import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/feedback_service.dart';
import '../services/history_service.dart';
import '../services/share_service.dart';
import '../services/gallery_qr_service.dart';
import '../services/qr_action_service.dart';
import '../services/favorites_service.dart';
import '../services/permission_explanation_service.dart';
import '../utils/qr_helpers.dart';

class EnhancedQRScannerScreen extends StatefulWidget {
  const EnhancedQRScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _EnhancedQRScannerScreenState();
}

class _EnhancedQRScannerScreenState extends State<EnhancedQRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? result;
  bool isFlashOn = false;
  bool isBackCamera = true;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    // İzin şeffaflığı ile kamera izni iste
    await PermissionExplanationService.requestCameraPermissionWithExplanation(
      context,
    );
  }

  // Galeriden QR kod tara
  Future<void> _scanFromGallery() async {
    try {
      final qrResult = await GalleryQRService.scanQRFromGallery(
        context: context,
      );
      if (qrResult != null && mounted) {
        setState(() {
          result = qrResult;
        });
        FeedbackService.scanSuccessFeedback();
        _showResultDialog(context, qrResult);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('QR kod bulunamadı')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Galeri erişimi başarısız')),
        );
      }
    }
  }

  // Kamera değiştir (Ön/Arka)
  Future<void> _switchCamera() async {
    await cameraController.switchCamera();
    setState(() {
      isBackCamera = !isBackCamera;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tarayıcı'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _scanFromGallery,
            tooltip: 'Galeriden QR Tara',
          ),
          IconButton(
            icon: Icon(isBackCamera ? Icons.camera_rear : Icons.camera_front),
            onPressed: _switchCamera,
            tooltip: 'Kamera Değiştir',
          ),
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {
                isFlashOn = !isFlashOn;
              });
            },
            tooltip: 'Flaş',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              fit: BoxFit.cover,
              scanWindow: Rect.fromCenter(
                center: MediaQuery.of(context).size.center(Offset.zero),
                width: 200,
                height: 200,
              ),
              placeholderBuilder: (context) =>
                  const Center(child: Text('Kamera başlatılıyor...')),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null &&
                      barcode.rawValue!.isNotEmpty) {
                    setState(() {
                      result = barcode.rawValue;
                    });
                    // Başarılı tarama feedback'i
                    FeedbackService.scanSuccessFeedback();
                    _showResultDialog(context, barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Tarama Sonucu:',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            result!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        'QR kodu kameranın görüş alanına getirin',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await cameraController.start();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Başlat'),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await cameraController.stop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Durdur'),
                        ),
                      ),
                      if (result != null)
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              _showResultDialog(context, result!);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Detaylar'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // QR kod sonucunu detaylı olarak göster
  void _showResultDialog(BuildContext context, String result) {
    final qrType = QRCodeUtils.determineQRType(result);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(_getIconForQRType(qrType), color: Colors.green),
              const SizedBox(width: 8),
              const Text('QR Kod Tarandı'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Tür: $qrType',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('İçerik:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  result,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Kapat'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ShareService.showQuickShareOptions(result, qrType, context);
              },
              icon: const Icon(Icons.share),
              label: const Text('Paylaş'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await QRActionService.performAction(context, result, qrType);
              },
              icon: const Icon(Icons.launch),
              label: const Text('Aç/Kullan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await FavoritesService.addToFavorites(
                  data: result,
                  type: qrType,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⭐ Favorilere eklendi!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: const Icon(Icons.favorite),
              label: const Text('Favorile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await HistoryService.addToHistory(
                  data: result,
                  type: qrType,
                  isScanned: true,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Geçmişe kaydedildi')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // QR türü için ikon döndür
  IconData _getIconForQRType(String type) {
    switch (type) {
      case 'WiFi':
        return Icons.wifi;
      case 'URL':
        return Icons.link;
      case 'Telefon':
        return Icons.phone;
      case 'E-mail':
        return Icons.email;
      case 'SMS':
        return Icons.sms;
      case 'Konum':
        return Icons.location_on;
      case 'Kartvizit':
        return Icons.contact_page;
      case 'Etkinlik':
        return Icons.event;
      case 'MeCard':
        return Icons.contacts;
      default:
        return Icons.text_fields;
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
