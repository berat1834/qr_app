import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/feedback_service.dart';
import '../services/history_service.dart';
import '../services/share_service.dart';
import '../utils/qr_helpers.dart';

class BatchScanItem {
  final String data;
  final String type;
  final DateTime timestamp;
  bool isProcessed;

  BatchScanItem({
    required this.data,
    required this.type,
    required this.timestamp,
    this.isProcessed = false,
  });

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

class _BatchScannerScreenState extends State<BatchScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  List<BatchScanItem> scannedItems = [];
  bool isScanning = true;
  bool isFlashOn = false;
  bool isBackCamera = true;
  bool preventDuplicates = true;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        final data = barcode.rawValue!;
        final type = QRCodeUtils.determineQRType(data);

        final newItem = BatchScanItem(
          data: data,
          type: type,
          timestamp: DateTime.now(),
        );

        // Duplikasyon kontrolü
        if (preventDuplicates && scannedItems.contains(newItem)) {
          continue;
        }

        setState(() {
          scannedItems.insert(0, newItem);
        });

        FeedbackService.scanSuccessFeedback();
        break; // Bir kere taradık, break
      }
    }
  }

  void _switchCamera() async {
    await cameraController.switchCamera();
    setState(() {
      isBackCamera = !isBackCamera;
    });
  }

  void _toggleFlash() async {
    await cameraController.toggleTorch();
    setState(() {
      isFlashOn = !isFlashOn;
    });
  }

  void _toggleScanning() {
    setState(() {
      isScanning = !isScanning;
    });
    FeedbackService.buttonTapFeedback();
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tümünü Temizle'),
        content: const Text(
          'Tüm taranan QR kodları silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => scannedItems.clear());
              Navigator.pop(context);
              FeedbackService.scanErrorFeedback();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    final item = scannedItems[index];
    setState(() {
      scannedItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.type} QR kodu silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            setState(() {
              scannedItems.insert(index, item);
            });
          },
        ),
      ),
    );
  }

  void _saveAllToHistory() async {
    int savedCount = 0;
    for (final item in scannedItems) {
      if (!item.isProcessed) {
        await HistoryService.addToHistory(
          data: item.data,
          type: item.type,
          isScanned: true,
        );
        item.isProcessed = true;
        savedCount++;
      }
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$savedCount QR kod geçmişe kaydedildi')),
    );
  }

  void _exportAll() {
    final exportData = scannedItems
        .map((item) {
          return '${item.type}: ${item.data}\nTarih: ${_formatDateTime(item.timestamp)}\n';
        })
        .join('\n');

    final fullExport =
        'Toplu QR Tarama Sonuçları:\nToplam: ${scannedItems.length} kod\n\n$exportData';

    ShareService.shareText(fullExport);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplu Tarama'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Text(
            '${scannedItems.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          if (scannedItems.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'save_all':
                    _saveAllToHistory();
                    break;
                  case 'export':
                    _exportAll();
                    break;
                  case 'clear':
                    _clearAll();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'save_all',
                  child: Row(
                    children: [
                      Icon(Icons.save, size: 18),
                      SizedBox(width: 8),
                      Text('Tümünü Kaydet'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 18),
                      SizedBox(width: 8),
                      Text('Dışa Aktar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Tümünü Sil', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Kamera görünümü
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  fit: BoxFit.cover,
                  scanWindow: Rect.fromCenter(
                    center: MediaQuery.of(context).size.center(Offset.zero),
                    width: 250,
                    height: 250,
                  ),
                  onDetect: _onDetect,
                ),
                // Tarama durumu overlay
                if (!isScanning)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pause, size: 64, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'TARAMA DURAKLATILDI',
                            style: TextStyle(
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
          // Kontrol butonları
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flaş
                IconButton(
                  icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
                  onPressed: _toggleFlash,
                  tooltip: 'Flaş',
                ),
                // Kamera değiştir
                IconButton(
                  icon: Icon(
                    isBackCamera ? Icons.camera_rear : Icons.camera_front,
                  ),
                  onPressed: _switchCamera,
                  tooltip: 'Kamera Değiştir',
                ),
                // Tarama duraklat/başlat
                ElevatedButton.icon(
                  onPressed: _toggleScanning,
                  icon: Icon(isScanning ? Icons.pause : Icons.play_arrow),
                  label: Text(isScanning ? 'Duraklat' : 'Başlat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isScanning ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                // Duplikasyon kontrolü
                IconButton(
                  icon: Icon(
                    preventDuplicates ? Icons.filter_1 : Icons.filter_none,
                    color: preventDuplicates ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      preventDuplicates = !preventDuplicates;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          preventDuplicates
                              ? 'Duplikasyon engelleme aktif'
                              : 'Duplikasyon engelleme pasif',
                        ),
                      ),
                    );
                  },
                  tooltip: 'Duplikasyon Kontrolü',
                ),
              ],
            ),
          ),
          // Taranan kodlar listesi
          Expanded(
            flex: 2,
            child: scannedItems.isEmpty
                ? _buildEmptyState()
                : _buildScannedList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'QR kodları tarayın',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Taranan kodlar burada görünecek',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.list, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Taranan Kodlar (${scannedItems.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${scannedItems.where((item) => item.isProcessed).length} kaydedildi',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
              return _buildScanItem(item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScanItem(BatchScanItem item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _getColorForType(item.type),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            _getIconForType(item.type),
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(
          QRCodeUtils.truncateQRData(item.data, maxLength: 30),
          style: const TextStyle(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              item.type,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(item.timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
            if (item.isProcessed) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, size: 12, color: Colors.green),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!item.isProcessed)
              IconButton(
                icon: const Icon(Icons.save, size: 18),
                onPressed: () async {
                  await HistoryService.addToHistory(
                    data: item.data,
                    type: item.type,
                    isScanned: true,
                  );
                  setState(() {
                    item.isProcessed = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Geçmişe kaydedildi')),
                  );
                },
                tooltip: 'Kaydet',
              ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _removeItem(index),
              tooltip: 'Sil',
            ),
          ],
        ),
        onTap: () => _showItemDetail(item),
      ),
    );
  }

  void _showItemDetail(BatchScanItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _getIconForType(item.type),
                color: _getColorForType(item.type),
              ),
              const SizedBox(width: 8),
              Text(item.type),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Taranma: ${_formatDateTime(item.timestamp)}'),
              const SizedBox(height: 16),
              const Text(
                'İçerik:',
                style: TextStyle(fontWeight: FontWeight.bold),
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
            if (!item.isProcessed)
              ElevatedButton.icon(
                onPressed: () async {
                  await HistoryService.addToHistory(
                    data: item.data,
                    type: item.type,
                    isScanned: true,
                  );
                  setState(() {
                    item.isProcessed = true;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Geçmişe kaydedildi')),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
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
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
