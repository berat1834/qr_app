// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/enhanced_theme_provider.dart';
import '../services/feedback_service.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  Color _colorForTheme(AppThemeColor color) {
    switch (color) {
      case AppThemeColor.blue:
        return Colors.blue;
      case AppThemeColor.green:
        return Colors.green;
      case AppThemeColor.purple:
        return Colors.purple;
      case AppThemeColor.orange:
        return Colors.orange;
      case AppThemeColor.pink:
        return Colors.pink;
      case AppThemeColor.teal:
        return Colors.teal;
      case AppThemeColor.indigo:
        return Colors.indigo;
      case AppThemeColor.red:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.themeSettings),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              FeedbackService.buttonTapFeedback();
              _showColorPicker(context);
            },
            tooltip: loc.themeQuickColorPicker,
          ),
        ],
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentThemeCard(context, themeProvider),
                const SizedBox(height: 24),
                _buildThemeModeSection(context, themeProvider),
                const SizedBox(height: 24),
                _buildColorThemeSection(context, themeProvider),
                const SizedBox(height: 24),
                _buildPreviewSection(context, themeProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentThemeCard(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              themeProvider.primaryColor.withValues(alpha: 0.1),
              themeProvider.primaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.palette, size: 48, color: themeProvider.primaryColor),
            const SizedBox(height: 12),
            Text(
              loc.themeCurrentTheme,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: themeProvider.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_getLocalizedColorName(loc, themeProvider.themeColor)} • ${_getLocalizedThemeModeName(loc, themeProvider.themeMode)}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.brightness_6, color: themeProvider.primaryColor),
                const SizedBox(width: 8),
                Text(
                  loc.themeModeTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...AppThemeMode.values.map((mode) {
              return RadioListTile<AppThemeMode>(
                title: Text(_getLocalizedThemeModeName(loc, mode)),
                subtitle: Text(_getThemeModeDescription(loc, mode)),
                value: mode,
                groupValue: themeProvider.themeMode,
                activeColor: themeProvider.primaryColor,
                onChanged: (value) async {
                  if (value != null) {
                    FeedbackService.buttonTapFeedback();
                    await themeProvider.setThemeMode(value);
                  }
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildColorThemeSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.color_lens, color: themeProvider.primaryColor),
                const SizedBox(width: 8),
                Text(
                  loc.themeColorThemeTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: AppThemeColor.values.length,
              itemBuilder: (context, index) {
                final colorEnum = AppThemeColor.values[index];
                final previewColor = _colorForTheme(colorEnum);
                final isSelected = themeProvider.themeColor == colorEnum;
                return GestureDetector(
                  onTap: () async {
                    FeedbackService.buttonTapFeedback();
                    await themeProvider.setThemeColor(colorEnum);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: previewColor,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              loc.themeSelectedColor(
                _getLocalizedColorName(loc, themeProvider.themeColor),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: themeProvider.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: themeProvider.primaryColor),
                const SizedBox(width: 8),
                Text(
                  loc.themePreviewTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: themeProvider.primaryColor,
                        child: const Icon(Icons.qr_code, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.appTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              loc.themePreviewSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => FeedbackService.buttonTapFeedback(),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: Text(loc.homeActionScanQr),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => FeedbackService.buttonTapFeedback(),
                          icon: const Icon(Icons.qr_code),
                          label: Text(loc.homeActionCreateQr),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: themeProvider.primaryColor),
                            foregroundColor: themeProvider.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    avatar: Icon(
                      Icons.palette,
                      size: 18,
                      color: themeProvider.primaryColor,
                    ),
                    label: Text(
                      _getLocalizedColorName(loc, themeProvider.themeColor),
                    ),
                    backgroundColor: themeProvider.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              loc.themeQuickColorPicker,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppThemeColor.values.map((colorEnum) {
                    final previewColor = _colorForTheme(colorEnum);
                    final isSelected = themeProvider.themeColor == colorEnum;
                    return GestureDetector(
                      onTap: () async {
                        FeedbackService.buttonTapFeedback();
                        await themeProvider.setThemeColor(colorEnum);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: previewColor,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: previewColor.withValues(alpha: 0.3),
                              spreadRadius: isSelected ? 3 : 1,
                              blurRadius: isSelected ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getLocalizedColorName(AppLocalizations loc, AppThemeColor color) {
    switch (color) {
      case AppThemeColor.blue:
        return loc.themeColorBlue;
      case AppThemeColor.green:
        return loc.themeColorGreen;
      case AppThemeColor.purple:
        return loc.themeColorPurple;
      case AppThemeColor.orange:
        return loc.themeColorOrange;
      case AppThemeColor.pink:
        return loc.themeColorPink;
      case AppThemeColor.teal:
        return loc.themeColorTeal;
      case AppThemeColor.indigo:
        return loc.themeColorIndigo;
      case AppThemeColor.red:
        return loc.themeColorRed;
    }
  }

  String _getLocalizedThemeModeName(AppLocalizations loc, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return loc.themeModeLight;
      case AppThemeMode.dark:
        return loc.themeModeDark;
      case AppThemeMode.system:
        return loc.themeModeSystem;
    }
  }

  String _getThemeModeDescription(AppLocalizations loc, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return loc.themeModeLightDescription;
      case AppThemeMode.dark:
        return loc.themeModeDarkDescription;
      case AppThemeMode.system:
        return loc.themeModeSystemDescription;
    }
  }
}
