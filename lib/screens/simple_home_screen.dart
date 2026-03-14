import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_theme_provider.dart';
import '../services/history_service.dart';
import '../services/feedback_service.dart';
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

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  int scannedCount = 0;
  int createdCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final history = await HistoryService.getHistory();
    setState(() {
      scannedCount = history.where((item) => item.isScanned == true).length;
      createdCount = history.where((item) => item.isScanned == false).length;
    });
  }

  Future<void> _addSampleData() async {
    // Test amaçlı örnek veri ekle
    await HistoryService.addToHistory(
      data: 'https://example.com',
      type: 'URL',
      isScanned: true,
    );
    await HistoryService.addToHistory(
      data: 'https://example.org',
      type: 'URL',
      isScanned: false,
    );

    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Kod Uygulaması',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
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
            tooltip: 'Tema Ayarları',
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              FeedbackService.buttonTapFeedback();
              themeProvider.toggleTheme();
            },
            tooltip: themeProvider.isDarkMode ? 'Aydınlık Mod' : 'Karanlık Mod',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildHeaderCard(context, colorScheme),
              const SizedBox(height: 24),
              _buildStatsCard(context, colorScheme, themeProvider),
              const SizedBox(height: 24),
              _buildFeaturesGrid(context, colorScheme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
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
            'QR Kod Uygulaması',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'QR kodlarını tarayın ve oluşturun',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
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
                'Tarama',
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
                'Oluşturma',
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
                themeProvider.themeColorName,
                'Tema',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özellikler',
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
              'QR Tara',
              Icons.qr_code_scanner,
              Colors.blue,
              () {
                FeedbackService.buttonTapFeedback();
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
              'QR Oluştur',
              Icons.qr_code,
              Colors.green,
              () {
                FeedbackService.buttonTapFeedback();
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
              'Kaydedilenler',
              Icons.history,
              Colors.orange,
              () {
                FeedbackService.buttonTapFeedback();
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
              'Favoriler',
              Icons.favorite,
              Colors.red,
              () {
                FeedbackService.buttonTapFeedback();
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
              'Toplu Tarama',
              Icons.multiple_stop,
              Colors.purple,
              () {
                FeedbackService.buttonTapFeedback();
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
              'Gelişmiş Barkod',
              Icons.crop_free,
              Colors.indigo,
              () {
                FeedbackService.buttonTapFeedback();
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
              'QR Özelleştir',
              Icons.brush,
              Colors.teal,
              () {
                FeedbackService.buttonTapFeedback();
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
              'Ayarlar',
              Icons.settings,
              colorScheme.primary,
              () {
                FeedbackService.buttonTapFeedback();
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
              'İstatistikler',
              Icons.analytics,
              Colors.deepPurple,
              () {
                FeedbackService.buttonTapFeedback();
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
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
