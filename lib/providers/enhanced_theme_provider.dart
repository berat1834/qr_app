import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tema renk seçenekleri enum'u
enum AppThemeColor { blue, green, purple, orange, pink, teal, indigo, red }

// Tema modu enum'u
enum AppThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _themeColorKey = 'theme_color';

  AppThemeMode _themeMode = AppThemeMode.light;
  AppThemeColor _themeColor = AppThemeColor.blue;

  ThemeProvider() {
    _loadTheme();
  }

  AppThemeMode get themeMode => _themeMode;
  AppThemeColor get themeColor => _themeColor;

  // Eski isimlendirme ile uyumluluk için
  String get themeColorName => getColorName(_themeColor);
  String get themeModeString => getThemeModeDisplayName(_themeMode);

  void _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex =
          prefs.getInt(_themeModeKey) ?? 0; // Varsayılan light (0)
      final themeColorIndex = prefs.getInt(_themeColorKey) ?? 0;

      _themeMode = AppThemeMode.values[themeModeIndex];
      _themeColor = AppThemeColor.values[themeColorIndex];

      notifyListeners();
    } catch (e) {
      // Hata durumunda varsayılan değerleri kullan
      _themeMode = AppThemeMode.light;
      _themeColor = AppThemeColor.blue;
      notifyListeners();
    }
  }

  bool get isDarkMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_themeModeKey, mode.index);
      } catch (e) {
        // Handle error silently
      }
      notifyListeners();
    }
  }

  void toggleTheme() {
    // Ana sayfa butonunda sadece light ve dark arasında geçiş yap
    // Sistem modundan çıkarak manual olarak light/dark seç
    if (_themeMode == AppThemeMode.dark) {
      setThemeMode(AppThemeMode.light);
    } else {
      setThemeMode(AppThemeMode.dark);
    }
  }

  Future<void> setThemeColor(AppThemeColor color) async {
    _themeColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorKey, color.index);
    notifyListeners();
  }

  Future<void> setColor(AppThemeColor color) async {
    _themeColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorKey, color.index);
    notifyListeners();
  }

  void resetToDefaults() {
    _themeMode = AppThemeMode.light;
    _themeColor = AppThemeColor.blue;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, _themeMode.index);
      await prefs.setInt(_themeColorKey, _themeColor.index);
    } catch (e) {
      // Handle error silently
    }
  }

  // Ana renk getter'ı
  Color get primaryColor {
    switch (_themeColor) {
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

  // Material 3 ColorScheme'leri
  ColorScheme get lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );
  }

  ColorScheme get darkColorScheme {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );
  }

  // Ana tema getter'ları
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.inversePrimary,
        foregroundColor: lightColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: lightColorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightColorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: lightColorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: darkColorScheme.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: darkColorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColorScheme.primary,
        foregroundColor: darkColorScheme.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkColorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: darkColorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Kullanıcının seçtiği tema moduna göre tema döndür
  ThemeMode get currentThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Tema renk isimlerini almak için yardımcı method
  String getColorName(AppThemeColor color) {
    switch (color) {
      case AppThemeColor.blue:
        return 'Mavi';
      case AppThemeColor.green:
        return 'Yeşil';
      case AppThemeColor.purple:
        return 'Mor';
      case AppThemeColor.orange:
        return 'Turuncu';
      case AppThemeColor.pink:
        return 'Pembe';
      case AppThemeColor.teal:
        return 'Teal';
      case AppThemeColor.indigo:
        return 'İndigo';
      case AppThemeColor.red:
        return 'Kırmızı';
    }
  }

  // Tema modu isimlerini almak için yardımcı method
  String getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Açık Tema';
      case AppThemeMode.dark:
        return 'Koyu Tema';
      case AppThemeMode.system:
        return 'Sistem Teması';
    }
  }
}
