import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SyncStatus { idle, syncing, success, error, conflict }

enum CloudProvider { firebase, icloud, googledrive, onedrive, dropbox }

class SyncData {
  final String id;
  final String
  type; // 'scan_history', 'favorites', 'settings', 'ar_data', 'ocr_results'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final bool isDeleted;

  SyncData({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    this.isDeleted = false,
  });

  factory SyncData.fromJson(Map<String, dynamic> json) {
    return SyncData(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      data: json['data'] ?? {},
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      deviceId: json['deviceId'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deviceId': deviceId,
      'isDeleted': isDeleted,
    };
  }
}

class SyncResult {
  final bool success;
  final SyncStatus status;
  final String? error;
  final int? syncedItemCount;
  final int? conflictCount;
  final List<SyncConflict>? conflicts;
  final DateTime? lastSyncTime;

  SyncResult({
    required this.success,
    required this.status,
    this.error,
    this.syncedItemCount,
    this.conflictCount,
    this.conflicts,
    this.lastSyncTime,
  });
}

class SyncConflict {
  final String itemId;
  final String itemType;
  final SyncData localData;
  final SyncData cloudData;
  final ConflictResolution? resolution;

  SyncConflict({
    required this.itemId,
    required this.itemType,
    required this.localData,
    required this.cloudData,
    this.resolution,
  });
}

enum ConflictResolution { useLocal, useCloud, merge, skip }

class CloudSyncService {
  static const String _channelName = 'qr_app/cloud_sync';
  static const MethodChannel _methodChannel = MethodChannel(_channelName);

  static SyncStatus _currentStatus = SyncStatus.idle;
  static DateTime? _lastSyncTime;
  static String? _currentDeviceId;
  static CloudProvider _currentProvider = CloudProvider.firebase;

  // Event listeners
  static final List<Function(SyncStatus)> _statusListeners = [];
  static final List<Function(SyncResult)> _syncCompletedListeners = [];

  /// Senkronizasyon servisini başlat
  static Future<bool> initialize({CloudProvider? provider}) async {
    try {
      _currentProvider = provider ?? CloudProvider.firebase;
      _currentDeviceId = await _getDeviceId();

      final result = await _methodChannel.invokeMethod('initializeSync', {
        'provider': _currentProvider.name,
        'deviceId': _currentDeviceId,
      });

      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Sync servis başlatma hatası: ${e.message}');
      return false;
    }
  }

  /// Cihaz ID'sini al
  static Future<String> _getDeviceId() async {
    try {
      final result = await _methodChannel.invokeMethod('getDeviceId');
      return result ?? 'unknown_device';
    } catch (e) {
      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// QR tarama geçmişini senkronize et
  static Future<SyncResult> syncScanHistory() async {
    return await _performSync('scan_history', await _getScanHistoryData());
  }

  /// Favorileri senkronize et
  static Future<SyncResult> syncFavorites() async {
    return await _performSync('favorites', await _getFavoritesData());
  }

  /// Uygulama ayarlarını senkronize et
  static Future<SyncResult> syncSettings() async {
    return await _performSync('settings', await _getSettingsData());
  }

  /// AR verilerini senkronize et
  static Future<SyncResult> syncARData() async {
    return await _performSync('ar_data', await _getARData());
  }

  /// OCR sonuçlarını senkronize et
  static Future<SyncResult> syncOCRResults() async {
    return await _performSync('ocr_results', await _getOCRResultsData());
  }

  /// Tüm verileri senkronize et
  static Future<SyncResult> syncAll() async {
    try {
      _updateStatus(SyncStatus.syncing);

      final results = await Future.wait([
        syncScanHistory(),
        syncFavorites(),
        syncSettings(),
        syncARData(),
        syncOCRResults(),
      ]);

      final allSuccess = results.every((result) => result.success);
      final totalSynced = results.fold<int>(
        0,
        (sum, result) => sum + (result.syncedItemCount ?? 0),
      );
      final totalConflicts = results.fold<int>(
        0,
        (sum, result) => sum + (result.conflictCount ?? 0),
      );

      final finalResult = SyncResult(
        success: allSuccess,
        status: allSuccess ? SyncStatus.success : SyncStatus.error,
        syncedItemCount: totalSynced,
        conflictCount: totalConflicts,
        lastSyncTime: DateTime.now(),
      );

      if (allSuccess) {
        _lastSyncTime = DateTime.now();
        await _saveLastSyncTime(_lastSyncTime!);
      }

      _updateStatus(finalResult.status);
      _notifySyncCompleted(finalResult);

      return finalResult;
    } catch (e) {
      final errorResult = SyncResult(
        success: false,
        status: SyncStatus.error,
        error: 'Genel sync hatası: $e',
      );

      _updateStatus(SyncStatus.error);
      _notifySyncCompleted(errorResult);

      return errorResult;
    }
  }

  /// Otomatik senkronizasyonu başlat
  static Future<void> startAutoSync({
    Duration interval = const Duration(minutes: 15),
  }) async {
    try {
      await _methodChannel.invokeMethod('startAutoSync', {
        'intervalMinutes': interval.inMinutes,
      });
    } on PlatformException catch (e) {
      debugPrint('Otomatik sync başlatma hatası: ${e.message}');
    }
  }

  /// Otomatik senkronizasyonu durdur
  static Future<void> stopAutoSync() async {
    try {
      await _methodChannel.invokeMethod('stopAutoSync');
    } on PlatformException catch (e) {
      debugPrint('Otomatik sync durdurma hatası: ${e.message}');
    }
  }

  /// Çakışmaları çöz
  static Future<SyncResult> resolveConflicts(
    List<SyncConflict> conflicts,
  ) async {
    try {
      final resolutions = conflicts
          .map(
            (conflict) => {
              'itemId': conflict.itemId,
              'resolution': conflict.resolution?.name ?? 'skip',
              'localData': conflict.localData.toJson(),
              'cloudData': conflict.cloudData.toJson(),
            },
          )
          .toList();

      final result = await _methodChannel.invokeMethod('resolveConflicts', {
        'resolutions': resolutions,
      });

      if (result != null && result['success'] == true) {
        return SyncResult(
          success: true,
          status: SyncStatus.success,
          syncedItemCount: result['resolvedCount'] ?? 0,
        );
      } else {
        return SyncResult(
          success: false,
          status: SyncStatus.error,
          error: result?['error'] ?? 'Çakışma çözme hatası',
        );
      }
    } on PlatformException catch (e) {
      return SyncResult(
        success: false,
        status: SyncStatus.error,
        error: 'Çakışma çözme hatası: ${e.message}',
      );
    }
  }

  /// Bulut verilerini geri yükle (restore)
  static Future<SyncResult> restoreFromCloud() async {
    try {
      _updateStatus(SyncStatus.syncing);

      final result = await _methodChannel.invokeMethod('restoreFromCloud');

      if (result != null && result['success'] == true) {
        _lastSyncTime = DateTime.now();
        await _saveLastSyncTime(_lastSyncTime!);

        final syncResult = SyncResult(
          success: true,
          status: SyncStatus.success,
          syncedItemCount: result['restoredCount'] ?? 0,
          lastSyncTime: _lastSyncTime,
        );

        _updateStatus(SyncStatus.success);
        _notifySyncCompleted(syncResult);

        return syncResult;
      } else {
        final errorResult = SyncResult(
          success: false,
          status: SyncStatus.error,
          error: result?['error'] ?? 'Geri yükleme hatası',
        );

        _updateStatus(SyncStatus.error);
        _notifySyncCompleted(errorResult);

        return errorResult;
      }
    } on PlatformException catch (e) {
      final errorResult = SyncResult(
        success: false,
        status: SyncStatus.error,
        error: 'Geri yükleme hatası: ${e.message}',
      );

      _updateStatus(SyncStatus.error);
      _notifySyncCompleted(errorResult);

      return errorResult;
    }
  }

  /// Bulut hesabını değiştir
  static Future<bool> switchCloudProvider(CloudProvider newProvider) async {
    try {
      final result = await _methodChannel.invokeMethod('switchCloudProvider', {
        'newProvider': newProvider.name,
      });

      if (result == true) {
        _currentProvider = newProvider;
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      debugPrint('Bulut sağlayıcı değiştirme hatası: ${e.message}');
      return false;
    }
  }

  /// Sync status listener ekle
  static void addStatusListener(Function(SyncStatus) listener) {
    _statusListeners.add(listener);
  }

  /// Sync completed listener ekle
  static void addSyncCompletedListener(Function(SyncResult) listener) {
    _syncCompletedListeners.add(listener);
  }

  /// Listener'ları temizle
  static void removeAllListeners() {
    _statusListeners.clear();
    _syncCompletedListeners.clear();
  }

  /// Genel sync işlemi
  static Future<SyncResult> _performSync(
    String dataType,
    List<SyncData> localData,
  ) async {
    try {
      final result = await _methodChannel.invokeMethod('performSync', {
        'dataType': dataType,
        'localData': localData.map((item) => item.toJson()).toList(),
        'deviceId': _currentDeviceId,
      });

      if (result != null && result['success'] == true) {
        final conflicts = result['conflicts'] != null
            ? (result['conflicts'] as List)
                  .map((conflictData) => _parseConflict(conflictData))
                  .toList()
            : <SyncConflict>[];

        return SyncResult(
          success: true,
          status: conflicts.isNotEmpty
              ? SyncStatus.conflict
              : SyncStatus.success,
          syncedItemCount: result['syncedCount'] ?? 0,
          conflictCount: conflicts.length,
          conflicts: conflicts,
        );
      } else {
        return SyncResult(
          success: false,
          status: SyncStatus.error,
          error: result?['error'] ?? '$dataType sync hatası',
        );
      }
    } on PlatformException catch (e) {
      return SyncResult(
        success: false,
        status: SyncStatus.error,
        error: '$dataType sync hatası: ${e.message}',
      );
    }
  }

  /// Çakışma verilerini parse et
  static SyncConflict _parseConflict(Map<String, dynamic> conflictData) {
    return SyncConflict(
      itemId: conflictData['itemId'] ?? '',
      itemType: conflictData['itemType'] ?? '',
      localData: SyncData.fromJson(conflictData['localData'] ?? {}),
      cloudData: SyncData.fromJson(conflictData['cloudData'] ?? {}),
    );
  }

  /// Status güncelle ve dinleyicileri bilgilendir
  static void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    for (final listener in _statusListeners) {
      listener(status);
    }
  }

  /// Sync tamamlandığında dinleyicileri bilgilendir
  static void _notifySyncCompleted(SyncResult result) {
    for (final listener in _syncCompletedListeners) {
      listener(result);
    }
  }

  /// Son sync zamanını kaydet
  static Future<void> _saveLastSyncTime(DateTime time) async {
    try {
      await _methodChannel.invokeMethod('saveLastSyncTime', {
        'timestamp': time.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Son sync zamanı kaydetme hatası: $e');
    }
  }

  /// Mock veri getirme fonksiyonları
  static Future<List<SyncData>> _getScanHistoryData() async {
    // Gerçek uygulamada local database'den çekilir
    return [
      SyncData(
        id: 'scan_001',
        type: 'scan_history',
        data: {
          'qrData': 'https://example.com',
          'scanType': 'url',
          'timestamp': DateTime.now()
              .subtract(Duration(hours: 1))
              .toIso8601String(),
        },
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(Duration(hours: 1)),
        deviceId: _currentDeviceId ?? 'unknown',
      ),
    ];
  }

  static Future<List<SyncData>> _getFavoritesData() async {
    return [
      SyncData(
        id: 'fav_001',
        type: 'favorites',
        data: {
          'itemId': 'product_12345',
          'itemType': 'product',
          'name': 'Samsung Galaxy S24',
          'addedAt': DateTime.now()
              .subtract(Duration(days: 1))
              .toIso8601String(),
        },
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
        deviceId: _currentDeviceId ?? 'unknown',
      ),
    ];
  }

  static Future<List<SyncData>> _getSettingsData() async {
    return [
      SyncData(
        id: 'settings_001',
        type: 'settings',
        data: {
          'theme': 'dark',
          'language': 'tr',
          'notifications': true,
          'autoSync': true,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deviceId: _currentDeviceId ?? 'unknown',
      ),
    ];
  }

  static Future<List<SyncData>> _getARData() async {
    return [];
  }

  static Future<List<SyncData>> _getOCRResultsData() async {
    return [];
  }

  // Getter'lar
  static SyncStatus get currentStatus => _currentStatus;
  static DateTime? get lastSyncTime => _lastSyncTime;
  static String? get currentDeviceId => _currentDeviceId;
  static CloudProvider get currentProvider => _currentProvider;
}
