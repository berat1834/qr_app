import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_app/models/history_item.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/feedback_service.dart';
import '../services/share_service.dart';
import '../services/favorites_service.dart';
import 'qr_detail_screen.dart';
import '../utils/qr_helpers.dart';
import '../services/history_service.dart';

enum _SortOption { date, name, type }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin, RouteAware {
  // Arama ve filtreleme için state
  late TextEditingController _searchController;
  String _searchQuery = '';
  String? _selectedType;
  DateTimeRange? _selectedDateRange;
  String? _selectedTag;
  String? _selectedCategory;
  // Geçmiş verisi için state
  List<HistoryItem> qrHistory = [];
  _SortOption _sortOption = _SortOption.date;
  bool _sortAscending = false;
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      final query = _normalizeSearchText(_searchQuery);
      final matchesQuery =
          query.isEmpty ||
          _normalizeSearchText(qr.data).contains(query) ||
          _normalizeSearchText(qr.type).contains(query) ||
          _normalizeSearchText(qr.customName ?? '').contains(query) ||
          _normalizeSearchText(qr.date.toString()).contains(query);

      final matchesType = _selectedType == null || qr.type == _selectedType;
      final matchesTag =
          _selectedTag == null || (qr.customName ?? '').contains(_selectedTag!);
      final matchesCategory =
          _selectedCategory == null || qr.category == _selectedCategory;
      final matchesDate =
          _selectedDateRange == null ||
          _isInDateRange(qr.date, _selectedDateRange!);
      final matchesArchive = _showArchived ? qr.isArchived : !qr.isArchived;
      return matchesQuery &&
          matchesType &&
          matchesTag &&
          matchesCategory &&
          matchesDate &&
          matchesArchive;
    }).toList();
    _sortHistory(filtered);
    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedIds.length} seçili')
            : const Text('Kaydedilenler'),
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
        actions: [],
        bottom: _selectionMode
            ? PreferredSize(
                preferredSize: const Size.fromHeight(216),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : _showBulkEditDialog,
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('İsim Ata'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : _showBulkCategoryDialog,
                              icon: const Icon(Icons.label, size: 18),
                              label: const Text('Kategori Ata'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : () => _addSelectedToFavorites(),
                              icon: const Icon(Icons.favorite, size: 18),
                              label: const Text('Favorilere'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : () => _archiveSelected(true),
                              icon: const Icon(Icons.archive, size: 18),
                              label: const Text('Arsivle'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : _shareSelectedAsImages,
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Paylaş (Resim)'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : _exportSelected,
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Export'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : _exportSelected,
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Export'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : _confirmBulkDelete,
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Sil'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.text,
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
                IconButton(
                  icon: Icon(_showArchived ? Icons.archive : Icons.unarchive),
                  tooltip: _showArchived ? 'Arsivdekiler' : 'Aktif kayitlar',
                  onPressed: () {
                    setState(() => _showArchived = !_showArchived);
                  },
                ),
                PopupMenuButton<_SortOption>(
                  tooltip: 'Sırala',
                  icon: const Icon(Icons.sort),
                  onSelected: (value) {
                    setState(() => _sortOption = value);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _SortOption.date,
                      child: Text('Tarihe göre'),
                    ),
                    PopupMenuItem(
                      value: _SortOption.name,
                      child: Text('İsme göre'),
                    ),
                    PopupMenuItem(
                      value: _SortOption.type,
                      child: Text('Türe göre'),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: _sortAscending ? 'Artan' : 'Azalan',
                  icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: () {
                    setState(() => _sortAscending = !_sortAscending);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
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
                                  PopupMenuItem(
                                    value: 'archive',
                                    child: Text(
                                      qr.isArchived
                                          ? 'Arsivden Cikar'
                                          : 'Arsivle',
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'editName',
                                    child: Text('İsim Düzenle'),
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
      floatingActionButton: qrHistory.isNotEmpty && !_selectionMode
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

  void _sortHistory(List<HistoryItem> items) {
    int compareStrings(String a, String b) {
      return _normalizeSearchText(a).compareTo(_normalizeSearchText(b));
    }

    items.sort((a, b) {
      int result;
      switch (_sortOption) {
        case _SortOption.name:
          final nameA = (a.customName?.isNotEmpty ?? false)
              ? a.customName!
              : a.data;
          final nameB = (b.customName?.isNotEmpty ?? false)
              ? b.customName!
              : b.data;
          result = compareStrings(nameA, nameB);
          break;
        case _SortOption.type:
          result = compareStrings(a.type, b.type);
          break;
        case _SortOption.date:
          result = a.date.compareTo(b.date);
          break;
      }
      return _sortAscending ? result : -result;
    });
  }

  String _normalizeSearchText(String text) {
    return text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  // Filtre dialogu
  Future<void> _showFilterDialog(BuildContext context) async {
    final types = qrHistory.map((e) => e.type).toSet().toList();
    final tags = qrHistory
        .map((e) => e.customName)
        .whereType<String>()
        .toSet()
        .toList();
    final categories = qrHistory
        .map((e) => e.category)
        .whereType<String>()
        .toSet()
        .toList();

    DateTimeRange? tempRange = _selectedDateRange;
    String? tempType = _selectedType;
    String? tempTag = _selectedTag;
    String? tempCategory = _selectedCategory;

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
              DropdownButtonFormField<String?>(
                initialValue: tempCategory,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tümü'),
                  ),
                  ...categories.map(
                    (c) => DropdownMenuItem<String?>(value: c, child: Text(c)),
                  ),
                ],
                onChanged: (v) => setStateSB(() => tempCategory = v),
                decoration: const InputDecoration(labelText: 'Kategori'),
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
                  _selectedCategory = tempCategory;
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showQRDetail(context, qr, index),
        borderRadius: BorderRadius.circular(16),
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
                    color: _getColorForType(qr.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconForType(qr.type),
                    color: _getColorForType(qr.type),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Kategori chip
              if (qr.category != null && qr.category!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      qr.category!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              Text(
                qr.type,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              if (qr.customName != null && qr.customName!.isNotEmpty)
                Text(
                  qr.customName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else ...[
                Expanded(
                  child: Text(
                    readableContent,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showEditNameDialog(qr),
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('İsim ekle'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
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
      case 'editName':
        _showEditNameDialog(qr);
        break;
      case 'copy':
        _copyToClipboard(qr.data);
        break;
      case 'share':
        _shareQR(qr.data, qr.type);
        break;
      case 'archive':
        _toggleArchive(qr);
        break;
      case 'delete':
        _deleteQR(qr);
        break;
    }
  }

  Future<void> _toggleArchive(HistoryItem qr) async {
    final wasArchived = qr.isArchived;

    await HistoryService.setArchived(qr.id, !qr.isArchived);
    await _loadHistory();
    if (mounted) {
      final label = wasArchived ? 'Arsivden cikti' : 'Arsive alindi';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(label),
          action: SnackBarAction(
            label: 'GERİ AL',
            onPressed: () async {
              // Undo: Arşiv durumunu eski haline getir
              await HistoryService.setArchived(qr.id, wasArchived);
              await _loadHistory();
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _archiveSelected(bool archived) async {
    if (_selectedIds.isEmpty) return;

    // Undo için önceki durumu sakla
    final selectedItems = qrHistory
        .where((item) => _selectedIds.contains(item.id))
        .toList();

    await HistoryService.setArchivedForIds(
      Set<String>.from(_selectedIds),
      archived,
    );
    await _loadHistory();
    if (mounted) {
      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            archived ? 'Secililer arsivlendi' : 'Secililer geri alindi',
          ),
          action: SnackBarAction(
            label: 'GERİ AL',
            onPressed: () async {
              // Undo: Arşiv durumunu eski haline getir
              await HistoryService.setArchivedForIds(
                selectedItems.map((e) => e.id).toSet(),
                !archived,
              );
              await _loadHistory();
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _addSelectedToFavorites() async {
    if (_selectedIds.isEmpty) return;

    int added = 0;
    int skipped = 0;

    for (String id in _selectedIds) {
      final item = qrHistory.firstWhere(
        (h) => h.id == id,
        orElse: () => throw Exception('Item not found'),
      );

      try {
        await FavoritesService.addToFavorites(
          data: item.data,
          type: item.type,
          customName: item.customName,
        );
        added++;
      } catch (e) {
        // Zaten favorilerde olan items için skip et
        skipped++;
      }
    }

    if (mounted) {
      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });

      final message = skipped > 0
          ? '✅ $added eklendi, $skipped zaten favori'
          : '✅ $added favorilere eklendi';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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

  void _showEditNameDialog(HistoryItem qr) {
    final controller = TextEditingController(text: qr.customName ?? '');
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Kayıt İsmini Düzenle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'İsim (boş bırakılabilir)',
              border: OutlineInputBorder(),
              hintText: 'Örn: İş QR Kodu',
            ),
            maxLength: 50,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await HistoryService.updateCustomName(
                  qr.id,
                  controller.text.trim(),
                );
                Navigator.of(dialogContext).pop();
                _loadHistory();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('İsim güncellendi')),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showBulkEditDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Seçililere İsim Ata'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'İsim (boş bırakılırsa temizler)',
              border: OutlineInputBorder(),
              hintText: 'Örn: İş QR Kodları',
            ),
            maxLength: 50,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await HistoryService.updateCustomNameForIds(
                  Set<String>.from(_selectedIds),
                  controller.text.trim(),
                );
                Navigator.of(dialogContext).pop();
                await _loadHistory();
                if (mounted) {
                  setState(() {
                    _selectedIds.clear();
                    _selectionMode = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seçililere isim atandı')),
                  );
                }
              },
              child: const Text('Uygula'),
            ),
          ],
        );
      },
    );
  }

  void _showBulkCategoryDialog() async {
    final usedCategories = await HistoryService.getUsedCategories();
    final suggestedCategories = HistoryService.getSuggestedCategories();

    // Kullanılan kategoriler + önerilen kategoriler (tekrar etmeyenler)
    final allCategories = <String>[
      ...usedCategories,
      ...suggestedCategories.where((s) => !usedCategories.contains(s)),
    ];

    final controller = TextEditingController();
    String? selectedCategory;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Seçililere Kategori Ata'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (allCategories.isNotEmpty) ...[
                  const Text(
                    'Mevcut Kategoriler:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: allCategories.map((category) {
                      final isSelected = selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            selectedCategory = selected ? category : null;
                            controller.text = selected ? category : '';
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Yeni Kategori (veya boş bırak)',
                    border: OutlineInputBorder(),
                    hintText: 'Örn: Faturalar',
                  ),
                  maxLength: 30,
                  autofocus: allCategories.isEmpty,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value.isEmpty ? null : value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final category = controller.text.trim();
                  await HistoryService.updateCategoryForIds(
                    Set<String>.from(_selectedIds),
                    category.isEmpty ? null : category,
                  );
                  Navigator.of(dialogContext).pop();
                  await _loadHistory();
                  if (mounted) {
                    setState(() {
                      _selectedIds.clear();
                      _selectionMode = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          category.isEmpty
                              ? 'Kategoriler temizlendi'
                              : 'Kategori atandı: $category',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Uygula'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareSelectedAsImages() async {
    if (_selectedIds.isEmpty) return;

    try {
      // Gösterge göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR kodlar resme dönüştürülüyor...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Seçilen itemları al
      final selectedItems = qrHistory
          .where((item) => _selectedIds.contains(item.id))
          .toList();

      final tempDir = await getTemporaryDirectory();
      final qrDir = Directory(
        '${tempDir.path}/qr_share_${DateTime.now().millisecondsSinceEpoch}',
      );
      await qrDir.create();

      // Her QR kodu için resim oluştur
      final List<String> imagePaths = [];
      for (int i = 0; i < selectedItems.length; i++) {
        final item = selectedItems[i];

        // QR kodu oluştur (programatik olarak)
        final qrPainter = QrPainter(
          data: item.data,
          version: QrVersions.auto,
          gapless: false,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
        );

        // Resme dönüştür
        final pictureRecorder = ui.PictureRecorder();
        final canvas = Canvas(pictureRecorder);
        const size = 1024.0; // Yüksek çözünürlük

        // Beyaz arka plan
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size, size),
          Paint()..color = Colors.white,
        );

        // QR kodu çiz
        qrPainter.paint(canvas, const Size(1024, 1024));

        final picture = pictureRecorder.endRecording();
        final image = await picture.toImage(size.toInt(), size.toInt());
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        // Dosya oluştur
        final fileName = 'qr_${i + 1}_${item.customName ?? item.type}.png'
            .replaceAll(' ', '_')
            .replaceAll(RegExp(r'[^\w\.]'), '');
        final file = File('${qrDir.path}/$fileName');
        await file.writeAsBytes(pngBytes);
        imagePaths.add(file.path);
      }

      // Tüm resimleri paylaş
      if (imagePaths.length == 1) {
        await ShareService.shareText(imagePaths.first);
      } else {
        // Birden fazla dosya için: Her birini ayrı ayrı share etmek yerine
        // ilk dosyayı share et ve kullanıcıya bilgi ver
        await ShareService.shareText(imagePaths.first);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${imagePaths.length} QR kod oluşturuldu. '
                'Dosyalar: ${qrDir.path}',
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _selectedIds.clear();
          _selectionMode = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedItems.length} QR kod resmi oluşturuldu'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşma hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportSelected() async {
    if (_selectedIds.isEmpty) return;

    // Format seçimi dialogu
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Formatı Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON'),
              subtitle: const Text('Standart veri formatı'),
              onTap: () => Navigator.pop(context, 'json'),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV'),
              subtitle: const Text('Excel uyumlu tablo'),
              onTap: () => Navigator.pop(context, 'csv'),
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

    if (format == null) return;

    try {
      // Seçilen itemları al
      final selectedItems = qrHistory
          .where((item) => _selectedIds.contains(item.id))
          .toList();

      String content;
      String fileName;
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];

      if (format == 'json') {
        // JSON export
        final jsonData = selectedItems.map((item) => item.toJson()).toList();
        content = const JsonEncoder.withIndent('  ').convert(jsonData);
        fileName = 'qr_export_$timestamp.json';
      } else {
        // CSV export
        content = 'ID,Type,Data,CustomName,Category,Date,Scanned,Archived\n';
        for (var item in selectedItems) {
          final row = [
            item.id,
            item.type,
            '"${item.data.replaceAll('"', '""')}"', // CSV escape
            item.customName ?? '',
            item.category ?? '',
            item.date.toIso8601String(),
            item.isScanned.toString(),
            item.isArchived.toString(),
          ].join(',');
          content += '$row\n';
        }
        fileName = 'qr_export_$timestamp.csv';
      }

      // Dosyayı Downloads klasörüne kaydet
      final directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception('Depolama erişimi başarısız');

      // Downloads klasörü yolunu bul
      final downloadsPath =
          directory.path
              .replaceFirst('/Android/data/', '/Download/')
              .split('/Android')[0] +
          '/Download';
      final downloadsDir = Directory(downloadsPath);
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsString(content);

      if (mounted) {
        setState(() {
          _selectedIds.clear();
          _selectionMode = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export başarılı: $fileName'),
            action: SnackBarAction(
              label: 'PAYLAŞ',
              onPressed: () => ShareService.shareText(file.path),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmBulkDelete() async {
    if (_selectedIds.isEmpty) return;
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final Set<String> idsToDelete = Set.from(_selectedIds);

      // Undo için silinen itemları sakla
      final deletedItems = qrHistory
          .where((qr) => idsToDelete.contains(qr.id))
          .toList();

      setState(() {
        qrHistory.removeWhere((qr) => idsToDelete.contains(qr.id));
        _selectedIds.clear();
        _selectionMode = false;
      });

      await Future.wait(
        idsToDelete.map((id) => HistoryService.deleteHistoryItem(id)),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Seçili QR kodlar silindi'),
            action: SnackBarAction(
              label: 'GERİ AL',
              onPressed: () async {
                // Undo: Silinen itemları geri ekle
                for (var item in deletedItems) {
                  await HistoryService.addToHistory(
                    data: item.data,
                    type: item.type,
                    isScanned: item.isScanned,
                    customName: item.customName,
                    category: item.category,
                  );
                }
                await _loadHistory();
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _deleteQR(HistoryItem qr) async {
    // Undo için item'ı sakla (kopyası)
    final deletedItem = qr;

    setState(() {
      qrHistory.removeWhere((item) => item.id == qr.id);
    });
    await HistoryService.deleteHistoryItem(qr.id);

    FeedbackService.scanErrorFeedback();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${qr.type} QR kodu silindi'),
          action: SnackBarAction(
            label: 'GERİ AL',
            onPressed: () async {
              // Undo: Silinen item'ı geri ekle
              await HistoryService.addToHistory(
                data: deletedItem.data,
                type: deletedItem.type,
                isScanned: deletedItem.isScanned,
                customName: deletedItem.customName,
                category: deletedItem.category,
              );
              await _loadHistory();
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tümünü Temizle'),
        content: const Text(
          'Tüm kayıtları silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
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
                  const SnackBar(content: Text('Tüm kayıtlar temizlendi')),
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRDetailScreen(item: qr)),
    ).then((_) => _loadHistory()); // Geri dönünce listeyi güncelle
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    if (_searchQuery.isNotEmpty) {
      // Arama sonucu boş
      title = 'Arama sonucu bulunamadı';
      subtitle = 'Farklı kelimeler deneyin';
      icon = Icons.search_off;
    } else if (_showArchived) {
      // Arşiv boş
      title = 'Arşivde QR kod yok';
      subtitle = 'Arşivlenen QR kodlar burada görünecek';
      icon = Icons.archive_outlined;
    } else {
      // Liste boş
      title = 'Henüz kayıtlı QR kod yok';
      subtitle = 'QR kod taramaya başlayın veya yeni QR kod oluşturun';
      icon = Icons.qr_code_2;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
