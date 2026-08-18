import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  void _sendEmail(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@qrkodproje.com',
      query:
          'subject=${Uri.encodeComponent(loc.feedbackEmailSubject)}&body=${Uri.encodeComponent(loc.feedbackEmailBody)}',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.feedbackTitle),
        backgroundColor: colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.feedbackHeading,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(loc.feedbackBody, style: textTheme.bodyMedium),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.email_outlined),
                label: Text(loc.feedbackEmailButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _sendEmail(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.feedbackEmailAddress,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
