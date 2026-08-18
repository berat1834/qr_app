import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_app/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/ad_placements.dart';
import '../services/favorites_service.dart';
import '../services/feedback_service.dart';
import '../services/premium_access_service.dart';
import '../services/share_service.dart';
import '../services/qr_action_service.dart';
import '../utils/qr_helpers.dart';
import '../widgets/native_ad_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Çoklu seçim için
  bool selectionMode = false;
  Set<String> selectedIds = {};

  List<_TypeFilterOption> _typeFilterOptions(AppLocalizations l10n) => [
    _TypeFilterOption('', l10n.favoritesAll),
    _TypeFilterOption('URL', l10n.enhancedQrGenTypeUrl),
    _TypeFilterOption('WiFi', l10n.enhancedQrGenTypeWifi),
    _TypeFilterOption('Telefon', l10n.enhancedQrGenTypePhone),
    _TypeFilterOption('E-mail', l10n.enhancedQrGenTypeEmail),
    _TypeFilterOption('SMS', l10n.enhancedQrGenTypeSms),
    _TypeFilterOption('Konum', l10n.enhancedQrGenTypeLocation),
    _TypeFilterOption('Kartvizit', l10n.enhancedQrGenTypeVcard),
    _TypeFilterOption('Metin', l10n.enhancedQrGenTypeText),
  ];

  String _localizedTypeLabel(AppLocalizations l10n, String type) {
    for (final option in _typeFilterOptions(l10n)) {
      if (option.value == type) return option.label;
    }
    return type;
  }

  void _showEditNoteDialog(FavoriteItem item) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: item.note ?? '');
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.favoritesEditNoteTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.favoritesOptionalNoteLabel,
              border: const OutlineInputBorder(),
            ),
            maxLength: 200,
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.favoritesCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                await FavoritesService.updateFavoriteNote(
                  item.id,
                  controller.text,
                );
                if (!dialogContext.mounted || !mounted) return;
                Navigator.of(dialogContext).pop();
                _loadFavorites();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.favoritesNoteUpdated)),
                );
              },
              child: Text(l10n.commonSave),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
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
    final typeOptions = _typeFilterOptions(l10n);
    if (!typeOptions.any((option) => option.value == tempType)) {
      tempType = '';
    }
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          title: Text(l10n.favoritesAdvancedFilter),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: tempType,
                items: typeOptions
                    .map(
                      (type) => DropdownMenuItem(
                        value: type.value,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setStateSB(() => tempType = v ?? ''),
                decoration: InputDecoration(labelText: l10n.favoritesType),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: tempTag,
                items:
                    [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.favoritesAll),
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
                decoration: InputDecoration(labelText: l10n.favoritesTag),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tempRange == null
                          ? l10n.favoritesDateRangeNotSelected
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
                    child: Text(l10n.favoritesSelectDate),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.favoritesCancel),
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
              child: Text(l10n.favoritesApply),
            ),
          ],
        ),
      ),
    );
  }

  List<FavoriteItem> favorites = [];
  String searchQuery = '';
  String selectedFilter = '';
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

      final matchesType = selectedFilter.isEmpty || item.type == selectedFilter;
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
    final l10n = AppLocalizations.of(context)!;
    final filterOptions = _typeFilterOptions(l10n);
    final currentFilter =
        filterOptions.any((option) => option.value == selectedFilter)
        ? selectedFilter
        : '';
    final filtered = filteredFavorites;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        foregroundColor: colorScheme.onSurface,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          selectionMode
              ? l10n.favoritesSelectedCount(selectedIds.length)
              : l10n.homeActionFavorites,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        centerTitle: false,
        leading: selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    selectionMode = false;
                    selectedIds.clear();
                  });
                },
                tooltip: l10n.favoritesCancelSelection,
              )
            : null,
        actions: selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: l10n.favoritesDeleteSelectedTitle,
                  onPressed: selectedIds.isEmpty
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.favoritesDeleteSelectedTitle),
                              content: Text(
                                l10n.favoritesDeleteSelectedConfirm(
                                  selectedIds.length,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l10n.favoritesCancel),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text(l10n.favoritesDelete),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final toDelete = favorites
                                .where((f) => selectedIds.contains(f.id))
                                .toList();
                            for (final fav in toDelete) {
                              await FavoritesService.removeFromFavorites(
                                fav.id,
                              );
                            }
                            setState(() {
                              selectionMode = false;
                              selectedIds.clear();
                            });
                            _loadFavorites();
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.favoritesSelectedDeleted),
                                ),
                              );
                            }
                          }
                        },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  tooltip: l10n.favoritesAdvancedFilter,
                  onPressed: () async {
                    await _showFilterDialog(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: favorites.isEmpty ? null : _showClearDialog,
                  tooltip: l10n.favoritesClearAllTitle,
                ),
              ],
      ),
      body: Container(
        color: bgColor,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: colorScheme.surface.withValues(alpha: 0.97),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 22,
                  ),
                  child: Column(
                    children: [
                      // Arama Ã§ubuÄŸu
                      TextField(
                        decoration: InputDecoration(
                          hintText: l10n.favoritesSearchHint,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: colorScheme.surface.withValues(alpha: 0.8),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() => searchQuery = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => searchQuery = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: currentFilter,
                        decoration: InputDecoration(
                          labelText: l10n.favoritesTypeFilter,
                          filled: true,
                          fillColor: colorScheme.surface.withValues(alpha: 0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: filterOptions.map((type) {
                          return DropdownMenuItem(
                            value: type.value,
                            child: Text(type.label),
                          );
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
              ),
            ),
            // Liste
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: PremiumAccessService.premiumNotifier,
                builder: (context, isPremium, _) {
                  final showAds = AdPolicy.shouldShowAds(isPremium: isPremium);
                  return isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                      ? _buildEmptyState()
                      : _buildFavoritesList(filtered, showAds: showAds);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isNotEmpty ? Icons.search_off : Icons.bookmark_border,
            size: 72,
            color: isDark
                ? colorScheme.primary.withValues(alpha: 0.22)
                : colorScheme.primary.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 18),
          Text(
            searchQuery.isNotEmpty
                ? l10n.favoritesNoSearchResults
                : l10n.favoritesEmptyTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark
                  ? colorScheme.primary.withValues(alpha: 0.7)
                  : colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? l10n.favoritesTryDifferentKeywords
                : l10n.favoritesEmptySubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
    List<FavoriteItem> filtered, {
    required bool showAds,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    const adInsertInterval = AdPlacements.nativeInsertInterval;
    final adSlots = showAds
        ? AdPolicy.nativeInlineAdSlots(
            itemCount: filtered.length,
            isPremium: false,
          )
        : 0;

    int adIndexForSlot(int slot) => slot * adInsertInterval + (slot - 1);

    int adsBeforeIndex(int index) {
      var count = 0;
      for (var slot = 1; slot <= adSlots; slot++) {
        if (adIndexForSlot(slot) < index) count++;
      }
      return count;
    }

    final adIndexes = <int>{
      for (var slot = 1; slot <= adSlots; slot++) adIndexForSlot(slot),
    };

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: filtered.length + adSlots,
      itemBuilder: (context, index) {
        final isAdSlot = showAds && adIndexes.contains(index);

        if (isAdSlot) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: NativeAdWidget(
              adUnitId: AdPlacements.nativeInline,
              height: 110,
            ),
          );
        }

        final realIndex = showAds ? index - adsBeforeIndex(index) : index;
        if (realIndex >= filtered.length) return const SizedBox.shrink();
        final item = filtered[realIndex];
        final isSelected = selectedIds.contains(item.id);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: GestureDetector(
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
                  child: _buildFavoriteCard(item, realIndex),
                ),
                if (isSelected)
                  Positioned(
                    top: 14,
                    right: 18,
                    child: Material(
                      color: Colors.transparent,
                      child: Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteCard(FavoriteItem item, int index) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: isDark ? 2 : 5,
      margin: const EdgeInsets.only(bottom: 16, left: 2, right: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      shadowColor: isDark
          ? colorScheme.primary.withValues(alpha: 0.10)
          : colorScheme.shadow.withValues(alpha: 0.10),
      color: isDark
          ? colorScheme.surface.withValues(alpha: 0.85)
          : colorScheme.surface.withValues(alpha: 0.98),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getColorForType(item.type).withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIconForType(item.type),
              color: _getColorForType(item.type),
              size: 22,
            ),
          ),
          title: Text(
            item.displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.primary,
            ),
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
                      size: 15,
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
                const SizedBox(height: 3),
              ],
              if (item.note != null && item.note!.trim().isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.sticky_note_2_outlined,
                      size: 14,
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
                _localizedTypeLabel(l10n, item.type),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                QRCodeUtils.truncateQRData(item.data, maxLength: 40),
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                _formatDate(item.addedAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, item, index),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'use',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.launch, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.favoritesUse),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'qr',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.favoritesShowQr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.favoritesRename),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit_note',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sticky_note_2_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.favoritesEditNote),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.copy, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.favoritesCopy),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.favoritesShare),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.delete, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      l10n.favoritesDelete,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _showDetailDialog(item),
        ),
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
    final l10n = AppLocalizations.of(context)!;
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
              _buildInfoRow(
                l10n.favoritesType,
                _localizedTypeLabel(l10n, item.type),
              ),
              _buildInfoRow(l10n.favoritesAddedAt, _formatDate(item.addedAt)),
              const SizedBox(height: 16),
              Text(
                l10n.favoritesContentLabel,
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonClose),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                QRActionService.performAction(context, item.data, item.type);
              },
              icon: const Icon(Icons.launch),
              label: Text(l10n.favoritesUse),
            ),
          ],
        );
      },
    );
  }

  void _showQRDialog(FavoriteItem item) {
    final l10n = AppLocalizations.of(context)!;
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
                _localizedTypeLabel(l10n, item.type),
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
              child: Text(l10n.commonClose),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _shareItem(item);
              },
              icon: const Icon(Icons.share),
              label: Text(l10n.favoritesShare),
            ),
          ],
        );
      },
    );
  }

  void _showEditNameDialog(FavoriteItem item) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: item.customName ?? '');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.favoritesEditNameTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.favoritesOptionalCustomNameLabel,
              border: const OutlineInputBorder(),
            ),
            maxLength: 50,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.favoritesCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                await FavoritesService.updateFavoriteName(
                  item.id,
                  controller.text,
                );
                if (!dialogContext.mounted || !mounted) return;
                Navigator.of(dialogContext).pop();
                _loadFavorites();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.favoritesNameUpdated)),
                );
              },
              child: Text(l10n.commonSave),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String data) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: data));
    FeedbackService.buttonTapFeedback();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.favoritesCopiedToClipboard)));
  }

  void _shareItem(FavoriteItem item) {
    ShareService.showQuickShareOptions(item.data, item.type, context);
  }

  void _deleteItem(FavoriteItem item) async {
    final l10n = AppLocalizations.of(context)!;
    await FavoritesService.removeFromFavorites(item.id);
    if (!mounted) return;
    _loadFavorites();
    FeedbackService.scanErrorFeedback();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.favoritesRemovedMessage(item.displayName)),
        action: SnackBarAction(
          label: l10n.favoritesUndo,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.favoritesClearAllTitle),
        content: Text(l10n.favoritesClearAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.favoritesCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await FavoritesService.clearFavorites();
              if (!dialogContext.mounted || !mounted) return;
              Navigator.pop(dialogContext);
              _loadFavorites();
              FeedbackService.scanErrorFeedback();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.favoritesAllCleared)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              l10n.favoritesDelete,
              style: const TextStyle(color: Colors.white),
            ),
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
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.favoritesTodayAt(
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
      );
    } else if (difference.inDays == 1) {
      return l10n.favoritesYesterdayAt(
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
      );
    } else if (difference.inDays < 7) {
      return l10n.favoritesDaysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _TypeFilterOption {
  final String value;
  final String label;

  const _TypeFilterOption(this.value, this.label);
}
