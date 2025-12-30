import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ARObjectType { product3D, locationInfo, textOverlay, animation }

class ARData {
  final String id;
  final ARObjectType type;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;
  final String? modelUrl;
  final String? imageUrl;
  final List<String>? tags;

  ARData({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.metadata,
    this.modelUrl,
    this.imageUrl,
    this.tags,
  });

  factory ARData.fromJson(Map<String, dynamic> json) {
    return ARData(
      id: json['id'] ?? '',
      type: ARObjectType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ARObjectType.textOverlay,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      metadata: json['metadata'] ?? {},
      modelUrl: json['modelUrl'],
      imageUrl: json['imageUrl'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}

class ARResult {
  final bool success;
  final ARData? arData;
  final String? error;

  ARResult({required this.success, this.arData, this.error});
}

class ARService {
  static const String _channelName = 'qr_app/ar_service';
  static const MethodChannel _methodChannel = MethodChannel(_channelName);

  // Örnek AR verileri - Gerçek uygulamada API'den gelir
  static final Map<String, ARData> _mockARData = {
    // Ürün QR kodları
    'product_12345': ARData(
      id: 'product_12345',
      type: ARObjectType.product3D,
      title: 'Samsung Galaxy S24',
      description: '256GB Phantom Black - Son teknoloji akıllı telefon',
      metadata: {
        'price': '₺45.999',
        'rating': 4.8,
        'inStock': true,
        'brand': 'Samsung',
        'category': 'Smartphone',
      },
      modelUrl: 'https://example.com/models/samsung_s24.glb',
      imageUrl: 'https://example.com/images/samsung_s24.jpg',
      tags: ['telefon', 'samsung', 'teknoloji'],
    ),
    'product_67890': ARData(
      id: 'product_67890',
      type: ARObjectType.product3D,
      title: 'Apple iPhone 15 Pro',
      description: '512GB Titanyum - Pro fotoğraf ve video çekimi',
      metadata: {
        'price': '₺65.999',
        'rating': 4.9,
        'inStock': false,
        'brand': 'Apple',
        'category': 'Smartphone',
      },
      modelUrl: 'https://example.com/models/iphone_15_pro.glb',
      imageUrl: 'https://example.com/images/iphone_15_pro.jpg',
      tags: ['iphone', 'apple', 'pro'],
    ),

    // Mekan QR kodları
    'location_starbucks_001': ARData(
      id: 'location_starbucks_001',
      type: ARObjectType.locationInfo,
      title: 'Starbucks - Bağdat Caddesi',
      description:
          'Kahve deneyimini yaşayın! WiFi, çalışma alanı ve taze kahve.',
      metadata: {
        'openTime': '07:00',
        'closeTime': '23:00',
        'rating': 4.5,
        'hasWifi': true,
        'hasParking': false,
        'phone': '+90 216 123 4567',
        'address': 'Bağdat Caddesi No: 123, Kadıköy/İstanbul',
      },
      imageUrl: 'https://example.com/images/starbucks_interior.jpg',
      tags: ['kahve', 'wifi', 'çalışma'],
    ),
    'location_museum_001': ARData(
      id: 'location_museum_001',
      type: ARObjectType.locationInfo,
      title: 'İstanbul Arkeoloji Müzeleri',
      description: 'Tarihi eserler ve antik medeniyetlerin izlerini keşfedin.',
      metadata: {
        'openTime': '09:00',
        'closeTime': '17:00',
        'ticketPrice': '₺30',
        'studentDiscount': '₺15',
        'hasAudioGuide': true,
        'languages': ['TR', 'EN', 'DE', 'FR'],
        'estimatedVisitTime': '2-3 saat',
      },
      imageUrl: 'https://example.com/images/archaeology_museum.jpg',
      tags: ['müze', 'tarih', 'kültür'],
    ),
  };

  /// QR kod verisine göre AR bilgilerini getir
  static Future<ARResult> getARDataForQR(String qrData) async {
    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate API call

      // QR kod verisine göre AR verisi ara
      ARData? foundData;

      // Direkt ID eşleşmesi
      if (_mockARData.containsKey(qrData)) {
        foundData = _mockARData[qrData];
      } else {
        // Kısmi eşleşme ara (URL, barcode vb.)
        for (var entry in _mockARData.entries) {
          if (qrData.contains(entry.key) ||
              entry.value.tags?.any(
                    (tag) => qrData.toLowerCase().contains(tag.toLowerCase()),
                  ) ==
                  true) {
            foundData = entry.value;
            break;
          }
        }
      }

      if (foundData != null) {
        return ARResult(success: true, arData: foundData);
      } else {
        // Genel AR overlay oluştur
        foundData = ARData(
          id: 'generic_${DateTime.now().millisecondsSinceEpoch}',
          type: ARObjectType.textOverlay,
          title: 'QR Kod Bilgileri',
          description: 'Bu QR kod hakkında AR bilgisi mevcut değil.',
          metadata: {
            'qrData': qrData,
            'scannedAt': DateTime.now().toIso8601String(),
          },
        );
        return ARResult(success: true, arData: foundData);
      }
    } catch (e) {
      return ARResult(success: false, error: 'AR verisi yüklenirken hata: $e');
    }
  }

  /// AR oturumu başlat
  static Future<bool> startARSession() async {
    try {
      final result = await _methodChannel.invokeMethod('startARSession');
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('AR oturumu başlatılırken hata: ${e.message}');
      return false;
    }
  }

  /// AR oturumunu durdur
  static Future<void> stopARSession() async {
    try {
      await _methodChannel.invokeMethod('stopARSession');
    } on PlatformException catch (e) {
      debugPrint('AR oturumu durdurulurken hata: ${e.message}');
    }
  }

  /// AR objesi yerleştir
  static Future<bool> placeARObject(
    ARData arData,
    double x,
    double y,
    double z,
  ) async {
    try {
      final result = await _methodChannel.invokeMethod('placeARObject', {
        'id': arData.id,
        'type': arData.type.name,
        'title': arData.title,
        'description': arData.description,
        'modelUrl': arData.modelUrl,
        'imageUrl': arData.imageUrl,
        'x': x,
        'y': y,
        'z': z,
        'metadata': arData.metadata,
      });
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('AR objesi yerleştirilirken hata: ${e.message}');
      return false;
    }
  }

  /// Cihazın AR desteğini kontrol et
  static Future<bool> isARSupported() async {
    try {
      if (Platform.isIOS) {
        // iOS için ARKit kontrolü
        final result = await _methodChannel.invokeMethod('checkARKitSupport');
        return result == true;
      } else if (Platform.isAndroid) {
        // Android için ARCore kontrolü
        final result = await _methodChannel.invokeMethod('checkARCoreSupport');
        return result == true;
      }
      return false;
    } on PlatformException catch (e) {
      debugPrint('AR destek kontrolü hatası: ${e.message}');
      return false;
    }
  }

  /// AR kamera izinlerini kontrol et
  static Future<bool> checkARPermissions() async {
    try {
      final result = await _methodChannel.invokeMethod('checkARPermissions');
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('AR izin kontrolü hatası: ${e.message}');
      return false;
    }
  }

  /// AR izinlerini iste
  static Future<bool> requestARPermissions() async {
    try {
      final result = await _methodChannel.invokeMethod('requestARPermissions');
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('AR izin isteme hatası: ${e.message}');
      return false;
    }
  }

  /// AR overlay bilgileri güncelle
  static Future<void> updateAROverlay(
    String objectId,
    Map<String, dynamic> newData,
  ) async {
    try {
      await _methodChannel.invokeMethod('updateAROverlay', {
        'objectId': objectId,
        'data': newData,
      });
    } on PlatformException catch (e) {
      debugPrint('AR overlay güncelleme hatası: ${e.message}');
    }
  }

  /// AR screenshot al
  static Future<Uint8List?> captureARScreenshot() async {
    try {
      final result = await _methodChannel.invokeMethod('captureARScreenshot');
      return result as Uint8List?;
    } on PlatformException catch (e) {
      debugPrint('AR screenshot hatası: ${e.message}');
      return null;
    }
  }

  /// Yerleştirilen AR objelerini temizle
  static Future<void> clearAllARObjects() async {
    try {
      await _methodChannel.invokeMethod('clearAllARObjects');
    } on PlatformException catch (e) {
      debugPrint('AR objeler temizleme hatası: ${e.message}');
    }
  }

  /// AR performans istatistikleri al
  static Future<Map<String, dynamic>?> getARPerformanceStats() async {
    try {
      final result = await _methodChannel.invokeMethod('getARPerformanceStats');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      debugPrint('AR performans istatistik hatası: ${e.message}');
      return null;
    }
  }
}
