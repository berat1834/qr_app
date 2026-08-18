import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/price_comparison_service.dart';
import '../services/feedback_service.dart';
import '../services/share_service.dart';

class PriceAlertDetailScreen extends StatefulWidget {
  final String alertId;

  const PriceAlertDetailScreen({super.key, required this.alertId});

  @override
  State<PriceAlertDetailScreen> createState() => _PriceAlertDetailScreenState();
}

class _PriceAlertDetailScreenState extends State<PriceAlertDetailScreen> {
  Map<String, dynamic>? _alert;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlert();
  }

  Future<void> _loadAlert() async {
    try {
      final alerts = await PriceComparisonService.getActivePriceAlerts();
      final alert = alerts.firstWhere(
        (a) => a['id'] == widget.alertId,
        orElse: () => <String, dynamic>{},
      );

      if (!mounted) return;
      setState(() {
        _alert = alert.isNotEmpty ? alert : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _alert = null;
        _loading = false;
      });
    }
  }

  Future<void> _deleteAlert() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dlgLoc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dlgLoc.priceAlertDetailDeleteTitle),
          content: Text(dlgLoc.priceAlertDetailDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(dlgLoc.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(dlgLoc.priceAlertDetailDeleteButton),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      FeedbackService.buttonTapFeedback();
      await PriceComparisonService.deletePriceAlert(widget.alertId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _copyBarcode(String barcode) async {
    await Clipboard.setData(ClipboardData(text: barcode));
    FeedbackService.buttonTapFeedback();
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.priceAlertDetailBarcodeCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareAlert() async {
    if (_alert == null) return;

    final productName = _alert!['productName'] as String?;
    final barcode = _alert!['barcode'] as String?;
    final currentPrice = (_alert!['currentPrice'] as num?)?.toDouble();
    final targetPrice = (_alert!['targetPrice'] as num?)?.toDouble();

    final loc = AppLocalizations.of(context)!;
    // Template seçim dialog'u
    final selected = await showDialog<PriceAlertShareTemplate>(
      context: context,
      builder: (ctx) {
        final dlgLoc = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(dlgLoc.priceAlertDetailShareFormat),
          content: Text(dlgLoc.priceAlertDetailShareFormatQuestion),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, PriceAlertShareTemplate.compact),
              child: Text(dlgLoc.priceAlertDetailShareCompact),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(ctx, PriceAlertShareTemplate.detailed),
              child: Text(dlgLoc.priceAlertDetailShareDetailed),
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    await ShareService.sharePriceAlert(
      productName: productName ?? loc.priceAlertDetailUnknownProduct,
      barcode: barcode ?? '',
      currentPrice: currentPrice,
      targetPrice: targetPrice,
      template: selected,
    );

    FeedbackService.buttonTapFeedback();
  }

  String _formatSourceName(String source) {
    const sourceMap = {
      'trendyol': 'Trendyol',
      'hepsiburada': 'Hepsiburada',
      'n11': 'N11',
      'amazon': 'Amazon',
      'ciceksepeti': 'Çiçek Sepeti',
      'gittigidiyor': 'GittiGidiyor',
    };
    return sourceMap[source] ?? source;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.priceAlertDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_alert == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.priceAlertDetailTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                loc.priceAlertDetailNotFound,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.priceAlertDetailBack),
              ),
            ],
          ),
        ),
      );
    }

    final productName =
        _alert!['productName'] as String? ?? loc.priceAlertDetailUnknownProduct;
    final barcode = _alert!['barcode'] as String? ?? '';
    final source =
        _alert!['source'] as String? ?? loc.priceAlertDetailUnknownSource;
    final currentPrice = _alert!['currentPrice'] as num?;
    final targetPrice = _alert!['targetPrice'] as num?;
    final createdAt = _alert!['createdAt'] as String?;

    final isTriggered =
        currentPrice != null &&
        targetPrice != null &&
        currentPrice.toDouble() <= targetPrice.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.priceAlertDetailTitle),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Triggered Badge
            if (isTriggered)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.priceAlertDetailTriggered,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Ürün Adı
            Text(
              loc.priceAlertDetailProductName,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Fiyat Bilgileri
            Row(
              children: [
                Expanded(
                  child: _buildPriceCard(
                    title: loc.priceAlertDetailTargetPrice,
                    price: targetPrice,
                    icon: Icons.flag,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPriceCard(
                    title: loc.priceAlertDetailCurrentPrice,
                    price: currentPrice,
                    icon: Icons.trending_down,
                    color: isTriggered ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Kaynak ve Barkod
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.priceAlertDetailSource,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatSourceName(source),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _copyBarcode(barcode),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.priceAlertDetailBarcode,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            barcode,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.priceAlertDetailTapToCopy,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Oluşturulma Tarihi
            if (createdAt != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.priceAlertDetailCreatedAt(createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // İşlem Butonları
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _shareAlert,
                    icon: const Icon(Icons.share),
                    label: Text(loc.priceAlertDetailShare),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: () => _copyBarcode(barcode),
                  child: const Icon(Icons.content_copy),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Sil Butonu
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _deleteAlert,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error.withValues(alpha: 0.9),
                ),
                child: Text(loc.priceAlertDetailDeleteTitle),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard({
    required String title,
    required num? price,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${price?.toString() ?? '-'} ₺',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
