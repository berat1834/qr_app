import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../services/feedback_service.dart';
import '../services/history_service.dart';
import '../services/share_service.dart';
import '../services/gallery_qr_service.dart';
import '../services/qr_action_service.dart';
import '../services/favorites_service.dart';
import '../services/permission_explanation_service.dart';
import '../services/price_comparison_service.dart';
import '../services/ai_vision_service.dart';
import '../services/offline_queue_service.dart';
import '../utils/qr_helpers.dart';
import '../models/history_item.dart';
import '../l10n/app_localizations.dart';
import 'qr_detail_screen.dart';
import 'price_alerts_screen.dart';

class EnhancedQRScannerScreen extends StatefulWidget {
  const EnhancedQRScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _EnhancedQRScannerScreenState();
}

class _EnhancedQRScannerScreenState extends State<EnhancedQRScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController cameraController = MobileScannerController(
    autoStart: false,
  );
  String? result;
  bool isFlashOn = false;
  bool isBackCamera = true;
  Timer? _aiPromptTimer;
  bool _showAIPrompt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Widget build edildikten sonra izin isteği yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestCameraPermission().then((_) {
        _startAIPromptTimer();
      });
    });
  }

  void _startAIPromptTimer() {
    _aiPromptTimer?.cancel();
    setState(() {
      _showAIPrompt = false;
    });

    // 6 saniye boyunca okunamazsa AI butonunu göster
    _aiPromptTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && result == null) {
        setState(() {
          _showAIPrompt = true;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        cameraController.stop();
        break;
      case AppLifecycleState.resumed:
        cameraController.start();
        break;
      default:
        break;
    }
  }

  Future<void> _requestCameraPermission() async {
    // İzin şeffaflığı ile kamera izni iste
    final granted =
        await PermissionExplanationService.requestCameraPermissionWithExplanation(
          context,
        );
    // İzin verildiyse kamerayı başlat
    if (granted && mounted) {
      await cameraController.start();
    }
  }

  // Galeriden QR kod tara
  Future<void> _scanFromGallery() async {
    final loc = AppLocalizations.of(context)!;
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
        ).showSnackBar(SnackBar(content: Text(loc.scannerQrNotFoundInGallery)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.scannerGalleryAccessFailed)));
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

  // AI Backend'i kullanarak hasarlı QR kod tarama
  Future<void> _scanWithAI() async {
    final loc = AppLocalizations.of(context)!;

    // Kullanıcıya kaynak sor
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  loc.aiRepairTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  title: Text(loc.aiRepairOptionCamera),
                  subtitle: Text(loc.aiRepairOptionCameraSubtitle),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.photo_library, color: Colors.white),
                  ),
                  title: Text(loc.aiRepairOptionGallery),
                  subtitle: Text(loc.aiRepairOptionGallerySubtitle),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    // Eğer kaynak galeri ise, önce izin iste ve açıklama göster.
    // Bu, normal "Galeriden Tara" butonuyla aynı kullanıcı deneyimini sağlar.
    if (source == ImageSource.gallery) {
      final bool galleryPermissionGranted =
          await PermissionExplanationService.requestGalleryPermissionWithExplanation(
            context,
          );
      // İzin verilmediyse işlemi durdur.
      if (!galleryPermissionGranted) return;
    }

    XFile? image;
    try {
      final picker = ImagePicker();
      image = await picker.pickImage(source: source);

      if (image == null) return;
      if (!mounted) return;

      // Yükleniyor dialogu göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const Center(
          child: CircularProgressIndicator(color: Colors.purple),
        ),
      );

      // FastAPI Backend'ine resmi yolla
      final response = await AIVisionService.processDamagedImage(
        File(image.path),
      );

      if (!mounted) return;
      Navigator.pop(context); // Dialogu kapat

      final decodedData = response['decoded_data'] as String?;

      if (decodedData != null && decodedData.isNotEmpty) {
        setState(() {
          result = decodedData;
        });
        FeedbackService.scanSuccessFeedback();
        _showResultDialog(context, decodedData);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.aiScanFailed)));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Dialogu kapat

      final err = e.toString();
      // Ağ/kök bağlantı hatası ise çevrimdışı kuyruğa kaydet
      if (err.contains('No route to host') ||
          err.contains('Yapay Zeka Sunucusuna ulaşılamadı') ||
          err.contains('SocketException') ||
          err.contains('Connection refused')) {
        try {
          if (image == null) {
            throw Exception('No image selected to enqueue');
          }
          final savedPath = await OfflineQueueService.saveImageToAppDir(
            File(image!.path),
          );
          await OfflineQueueService.enqueueScan({
            'imagePath': savedPath,
            'timestamp': DateTime.now().toIso8601String(),
            'note': 'Queued due to AI backend unreachable',
          });
          // Denemek için eşzamanlı senkronizasyon çağır
          await OfflineQueueService.syncQueuedScans();

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(loc.aiServerUnreachable)));
          }
        } catch (ex) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(loc.aiServerError('$ex'))));
          }
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.aiServerError('$e'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color shadowColor = Colors.black.withOpacity(0.06);
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.scannerTitle),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.auto_fix_high, color: colorScheme.primary),
            onPressed: _scanWithAI,
            tooltip: loc.aiRepairWithAI,
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _scanFromGallery,
            tooltip: loc.scannerScanFromGalleryTooltip,
          ),
          IconButton(
            icon: Icon(
              isBackCamera ? Icons.camera_rear : Icons.camera_front,
              color: colorScheme.onSurface,
            ),
            onPressed: _switchCamera,
            tooltip: loc.batchSwitchCameraTooltip,
          ),
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: colorScheme.onSurface,
            ),
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {
                isFlashOn = !isFlashOn;
              });
            },
            tooltip: loc.batchFlashTooltip,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 8,
                shadowColor: shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 36,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.scannerHeaderTitle,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loc.scannerHeaderSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          controller: cameraController,
                          fit: BoxFit.cover,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              if (barcode.rawValue != null &&
                                  barcode.rawValue!.isNotEmpty) {
                                _aiPromptTimer?.cancel();
                                cameraController.stop();
                                setState(() {
                                  result = barcode.rawValue;
                                  _showAIPrompt = false;
                                });
                                FeedbackService.scanSuccessFeedback();
                                _showResultDialog(context, barcode.rawValue!);
                                break;
                              }
                            }
                          },
                        ),
                      ),
                      if (_showAIPrompt && result == null)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton.icon(
                              onPressed: _scanWithAI,
                              icon: const Icon(Icons.auto_fix_high),
                              label: Text(loc.aiDamagedQrPrompt),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                elevation: 4,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      if (result != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.18),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                loc.scannerResultTitle,
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
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.18),
                            ),
                          ),
                          child: Text(
                            loc.scannerBringCodeIntoView,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.blue[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await cameraController.start();
                                _startAIPromptTimer();
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: Text(loc.batchStart),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await cameraController.stop();
                              },
                              icon: const Icon(Icons.stop),
                              label: Text(loc.scannerStop),
                            ),
                            if (result != null) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showResultDialog(context, result!),
                                icon: const Icon(Icons.info_outline),
                                label: Text(loc.scannerDetails),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // QR kod sonucunu detaylı olarak göster
  void _showResultDialog(BuildContext context, String result) {
    final isBarcode = _isBarcodeValue(result);
    final normalizedResult = isBarcode
        ? _normalizeBarcodeValue(result)
        : result;
    final loc = AppLocalizations.of(context)!;
    final qrType = isBarcode
        ? loc.scannerBarcodeType
        : QRCodeUtils.determineQRType(result);

    showDialog(
      context: context,
      // Context çakışmasını (shadowing) engellemek için isim değiştirdik
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(_getIconForQRType(qrType), color: Colors.green),
              const SizedBox(width: 8),
              Text(loc.scannerScannedDialogTitle),
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
                    loc.scannerTypeLabel(qrType),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(loc.batchContentLabel),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  normalizedResult,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(loc.commonClose),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ShareService.showQuickShareOptions(
                  normalizedResult,
                  qrType,
                  context,
                );
              },
              icon: const Icon(Icons.share),
              label: Text(loc.favoritesShare),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (isBarcode) {
                  await _openBarcodeDetailForPriceComparison(normalizedResult);
                } else {
                  await QRActionService.performAction(
                    context,
                    normalizedResult,
                    qrType,
                  );
                }
              },
              icon: const Icon(Icons.launch),
              label: Text(
                isBarcode
                    ? loc.scannerComparePriceAction
                    : loc.scannerOpenUseAction,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            if (isBarcode)
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _quickCreatePriceAlert(normalizedResult);
                },
                icon: const Icon(Icons.notifications_active),
                label: Text(loc.scannerSetAlertAction),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await FavoritesService.addToFavorites(
                  data: normalizedResult,
                  type: qrType,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.historyAddedToFavorites),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: const Icon(Icons.favorite),
              label: Text(loc.scannerAddFavoriteAction),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await HistoryService.addToHistory(
                  data: normalizedResult,
                  type: qrType,
                  isScanned: true,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.batchSavedToHistory)),
                );
              },
              icon: const Icon(Icons.save),
              label: Text(loc.commonSave),
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

  bool _isBarcodeValue(String value) {
    return RegExp(r'^\d{8,14}$').hasMatch(_normalizeBarcodeValue(value));
  }

  String _normalizeBarcodeValue(String value) {
    return value.trim().replaceAll(RegExp(r'[\u0000-\u001F\s]+'), '');
  }

  Future<void> _openBarcodeDetailForPriceComparison(String barcode) async {
    if (!mounted) return;

    final item = HistoryItem(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      data: barcode,
      type: AppLocalizations.of(context)!.scannerBarcodeType,
      date: DateTime.now(),
      isScanned: true,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRDetailScreen(item: item)),
    );
  }

  Future<void> _quickCreatePriceAlert(String barcode) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final result = await PriceComparisonService.compareProductPrices(barcode);
      if (!mounted) return;

      if (!result.success || result.lowestPrice == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? loc.scannerPriceNotFound)),
        );
        return;
      }

      final lowestPrice = result.lowestPrice!;
      final controller = TextEditingController(
        text: lowestPrice.price.toStringAsFixed(0),
      );

      final created = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              void applyPercentPreset(double percent) {
                final target = lowestPrice.price * (1 - percent);
                controller.text = target.toStringAsFixed(2);
                setDialogState(() {});
              }

              return AlertDialog(
                title: Text(loc.scannerSetPriceAlertTitle),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.productInfo?.name ?? loc.scannerUnknownProduct),
                    const SizedBox(height: 8),
                    Text(
                      loc.scannerCurrentLowestPrice(
                        lowestPrice.price.toStringAsFixed(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => applyPercentPreset(0.05),
                          child: Text(loc.scannerPreset5Below),
                        ),
                        OutlinedButton(
                          onPressed: () => applyPercentPreset(0.10),
                          child: Text(loc.scannerPreset10Below),
                        ),
                        OutlinedButton(
                          onPressed: () => applyPercentPreset(0.15),
                          child: Text(loc.scannerPreset15Below),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            controller.text = lowestPrice.price.toStringAsFixed(
                              2,
                            );
                            setDialogState(() {});
                          },
                          child: Text(loc.scannerCurrentPricePreset),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: loc.scannerTargetPriceLabel,
                        prefixText: '₺ ',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(loc.favoritesCancel),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final parsed = double.tryParse(
                        controller.text.trim().replaceAll(',', '.'),
                      );
                      if (parsed == null || parsed <= 0) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(content: Text(loc.scannerEnterValidPrice)),
                        );
                        return;
                      }

                      final ok = await PriceComparisonService.createPriceAlert(
                        barcode,
                        parsed,
                        lowestPrice.source,
                        productName: result.productInfo?.name,
                        currentPrice: lowestPrice.price,
                      );
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext, ok);
                    },
                    child: Text(loc.commonSave),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted) return;

      if (created == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.scannerPriceAlertCreated)));
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PriceAlertsScreen(highlightedBarcode: barcode),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.scannerPriceAlertNotCreated)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.scannerAlertCreateError('$e'))),
      );
    }
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
      case 'Barkod':
      case 'Barcode':
        return Icons.qr_code_2;
      default:
        return Icons.text_fields;
    }
  }

  @override
  void dispose() {
    _aiPromptTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }
}

/// QR Kod Tarama çerçevesini (köşeler ve karartılmış arkaplan) çizen CustomPainter sınıfı
class ScannerOverlay extends CustomPainter {
  const ScannerOverlay(this.scanWindow, this.color, this.strokeWidth);

  final Rect scanWindow;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Ekranın geri kalanını karart, sadece tarama alanını şeffaf bırak
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRect(scanWindow)
      ..fillType = PathFillType.evenOdd;

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(finalPath, backgroundPaint);

    // Köşeleri belirgin şekilde çiz
    final cornerLength = 25.0;
    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.5
      ..strokeCap = StrokeCap.round;

    // Sol Üst
    canvas.drawLine(
      scanWindow.topLeft,
      scanWindow.topLeft + Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.topLeft,
      scanWindow.topLeft + Offset(0, cornerLength),
      cornerPaint,
    );
    // Sağ Üst
    canvas.drawLine(
      scanWindow.topRight,
      scanWindow.topRight + Offset(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.topRight,
      scanWindow.topRight + Offset(0, cornerLength),
      cornerPaint,
    );
    // Sol Alt
    canvas.drawLine(
      scanWindow.bottomLeft,
      scanWindow.bottomLeft + Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.bottomLeft,
      scanWindow.bottomLeft + Offset(0, -cornerLength),
      cornerPaint,
    );
    // Sağ Alt
    canvas.drawLine(
      scanWindow.bottomRight,
      scanWindow.bottomRight + Offset(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.bottomRight,
      scanWindow.bottomRight + Offset(0, -cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow || color != oldDelegate.color;
  }
}
