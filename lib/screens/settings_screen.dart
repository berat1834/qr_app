import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../services/analytics_service.dart';
import '../services/cloud_backup_service.dart';
import '../services/feedback_service.dart';
import '../services/premium_access_service.dart';
import '../services/premium_sync_service.dart';
import 'theme_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Hata notifier'ını dinle ve dialog göster
    PremiumAccessService.errorNotifier.addListener(_showErrorDialog);
  }

  @override
  void dispose() {
    PremiumAccessService.errorNotifier.removeListener(_showErrorDialog);
    super.dispose();
  }

  void _showErrorDialog() {
    final error = PremiumAccessService.errorNotifier.value;
    if (error != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Satın Alma Hatası'),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Hata gösterildi, sıfırla
                PremiumAccessService.errorNotifier.value = null;
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayarlar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: PremiumAccessService.premiumNotifier,
        builder: (context, isPremium, _) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tercihlerinizi Yönetin',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tema, premium ve yedekleme ayarları',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    ),

                    // Tema Ayarları Section
                    _buildSectionTitle('Görünüm', context),
                    _buildModernCard(
                      context,
                      icon: Icons.palette,
                      title: 'Tema Ayarları',
                      subtitle: 'Renk, koyu/açık mod ve stil',
                      iconColor: Colors.purple,
                      onTap: () {
                        FeedbackService.buttonTapFeedback();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ThemeSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Premium Section
                    _buildSectionTitle('Premium', context),
                    _buildPremiumCard(context, isPremium),
                    const SizedBox(height: 24),

                    // Bulut Yedekleme Section
                    _buildSectionTitle('Bulut & Senkronizasyon', context),
                    _buildCloudBackupCard(context, isPremium),
                    const SizedBox(height: 24),

                    // Hakkında Section
                    _buildSectionTitle('Diğer', context),
                    _buildAboutCard(context),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildModernCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, bool isPremium) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPremium
              ? Colors.amber.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      color: isPremium ? Colors.amber.withOpacity(0.08) : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium Durumu',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPremium ? '✅ Aktif' : '⭕ Pasif',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isPremium ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isPremium
                  ? 'Bulut senkronizasyon, gelişmiş export ve daha fazlası aktif.'
                  : 'Premium üyelik ile bulut senkronizasyon, export ve diğer özellikleri açın.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 16),
            if (!isPremium) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await AnalyticsService.logPaywallOpen(
                      screen: 'settings_premium',
                    );
                    final started =
                        await PremiumAccessService.purchasePremium();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            started
                                ? '🛒 Satın alma akışı başlatıldı'
                                : '❌ Satın alma başlatılamadı',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.workspace_premium, size: 20),
                  label: const Text('Premium Satın Al'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await PremiumAccessService.restorePurchases();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔄 Satın alımlar geri yükleniyor...'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.restore, size: 20),
                  label: const Text('Satın Alımı Geri Yükle'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Demo Mode Switch - Always show
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                isPremium
                    ? 'Demo Premium Modunu Kapat'
                    : 'Demo Premium Modunu Aç',
              ),
              subtitle: const Text('Test amaçlı premium özellikler'),
              value: isPremium,
              onChanged: (value) async {
                await PremiumAccessService.setPremium(value);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? '✅ Premium aktif edildi'
                            : '⭕ Premium pasifleştirildi',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudBackupCard(BuildContext context, bool isPremium) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.cloud_sync, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bulut Senkronizasyon',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPremium ? '✅ Aktif' : '🔒 Kilitli',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isPremium ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Verilerinizi Google Drive\'da güvenli şekilde saklayın ve cihazlar arası senkronize edin.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            if (isPremium) ...[
              const SizedBox(height: 16),
              FutureBuilder<DateTime?>(
                future: PremiumSyncService.getLastSyncTimestamp(),
                builder: (context, snapshot) {
                  final lastSync = snapshot.data;
                  return Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lastSync == null
                            ? 'Son senkronizasyon: Henüz yok'
                            : 'Son: ${_formatDateTime(lastSync)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<bool>(
                future: PremiumSyncService.isAutoSyncEnabled(),
                builder: (context, snapshot) {
                  final enabled = snapshot.data ?? false;
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Otomatik Senkronizasyon'),
                    subtitle: const Text(
                      'Güncellemeleri otomatik olarak yedekle',
                    ),
                    value: enabled,
                    onChanged: (value) async {
                      await PremiumSyncService.setAutoSyncEnabled(value);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? '✅ Otomatik senkronizasyon açıldı'
                                  : '⭕ Otomatik senkronizasyon kapatıldı',
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        FeedbackService.buttonTapFeedback();
                        await _handleSyncNow(context);
                      },
                      icon: const Icon(Icons.sync, size: 20),
                      label: const Text('Senkronize Et'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        FeedbackService.buttonTapFeedback();
                        await _handleRestore(context);
                      },
                      icon: const Icon(Icons.download, size: 20),
                      label: const Text('Geri Yükle'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 18, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Premium ile açılır',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _buildModernCard(
          context,
          icon: Icons.info_outline,
          title: 'Uygulama Hakkında',
          subtitle: 'Versiyon 1.0.0',
          iconColor: Colors.cyan,
          onTap: () {
            FeedbackService.buttonTapFeedback();
            _showAboutDialog(context);
          },
        ),
        const SizedBox(height: 12),
        _buildModernCard(
          context,
          icon: Icons.privacy_tip_outlined,
          title: 'Gizlilik Politikası',
          subtitle: 'Veri güvenliği ve gizlilik',
          iconColor: Colors.indigo,
          onTap: () {
            FeedbackService.buttonTapFeedback();
            _showPrivacyPolicyDialog(context);
          },
        ),
      ],
    );
  }

  Future<void> _handleSyncNow(BuildContext context) async {
    // Log analytics: Sinkronizasyon başlangıcı
    await AnalyticsService.logSyncStart();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senkronizasyon başlatılıyor...')),
      );
    }

    final success = await PremiumSyncService.syncNow();

    // Log analytics: Sinkronizasyon sonucu
    if (success) {
      await AnalyticsService.logSyncSuccess(itemCount: 0);
    } else {
      await AnalyticsService.logSyncFailed(errorCode: 'SYNC_FAILED');
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Senkronizasyon tamamlandı'
                : '❌ Senkronizasyon başarısız',
          ),
        ),
      );
    }
  }

  static String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  Future<void> _handleRestore(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geri yükleme başlatılıyor...')),
      );
    }
    final success = await PremiumSyncService.restoreNow();

    if (success) {
      // Log analytics: Başarılı geri yükleme
      await AnalyticsService.logRestoreSuccess(restoreCount: 1);

      if (context.mounted) {
        await context.read<HistoryProvider>().loadHistory();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Veriler geri yüklendi! Favoriler sayfasını açıp kapatarak güncelleyebilirsiniz.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } else {
      // Log analytics: Başarısız geri yükleme
      await AnalyticsService.logRestoreFailed(errorCode: 'RESTORE_FAILED');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Geri yükleme hatası veya yedek bulunamadı'),
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code, size: 32),
            SizedBox(width: 12),
            Text('QR Kod Uygulaması'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Versiyon: 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Flutter ile geliştirilmiş profesyonel QR kod okuyucu ve oluşturucu uygulama.',
            ),
            const SizedBox(height: 12),
            const Text('Özellikler:'),
            const SizedBox(height: 8),
            _buildFeatureItem('📷 Gelişmiş QR kod tarama'),
            _buildFeatureItem('✏️ Özel QR kod oluşturma'),
            _buildFeatureItem('⭐ Favoriler yönetimi'),
            _buildFeatureItem('☁️ Bulut yedekleme'),
            _buildFeatureItem('🎨 Özelleştirilebilir temalar'),
            _buildFeatureItem('📊 İstatistik ve analiz'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined, size: 32),
            SizedBox(width: 12),
            Text('Gizlilik Politikası'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Veri Gizliliği ve Güvenliği',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Toplanan Veriler\n'
                'Bu uygulama minimum veri toplar. QR kod tarama ve oluşturma işlemleri tamamen cihazınızda gerçekleştirilir.\n\n'
                '2. Bulut Yedekleme (Premium)\n'
                'Premium üyelikle verileriniz Google Drive üzerinde şifreli olarak saklanır. Kişisel bilgileriniz hiçbir zaman üçüncü taraflara paylaşılmaz.\n\n'
                '3. Analitik (İsteğe bağlı)\n'
                'Firebase Analytics kullanılarak güncellemeleri iyileştirmek için anonim veriler toplanabilir.\n\n'
                '4. Kamera İzni\n'
                'Kamera izni sadece QR kod taraması için kullanılır. Hiçbir fotoğraf kaydedilmez veya gönderilmez.\n\n'
                '5. Veri Silme\n'
                'İstediğiniz zaman uygulama ayarlarından tüm verilerinizi silebilirsiniz.\n\n'
                '6. İletişim\n'
                'Gizlilikle ilgili sorularınız için bize ulaşabilirsiniz.',
              ),
              const SizedBox(height: 12),
              const Text(
                'Son güncellenme: Mart 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Tamam'),
          ),
        ],
        actionsPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
