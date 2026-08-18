import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../services/history_service.dart';
import '../utils/qr_helpers.dart';
import '../services/feedback_service.dart';

enum ExportFormat { csv, excel, json }

class BatchScanItem {
  BatchScanItem({
    required this.data,
    required this.type,
    required this.timestamp,
    this.isProcessed = false,
  });

  final String data;
  bool isProcessed;
  final DateTime timestamp;
  final String type;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BatchScanItem && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

class BatchScannerScreen extends StatefulWidget {
  const BatchScannerScreen({super.key});

  @override
  State<BatchScannerScreen> createState() => _BatchScannerScreenState();
}

class _BatchScannerScreenState extends State<BatchScannerScreen> with WidgetsBindingObserver {
  final MobileScannerController cameraController = MobileScannerController(
    autoStart: false,
  );
  bool isBackCamera = true;
  bool isFlashOn = false;
  bool isScanning = true;
  bool preventDuplicates = true;
  List<BatchScanItem> scannedItems = [];

  // Modern uyarı dialogu
  Future<void> _showModernWarningDialog({
    required String title,
    required String message,
    IconData icon = Icons.warning,
    Color? iconColor,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.orange).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: iconColor ?? Colors.orange, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.commonOk),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestCameraPermission();
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
    final loc = AppLocalizations.of(context)!;
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        if (mounted) {
          await _showModernWarningDialog(
            title: loc.batchCameraPermissionRequiredTitle,
            message: loc.batchCameraPermissionRequiredMessage,
            icon: Icons.camera_alt,
            iconColor: Colors.red,
          );
        }
        return;
      }
    }
    // İzin varsa kamerayı başlat
    if (mounted) {
      await cameraController.start();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;
    bool addedNew = false;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.isEmpty) continue;
      final type = barcode.format.name;
      final alreadyExists = scannedItems.any((item) => item.data == value);
      if (preventDuplicates && alreadyExists) continue;
      
      scannedItems.add(
        BatchScanItem(data: value, type: type, timestamp: DateTime.now()),
      );
      addedNew = true;
    }
    
    if (addedNew) {
      FeedbackService.scanSuccessFeedback();
      setState(() {});
    }
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      cameraController.toggleTorch();
    });
  }

  void _switchCamera() {
    setState(() {
      isBackCamera = !isBackCamera;
      cameraController.switchCamera();
    });
  }

  void _toggleScanning() {
    setState(() {
      isScanning = !isScanning;
    });
  }

  void _removeItem(int index) {
    final loc = AppLocalizations.of(context)!;
    final item = scannedItems[index];
    setState(() {
      scannedItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(loc.batchDeletedMessage(item.type))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  void _showItemDetail(BatchScanItem item) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: colorScheme.surface,
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _getColorForType(item.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _getIconForType(item.type),
                  color: _getColorForType(item.type),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.batchScannedAtLabel(_formatDateTime(item.timestamp)),
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text(
                loc.batchContentLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(item.data),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.commonClose),
            ),
            if (!item.isProcessed)
              ElevatedButton.icon(
                onPressed: () async {
                  await HistoryService.addToHistory(
                    data: item.data,
                    type: item.type,
                    isScanned: true,
                  );
                  if (!dialogContext.mounted || !mounted) return;
                  setState(() {
                    item.isProcessed = true;
                  });
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.batchSavedToHistory)),
                  );
                },
                icon: const Icon(Icons.save),
                label: Text(loc.batchSaveButton),
              ),
          ],
        );
      },
    );
  }

  IconData _getIconForType(String type) {
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
      default:
        return Icons.text_fields;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'WiFi':
        return Colors.blue;
      case 'URL':
        return Colors.green;
      case 'Telefon':
        return Colors.orange;
      case 'E-mail':
        return Colors.red;
      case 'SMS':
        return Colors.purple;
      case 'Konum':
        return Colors.teal;
      case 'Kartvizit':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Modern başlık kartı
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.15),
                        colorScheme.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.deepPurple,
                          size: 24,
                        ),
                        tooltip: loc.commonBack,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.qr_code_scanner, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.batchTitle,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loc.batchSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.88,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${scannedItems.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Kamera görünümü kartı
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  margin: const EdgeInsets.only(bottom: 18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 240,
                      child: Stack(
                        children: [
                          MobileScanner(
                            controller: cameraController,
                            fit: BoxFit.cover,
                            onDetect: _onDetect,
                          ),
                          if (!isScanning)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.pause,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      loc.batchPausedTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
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
                ),
                // Kontrol butonları kartı
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  margin: const EdgeInsets.only(bottom: 18),
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: isFlashOn
                                ? Colors.amber
                                : colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _toggleFlash,
                          tooltip: loc.batchFlashTooltip,
                        ),
                        IconButton(
                          icon: Icon(
                            isBackCamera
                                ? Icons.camera_rear
                                : Icons.camera_front,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _switchCamera,
                          tooltip: loc.batchSwitchCameraTooltip,
                        ),
                        ElevatedButton.icon(
                          onPressed: _toggleScanning,
                          icon: Icon(
                            isScanning ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(
                            isScanning ? loc.batchPause : loc.batchStart,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isScanning
                                ? Colors.orange
                                : Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            preventDuplicates
                                ? Icons.filter_1
                                : Icons.filter_none,
                            color: preventDuplicates
                                ? Colors.blue
                                : colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              preventDuplicates = !preventDuplicates;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      preventDuplicates
                                          ? Icons.check_circle
                                          : Icons.info_outline,
                                      color: preventDuplicates
                                          ? Colors.blue
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        preventDuplicates
                                            ? loc.batchDuplicateEnabled
                                            : loc.batchDuplicateDisabled,
                                        style: TextStyle(
                                          color: colorScheme.onInverseSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: colorScheme.inverseSurface,
                              ),
                            );
                          },
                          tooltip: loc.batchDuplicateControlTooltip,
                        ),
                      ],
                    ),
                  ),
                ),
                // Taranan kodlar listesi veya boş durum
                scannedItems.isEmpty
                    ? _buildEmptyStateModern(context)
                    : _buildScannedListModern(context),

                // Alt bilgi: Duplikasyon engelleme durumu
                const SizedBox(height: 18),
                Container(
                  margin: const EdgeInsets.only(bottom: 8, top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSecondaryContainer
                          .withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        preventDuplicates
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: preventDuplicates ? Colors.blue : Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        preventDuplicates
                            ? loc.batchDuplicateEnabled
                            : loc.batchDuplicateDisabled,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modern boş durum
  Widget _buildEmptyStateModern(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 64,
            color: colorScheme.primary.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 16),
          Text(
            loc.batchEmptyTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.batchEmptySubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // Modern tarananlar listesi
  Widget _buildScannedListModern(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(
                Icons.list,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                loc.batchScannedCodesCount(scannedItems.length),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: scannedItems.length,
            itemBuilder: (context, index) {
              final item = scannedItems[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                color: colorScheme.surface,
                child: ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _getColorForType(
                        item.type,
                      ).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForType(item.type),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    QRCodeUtils.truncateQRData(item.data, maxLength: 30),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        item.type,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(item.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      if (item.isProcessed) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          size: 13,
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!item.isProcessed)
                        IconButton(
                          icon: const Icon(Icons.save, size: 20),
                          onPressed: () async {
                            await HistoryService.addToHistory(
                              data: item.data,
                              type: item.type,
                              isScanned: true,
                            );
                            if (!context.mounted || !mounted) return;
                            setState(() {
                              item.isProcessed = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.batchSavedToHistory)),
                            );
                          },
                          tooltip: loc.commonSave,
                        ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeItem(index),
                        tooltip: loc.commonDelete,
                      ),
                    ],
                  ),
                  onTap: () => _showItemDetail(item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
