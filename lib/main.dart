import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_app/providers/history_provider.dart';
import 'package:qr_app/services/premium_access_service.dart';
import 'package:qr_app/services/premium_sync_service.dart';
import 'firebase_options.dart';
import 'providers/enhanced_theme_provider.dart';
import 'screens/simple_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await PremiumAccessService.initialize();
  PremiumSyncService.runStartupSyncIfEnabled();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider()),
      ],
      child: const QRCodeApp(),
    ),
  );
}

class QRCodeApp extends StatelessWidget {
  const QRCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'QR Kod Uygulaması',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.currentThemeMode,
          home: const SimpleHomeScreen(),
        );
      },
    );
  }
}
