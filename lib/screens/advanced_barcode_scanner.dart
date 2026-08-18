import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/app_localizations.dart';
import '../services/feedback_service.dart';
import '../services/history_service.dart';
import '../services/qr_action_service.dart';

class BarcodeTypes {
  static const List<BarcodeFormat> allFormats = [
    BarcodeFormat.qrCode,
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.code128,
    BarcodeFormat.code39,
    BarcodeFormat.code93,
    BarcodeFormat.dataMatrix,
    BarcodeFormat.aztec,
    BarcodeFormat.pdf417,
    BarcodeFormat.itf14,
    BarcodeFormat.codabar,
  ];

  static String getBarcodeTypeName(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      case BarcodeFormat.code93:
        return 'Code 93';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      case BarcodeFormat.aztec:
        return 'Aztec';
      case BarcodeFormat.pdf417:
        return 'PDF 417';
      case BarcodeFormat.itf14:
        return 'ITF';
      case BarcodeFormat.codabar:
        return 'Codabar';
      default:
        return 'Unknown';
    }
  }

  static IconData getBarcodeTypeIcon(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return Icons.qr_code;
      case BarcodeFormat.ean13:
      case BarcodeFormat.ean8:
        return Icons.shopping_cart;
      case BarcodeFormat.code128:
      case BarcodeFormat.code39:
      case BarcodeFormat.code93:
        return Icons.inventory;
      case BarcodeFormat.dataMatrix:
        return Icons.grid_on;
      case BarcodeFormat.aztec:
        return Icons.center_focus_strong;
      case BarcodeFormat.pdf417:
        return Icons.document_scanner;
      case BarcodeFormat.itf14:
      case BarcodeFormat.codabar:
        return Icons.all_inclusive;
      default:
        return Icons.crop_free;
    }
  }
}

class AdvancedBarcodeScanner extends StatefulWidget {
  const AdvancedBarcodeScanner({super.key});

  @override
  State<AdvancedBarcodeScanner> createState() => _AdvancedBarcodeScannerState();
}

class _AdvancedBarcodeScannerState extends State<AdvancedBarcodeScanner> {
  late MobileScannerController _cameraController;
  bool _screenOpened = false;
  bool _isFlashOn = false;
  bool _isDetectionActive = true;
  bool _isContinuousMode = false;
  late List<BarcodeFormat> _selectedFormats;
  late BarcodeFormat _lastDetectedFormat;
  String? _lastDetectedData;
  DateTime? _lastDetectionTime;
  int _detectionCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedFormats = [BarcodeFormat.qrCode];
    _cameraController = MobileScannerController();
    _updateCameraConfiguration();
  }

  void _updateCameraConfiguration() {
    _cameraController = MobileScannerController(
      formats: _selectedFormats,
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: _isFlashOn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.advancedScannerTitle),
        backgroundColor: Colors.black.withValues(alpha: 0.95),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Format seçici
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFormatSelector,
            tooltip: AppLocalizations.of(context)!.advancedFormatOptions,
          ),
          // Flash açma/kapama
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: AppLocalizations.of(context)!.batchFlashTooltip,
          ),
          // Kamera değiştirme
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: _switchCamera,
            tooltip: AppLocalizations.of(context)!.batchSwitchCameraTooltip,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner view
          MobileScanner(
            controller: _cameraController,
            onDetect: _onBarcodeDetect,
          ),

          // Overlay with scan area
          _buildScanOverlay(),

          // Bottom panel
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: _isDetectionActive ? Colors.green : Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: isDark ? 0.98 : 0.97),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tespit bilgileri
            if (_lastDetectedData != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          BarcodeTypes.getBarcodeTypeIcon(_lastDetectedFormat),
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          BarcodeTypes.getBarcodeTypeName(_lastDetectedFormat),
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.advancedDetectionCount(_detectionCount),
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastDetectedData!,
                      style: TextStyle(color: colorScheme.onSurface),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Kontrol butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tespit durumu
                Column(
                  children: [
                    Switch(
                      value: _isDetectionActive,
                      onChanged: (value) {
                        setState(() {
                          _isDetectionActive = value;
                        });
                      },
                      activeThumbColor: colorScheme.primary,
                    ),
                    Text(
                      AppLocalizations.of(context)!.advancedDetectionActive,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Sürekli mod
                Column(
                  children: [
                    Switch(
                      value: _isContinuousMode,
                      onChanged: (value) {
                        setState(() {
                          _isContinuousMode = value;
                        });
                      },
                      activeThumbColor: colorScheme.secondary,
                    ),
                    Text(
                      AppLocalizations.of(context)!.advancedContinuousMode,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Son tespit detayları
                if (_lastDetectedData != null)
                  ElevatedButton.icon(
                    onPressed: _showDetectionDetails,
                    icon: Icon(Icons.info, color: colorScheme.onPrimary),
                    label: Text(
                      AppLocalizations.of(context)!.advancedDetails,
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Format bilgisi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppLocalizations.of(context)!.advancedActiveFormats(
                  _selectedFormats
                      .map((f) => BarcodeTypes.getBarcodeTypeName(f))
                      .join(', '),
                ),
                style: TextStyle(color: colorScheme.secondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (!_isDetectionActive) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    // Sürekli mod değilse aynı kod tekrar tespit edilmesini engelle
    if (!_isContinuousMode && _lastDetectedData == barcode.rawValue) {
      return;
    }

    // Çok hızlı tespit edilmeyi engelle
    final now = DateTime.now();
    if (_lastDetectionTime != null &&
        now.difference(_lastDetectionTime!).inMilliseconds < 1000) {
      return;
    }

    setState(() {
      _lastDetectedData = barcode.rawValue;
      _lastDetectedFormat = barcode.format;
      _lastDetectionTime = now;
      _detectionCount++;
    });

    // Geçmişe kaydet
    HistoryService.addToHistory(
      data: barcode.rawValue!,
      type: BarcodeTypes.getBarcodeTypeName(barcode.format),
      isScanned: true,
    );

    // Vibrasyon ve ses feedback'i
    _provideFeedback();

    // Sürekli mod değilse bir sonraki ekrana git
    if (!_isContinuousMode && !_screenOpened) {
      _screenOpened = true;
      Navigator.of(context).pop(barcode.rawValue);
    }
  }

  void _provideFeedback() {
    FeedbackService.scanSuccessFeedback();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _cameraController.toggleTorch();
  }

  void _switchCamera() {
    _cameraController.switchCamera();
  }

  void _showFormatSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.advancedBarcodeFormats,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFormats = List.from(BarcodeTypes.allFormats);
                        });
                        _updateCameraConfiguration();
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.advancedSelectAll,
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 260,
                child: ListView.builder(
                  itemCount: BarcodeTypes.allFormats.length,
                  itemBuilder: (context, index) {
                    final format = BarcodeTypes.allFormats[index];
                    final isSelected = _selectedFormats.contains(format);
                    return CheckboxListTile(
                      title: Text(
                        BarcodeTypes.getBarcodeTypeName(format),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: _getFormatDescription(format, colorScheme),
                      secondary: Icon(
                        BarcodeTypes.getBarcodeTypeIcon(format),
                        color: colorScheme.primary,
                      ),
                      value: isSelected,
                      activeColor: colorScheme.primary,
                      checkColor: isDark ? Colors.black : Colors.white,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedFormats.add(format);
                          } else {
                            _selectedFormats.remove(format);
                          }
                          if (_selectedFormats.isEmpty) {
                            _selectedFormats.add(BarcodeFormat.qrCode);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      _updateCameraConfiguration();
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.advancedApply),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _getFormatDescription(
    BarcodeFormat format, [
    ColorScheme? colorScheme,
  ]) {
    String description;
    switch (format) {
      case BarcodeFormat.qrCode:
        description = AppLocalizations.of(context)!.advancedDescQrCode;
        break;
      case BarcodeFormat.ean13:
      case BarcodeFormat.ean8:
        description = AppLocalizations.of(context)!.advancedDescProductBarcode;
        break;
      case BarcodeFormat.code128:
        description = AppLocalizations.of(context)!.advancedDescIndustrial;
        break;
      default:
        description = AppLocalizations.of(context)!.advancedDescSpecialPurpose;
    }
    final cs = colorScheme ?? Theme.of(context).colorScheme;
    return Text(
      description,
      style: TextStyle(
        fontSize: 12,
        color: cs.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  void _showDetectionDetails() {
    if (_lastDetectedData == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(BarcodeTypes.getBarcodeTypeIcon(_lastDetectedFormat)),
            const SizedBox(width: 8),
            Text(BarcodeTypes.getBarcodeTypeName(_lastDetectedFormat)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.advancedDetectedData,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(_lastDetectedData!),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(
                context,
              )!.advancedDetectionCountLabel(_detectionCount),
            ),
            if (_lastDetectionTime != null)
              Text(
                AppLocalizations.of(context)!.advancedLastDetection(
                  _lastDetectionTime!.toLocal().toString().split('.')[0],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.commonClose),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              QRActionService.performAction(
                context,
                _lastDetectedData!,
                BarcodeTypes.getBarcodeTypeName(_lastDetectedFormat),
              );
            },
            child: Text(AppLocalizations.of(context)!.advancedPerformAction),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}

// Custom overlay shape for scanner
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderOffset;
    final cutOutHeight = cutOutSize < height
        ? cutOutSize
        : height - borderOffset;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - cutOutWidth / 2 + borderOffset,
      rect.top + height / 2 - cutOutHeight / 2 + borderOffset,
      cutOutWidth - borderOffset * 2,
      cutOutHeight - borderOffset * 2,
    );

    final cutOutRRect = RRect.fromRectAndRadius(
      cutOutRect,
      Radius.circular(borderRadius),
    );

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(cutOutRRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw the border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path()
      ..moveTo(cutOutRect.left, cutOutRect.top + borderLength)
      ..lineTo(cutOutRect.left, cutOutRect.top)
      ..lineTo(cutOutRect.left + borderLength, cutOutRect.top)
      ..moveTo(cutOutRect.right - borderLength, cutOutRect.top)
      ..lineTo(cutOutRect.right, cutOutRect.top)
      ..lineTo(cutOutRect.right, cutOutRect.top + borderLength)
      ..moveTo(cutOutRect.right, cutOutRect.bottom - borderLength)
      ..lineTo(cutOutRect.right, cutOutRect.bottom)
      ..lineTo(cutOutRect.right - borderLength, cutOutRect.bottom)
      ..moveTo(cutOutRect.left + borderLength, cutOutRect.bottom)
      ..lineTo(cutOutRect.left, cutOutRect.bottom)
      ..lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
