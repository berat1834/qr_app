import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/favorites_service.dart';
import '../services/feedback_service.dart';
import '../services/share_service.dart';
import '../services/qr_action_service.dart';
import '../utils/qr_helpers.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Çoklu seçim için
  bool selectionMode = false;
  Set<String> selectedIds = {};
  void _showEditNoteDialog(FavoriteItem item) {
    final controller = TextEditingController(text: item.note ?? '');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Favori Notunu Düzenle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Not (boş bırakılabilir)',
              border: OutlineInputBorder(),
            ),
            maxLength: 200,
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FavoritesService.updateFavoriteNote(
                  item.id,
                  controller.text,
                );
                Navigator.of(context).pop();
                _loadFavorites();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Favori notu güncellendi')),
                );
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    final tags = <String>{}
      ..addAll(
        favorites
            .where(
              (e) => e.customName != null && e.customName!.trim().isNotEmpty,
            )
            .map((e) => e.customName!.trim()),
      )
      ..addAll(
        favorites
            .where((e) => e.note != null && e.note!.trim().isNotEmpty)
            .map((e) => e.note!.trim()),
      );
    final tagList = tags.toList();
    DateTimeRange? tempRange = selectedDateRange;
    String? tempTag = selectedTag;
    String tempType = selectedFilter;
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          title: const Text('Gelişmiş Filtrele'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: tempType,
                items:
                    [
                          'Tümü',
                          'URL',
                          'WiFi',
                          'Telefon',
                          'E-mail',
                          'SMS',
                          'Konum',
                          'Kartvizit',
                          'Metin',
                        ]
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged: (v) => setStateSB(() => tempType = v ?? 'Tümü'),
                decoration: const InputDecoration(labelText: 'Tür'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: tempTag,
                items:
                    [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tümü'),
                      ),
                    ] +
                    tagList
                        .map(
                          (t) => DropdownMenuItem<String?>(
                            value: t,
                            child: Text(t),
                          ),
                        )
                        .toList(),
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
                  selectedFilter = tempType;
                  selectedTag = tempTag;
                  selectedDateRange = tempRange;
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

  List<FavoriteItem> favorites = [];
  String searchQuery = '';
  String selectedFilter = 'Tümü';
  String? selectedTag;
  DateTimeRange? selectedDateRange;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);
    favorites = await FavoritesService.getFavorites();
    setState(() => isLoading = false);
  }

  List<FavoriteItem> get filteredFavorites {
    return favorites.where((item) {
      final query = searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          item.data.toLowerCase().contains(query) ||
          item.type.toLowerCase().contains(query) ||
          (item.customName?.toLowerCase().contains(query) ?? false) ||
          (item.note?.toLowerCase().contains(query) ?? false);

      final matchesType =
          selectedFilter == 'Tümü' || item.type == selectedFilter;
      final matchesTag =
          selectedTag == null ||
          (item.customName?.contains(selectedTag!) ?? false) ||
          (item.note?.contains(selectedTag!) ?? false);
      final matchesDate =
          selectedDateRange == null ||
          (item.addedAt.isAfter(selectedDateRange!.start) ||
                  item.addedAt.isAtSameMomentAs(selectedDateRange!.start)) &&
              (item.addedAt.isBefore(selectedDateRange!.end) ||
                  item.addedAt.isAtSameMomentAs(selectedDateRange!.end));

      return matchesSearch && matchesType && matchesTag && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredFavorites;

    return Scaffold(
      appBar: AppBar(
        title: selectionMode
            ? Text('${selectedIds.length} seçili')
            : const Text('Favoriler'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    selectionMode = false;
                    selectedIds.clear();
                  });
                },
                tooltip: 'Seçimi İptal Et',
              )
            : null,
        actions: [
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Seçili Favorileri Sil',
              onPressed: selectedIds.isEmpty
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Seçili Favorileri Sil'),
                          content: Text(
                            '${selectedIds.length} favoriyi silmek istediğinize emin misiniz?',
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
                        final toDelete = favorites
                            .where((f) => selectedIds.contains(f.id))
                            .toList();
                        for (final fav in toDelete) {
                          await FavoritesService.removeFromFavorites(fav.id);
                        }
                        setState(() {
                          selectionMode = false;
                          selectedIds.clear();
                        });
                        _loadFavorites();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Seçili favoriler silindi')),
                          );
                        }
                      }
                    },
            ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Gelişmiş Filtre',
            onPressed: () async {
              await _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: favorites.isEmpty ? null : _showClearDialog,
            tooltip: 'Tümünü Temizle',
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama ve Filtre
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Arama çubuğu
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Favorilerde ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
                // Filtre dropdown (kısa yol)
                DropdownButtonFormField<String>(
                  initialValue: selectedFilter,
                  decoration: InputDecoration(
                    labelText: 'Tür Filtresi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items:
                      [
                        'Tümü',
                        'URL',
                        'WiFi',
                        'Telefon',
                        'E-mail',
                        'SMS',
                        'Konum',
                        'Kartvizit',
                        'Metin',
                      ].map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedFilter = value);
                    }
                  },
                ),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(filtered),
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
          Icon(
            searchQuery.isNotEmpty ? Icons.search_off : Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty
                ? 'Arama sonucu bulunamadı'
                : 'Henüz favori yok',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'Farklı kelimeler deneyin'
                : 'QR kodları tarayıp favorilere ekleyebilirsiniz',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<FavoriteItem> filtered) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final isSelected = selectedIds.contains(item.id);
        return GestureDetector(
          onLongPress: () {
            setState(() {
              selectionMode = true;
              selectedIds.add(item.id);
            });
          },
          onTap: () {
            if (selectionMode) {
              setState(() {
                if (isSelected) {
                  selectedIds.remove(item.id);
                  if (selectedIds.isEmpty) selectionMode = false;
                } else {
                  selectedIds.add(item.id);
                }
              });
            } else {
              _showDetailDialog(item);
            }
          },
          child: Stack(
            children: [
              Opacity(
                opacity: isSelected ? 0.5 : 1.0,
                child: _buildFavoriteCard(item, index),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.check_circle, color: Colors.blue, size: 28),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteCard(FavoriteItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getColorForType(item.type),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconForType(item.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          item.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.customName != null &&
                item.customName!.trim().isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.label_important_outline,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item.customName!,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (item.note != null && item.note!.trim().isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 15,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item.note!,
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
            ],
            Text(
              item.type,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              QRCodeUtils.truncateQRData(item.data, maxLength: 40),
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(item.addedAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, item, index),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'use',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.launch, size: 18),
                  SizedBox(width: 8),
                  Text('Kullan'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'qr',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code, size: 18),
                  SizedBox(width: 8),
                  Text('QR Göster'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Adını Değiştir'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit_note',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sticky_note_2_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Notu Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'copy',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy, size: 18),
                  SizedBox(width: 8),
                  Text('Kopyala'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, size: 18),
                  SizedBox(width: 8),
                  Text('Paylaş'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showDetailDialog(item),
      ),
    );
  }

  void _handleMenuAction(String action, FavoriteItem item, int index) {
    switch (action) {
      case 'use':
        QRActionService.performAction(context, item.data, item.type);
        break;
      case 'qr':
        _showQRDialog(item);
        break;
      case 'edit':
        _showEditNameDialog(item);
        break;
      case 'edit_note':
        _showEditNoteDialog(item);
        break;
      case 'copy':
        _copyToClipboard(item.data);
        break;
      case 'share':
        _shareItem(item);
        break;
      case 'delete':
        _deleteItem(item);
        break;
    }
  }

  void _showDetailDialog(FavoriteItem item) {
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
              Expanded(child: Text(item.displayName)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Tür', item.type),
              _buildInfoRow('Eklenme', _formatDate(item.addedAt)),
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
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                QRActionService.performAction(context, item.data, item.type);
              },
              icon: const Icon(Icons.launch),
              label: const Text('Kullan'),
            ),
          ],
        );
      },
    );
  }

  void _showQRDialog(FavoriteItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.displayName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: QrImageView(
                  data: item.data,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.type,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _shareItem(item);
              },
              icon: const Icon(Icons.share),
              label: const Text('Paylaş'),
            ),
          ],
        );
      },
    );
  }

  void _showEditNameDialog(FavoriteItem item) {
    final controller = TextEditingController(text: item.customName ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Favori Adını Değiştir'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Özel ad (boş bırakılabilir)',
              border: OutlineInputBorder(),
            ),
            maxLength: 50,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FavoritesService.updateFavoriteName(
                  item.id,
                  controller.text,
                );
                Navigator.of(context).pop();
                _loadFavorites();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Favori adı güncellendi')),
                );
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    FeedbackService.buttonTapFeedback();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Panoya kopyalandı')));
  }

  void _shareItem(FavoriteItem item) {
    ShareService.showQuickShareOptions(item.data, item.type, context);
  }

  void _deleteItem(FavoriteItem item) async {
    await FavoritesService.removeFromFavorites(item.id);
    _loadFavorites();
    FeedbackService.scanErrorFeedback();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.displayName} favorilerden silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () async {
            await FavoritesService.addToFavorites(
              data: item.data,
              type: item.type,
              customName: item.customName,
            );
            _loadFavorites();
          },
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Favorileri Temizle'),
        content: const Text(
          'Tüm favorileri silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FavoritesService.clearFavorites();
              Navigator.pop(context);
              _loadFavorites();
              FeedbackService.scanErrorFeedback();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm favoriler temizlendi')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Dün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
