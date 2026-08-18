import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/providers/history_provider.dart';
import 'package:qr_app/providers/locale_provider.dart';
import 'package:qr_app/services/premium_access_service.dart';
import 'firebase_options.dart';
import 'providers/enhanced_theme_provider.dart';
import 'screens/simple_home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/price_alert_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/price_notification_service.dart';
import 'services/offline_queue_service.dart';
import 'services/network_connectivity_service.dart';

// Deep linking için global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool _hasRealFirebaseConfig() {
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    return !options.apiKey.startsWith('YOUR_') &&
        !options.projectId.contains('your-firebase-project-id') &&
        !options.appId.contains('YOUR_') &&
        options.projectId.trim().isNotEmpty;
  } catch (_) {
    return false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Deep linking için navigator key'i set et
  PriceNotificationService.setNavigatorKey(navigatorKey);

  // AdMob reklam servisini başlat
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await MobileAds.instance.initialize();
  }

  if (!kIsWeb &&
      (Platform.isAndroid || Platform.isIOS) &&
      _hasRealFirebaseConfig()) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  }

  // Şimdilik Premium Access manuel başlatılıyor (opsiyonel)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await PremiumAccessService.initialize();
    } catch (e) {
      debugPrint('Premium Access başlatılamadı (opsiyonel): $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const QRCodeApp(),
    ),
  );
}

class QRCodeApp extends StatefulWidget {
  const QRCodeApp({super.key});

  @override
  State<QRCodeApp> createState() => _QRCodeAppState();
}

class _QRCodeAppState extends State<QRCodeApp> with WidgetsBindingObserver {
  bool _onboardingComplete = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkOnboarding();
    // Ağ durumu değişikliklerini dinle ve offline kuyrağı otomatik senkronize et
    NetworkConnectivityService.startListening();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App returned to foreground: try syncing queued scans
      OfflineQueueService.syncQueuedScans();
    }
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboardingComplete = prefs.getBool('onboarding_completed') ?? false;
      _loading = false;
    });
  }

  void _finishOnboarding() {
    setState(() {
      _onboardingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.currentThemeMode,
          navigatorKey: navigatorKey,
          onGenerateRoute: (settings) {
            if (settings.name?.startsWith('/alert/') ?? false) {
              final alertId = settings.name!.replaceFirst('/alert/', '');
              return MaterialPageRoute(
                builder: (context) => PriceAlertDetailScreen(alertId: alertId),
              );
            }
            return null;
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: localeProvider.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            if (localeProvider.locale != null) return localeProvider.locale;
            if (locale == null) return supportedLocales.first;
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          home: _loading
              ? const SizedBox.shrink()
              : _onboardingComplete
              ? const SimpleHomeScreen()
              : OnboardingScreen(onFinish: _finishOnboarding),
        );
      },
    );
  }
}
