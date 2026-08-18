import 'package:flutter/material.dart';
import 'package:qr_app/models/history_item.dart';
import 'package:qr_app/l10n/app_localizations.dart';
import '../services/feedback_service.dart';
import '../services/history_service.dart';
import '../services/favorites_service.dart';
import '../services/share_service.dart';

enum _SortOption { date, name, type }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Modern ve işlevsel geçmiş listesi
  Widget _buildHistoryListModern(
    BuildContext context,
    List<HistoryItem> items,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (items.isEmpty) {
      return _buildEmptyStateModern(context);
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 80),
      itemCount: items.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final item = items[idx];
        final selected = _selectedIds.contains(item.id);
        return GestureDetector(
          onLongPress: () {
            setState(() {
              _selectionMode = true;
              _selectedIds.add(item.id);
            });
          },
          onTap: () {
            if (_selectionMode) {
              setState(() {
                if (selected) {
                  _selectedIds.remove(item.id);
                  if (_selectedIds.isEmpty) _selectionMode = false;
                } else {
                  _selectedIds.add(item.id);
                }
              });
            } else {
              _showHistoryDetailDialog(context, item);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.18)
                  : colorScheme.surface.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.12),
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                if (!selected)
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              leading: Icon(
                _getIconForType(item.type),
                color: colorScheme.primary,
                size: 32,
              ),
              title: Text(
                item.customName?.isNotEmpty == true
                    ? item.customName!
                    : item.data,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${item.type} • ${_formatDate(item.date)}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: _selectionMode
                  ? Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outline,
                    )
                  : PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: colorScheme.outline),
                      onSelected: (value) async {
                        if (value == 'fav') {
                          await FavoritesService.addToFavorites(
                            data: item.data,
                            type: item.type,
                            customName: item.customName,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.historyAddedToFavorites),
                              ),
                            );
                          }
                        } else if (value == 'share') {
                          await _shareQR(item);
                        } else if (value == 'delete') {
                          await _deleteSingleItem(item);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'fav',
                          child: Text(l10n.historyAddToFavorites),
                        ),
                        PopupMenuItem(
                          value: 'share',
                          child: Text(l10n.historyShare),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.historyDelete),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  // QR türüne göre ikon
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'url':
        return Icons.link;
      case 'text':
        return Icons.text_snippet;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'location':
        return Icons.location_on;
      default:
        return Icons.qr_code;
    }
  }

  // Tarih formatı
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // Share a history item with the app's share options.
  Future<void> _shareQR(HistoryItem item) async {
    await ShareService.showQuickShareOptions(item.data, item.type, context);
  }

  // Tekli silme
  Future<void> _deleteSingleItem(HistoryItem item) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      qrHistory.removeWhere((qr) => qr.id == item.id);
    });
    await HistoryService.deleteHistoryItem(item.id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.historyRecordDeleted)));
    }
  }

  // Detay gösterimi (basit dialog)
  void _showHistoryDetailDialog(BuildContext context, HistoryItem item) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item.customName?.isNotEmpty == true ? item.customName! : item.data,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.historyTypeLabel(item.type), style: textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              l10n.historyDateLabel(_formatDate(item.date)),
              style: textTheme.bodyMedium,
            ),
            if (item.category != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.historyCategoryLabel(item.category!),
                style: textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            SelectableText(item.data, style: textTheme.bodyLarge),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonClose),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _shareQR(item);
            },
            child: Text(l10n.historyShare),
          ),
        ],
      ),
    );
  }

  // Boş geçmiş durumu için modern görünüm
  Widget _buildEmptyStateModern(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 64,
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.historyEmptyTitle,
            style: TextStyle(
              fontSize: 20,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.historyEmptySubtitle,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Filtreleme ve sıralama
    final filtered = qrHistory.where((item) {
      if (_selectedType != null && item.type != _selectedType) {
        return false;
      }
      if (_selectedTag != null && item.customName != _selectedTag) {
        return false;
      }
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      if (_selectedDateRange != null &&
          !_isInDateRange(item.date, _selectedDateRange!)) {
        return false;
      }
      return true;
    }).toList();
    _sortHistory(filtered);

    final bgColor = colorScheme.surface;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.historyTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${qrHistory.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded),
            tooltip: l10n.historyFilter,
            onPressed: () => _showFilterDialog(context),
          ),
          PopupMenuButton<_SortOption>(
            tooltip: l10n.historySort,
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortOption = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _SortOption.date,
                child: Text(l10n.historySortByDate),
              ),
              PopupMenuItem(
                value: _SortOption.name,
                child: Text(l10n.historySortByName),
              ),
              PopupMenuItem(
                value: _SortOption.type,
                child: Text(l10n.historySortByType),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: bgColor,
        child: Column(
          children: [
            if (_selectionMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: colorScheme.surface.withValues(alpha: 0.98),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectedIds.isEmpty
                                ? null
                                : _confirmBulkDelete,
                            icon: const Icon(Icons.delete, size: 18),
                            label: Text(l10n.historyDeleteSelected),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectedIds.isEmpty
                                ? null
                                : _addSelectedToFavorites,
                            icon: const Icon(Icons.favorite, size: 18),
                            label: Text(l10n.historyToFavorites),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyStateModern(context)
                  : _buildHistoryListModern(context, filtered),
            ),
          ],
        ),
      ),
      floatingActionButton: qrHistory.isNotEmpty && !_selectionMode
          ? FloatingActionButton.extended(
              onPressed: _showClearDialog,
              icon: const Icon(Icons.delete_sweep),
              label: Text(l10n.historyClearAll),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
    );
  }

  // State variables
  List<HistoryItem> qrHistory = [];
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;
  _SortOption _sortOption = _SortOption.date;
  final bool _sortAscending = false;
  DateTimeRange? _selectedDateRange;
  String? _selectedType;
  String? _selectedTag;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Core loading function
  Future<void> _loadHistory() async {
    final history = await HistoryService.getHistory();
    if (!mounted) return;
    setState(() {
      qrHistory = history;
    });
  }

  // Date range check
  bool _isInDateRange(DateTime date, DateTimeRange range) {
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
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  // Filtre dialogu
  Future<void> _showFilterDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
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
          title: Text(l10n.historyFilter),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: tempType,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.historyAll),
                  ),
                  ...types.map(
                    (t) => DropdownMenuItem<String?>(value: t, child: Text(t)),
                  ),
                ],
                onChanged: (v) => setStateSB(() => tempType = v),
                decoration: InputDecoration(labelText: l10n.historyType),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: tempTag,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.historyAll),
                  ),
                  ...tags.map(
                    (t) => DropdownMenuItem<String?>(value: t, child: Text(t)),
                  ),
                ],
                onChanged: (v) => setStateSB(() => tempTag = v),
                decoration: InputDecoration(labelText: l10n.historyTag),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: tempCategory,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.historyAll),
                  ),
                  ...categories.map(
                    (c) => DropdownMenuItem<String?>(value: c, child: Text(c)),
                  ),
                ],
                onChanged: (v) => setStateSB(() => tempCategory = v),
                decoration: InputDecoration(labelText: l10n.historyCategory),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tempRange == null
                          ? l10n.historyDateRangeNotSelected
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
                    child: Text(l10n.historySelectDate),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.historyCancel),
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
              child: Text(l10n.historyApply),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSelectedToFavorites() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedIds.isEmpty) return;

    int added = 0;
    int skipped = 0;

    for (final String id in _selectedIds) {
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
        // Skip entries that are already in favorites.
        skipped++;
      }
    }

    if (mounted) {
      setState(() {
        _selectedIds.clear();
        _selectionMode = false;
      });

      final message = skipped > 0
          ? l10n.historyAddedAndSkippedMessage(added, skipped)
          : l10n.historyAddedToFavoritesCount(added);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirmBulkDelete() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedIds.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.historyDeleteSelectedTitle),
        content: Text(l10n.historyDeleteSelectedConfirm(_selectedIds.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.historyCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.historyDelete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final Set<String> idsToDelete = Set.from(_selectedIds);

      // Keep deleted items for undo action.
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
            content: Text(l10n.historySelectedDeleted),
            action: SnackBarAction(
              label: l10n.historyUndo,
              onPressed: () async {
                // Restore deleted items.
                for (final item in deletedItems) {
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

  void _showClearDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.historyClearAllTitle),
        content: Text(l10n.historyClearAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.historyCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                qrHistory.clear();
              });
              await HistoryService.clearHistory();
              if (!dialogContext.mounted || !mounted) return;
              Navigator.pop(dialogContext);
              FeedbackService.scanErrorFeedback();
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.historyAllCleared)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              l10n.historyDelete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Unused method removed: _showStatsDialog

  // Unused method removed: _buildStatItem

  // Unused method removed: _calculateStats

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // History can be refreshed on route resume via RouteAware if needed.
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // routeObserver.subscribe(this, route);
    }
  }
}
