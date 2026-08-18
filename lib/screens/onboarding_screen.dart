import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    final List<_OnboardingPage> pages = [
      _OnboardingPage(
        title: loc.onboardingWelcomeTitle,
        description: loc.onboardingWelcomeDescription,
        image: Icons.qr_code,
      ),
      _OnboardingPage(
        title: loc.onboardingThemePremiumTitle,
        description: loc.onboardingThemePremiumDescription,
        image: Icons.palette,
      ),
      _OnboardingPage(
        title: loc.onboardingCloudBackupTitle,
        description: loc.onboardingCloudBackupDescription,
        image: Icons.cloud_upload,
      ),
      _OnboardingPage(
        title: loc.onboardingPrivacyTitle,
        description: loc.onboardingPrivacyDescription,
        image: Icons.verified_user,
      ),
    ];
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => pages[i],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => _dot(i == _currentPage, colorScheme),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      ),
                      child: Text(loc.commonBack),
                    ),
                  if (_currentPage < pages.length - 1)
                    ElevatedButton(
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      ),
                      child: Text(loc.onboardingNext),
                    ),
                  if (_currentPage == pages.length - 1)
                    ElevatedButton(
                      onPressed: _finishOnboarding,
                      child: Text(loc.onboardingStart),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      width: active ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? colorScheme.primary : colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData image;
  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(image, size: 100, color: colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
