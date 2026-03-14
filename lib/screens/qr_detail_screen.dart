import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/history_item.dart';
import '../services/share_service.dart';
import '../services/feedback_service.dart';

class QRDetailScreen extends StatefulWidget {
  final HistoryItem item;

  const QRDetailScreen({super.key, required this.item});

  @override
  State<QRDetailScreen> createState() => _QRDetailScreenState();
}

class _QRDetailScreenState extends State<QRDetailScreen> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _shareAsImage() async {
    try {
      // QR kodunu resme dönüştür
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'qr_${widget.item.customName ?? widget.item.type}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      // Resmi paylaş
      await ShareService.shareText(file.path);

      if (mounted) {
        FeedbackService.buttonTapFeedback();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR kod resmi paylaşıldı')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşma hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paylaşım Türü Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Metin Paylaş'),
              subtitle: const Text('QR kod içeriğini metin olarak paylaş'),
              onTap: () {
                Navigator.pop(context);
                FeedbackService.buttonTapFeedback();
                ShareService.shareText(
                  _formatContentForSharing(widget.item.data, widget.item.type),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Resim Paylaş'),
              subtitle: const Text('QR kodu resim olarak paylaş'),
              onTap: () {
                Navigator.pop(context);
                _shareAsImage();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.customName ?? 'QR Kod Detayı'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Kopyala',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.item.data));
              FeedbackService.buttonTapFeedback();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Panoya kopyalandı')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Paylaş',
            onPressed: _showShareDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Kod Gösterimi
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.white,
                      child: QrImageView(
                        data: widget.item.data,
                        version: QrVersions.auto,
                        size: 280,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tip ve Kategori
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Tür',
                    widget.item.type,
                    _getIconForType(widget.item.type),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Kategori',
                    widget.item.category ?? 'Kategori yok',
                    Icons.label,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // İsim
            if (widget.item.customName != null)
              _buildInfoCard(
                context,
                'İsim',
                widget.item.customName!,
                Icons.title,
              ),
            if (widget.item.customName != null) const SizedBox(height: 16),

            // Veri
            _buildInfoCard(
              context,
              'Veri',
              widget.item.data,
              Icons.data_object,
              maxLines: null,
            ),
            const SizedBox(height: 16),

            // Tarih
            _buildInfoCard(
              context,
              'Tarih',
              _formatDate(widget.item.date),
              Icons.calendar_today,
            ),
            const SizedBox(height: 16),

            // Durum
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Durum',
                    widget.item.isScanned ? 'Tarandı' : 'Oluşturuldu',
                    widget.item.isScanned
                        ? Icons.qr_code_scanner
                        : Icons.qr_code,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Arşiv',
                    widget.item.isArchived ? 'Evet' : 'Hayır',
                    widget.item.isArchived ? Icons.archive : Icons.unarchive,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    int? maxLines = 1,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              maxLines: maxLines,
              overflow: maxLines == null ? null : TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  String _formatContentForSharing(String content, String type) {
    return '$type QR Kodu:\n\n$content';
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'url':
        return Icons.link;
      case 'wifi':
        return Icons.wifi;
      case 'telefon':
        return Icons.phone;
      case 'e-mail':
        return Icons.email;
      case 'sms':
        return Icons.sms;
      case 'konum':
        return Icons.location_on;
      case 'kartvizit':
        return Icons.contact_page;
      case 'metin':
      default:
        return Icons.text_fields;
    }
  }
}
