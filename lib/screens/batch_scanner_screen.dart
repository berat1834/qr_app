<<<<<<< HEAD

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../services/feedback_service.dart';
import '../services/history_service.dart';
import '../services/premium_access_service.dart';
import '../services/share_service.dart';
import '../utils/qr_helpers.dart';

enum ExportFormat { csv, excel, json }

=======
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/feedback_service.dart';
import '../services/history_service.dart';
import '../services/share_service.dart';
import '../utils/qr_helpers.dart';

>>>>>>> fe1c515 (Goodbye 2025, thanks for the lessons.)
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

<<<<<<< HEAD
  Future<void> _showExportFormatDialog({required bool emailMode}) async {
    final isPremium = PremiumAccessService.premiumNotifier.value;
    if (!isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu özellik Premium üyelik gerektirir.')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(emailMode ? 'E-posta için format seçin' : 'Dışa Aktarım'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV'),
              subtitle: const Text('Excel ve analiz araçları ile uyumlu'),
              onTap: () {
                Navigator.pop(context);
                _exportAll(ExportFormat.csv, emailMode: emailMode);
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_on),
              title: const Text('Excel (.xls)'),
              subtitle: const Text('Excel dosyası olarak paylaşılır'),
              onTap: () {
                Navigator.pop(context);
                _exportAll(ExportFormat.excel, emailMode: emailMode);
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_object),
              title: const Text('JSON'),
              subtitle: const Text('Yazılım entegrasyonları için ideal'),
              onTap: () {
                Navigator.pop(context);
                _exportAll(ExportFormat.json, emailMode: emailMode);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAll(
    ExportFormat format, {
    required bool emailMode,
  }) async {
    if (scannedItems.isEmpty) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _fileExtensionFor(format);
      final fileName = 'batch_qr_export_$timestamp.$extension';
      final file = File('${tempDir.path}/$fileName');

      final content = switch (format) {
        ExportFormat.csv => _buildCsvContent(),
        ExportFormat.excel => _buildExcelXmlContent(),
        ExportFormat.json => _buildJsonContent(),
      };

      await file.writeAsString(content, flush: true);

      final shareSubject =
          'Toplu Tarama Dışa Aktarım (${_formatLabelFor(format)})';
      final shareText = emailMode
          ? 'Toplu tarama çıktısı ektedir. (${scannedItems.length} kayıt)'
          : 'Toplu tarama çıktısı (${scannedItems.length} kayıt)';

      await ShareService.shareFile(
        file.path,
        text: shareText,
        subject: shareSubject,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Dışa aktarma hatası: $e')));
    }
  }

  String _buildCsvContent() {
    const header = 'Tip,Icerik,Tarih,Durum';
    final rows = scannedItems.map((item) {
      final safeData = item.data.replaceAll('"', '""');
      final state = item.isProcessed ? 'Kaydedildi' : 'Kaydedilmedi';
      return '${item.type},"$safeData",${_formatDateTime(item.timestamp)},$state';
    });
    return '$header\n${rows.join('\n')}';
  }

  String _buildJsonContent() {
    final data = scannedItems
        .map(
          (item) => {
            'type': item.type,
            'data': item.data,
            'timestamp': item.timestamp.toIso8601String(),
            'isProcessed': item.isProcessed,
          },
        )
        .toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String _buildExcelXmlContent() {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0"?>');
    buffer.writeln('<?mso-application progid="Excel.Sheet"?>');
    buffer.writeln(
      '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" '
      'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">',
    );
    buffer.writeln('<Worksheet ss:Name="QR Export"><Table>');

    buffer.writeln('<Row>');
    buffer.writeln('<Cell><Data ss:Type="String">Tip</Data></Cell>');
    buffer.writeln('<Cell><Data ss:Type="String">İçerik</Data></Cell>');
    buffer.writeln('<Cell><Data ss:Type="String">Tarih</Data></Cell>');
    buffer.writeln('<Cell><Data ss:Type="String">Durum</Data></Cell>');
    buffer.writeln('</Row>');

    for (final item in scannedItems) {
      buffer.writeln('<Row>');
      buffer.writeln(
        '<Cell><Data ss:Type="String">${_escapeXml(item.type)}</Data></Cell>',
      );
      buffer.writeln(
        '<Cell><Data ss:Type="String">${_escapeXml(item.data)}</Data></Cell>',
      );
      buffer.writeln(
        '<Cell><Data ss:Type="String">${_escapeXml(_formatDateTime(item.timestamp))}</Data></Cell>',
      );
      buffer.writeln(
        '<Cell><Data ss:Type="String">${item.isProcessed ? 'Kaydedildi' : 'Kaydedilmedi'}</Data></Cell>',
      );
      buffer.writeln('</Row>');
    }

    buffer.writeln('</Table></Worksheet></Workbook>');
    return buffer.toString();
  }

  String _escapeXml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  String _fileExtensionFor(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.excel:
        return 'xls';
      case ExportFormat.json:
        return 'json';
    }
  }

  String _formatLabelFor(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.json:
        return 'JSON';
    }
=======
  void _exportAll() {
    final exportData = scannedItems
        .map((item) {
          return '${item.type}: ${item.data}\nTarih: ${_formatDateTime(item.timestamp)}\n';
        })
        .join('\n');

    final fullExport =
        'Toplu QR Tarama Sonuçları:\nToplam: ${scannedItems.length} kod\n\n$exportData';

    ShareService.shareText(fullExport);
>>>>>>> fe1c515 (Goodbye 2025, thanks for the lessons.)
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
<<<<<<< HEAD
            ValueListenableBuilder<bool>(
              valueListenable: PremiumAccessService.premiumNotifier,
              builder: (context, isPremium, _) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'save_all':
                        _saveAllToHistory();
                        break;
                      case 'export':
                        _showExportFormatDialog(emailMode: false);
                        break;
                      case 'export_email':
                        _showExportFormatDialog(emailMode: true);
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
                    PopupMenuItem(
                      value: 'export',
                      enabled: isPremium,
                      child: Row(
                        children: [
                          Icon(isPremium ? Icons.share : Icons.lock, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isPremium
                                ? 'Dışa Aktar (Paylaş)'
                                : 'Dışa Aktar (Premium)',
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'export_email',
                      enabled: isPremium,
                      child: Row(
                        children: [
                          Icon(isPremium ? Icons.email : Icons.lock, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isPremium
                                ? 'Dışa Aktar (E-posta)'
                                : 'E-posta Export (Premium)',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Tümünü Sil',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
=======
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
>>>>>>> fe1c515 (Goodbye 2025, thanks for the lessons.)
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
