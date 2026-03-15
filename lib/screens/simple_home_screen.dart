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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
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
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 64,
                      color: themeProvider.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'QR Kod Uygulaması',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: themeProvider.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'QR kodlarını tarayın ve oluşturun',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(
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
                  _buildActionCard(
                    context,
                    'QR Oluştur',
                    Icons.qr_code,
                    Colors.green,
                    () {
                      FeedbackService.buttonTapFeedback();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const EnhancedQRGeneratorScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    context,
                    'Geçmiş',
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
                  _buildActionCard(
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
                  _buildActionCard(
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
                  _buildActionCard(
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
                  _buildActionCard(
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
                  _buildActionCard(
                    context,
                    'Tema Ayarları',
                    Icons.palette,
                    themeProvider.primaryColor,
                    () {
                      FeedbackService.buttonTapFeedback();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats Card
            Card(
              elevation: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickStat(
                      context,
                      scannedCount > 0 ? scannedCount.toString() : '-',
                      'Tarama',
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    _buildQuickStat(
                      context,
                      createdCount > 0 ? createdCount.toString() : '-',
                      'Oluşturma',
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    _buildQuickStat(
                      context,
                      themeProvider.themeColorName,
                      'Tema',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
