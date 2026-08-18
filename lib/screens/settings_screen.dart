import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/premium_access_service.dart';
import '../services/store_review_gateway.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import 'theme_settings_screen.dart';
import 'cloud_backup_screen.dart';
import 'feedback_screen.dart';
import 'about_screen.dart';
import 'help_faq_screen.dart';
import 'premium_purchase_screen.dart';

class SettingsScreen extends StatefulWidget {
  final StoreReviewGateway? storeReviewGateway;

  const SettingsScreen({super.key, this.storeReviewGateway});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _androidPackageName = 'com.qrscanner.professional';
  late final StoreReviewGateway _storeReviewGateway;

  void _showRateAppDialog() async {
    try {
      await _storeReviewGateway.rateApp(
        androidPackageName: _androidPackageName,
      );
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.settingsStoreOpenFailed('$e')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Helper for section titles
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

  void _showErrorDialog() {
    final error = PremiumAccessService.errorNotifier.value;
    if (error != null && mounted) {
      final loc = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(loc.settingsPurchaseErrorTitle),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                PremiumAccessService.errorNotifier.value = null;
              },
              child: Text(loc.commonOk),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _storeReviewGateway =
        widget.storeReviewGateway ?? const DefaultStoreReviewGateway();
    PremiumAccessService.errorNotifier.addListener(_showErrorDialog);
  }

  @override
  void dispose() {
    PremiumAccessService.errorNotifier.removeListener(_showErrorDialog);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: colorScheme.onSurface,
        title: Text(
          loc.settings,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.10),
              colorScheme.surface.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: PremiumAccessService.premiumNotifier,
          builder: (context, isPremium, _) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                // Header (açıklama + dil seçici)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${loc.themeSettings}, ${loc.premium} ve ${loc.cloudBackup.toLowerCase()} ${loc.settings.toLowerCase()}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          const Icon(Icons.language, size: 20),
                          Text(
                            loc.settingsLanguageLabel,
                            style: textTheme.bodyMedium,
                          ),
                          Builder(
                            builder: (context) {
                              LocaleProvider? localeProvider;
                              try {
                                localeProvider = Provider.of<LocaleProvider>(
                                  context,
                                  listen: false,
                                );
                              } on ProviderNotFoundException {
                                localeProvider = null;
                              }

                              return DropdownButton<Locale>(
                                value:
                                    localeProvider?.locale ??
                                    Localizations.localeOf(context),
                                items: [
                                  DropdownMenuItem(
                                    value: const Locale('tr'),
                                    child: Text(loc.settingsLanguageTurkish),
                                  ),
                                  DropdownMenuItem(
                                    value: const Locale('en'),
                                    child: Text(loc.settingsLanguageEnglish),
                                  ),
                                ],
                                onChanged: localeProvider == null
                                    ? null
                                    : (locale) {
                                        if (locale != null) {
                                          localeProvider!.setLocale(locale);
                                        }
                                      },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Görünüm
                _buildSectionTitle(loc.themeSettings, context),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: colorScheme.surface.withValues(alpha: 0.98),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withValues(alpha: 0.15),
                      child: const Icon(Icons.palette, color: Colors.purple),
                    ),
                    title: Text(loc.themeSettings),
                    subtitle: Text(loc.themeSettingsSubtitle),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.outline,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                // Premium
                _buildSectionTitle(loc.premium, context),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: colorScheme.surface.withValues(alpha: 0.98),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.withValues(alpha: 0.18),
                      child: Icon(
                        isPremium ? Icons.verified : Icons.workspace_premium,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    title: Text(loc.premium),
                    subtitle: Text(
                      isPremium
                          ? loc.settingsPremiumActiveSubtitle
                          : loc.settingsPremiumUpgradeSubtitle,
                    ),
                    trailing: Icon(
                      isPremium ? Icons.check_circle : Icons.chevron_right,
                      color: isPremium ? Colors.green : colorScheme.outline,
                    ),
                    onTap: isPremium
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PremiumPurchaseScreen(),
                              ),
                            );
                          },
                  ),
                ),
                const SizedBox(height: 18),
                // Yardım / SSS
                _buildSectionTitle(loc.helpFaq, context),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: colorScheme.surface.withValues(alpha: 0.98),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.blueGrey,
                      ),
                    ),
                    title: Text(loc.helpFaq),
                    subtitle: Text(loc.helpFaqSubtitle),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.outline,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpFaqScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                // Uygulamayı Puanla
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: colorScheme.surface.withValues(alpha: 0.98),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withValues(alpha: 0.15),
                      child: const Icon(Icons.star_rate, color: Colors.orange),
                    ),
                    title: Text(loc.rateApp),
                    subtitle: Text(loc.rateAppSubtitle),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.outline,
                    ),
                    onTap: _showRateAppDialog,
                  ),
                ),
                const SizedBox(height: 18),
                // Geri Bildirim
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: colorScheme.surface.withValues(alpha: 0.98),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.feedback_outlined,
                        color: Colors.redAccent,
                      ),
                    ),
                    title: Text(loc.feedback),
                    subtitle: Text(loc.feedbackSubtitle),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.outline,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedbackScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                // Yedekleme (örnek)
                _buildSectionTitle(loc.cloudBackup, context),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: colorScheme.surface.withValues(alpha: 0.98),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withValues(alpha: 0.15),
                      child: const Icon(Icons.cloud, color: Colors.blue),
                    ),
                    title: Text(loc.cloudBackup),
                    subtitle: Text(loc.cloudBackupSubtitle),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.outline,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CloudBackupScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                // Hakkında
                _buildSectionTitle(loc.about, context),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: colorScheme.surface.withValues(alpha: 0.98),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                      child: const Icon(Icons.info, color: Colors.green),
                    ),
                    title: Text(loc.about),
                    subtitle: Text(loc.aboutSubtitle),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.outline,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
