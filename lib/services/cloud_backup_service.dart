import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites_service.dart';
import 'history_service.dart';

class CloudBackupService {
  static const String _lastBackupKey = 'last_backup_timestamp';
  static String? lastSignInError;
  // Google Drive Uygulama Verisi klasörüne erişim izni istiyoruz
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  static Future<GoogleSignInAccount?> trySilentSignIn() async {
    if (_googleSignIn.currentUser != null) {
      return _googleSignIn.currentUser;
    }

    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint('Sessiz giriş hatası (önemsiz): $e');
      return null;
    }
  }

  /// Kullanıcı oturum açmış mı kontrol et / Giriş yap
  static Future<GoogleSignInAccount?> signIn() async {
    lastSignInError = null;

    if (_googleSignIn.currentUser != null) {
      return _googleSignIn.currentUser;
    }

    try {
      // 1. Önce sessizce (kullanıcıya sormadan) giriş yapmayı dene
      final account = await _googleSignIn.signInSilently();
      if (account != null) return account;
    } catch (e) {
      debugPrint('Sessiz giriş hatası (önemsiz): $e');
      lastSignInError = e.toString();
    }

    try {
      // 2. Eğer sessiz giriş başarısızsa manuel giriş penceresini aç
      return await _googleSignIn.signIn();
    } catch (e) {
      debugPrint('Giriş hatası: $e');
      lastSignInError = e.toString();
      return null;
    }
  }

  /// Oturumu kapat
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Yedekleme İşlemi
  static Future<bool> backupData() async {
    final user = _googleSignIn.currentUser;
    if (user == null) return false;

    try {
      final authHeaders = await user.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      // 1. Verileri Hazırla
      final favoritesJson = await FavoritesService.exportFavoritesToJson();
      final historyJson = await HistoryService.exportHistoryToJson();

      // Yedeklenecek veri yapısı
      final backupMap = {
        'favorites': jsonDecode(favoritesJson),
        'history': jsonDecode(historyJson),
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      final jsonContent = jsonEncode(backupMap);
      final uploadMedia = drive.Media(
        Stream.value(utf8.encode(jsonContent)),
        utf8.encode(jsonContent).length,
      );

      // 2. Eski yedeği bul (varsa üzerine yazacağız)
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'qr_pro_backup.json'",
      );

      // 3. Dosyayı Yükle veya Güncelle
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Güncelle
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(
          drive.File(),
          fileId,
          uploadMedia: uploadMedia,
        );
      } else {
        // Yeni oluştur
        final fileToUpload = drive.File();
        fileToUpload.name = 'qr_pro_backup.json';
        fileToUpload.parents = ['appDataFolder']; // Gizli uygulama klasörü

        await driveApi.files.create(fileToUpload, uploadMedia: uploadMedia);
      }

      await _saveLastBackupTimestamp(DateTime.now());
      return true;
    } catch (e) {
      debugPrint('Yedekleme hatası: $e');
      return false;
    }
  }

  static Future<void> _saveLastBackupTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackupKey, timestamp.toIso8601String());
  }

  static Future<DateTime?> getLastBackupTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastBackupKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Geri Yükleme İşlemi
  static Future<bool> restoreData() async {
    final user = _googleSignIn.currentUser;
    if (user == null) return false;

    try {
      final authHeaders = await user.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      // 1. Yedeği bul
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'qr_pro_backup.json'",
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return false; // Yedek yok
      }

      // 2. Dosyayı indir
      final fileId = fileList.files!.first.id!;
      final drive.Media media =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final List<int> dataStore = [];
      await media.stream.forEach((data) {
        dataStore.addAll(data);
      });

      final jsonString = utf8.decode(dataStore);
      final Map<String, dynamic> backupMap = jsonDecode(jsonString);

      // 3. Verileri Geri Yükle
      if (backupMap.containsKey('favorites')) {
        final favList = jsonEncode(backupMap['favorites']);
        await FavoritesService.importFavoritesFromJson(favList);
      }

      if (backupMap.containsKey('history')) {
        final historyList = jsonEncode(backupMap['history']);
        await HistoryService.importHistoryFromJson(historyList);
      }

      return true;
    } catch (e) {
      debugPrint('Geri yükleme hatası: $e');
      return false;
    }
  }
}

// Google API Client Yardımcısı (Yetkilendirme başlıklarını ekler)
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
