import '../widgets/banner_ad_widget.dart';
import '../services/premium_access_service.dart';
import '../config/ad_placements.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/history_item.dart';
import '../services/share_service.dart';
import '../l10n/app_localizations.dart';

import '../services/feedback_service.dart';
import '../services/price_comparison_service.dart';
import 'package:url_launcher/url_launcher.dart';

class QRDetailScreen extends StatefulWidget {
  final HistoryItem item;

  const QRDetailScreen({super.key, required this.item});

  @override
  State<QRDetailScreen> createState() => _QRDetailScreenState();
}

class _QRDetailScreenState extends State<QRDetailScreen> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _shareAsImage() async {
    final loc = AppLocalizations.of(context)!;
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.qrDetailImageShared)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.qrDetailShareError(e.toString())),
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
        title: Text(AppLocalizations.of(context)!.qrDetailSelectShareType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: Text(AppLocalizations.of(context)!.qrDetailShareTextTitle),
              subtitle: Text(
                AppLocalizations.of(context)!.qrDetailShareTextSubtitle,
              ),
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
              title: Text(
                AppLocalizations.of(context)!.qrDetailShareImageTitle,
              ),
              subtitle: Text(
                AppLocalizations.of(context)!.qrDetailShareImageSubtitle,
              ),
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
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ValueListenableBuilder<bool>(
      valueListenable: PremiumAccessService.premiumNotifier,
      builder: (context, isPremium, _) {
        final showAds = AdPolicy.shouldShowAds(isPremium: isPremium);
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.item.customName ?? loc.qrDetailTitle),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: loc.qrDetailCopyTooltip,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.item.data));
                  FeedbackService.buttonTapFeedback();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.qrDetailCopiedToClipboard)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: loc.qrDetailShareTooltip,
                onPressed: _showShareDialog,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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

                      // Eğer barkod ise fiyat karşılaştırma butonu
                      if (_isBarcode(widget.item.data))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.price_check),
                            label: Text(loc.qrDetailCheapestWhere),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () =>
                                _showPriceComparison(context, widget.item.data),
                          ),
                        ),

                      // Tip ve Kategori
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              loc.qrDetailType,
                              widget.item.type,
                              _getIconForType(widget.item.type),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              loc.qrDetailCategory,
                              widget.item.category ?? loc.qrDetailNoCategory,
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
                          loc.qrDetailName,
                          widget.item.customName!,
                          Icons.title,
                        ),
                      if (widget.item.customName != null)
                        const SizedBox(height: 16),

                      // Veri
                      _buildInfoCard(
                        context,
                        loc.qrDetailData,
                        widget.item.data,
                        Icons.data_object,
                        maxLines: null,
                      ),
                      const SizedBox(height: 16),

                      // Tarih
                      _buildInfoCard(
                        context,
                        loc.qrDetailDate,
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
                              loc.qrDetailStatus,
                              widget.item.isScanned
                                  ? loc.qrDetailScanned
                                  : loc.qrDetailCreated,
                              widget.item.isScanned
                                  ? Icons.qr_code_scanner
                                  : Icons.qr_code,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              loc.qrDetailArchive,
                              widget.item.isArchived
                                  ? loc.qrDetailYes
                                  : loc.qrDetailNo,
                              widget.item.isArchived
                                  ? Icons.archive
                                  : Icons.unarchive,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (showAds)
                const BannerAdWidget(
                  adUnitId: AdPlacements.bannerBottom,
                  height: 60,
                ),
            ],
          ),
        );
      },
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

  // Barkod tespit fonksiyonu (EAN/UPC için basit kontrol)
  bool _isBarcode(String data) {
    final barcodeRegExp = RegExp(r'^[0-9]{8,14} ?$');
    return barcodeRegExp.hasMatch(data);
  }

  // Fiyat karşılaştırma modalı
  void _showPriceComparison(BuildContext context, String barcode) async {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FutureBuilder<PriceComparisonResult>(
          future: PriceComparisonService.compareProductPrices(barcode),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !(snapshot.data?.success ?? false)) {
              return AlertDialog(
                title: Text(loc.qrDetailPriceComparison),
                content: Text(
                  snapshot.data?.error ?? loc.qrDetailPriceInfoUnavailable,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.qrDetailClose),
                  ),
                ],
              );
            }
            final result = snapshot.data!;
            var alertRefreshKey = 0;
            return StatefulBuilder(
              builder: (context, setModalState) => AlertDialog(
                title: Text(
                  result.productInfo?.name ?? loc.qrDetailPriceComparison,
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (result.productInfo?.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Image.network(
                              result.productInfo!.imageUrl!,
                              height: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        if (result.productInfo?.brand != null)
                          Text(loc.qrDetailBrand(result.productInfo!.brand)),
                        if (result.productInfo?.category != null)
                          Text(
                            loc.qrDetailCategoryLabel(
                              result.productInfo!.category,
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (result.lowestPrice != null)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.local_offer,
                              color: Colors.green,
                            ),
                            title: Text(result.lowestPrice!.sourceName),
                            subtitle: Text(
                              '₺${result.lowestPrice!.price.toStringAsFixed(2)}',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                final url = Uri.parse(
                                  result.lowestPrice!.productUrl,
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(loc.qrDetailBuy),
                            ),
                          ),
                        if (result.lowestPrice != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            loc.qrDetailPriceHistory30Days,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildPriceHistorySection(
                            barcode,
                            result.lowestPrice!.source,
                          ),
                          const SizedBox(height: 12),
                          _buildPriceAlertSection(
                            barcode: barcode,
                            productName: result.productInfo?.name,
                            priceInfo: result.lowestPrice!,
                            refreshKey: alertRefreshKey,
                            onChanged: () {
                              setModalState(() {
                                alertRefreshKey++;
                              });
                            },
                          ),
                        ],
                        if (result.prices.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Text(
                              loc.qrDetailOtherPrices,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ...result.prices
                            .skip(1)
                            .map(
                              (p) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.store),
                                title: Text(p.sourceName),
                                subtitle: Text(
                                  '₺${p.price.toStringAsFixed(2)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.open_in_new),
                                  onPressed: () async {
                                    final url = Uri.parse(p.productUrl);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.qrDetailClose),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceHistorySection(String barcode, PriceSource source) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: PriceComparisonService.getPriceHistory(barcode, source),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final history = snapshot.data ?? const [];
        if (history.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(AppLocalizations.of(context)!.qrDetailNoPriceHistory),
          );
        }

        final spots = <FlSpot>[];
        final prices = <double>[];
        for (var index = 0; index < history.length; index++) {
          final price = (history[index]['price'] as num).toDouble();
          spots.add(FlSpot(index.toDouble(), price));
          prices.add(price);
        }

        final minPrice = prices.reduce((a, b) => a < b ? a : b);
        final maxPrice = prices.reduce((a, b) => a > b ? a : b);
        final baseline = (maxPrice - minPrice).abs() < 1
            ? 1000.0
            : (maxPrice - minPrice) * 0.15;

        return Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildHistoryStatChip(
                    AppLocalizations.of(context)!.qrDetailMin,
                    _formatCurrency(minPrice),
                  ),
                  const SizedBox(width: 8),
                  _buildHistoryStatChip(
                    AppLocalizations.of(context)!.qrDetailMax,
                    _formatCurrency(maxPrice),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: minPrice - baseline,
                    maxY: maxPrice + baseline,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: ((maxPrice - minPrice) / 3).clamp(
                        1,
                        double.infinity,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 54,
                          getTitlesWidget: (value, meta) => Text(
                            _formatYAxisLabel(value),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 7,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= history.length) {
                              return const SizedBox.shrink();
                            }
                            final date = DateTime.parse(
                              history[index]['date'] as String,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.orange.shade700,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.orange.shade100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceAlertSection({
    required String barcode,
    required PriceInfo priceInfo,
    required int refreshKey,
    required VoidCallback onChanged,
    String? productName,
  }) {
    return FutureBuilder<Map<String, dynamic>?>(
      key: ValueKey('price-alert-$barcode-$refreshKey'),
      future: PriceComparisonService.getPriceAlertForBarcode(barcode),
      builder: (context, snapshot) {
        final alert = snapshot.data;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.qrDetailPriceAlert,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                alert == null
                    ? AppLocalizations.of(context)!.qrDetailSetTargetHint
                    : AppLocalizations.of(context)!.qrDetailTargetPriceLabel(
                        _formatCurrency(
                          (alert['targetPrice'] as num).toDouble(),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final created = await _showCreatePriceAlertDialog(
                        context,
                        barcode: barcode,
                        productName: productName,
                        currentPrice: priceInfo.price,
                        preferredSource: priceInfo.source,
                      );
                      if (created) {
                        onChanged();
                      }
                    },
                    icon: Icon(
                      alert == null ? Icons.notifications_active : Icons.edit,
                    ),
                    label: Text(
                      alert == null
                          ? AppLocalizations.of(context)!.qrDetailSetAlert
                          : AppLocalizations.of(context)!.qrDetailUpdateAlert,
                    ),
                  ),
                  if (alert != null)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final deleted =
                            await PriceComparisonService.deletePriceAlert(
                              alert['id'] as String,
                            );
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              deleted
                                  ? AppLocalizations.of(
                                      context,
                                    )!.qrDetailAlertDeleted
                                  : AppLocalizations.of(
                                      context,
                                    )!.qrDetailAlertDeleteFailed,
                            ),
                          ),
                        );
                        if (deleted) {
                          onChanged();
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(
                        AppLocalizations.of(context)!.priceAlertsDeleteButton,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showCreatePriceAlertDialog(
    BuildContext context, {
    required String barcode,
    required double currentPrice,
    required PriceSource preferredSource,
    String? productName,
  }) async {
    final controller = TextEditingController(
      text: currentPrice.toStringAsFixed(0),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.qrDetailSetPriceAlertTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productName ??
                  AppLocalizations.of(context)!.qrDetailEnterTargetPrice,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.qrDetailTargetPriceInput,
                prefixText: '₺ ',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              final parsedValue = double.tryParse(
                controller.text.trim().replaceAll(',', '.'),
              );
              if (parsedValue == null || parsedValue <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.qrDetailEnterValidPrice,
                    ),
                  ),
                );
                return;
              }

              final created = await PriceComparisonService.createPriceAlert(
                barcode,
                parsedValue,
                preferredSource,
                productName: productName,
                currentPrice: currentPrice,
              );

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    created
                        ? AppLocalizations.of(context)!.qrDetailAlertSaved
                        : AppLocalizations.of(context)!.qrDetailAlertSaveFailed,
                  ),
                ),
              );
              Navigator.pop(context, created);
            },
            child: Text(AppLocalizations.of(context)!.qrDetailSave),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Widget _buildHistoryStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatCurrency(double value) {
    return '₺${value.toStringAsFixed(0)}';
  }

  String _formatYAxisLabel(double value) {
    if (value >= 1000) {
      return '₺${(value / 1000).toStringAsFixed(0)}K';
    }
    return '₺${value.toStringAsFixed(0)}';
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
