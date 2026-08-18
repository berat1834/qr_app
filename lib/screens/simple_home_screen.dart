import 'dart:async';

import '../config/ad_placements.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/premium_access_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/enhanced_theme_provider.dart';
import '../services/history_service.dart';
import '../services/feedback_service.dart';
import '../services/analytics_service.dart';
import '../services/price_comparison_service.dart';
import '../services/price_notification_service.dart';
import 'enhanced_qr_scanner_screen.dart';
import 'enhanced_qr_generator_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'theme_settings_screen.dart';
import 'favorites_screen.dart';
import 'batch_scanner_screen.dart';
import 'advanced_barcode_scanner.dart';
import 'custom_qr_generator_screen.dart';
import 'analytics_screen.dart';
import 'price_alerts_screen.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen>
    with WidgetsBindingObserver {
  int scannedCount = 0;
  int createdCount = 0;
  int triggeredAlertCount = 0;
  int totalAlertCount = 0;
  late final PriceNotificationService _notificationService;
  Timer? _notificationCheckTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadPriceAlertStats();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
  }

  @override
  void dispose() {
    _notificationCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStats();
      _loadPriceAlertStats();
      // Uygulama öne geldiğinde reset et (böylece kullanıcı döndüğünde yeni bildirimleri görebilir)
      _notificationService.resetNotifiedAlerts();
      // Hemen kontrol et
      _notificationService.checkTriggeredAlerts();
    }
  }

  Future<void> _loadStats() async {
    final history = await HistoryService.getHistory();
    if (!mounted) return;
    setState(() {
      scannedCount = history.where((item) => item.isScanned == true).length;
      createdCount = history.where((item) => item.isScanned == false).length;
    });
  }

  Future<void> _loadPriceAlertStats() async {
    final alerts = await PriceComparisonService.getActivePriceAlerts();
    final totalCount = alerts.length;
    final triggeredCount = alerts.where((alert) {
      final current = alert['currentPrice'];
      final target = alert['targetPrice'];
      if (current == null || target == null) {
        return false;
      }
      return (current as num).toDouble() <= (target as num).toDouble();
    }).length;

    if (!mounted) return;
    setState(() {
      triggeredAlertCount = triggeredCount;
      totalAlertCount = totalCount;
    });
  }

  /// Push notifications'ı initialize et
  Future<void> _initializeNotifications() async {
    try {
      _notificationService = PriceNotificationService();
      await _notificationService.initialize();

      // Hemen kontrol et
      await _notificationService.checkTriggeredAlerts();

      // Periyodik olarak kontrol için Timer kurup bildirim gönder
      _notificationCheckTimer?.cancel();
      _notificationCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (mounted) {
          _notificationService.checkTriggeredAlerts();
        }
      });
    } catch (e) {
      debugPrint('[SimpleHomeScreen] Notification initialize hatası: $e');
    }
  }

  Future<void> _sendPriceAlertTestNotification() async {
    final sent = await _notificationService.sendManualTestNotification();
    if (!mounted) return;

    final loc = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent ? loc.homePriceAlertTestSent : loc.homePriceAlertNeedAlertFirst,
        ),
      ),
    );
  }

  /// Merkezi event loglama fonksiyonu
  Future<void> _logHomeActionEvent({
    required String action,
    required String buttonTitle,
    required BuildContext context,
  }) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final theme = themeProvider.isDarkMode ? 'dark' : 'light';
    final now = DateTime.now().toIso8601String();
    await AnalyticsService.logCustomEvent(
      name: 'action_$action',
      parameters: {
        'button_title': buttonTitle,
        'theme': theme,
        'timestamp': now,
        'screen': 'SimpleHomeScreen',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return ValueListenableBuilder<bool>(
      valueListenable: PremiumAccessService.premiumNotifier,
      builder: (context, isPremium, _) {
        final showAds = AdPolicy.shouldShowAds(isPremium: isPremium);
        return Scaffold(
          appBar: AppBar(
            foregroundColor: colorScheme.onSurface,
            title: Text(
              loc.appTitle,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_active_outlined),
                onPressed: () {
                  FeedbackService.buttonTapFeedback();
                  _sendPriceAlertTestNotification();
                },
                tooltip: loc.homePriceAlertTestTooltip,
              ),
              IconButton(
                icon: const Icon(Icons.palette),
                onPressed: () {
                  FeedbackService.buttonTapFeedback();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeSettingsScreen(),
                    ),
                  );
                },
                tooltip: loc.themeSettings,
              ),
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  FeedbackService.buttonTapFeedback();
                  themeProvider.toggleTheme();
                },
                tooltip: themeProvider.isDarkMode
                    ? loc.homeLightMode
                    : loc.homeDarkMode,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildHeaderCard(context, colorScheme),
                        const SizedBox(height: 24),
                        _buildStatsCard(context, colorScheme, themeProvider),
                        const SizedBox(height: 24),
                        _buildFeaturesGrid(context, colorScheme, isPremium),
                        const SizedBox(height: 24),
                      ],
                    ),
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

  Widget _buildHeaderCard(BuildContext context, ColorScheme colorScheme) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.15),
            colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.qr_code, size: 40, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            loc.appTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            loc.homeScanCreateDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeProvider themeProvider,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                FeedbackService.buttonTapFeedback();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
              child: _buildQuickStat(
                context,
                scannedCount > 0 ? scannedCount.toString() : '-',
                loc.homeStatsScanned,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                FeedbackService.buttonTapFeedback();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedQRGeneratorScreen(),
                  ),
                );
              },
              child: _buildQuickStat(
                context,
                createdCount > 0 ? createdCount.toString() : '-',
                loc.homeStatsCreated,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                FeedbackService.buttonTapFeedback();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeSettingsScreen(),
                  ),
                );
              },
              child: _buildQuickStat(
                context,
                themeProvider.getColorName(themeProvider.themeColor),
                loc.homeStatsTheme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(
    BuildContext context,
    ColorScheme colorScheme,
    bool isPremium,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.homeFeaturesTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildModernActionCard(
              context,
              loc.homeActionScanQr,
              Icons.qr_code_scanner,
              Colors.blue,
              () async {
                FeedbackService.buttonTapFeedback();
                await _logHomeActionEvent(
                  action: 'open_qr_scanner',
                  buttonTitle: loc.homeActionScanQr,
                  context: context,
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedQRScannerScreen(),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              loc.homeActionCreateQr,
              Icons.qr_code,
              Colors.green,
              () async {
                FeedbackService.buttonTapFeedback();
                await _logHomeActionEvent(
                  action: 'open_qr_generator',
                  buttonTitle: loc.homeActionCreateQr,
                  context: context,
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedQRGeneratorScreen(),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              loc.homeActionSavedRecords,
              Icons.bookmark_added,
              Colors.orange,
              () async {
                FeedbackService.buttonTapFeedback();
                await _logHomeActionEvent(
                  action: 'open_history',
                  buttonTitle: loc.homeActionSavedRecords,
                  context: context,
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              loc.homeActionFavorites,
              Icons.favorite,
              Colors.red,
              () async {
                FeedbackService.buttonTapFeedback();
                await _logHomeActionEvent(
                  action: 'open_favorites',
                  buttonTitle: loc.homeActionFavorites,
                  context: context,
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              loc.homeActionBatchScan,
              Icons.multiple_stop,
              Colors.purple,
              () async {
                FeedbackService.buttonTapFeedback();
                await _logHomeActionEvent(
                  action: 'open_batch_scanner',
                  buttonTitle: loc.homeActionBatchScan,
                  context: context,
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BatchScannerScreen(),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              loc.homeActionAdvancedBarcode,
              Icons.crop_free,
              Colors.indigo,
              () async {
                FeedbackService.buttonTapFeedback();
                await _logHomeActionEvent(
                  action: 'open_advanced_barcode_scanner',
                  buttonTitle: loc.homeActionAdvancedBarcode,
                  context: context,
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdvancedBarcodeScanner(),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              loc.homeActionCustomizeQr,
              Icons.brush,
              Colors.teal,
              () async {
                FeedbackService.buttonTapFeedback();
                await _logHomeActionEvent(
                  action: 'open_custom_qr_generator',
                  buttonTitle: loc.homeActionCustomizeQr,
                  context: context,
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomQRGeneratorScreen(
                      data: 'https://example.com',
                    ),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              loc.settings,
              Icons.settings,
              colorScheme.primary,
              () async {
                FeedbackService.buttonTapFeedback();
                await _logHomeActionEvent(
                  action: 'open_settings',
                  buttonTitle: loc.settings,
                  context: context,
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              loc.homeActionPriceAlerts,
              Icons.notifications_active,
              Colors.amber,
              () async {
                FeedbackService.buttonTapFeedback();
                await _logHomeActionEvent(
                  action: 'open_price_alerts',
                  buttonTitle: loc.homeActionPriceAlerts,
                  context: context,
                );
                if (!context.mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PriceAlertsScreen(),
                  ),
                );
                _loadPriceAlertStats();
              },
              badgeCount: triggeredAlertCount,
              subtitle: totalAlertCount == 0
                  ? loc.homeNoAlerts
                  : loc.homeAlertsSummary(triggeredAlertCount, totalAlertCount),
            ),
            _buildModernActionCard(
              context,
              loc.homeActionAnalytics,
              Icons.analytics,
              Colors.deepPurple,
              () async {
                FeedbackService.buttonTapFeedback();
                await _logHomeActionEvent(
                  action: 'open_analytics',
                  buttonTitle: loc.homeActionAnalytics,
                  context: context,
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    int badgeCount = 0,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTiny =
                constraints.maxHeight < 70 || constraints.maxWidth < 70;
            final isCompact =
                constraints.maxHeight < 120 || constraints.maxWidth < 120;

            if (isTiny) {
              return Center(child: Icon(icon, size: 20, color: color));
            }

            final iconSize = isCompact ? 20.0 : 24.0;
            final iconBoxSize = isCompact ? 40.0 : 48.0;
            final titleLines = isCompact ? 1 : 2;
            final showSubtitle = subtitle != null && !isCompact;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: iconBoxSize,
                      height: iconBoxSize,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: iconSize, color: color),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          constraints: const BoxConstraints(minWidth: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: isCompact ? 4 : 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: isCompact ? 11 : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: titleLines,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
