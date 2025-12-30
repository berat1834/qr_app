import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_app/models/history_item.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/feedback_service.dart';
import '../services/share_service.dart';
import '../services/qr_action_service.dart';

import '../utils/qr_helpers.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin, RouteAware {
  // Arama ve filtreleme için state
  String _searchQuery = '';
  String? _selectedType;
  DateTimeRange? _selectedDateRange;
  String? _selectedTag;
  // Geçmiş verisi için state
  List<HistoryItem> qrHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Geçmişi yükleyen fonksiyon
  Future<void> _loadHistory() async {
    final history = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        qrHistory = history;
      });
    }
  }

  // Çoklu seçim için
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    // Gelişmiş filtreleme
    List<HistoryItem> filtered = qrHistory.where((qr) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          qr.data.toLowerCase().contains(query) ||
          qr.type.toLowerCase().contains(query) ||
          (qr.customName?.toLowerCase().contains(query) ?? false) ||
          qr.date.toString().toLowerCase().contains(query);

      final matchesType = _selectedType == null || qr.type == _selectedType;
      final matchesTag =
          _selectedTag == null || (qr.customName ?? '').contains(_selectedTag!);
      final matchesDate =
          _selectedDateRange == null ||
          _isInDateRange(qr.date, _selectedDateRange!);
      return matchesQuery && matchesType && matchesTag && matchesDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedIds.length} seçili')
            : const Text('QR Kod Geçmişi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectionMode = false;
                    _selectedIds.clear();
                  });
                },
                tooltip: 'Seçimi İptal Et',
              )
            : null,
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Seçili QR Kodları Sil'),
                          content: Text(
                            '${_selectedIds.length} QR kodunu silmek istediğinize emin misiniz?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('İptal'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sil'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final Set<String> idsToDelete = Set.from(_selectedIds);
                        setState(() {
                          qrHistory.removeWhere(
                            (qr) => idsToDelete.contains(qr.id),
                          );
                          _selectedIds.clear();
                          _selectionMode = false;
                        });

                        // Toplu silme işlemi
                        await Future.wait(
                          idsToDelete.map(
                            (id) => HistoryService.deleteHistoryItem(id),
                          ),
                        );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Seçili QR kodlar silindi'),
                            ),
                          );
                        }
                      }
                    },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Ara (metin, tür, etiket, tarih)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  tooltip: 'Filtrele',
                  onPressed: () async {
                    await _showFilterDialog(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Henüz QR kod geçmişi yok.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final qr = filtered[index];
                      final isSelected = _selectedIds.contains(qr.id);
                      return GestureDetector(
                        onLongPress: () {
                          setState(() {
                            _selectionMode = true;
                            _selectedIds.add(qr.id);
                          });
                        },
                        onTap: () {
                          if (_selectionMode) {
                            setState(() {
                              if (isSelected) {
                                _selectedIds.remove(qr.id);
                                if (_selectedIds.isEmpty) {
                                  _selectionMode = false;
                                }
                              } else {
                                _selectedIds.add(qr.id);
                              }
                            });
                          } else {
                            _showQRDetail(context, qr, index);
                          }
                        },
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: isSelected ? 0.5 : 1.0,
                              child: _buildGridItem(qr, index),
                            ),
                            if (isSelected)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                              ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: PopupMenuButton<String>(
                                onSelected: (action) =>
                                    _handleMenuAction(action, qr, index),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Text('Görüntüle'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'copy',
                                    child: Text('Kopyala'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'share',
                                    child: Text('Paylaş'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Sil'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: qrHistory.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showClearDialog,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Tümünü Temizle'),
            )
          : null,
    );
  }

  // Tarih aralığı kontrolü
  bool _isInDateRange(DateTime date, DateTimeRange range) {
    // Tarihlerin sadece gün, ay, yıl kısımlarını karşılaştır
    final cleanDate = DateUtils.dateOnly(date);
    final cleanStart = DateUtils.dateOnly(range.start);
    final cleanEnd = DateUtils.dateOnly(range.end);
    return (cleanDate.isAfter(cleanStart) ||
            cleanDate.isAtSameMomentAs(cleanStart)) &&
        (cleanDate.isBefore(cleanEnd) || cleanDate.isAtSameMomentAs(cleanEnd));
  }

  // Filtre dialogu
  Future<void> _showFilterDialog(BuildContext context) async {
    final types = qrHistory.map((e) => e.type).toSet().toList();
    final tags = qrHistory
        .map((e) => e.customName)
        .whereType<String>()
        .toSet()
        .toList();

    DateTimeRange? tempRange = _selectedDateRange;
    String? tempType = _selectedType;
    String? tempTag = _selectedTag;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          title: const Text('Filtrele'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: tempType,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tümü'),
                  ),
                  ...types.map(
                    (t) => DropdownMenuItem<String?>(value: t, child: Text(t)),
                  ),
                ],
                onChanged: (v) => setStateSB(() => tempType = v),
                decoration: const InputDecoration(labelText: 'Tür'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: tempTag,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tümü'),
                  ),
                  ...tags.map(
                    (t) => DropdownMenuItem<String?>(value: t, child: Text(t)),
                  ),
                ],
                onChanged: (v) => setStateSB(() => tempTag = v),
                decoration: const InputDecoration(labelText: 'Etiket'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tempRange == null
                          ? 'Tarih aralığı seçilmedi'
                          : '${tempRange!.start.toString().split(' ')[0]} - ${tempRange!.end.toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDateRangePicker(
                        context: dialogContext,
                        firstDate: DateTime(now.year - 5),
                        lastDate: DateTime(now.year + 1),
                        initialDateRange: tempRange,
                      );
                      if (picked != null) setStateSB(() => tempRange = picked);
                    },
                    child: const Text('Tarih Seç'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedType = tempType;
                  _selectedTag = tempTag;
                  _selectedDateRange = tempRange;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Uygula'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(HistoryItem qr, int index) {
    final readableContent = qr.data;

    // Basit tarih formatlama (intl paketi olmadan)
    final formattedDate =
        '${qr.date.day.toString().padLeft(2, '0')}.${qr.date.month.toString().padLeft(2, '0')}.${qr.date.year}';

    return Card(
      child: InkWell(
        onTap: () => _showQRDetail(context, qr, index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Hero(
                tag: 'qr_${qr.id}',
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getColorForType(qr.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForType(qr.type),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                qr.type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  readableContent,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                qr.customName ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, HistoryItem qr, int index) {
    FeedbackService.buttonTapFeedback();

    switch (action) {
      case 'view':
        _showQRDetail(context, qr, index);
        break;
      case 'copy':
        _copyToClipboard(qr.data);
        break;
      case 'share':
        _shareQR(qr.data, qr.type);
        break;
      case 'delete':
        _deleteQR(qr);
        break;
    }
  }

  void _copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Panoya kopyalandı')));
  }

  void _shareQR(String data, String type) {
    final formattedContent = _formatContentForSharing(data, type);
    ShareService.shareText(formattedContent);
  }

  String _formatContentForSharing(String content, String type) {
    // Bu fonksiyon doğrudan `qr_helpers.dart` veya `share_service.dart` içinde olabilir
    switch (type) {
      case 'WiFi':
        final wifi = QRCodeUtils.parseWiFiQR(content);
        if (wifi != null) {
          return ShareService.formatWiFiForSharing(
            wifi['ssid'] ?? '',
            wifi['password'] ?? '',
            wifi['security'] ?? '',
          );
        }
        break;
      case 'Konum':
        final location = QRCodeUtils.parseLocationQR(content);
        if (location != null) {
          return ShareService.formatLocationForSharing(
            location['latitude']!,
            location['longitude']!,
          );
        }
        break;
    }
    return content;
  }

  void _deleteQR(HistoryItem qr) async {
    setState(() {
      qrHistory.removeWhere((item) => item.id == qr.id);
    });
    await HistoryService.deleteHistoryItem(qr.id);

    FeedbackService.scanErrorFeedback();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${qr.type} QR kodu silindi')));
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tümünü Temizle'),
        content: const Text(
          'Tüm QR kod geçmişini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                qrHistory.clear();
              });
              await HistoryService.clearHistory();
              Navigator.pop(context);
              FeedbackService.scanErrorFeedback();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tüm geçmiş temizlendi')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Unused method removed: _showStatsDialog

  // Unused method removed: _buildStatItem

  // Unused method removed: _calculateStats

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'url':
        return Colors.blue;
      case 'wifi':
        return Colors.green;
      case 'telefon':
        return Colors.orange;
      case 'e-mail':
        return Colors.red;
      case 'sms':
        return Colors.purple;
      case 'konum':
        return Colors.teal;
      case 'kartvizit':
        return Colors.indigo;
      case 'metin':
      default:
        return Colors.grey;
    }
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

  void _showQRDetail(BuildContext context, HistoryItem qr, int index) {
    // Basit tarih formatlama
    final formattedDate =
        '${qr.date.day.toString().padLeft(2, '0')}.${qr.date.month.toString().padLeft(2, '0')}.${qr.date.year}';
    final formattedTime =
        '${qr.date.hour.toString().padLeft(2, '0')}:${qr.date.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'qr_${qr.id}',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qr.data,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                qr.type,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (qr.customName != null && qr.customName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '"${qr.customName!}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  qr.data,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$formattedDate $formattedTime',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      QRActionService.performAction(context, qr.data, qr.type);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Kullan'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _copyToClipboard(qr.data);
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Kopyala'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _shareQR(qr.data, qr.type);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Paylaş'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Unused method removed: _showEditQRDialog

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ekrana her dönüldüğünde geçmişi güncellemek için RouteAware kullanılabilir.
    // Şimdilik initState ve manuel yenileme yeterli.
    // Örneğin:
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // routeObserver.subscribe(this, route); // main.dart'ta bir observer lazım
    }
  }

  @override
  void dispose() {
    // routeObserver.unsubscribe(this); // Eğer subscribe edildiyse
    super.dispose();
  }
}
