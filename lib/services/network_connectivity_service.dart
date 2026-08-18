import 'package:connectivity_plus/connectivity_plus.dart';
import 'offline_queue_service.dart';

class NetworkConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static bool _isOnline = true;

  /// Dinleyiciyi başlat - app başladığında çağrıl
  static void startListening() {
    // İlk durum
    _connectivity.checkConnectivity().then((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      print('[NetworkConnectivity] İlk durum: $_isOnline');

      // Eğer online ise kuyrağı senkronize et
      if (_isOnline) {
        _syncQueueIfNeeded();
      }
    });

    // Değişiklikleri dinle
    _connectivity.onConnectivityChanged.listen((results) async {
      final wasOnline = _isOnline;
      _isOnline = results.any((r) => r != ConnectivityResult.none);

      print('[NetworkConnectivity] Durum değişti: $wasOnline → $_isOnline');

      // Offline → Online geçişinde kuyrağı senkronize et
      if (!wasOnline && _isOnline) {
        print(
          '[NetworkConnectivity] Ağ geri geldi! Kuyruk senkronize ediliyor...',
        );
        await _syncQueueIfNeeded();
      }
    });
  }

  static Future<void> _syncQueueIfNeeded() async {
    try {
      await OfflineQueueService.syncQueuedScans();
      print('[NetworkConnectivity] Kuyruk senkronize edildi');
    } catch (e) {
      print('[NetworkConnectivity] Kuyruk sync hatası: $e');
    }
  }

  static bool get isOnline => _isOnline;
}
