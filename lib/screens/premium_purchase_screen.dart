import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../l10n/app_localizations.dart';
import '../services/premium_access_service.dart';
import '../services/premium_purchase_service.dart';

class PremiumPurchaseScreen extends StatefulWidget {
  const PremiumPurchaseScreen({super.key});

  @override
  State<PremiumPurchaseScreen> createState() => _PremiumPurchaseScreenState();
}

class _PremiumPurchaseScreenState extends State<PremiumPurchaseScreen> {
  bool _isPurchasing = false;
  bool _isRestoring = false;
  bool _isPremium = false;

  static const List<_FeatureItem> _features = [
    _FeatureItem(Icons.block, 'premiumFeatureAdFree'),
    _FeatureItem(Icons.qr_code_2, 'premiumFeatureUnlimitedHistory'),
    _FeatureItem(Icons.palette, 'premiumFeatureCustomStyles'),
    _FeatureItem(Icons.cloud_upload, 'premiumFeatureCloudBackup'),
    _FeatureItem(Icons.batch_prediction, 'premiumFeatureBatchScan'),
    _FeatureItem(Icons.analytics, 'premiumFeatureAdvancedAnalytics'),
  ];

  @override
  void initState() {
    super.initState();
    _loadPremiumState();
    PremiumAccessService.premiumNotifier.addListener(_onPremiumChanged);
  }

  @override
  void dispose() {
    PremiumAccessService.premiumNotifier.removeListener(_onPremiumChanged);
    super.dispose();
  }

  void _onPremiumChanged() {
    if (mounted) {
      setState(() {
        _isPremium = PremiumAccessService.premiumNotifier.value;
      });
      if (_isPremium) {
        _showSuccessDialog();
      }
    }
  }

  Future<void> _loadPremiumState() async {
    final premium = await PremiumAccessService.isPremium();
    if (mounted) setState(() => _isPremium = premium);
  }

  Future<void> _purchase() async {
    setState(() => _isPurchasing = true);
    try {
      await PremiumAccessService.purchasePremium();
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isRestoring = true);
    try {
      await PremiumAccessService.restorePurchases();
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      final premium = await PremiumAccessService.isPremium();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            premium
                ? loc.premiumPurchaseRestoreSuccess
                : loc.premiumPurchaseRestoreNotFound,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  void _showSuccessDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text(loc.premiumPurchaseSuccessTitle),
          ],
        ),
        content: Text(loc.premiumPurchaseSuccessBody),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(loc.premiumPurchaseSuccessAction),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final products = PremiumPurchaseService.products;
    final storeAvailable = PremiumAccessService.isStoreAvailable();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorScheme.onSurface,
        title: Text(loc.premiumPurchaseTitle),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(
                    _isPremium ? Icons.verified : Icons.star_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isPremium
                        ? loc.premiumPurchaseHeadingActive
                        : loc.premiumPurchaseHeadingInactive,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_isPremium) ...[
                    const SizedBox(height: 6),
                    Text(
                      loc.premiumPurchaseUnlockSubtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Features list
            Text(
              loc.premiumPurchaseFeaturesHeading,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._features.map(
              (f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(f.icon, size: 20, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      _featureLabel(loc, f.labelKey),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Product offers
            if (!_isPremium && storeAvailable && products.isNotEmpty) ...[
              Text(
                loc.premiumPurchaseOptionsHeading,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...products.map((p) => _ProductCard(product: p)),
              const SizedBox(height: 20),
            ],

            // Purchase / Active button
            if (_isPremium)
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle),
                label: Text(loc.premiumPurchaseHeadingActive),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            else if (!storeAvailable)
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.store_mall_directory),
                label: Text(loc.premiumPurchaseStoreUnavailable),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            else
              FilledButton.icon(
                onPressed: _isPurchasing ? null : _purchase,
                icon: _isPurchasing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.star),
                label: Text(
                  _isPurchasing
                      ? loc.premiumPurchaseProcessing
                      : loc.premiumPurchaseBuyButton,
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Restore button
            if (!_isPremium)
              TextButton(
                onPressed: _isRestoring ? null : _restore,
                child: _isRestoring
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(loc.premiumPurchaseRestoreButton),
              ),

            const SizedBox(height: 12),
            Text(
              loc.premiumPurchaseLegalNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _featureLabel(AppLocalizations loc, String key) {
    switch (key) {
      case 'premiumFeatureAdFree':
        return loc.premiumFeatureAdFree;
      case 'premiumFeatureUnlimitedHistory':
        return loc.premiumFeatureUnlimitedHistory;
      case 'premiumFeatureCustomStyles':
        return loc.premiumFeatureCustomStyles;
      case 'premiumFeatureCloudBackup':
        return loc.premiumFeatureCloudBackup;
      case 'premiumFeatureBatchScan':
        return loc.premiumFeatureBatchScan;
      case 'premiumFeatureAdvancedAnalytics':
        return loc.premiumFeatureAdvancedAnalytics;
      default:
        return key;
    }
  }
}

class _FeatureItem {
  final IconData icon;
  final String labelKey;
  const _FeatureItem(this.icon, this.labelKey);
}

class _ProductCard extends StatelessWidget {
  final ProductDetails product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (product.description.isNotEmpty)
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            product.price,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
