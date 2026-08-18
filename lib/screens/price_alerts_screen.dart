import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/price_comparison_service.dart';
import '../services/feedback_service.dart';
import '../services/share_service.dart';
import '../l10n/app_localizations.dart';

enum AlertFilter { all, triggered, pending }

enum AlertSort { newest, closestToTarget, highestDifference }

enum AlertQuickAction { copyBarcode, copyProductName, share }

class PriceAlertsScreen extends StatefulWidget {
  final String? highlightedBarcode;

  const PriceAlertsScreen({super.key, this.highlightedBarcode});

  @override
  State<PriceAlertsScreen> createState() => _PriceAlertsScreenState();
}

class _PriceAlertsScreenState extends State<PriceAlertsScreen> {
  static const String _filterPrefKey = 'price_alerts_screen_filter_v1';
  static const String _sortPrefKey = 'price_alerts_screen_sort_v1';

  List<Map<String, dynamic>> _alerts = [];
  bool _loading = true;
  AlertFilter _selectedFilter = AlertFilter.all;
  AlertSort _selectedSort = AlertSort.newest;

  @override
  void initState() {
    super.initState();
    _restorePreferences().then((_) => _loadAlerts());
  }

  Future<void> _restorePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final rawFilter = prefs.getString(_filterPrefKey);
    final restoredFilter = AlertFilter.values.firstWhere(
      (filter) => filter.name == rawFilter,
      orElse: () => AlertFilter.all,
    );

    final rawSort = prefs.getString(_sortPrefKey);
    final restoredSort = AlertSort.values.firstWhere(
      (sort) => sort.name == rawSort,
      orElse: () => AlertSort.newest,
    );

    if (!mounted) return;
    setState(() {
      _selectedFilter = restoredFilter;
      _selectedSort = restoredSort;
    });
  }

  Future<void> _persistSelectedFilter(AlertFilter filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_filterPrefKey, filter.name);
  }

  Future<void> _persistSelectedSort(AlertSort sort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortPrefKey, sort.name);
  }

  Future<void> _loadAlerts() async {
    setState(() => _loading = true);
    final alerts = await PriceComparisonService.getActivePriceAlerts();
    if (mounted) {
      setState(() {
        _alerts = alerts;
        _loading = false;
      });
    }
  }

  Future<void> _deleteAlert(String alertId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.priceAlertsDeleteTitle),
        content: Text(AppLocalizations.of(ctx)!.priceAlertsDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx)!.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(ctx)!.priceAlertsDeleteButton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PriceComparisonService.deletePriceAlert(alertId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.priceAlertsDeletedMsg),
          ),
        );
        _loadAlerts();
      }
    }
  }

  Future<void> _copyBarcode(String barcode) async {
    final loc = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: barcode));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.priceAlertsBarcodecopied)));
  }

  Future<void> _copyProductName(String productName) async {
    final loc = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: productName));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.priceAlertsProductNameCopied)));
  }

  Future<void> _shareAlert({
    required String productName,
    required String barcode,
    required String sourceName,
    required dynamic targetPrice,
    required dynamic currentPrice,
  }) async {
    final loc = AppLocalizations.of(context)!;
    final message =
        '${loc.priceAlertsShareTitle}\n'
        '${loc.priceAlertsShareProduct(productName)}\n'
        '${loc.priceAlertsShareBarcode(barcode)}\n'
        '${loc.priceAlertsShareSource(sourceName)}\n'
        '${loc.priceAlertsShareTargetPrice(_formatPrice(targetPrice))}\n'
        '${loc.priceAlertsShareCurrentPrice(_formatPrice(currentPrice))}';
    await ShareService.shareText(message, subject: loc.priceAlertsShareSubject);
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '-';
    final p = (price as num).toDouble();
    return '₺${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return '-';
    }
  }

  bool _isPriceBelowTarget(Map<String, dynamic> alert) {
    final current = alert['currentPrice'];
    final target = alert['targetPrice'];
    if (current == null || target == null) return false;
    return (current as num).toDouble() <= (target as num).toDouble();
  }

  String _formatSourceName(String? rawSource) {
    if (rawSource == null || rawSource.isEmpty) {
      return AppLocalizations.of(context)!.priceAlertsAllSources;
    }

    switch (rawSource) {
      case 'trendyol':
        return 'Trendyol';
      case 'hepsiburada':
        return 'Hepsiburada';
      case 'n11':
        return 'N11';
      case 'amazon':
        return 'Amazon';
      case 'gittigidiyor':
        return 'GittiGidiyor';
      case 'sahibinden':
        return 'Sahibinden';
      case 'ciceksepeti':
        return 'Ciceksepeti';
      case 'morhipo':
        return 'Morhipo';
      default:
        return rawSource;
    }
  }

  List<Map<String, dynamic>> _getFilteredAlerts() {
    switch (_selectedFilter) {
      case AlertFilter.triggered:
        return _alerts.where(_isPriceBelowTarget).toList();
      case AlertFilter.pending:
        return _alerts.where((alert) => !_isPriceBelowTarget(alert)).toList();
      case AlertFilter.all:
        return _alerts;
    }
  }

  List<Map<String, dynamic>> _getSortedAlerts(
    List<Map<String, dynamic>> items,
  ) {
    final list = List<Map<String, dynamic>>.from(items);

    switch (_selectedSort) {
      case AlertSort.newest:
        list.sort(
          (a, b) => (b['createdAt'] as String? ?? '').compareTo(
            a['createdAt'] as String? ?? '',
          ),
        );
        break;
      case AlertSort.closestToTarget:
        list.sort((a, b) {
          final diffA = _priceDifferenceAbs(a);
          final diffB = _priceDifferenceAbs(b);
          return diffA.compareTo(diffB);
        });
        break;
      case AlertSort.highestDifference:
        list.sort((a, b) {
          final diffA = _priceDifferenceAbs(a);
          final diffB = _priceDifferenceAbs(b);
          return diffB.compareTo(diffA);
        });
        break;
    }

    return list;
  }

  double _priceDifferenceAbs(Map<String, dynamic> alert) {
    final current = alert['currentPrice'];
    final target = alert['targetPrice'];
    if (current == null || target == null) {
      return double.infinity;
    }

    final currentValue = (current as num).toDouble();
    final targetValue = (target as num).toDouble();
    return (currentValue - targetValue).abs();
  }

  String _sortLabel(AlertSort sort) {
    final loc = AppLocalizations.of(context)!;
    switch (sort) {
      case AlertSort.newest:
        return loc.priceAlertsSortNewest;
      case AlertSort.closestToTarget:
        return loc.priceAlertsSortClosest;
      case AlertSort.highestDifference:
        return loc.priceAlertsSortHighest;
    }
  }

  String _getFilterEmptyMessage() {
    final loc = AppLocalizations.of(context)!;
    switch (_selectedFilter) {
      case AlertFilter.triggered:
        return loc.priceAlertsEmptyTriggered;
      case AlertFilter.pending:
        return loc.priceAlertsEmptyPending;
      case AlertFilter.all:
        return loc.priceAlertsEmptyAll;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final totalCount = _alerts.length;
    final triggeredCount = _alerts.where(_isPriceBelowTarget).length;
    final pendingCount = totalCount - triggeredCount;
    final filteredAlerts = _getFilteredAlerts();
    final displayedAlerts = _getSortedAlerts(filteredAlerts);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.priceAlertsTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (!_loading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAlerts,
              tooltip: loc.priceAlertsRefreshTooltip,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryStrip(
                  colorScheme: colorScheme,
                  totalCount: totalCount,
                  triggeredCount: triggeredCount,
                  pendingCount: pendingCount,
                  loc: loc,
                ),
                _buildToolbarRow(),
                Expanded(
                  child: displayedAlerts.isEmpty
                      ? _buildEmptyState(
                          colorScheme,
                          message: _getFilterEmptyMessage(),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAlerts,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: displayedAlerts.length,
                            itemBuilder: (context, index) => _buildAlertCard(
                              displayedAlerts[index],
                              colorScheme,
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildToolbarRow() {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildFilterChip(
            label: loc.priceAlertsFilterAll,
            filter: AlertFilter.all,
          ),
          _buildFilterChip(
            label: loc.priceAlertsFilterTriggered,
            filter: AlertFilter.triggered,
          ),
          _buildFilterChip(
            label: loc.priceAlertsFilterPending,
            filter: AlertFilter.pending,
          ),
          PopupMenuButton<AlertSort>(
            onSelected: (sort) {
              setState(() {
                _selectedSort = sort;
              });
              _persistSelectedSort(sort);
            },
            itemBuilder: (context) => AlertSort.values
                .map(
                  (sort) => PopupMenuItem<AlertSort>(
                    value: sort,
                    child: Text(_sortLabel(sort)),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _sortLabel(_selectedSort),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required AlertFilter filter,
  }) {
    final selected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
        _persistSelectedFilter(filter);
      },
    );
  }

  Widget _buildSummaryStrip({
    required ColorScheme colorScheme,
    required int totalCount,
    required int triggeredCount,
    required int pendingCount,
    required AppLocalizations loc,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              label: loc.priceAlertsFilterTriggered,
              value: '$triggeredCount',
              color: Colors.green,
            ),
          ),
          Expanded(
            child: _buildMiniStat(
              label: loc.priceAlertsFilterPending,
              value: '$pendingCount',
              color: Colors.orange,
            ),
          ),
          Expanded(
            child: _buildMiniStat(
              label: loc.priceAlertsTotal,
              value: '$totalCount',
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.9),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, {required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.notifications_none,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.priceAlertsEmptyHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, ColorScheme colorScheme) {
    final loc = AppLocalizations.of(context)!;
    final isTriggered = _isPriceBelowTarget(alert);
    final productName =
        alert['productName'] as String? ??
        alert['barcode'] as String? ??
        loc.priceAlertsUnknownProduct;
    final barcode = alert['barcode'] as String? ?? '-';
    final sourceName = _formatSourceName(alert['preferredSource'] as String?);
    final targetPrice = alert['targetPrice'];
    final currentPrice = alert['currentPrice'];
    final isHighlighted = widget.highlightedBarcode == barcode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: isHighlighted
          ? colorScheme.primary.withValues(alpha: 0.06)
          : Theme.of(context).cardColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isHighlighted
              ? Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.45),
                  width: 1.5,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isTriggered
                          ? Colors.green.withValues(alpha: 0.15)
                          : colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isTriggered
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: isTriggered ? Colors.green : colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                productName,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isHighlighted) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  loc.priceAlertsNewBadge,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.priceAlertsCreatedAt(
                            _formatDate(alert['createdAt'] as String?),
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<AlertQuickAction>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: loc.priceAlertsQuickActions,
                    onSelected: (action) {
                      FeedbackService.buttonTapFeedback();
                      switch (action) {
                        case AlertQuickAction.copyBarcode:
                          _copyBarcode(barcode);
                          break;
                        case AlertQuickAction.copyProductName:
                          _copyProductName(productName);
                          break;
                        case AlertQuickAction.share:
                          _shareAlert(
                            productName: productName,
                            barcode: barcode,
                            sourceName: sourceName,
                            targetPrice: targetPrice,
                            currentPrice: currentPrice,
                          );
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: AlertQuickAction.copyBarcode,
                        child: Text(
                          AppLocalizations.of(ctx)!.priceAlertsCopyBarcodeItem,
                        ),
                      ),
                      PopupMenuItem(
                        value: AlertQuickAction.copyProductName,
                        child: Text(
                          AppLocalizations.of(
                            ctx,
                          )!.priceAlertsCopyProductNameItem,
                        ),
                      ),
                      PopupMenuItem(
                        value: AlertQuickAction.share,
                        child: Text(
                          AppLocalizations.of(ctx)!.priceAlertsShareAlertItem,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      FeedbackService.buttonTapFeedback();
                      _deleteAlert(alert['id'] as String);
                    },
                    tooltip: loc.priceAlertsDeleteTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      loc.priceAlertsSourceLabel(sourceName),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      loc.priceAlertsBarcodeLabel(barcode),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPriceChip(
                      label: loc.priceAlertsTargetPrice,
                      price: _formatPrice(targetPrice),
                      color: colorScheme.primary,
                      icon: Icons.flag_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriceChip(
                      label: loc.priceAlertsCurrentPrice,
                      price: _formatPrice(currentPrice),
                      color: isTriggered ? Colors.green : Colors.orange,
                      icon: isTriggered
                          ? Icons.trending_down
                          : Icons.trending_up,
                    ),
                  ),
                ],
              ),
              if (isTriggered) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        loc.priceAlertsPriceReached,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceChip({
    required String label,
    required String price,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
