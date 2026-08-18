import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.helpFaqTitle),
        backgroundColor: colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            loc.helpFaqHeading,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _faqItem(loc.helpFaqQ1, loc.helpFaqA1),
          _faqItem(loc.helpFaqQ2, loc.helpFaqA2),
          _faqItem(loc.helpFaqQ3, loc.helpFaqA3),
          _faqItem(loc.helpFaqQ4, loc.helpFaqA4),
          _faqItem(loc.helpFaqQ5, loc.helpFaqA5),
          const SizedBox(height: 32),
          Text(
            loc.helpFaqMoreHelp,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(answer, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
