import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _defaultPrivacyPolicyUrl =
      'https://sites.google.com/view/qrscanner-privacy';
  static const String _privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: _defaultPrivacyPolicyUrl,
  );

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.aboutTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.aboutAppName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(loc.aboutDescription),
            const SizedBox(height: 24),
            Text(
              loc.aboutVersion,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(loc.aboutDeveloper),
            const SizedBox(height: 24),
            Text(loc.aboutSupport),
            const SizedBox(height: 24),
            Text(loc.aboutOpenSourceNote),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(_privacyPolicyUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                loc.aboutPrivacyPolicy,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
