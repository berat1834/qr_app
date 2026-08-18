import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoryService Unit Testleri', () {
    setUp(() async {
      // Her test öncesi mock storage'ı temizle
      _mockStorage.clear();
    });

    group('HistoryItem Seri/Deseri', () {
      test('HistoryItem JSON\'a dönüştürülüyor mu?', () {
        final now = DateTime.now();
        final item = HistoryItem(
          id: '123',
          data: 'https://flutter.dev',
          type: 'URL',
          timestamp: now,
          isScanned: true,
        );

        final json = item.toJson();

        expect(json['id'], '123');
        expect(json['data'], 'https://flutter.dev');
        expect(json['type'], 'URL');
        expect(json['isScanned'], true);
        expect(json['timestamp'], now.toIso8601String());
      });

      test('JSON\'dan HistoryItem oluşturuluyor mu?', () {
        final json = {
          'id': '456',
          'data': 'WIFI:T:WPA;S:MyNetwork;P:Password;;',
          'type': 'WiFi',
          'timestamp': '2025-12-30T10:00:00.000Z',
          'isScanned': false,
        };

        final item = HistoryItem.fromJson(json);

        expect(item.id, '456');
        expect(item.data, 'WIFI:T:WPA;S:MyNetwork;P:Password;;');
        expect(item.type, 'WiFi');
        expect(item.isScanned, false);
      });

      test('HistoryItem round-trip dönüşümü başarılı mı?', () {
        final original = HistoryItem(
          id: 'test-id',
          data: 'Test data',
          type: 'Metin',
          timestamp: DateTime(2025, 12, 30, 10, 30),
          isScanned: true,
        );

        final json = original.toJson();
        final restored = HistoryItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.data, original.data);
        expect(restored.type, original.type);
        expect(restored.isScanned, original.isScanned);
      });
    });

    group('QR Tipi Belirleme', () {
      test('WiFi QR tipi tespit ediliyor mu?', () {
        final type = determineQRType('WIFI:T:WPA;S:MyWiFi;P:Pass;;');
        expect(type, 'WiFi');
      });

      test('URL QR tipi tespit ediliyor mu?', () {
        expect(determineQRType('https://flutter.dev'), 'URL');
        expect(determineQRType('http://example.com'), 'URL');
      });

      test('Telefon QR tipi tespit ediliyor mu?', () {
        final type = determineQRType('tel:+905551234567');
        expect(type, 'Telefon');
      });

      test('Email QR tipi tespit ediliyor mu?', () {
        final type = determineQRType('mailto:test@example.com');
        expect(type, 'E-mail');
      });

      test('SMS QR tipi tespit ediliyor mu?', () {
        final type = determineQRType('sms:+905551234567');
        expect(type, 'SMS');
      });

      test('Konum QR tipi tespit ediliyor mu?', () {
        final type = determineQRType('geo:40.7128,-74.0060');
        expect(type, 'Konum');
      });

      test('Kartvizit QR tipi tespit ediliyor mu?', () {
        final type = determineQRType('BEGIN:VCARD\nVERSION:3.0');
        expect(type, 'Kartvizit');
      });

      test('Bilinmeyen metin QR tipi tespit ediliyor mu?', () {
        final type = determineQRType('Basit metin');
        expect(type, 'Metin');
      });
    });

    group('Geçmiş İşlemleri', () {
      test('Yeni item geçmişe ekleniyor mu?', () async {
        await addToHistory(
          data: 'https://example.com',
          type: 'URL',
          isScanned: true,
        );

        final history = await getHistory();

        expect(history, isNotEmpty);
        expect(history[0].data, 'https://example.com');
        expect(history[0].type, 'URL');
        expect(history[0].isScanned, true);
      });

      test('Birden fazla item sıraya ekleniyor mu?', () async {
        await addToHistory(data: 'İlk item', type: 'Metin', isScanned: true);
        await addToHistory(
          data: 'İkinci item',
          type: 'Metin',
          isScanned: false,
        );

        final history = await getHistory();

        expect(history.length, 2);
        // En yeni başta olmalı
        expect(history[0].data, 'İkinci item');
        expect(history[1].data, 'İlk item');
      });

      test('Maksimum 100 item tutulabiliyor mu?', () async {
        // 101 item ekle
        for (int i = 0; i < 101; i++) {
          await addToHistory(data: 'Item $i', type: 'Metin', isScanned: true);
        }

        final history = await getHistory();

        // Maksimum 100 item tutulmalı
        expect(history.length, 100);
        // En eski item silinmiş olmalı
        expect(history[99].data, 'Item 1');
      });

      test('Geçmiş boş olduğunda doğru şekilde döndürülüyor mu?', () async {
        final history = await getHistory();
        expect(history, isEmpty);
      });

      test('Geçmiş tamamı temizleniyor mu?', () async {
        // Birkaç item ekle
        await addToHistory(data: 'Test 1', type: 'Metin', isScanned: true);
        await addToHistory(data: 'Test 2', type: 'Metin', isScanned: true);

        // Tümünü temizle
        await clearHistory();

        final history = await getHistory();
        expect(history, isEmpty);
      });

      test('Spesifik item silinebiliyor mu?', () async {
        // İki item ekle
        await addToHistory(data: 'Silinecek', type: 'Metin', isScanned: true);
        await addToHistory(data: 'Kalacak', type: 'Metin', isScanned: true);

        // İlk item'in ID'sini al
        var history = await getHistory();
        final firstItemId = history[1].id; // En eski item

        // Onu sil
        await deleteHistoryItem(firstItemId);

        // Kontrol et
        history = await getHistory();
        expect(history.length, 1);
        expect(history[0].data, 'Kalacak');
      });
    });

    group('Export/Import İşlemleri', () {
      test('Geçmiş JSON\'a dışa aktarılabiliyor mu?', () async {
        // Birkaç item ekle
        await addToHistory(
          data: 'https://flutter.dev',
          type: 'URL',
          isScanned: true,
        );
        await addToHistory(
          data: 'WIFI:T:WPA;S:WiFi;P:Pass;;',
          type: 'WiFi',
          isScanned: false,
        );

        final json = await exportHistoryToJson();

        expect(json, isNotEmpty);
        expect(json.contains('flutter.dev'), true);
        expect(json.contains('WiFi'), true);
      });

      test('Geçmiş JSON\'dan içe aktarılabiliyor mu?', () async {
        // Orijinal geçmiş ekle
        await addToHistory(
          data: 'Original data',
          type: 'Metin',
          isScanned: true,
        );

        // Dışa aktar
        final exported = await exportHistoryToJson();

        // Geçmişi temizle
        await clearHistory();
        var history = await getHistory();
        expect(history, isEmpty);

        // İçe aktar
        await importHistoryFromJson(exported);

        // Kontrol et
        history = await getHistory();
        expect(history, isNotEmpty);
        expect(history[0].data, 'Original data');
      });

      test('Hatalı JSON import\'da hata fırlatılıyor mu?', () async {
        final invalidJson = 'Bu geçerli JSON değil';

        expect(() => importHistoryFromJson(invalidJson), throwsException);
      });

      test('Export-Import round-trip başarılı mı?', () async {
        // Çeşitli tipler ekle
        await addToHistory(
          data: 'https://example.com',
          type: 'URL',
          isScanned: true,
        );
        await addToHistory(
          data: 'tel:+905551234567',
          type: 'Telefon',
          isScanned: false,
        );
        await addToHistory(
          data: 'mailto:test@example.com',
          type: 'E-mail',
          isScanned: true,
        );

        // Orijinal geçmişi al
        final original = await getHistory();

        // Dışa aktar
        final exported = await exportHistoryToJson();

        // Temizle ve içe aktar
        await clearHistory();
        await importHistoryFromJson(exported);

        // Yeni geçmişi al
        final restored = await getHistory();

        expect(restored.length, original.length);
        for (int i = 0; i < original.length; i++) {
          expect(restored[i].data, original[i].data);
          expect(restored[i].type, original[i].type);
          expect(restored[i].isScanned, original[i].isScanned);
        }
      });
    });

    group('Tarama vs Oluşturma Ayrımı', () {
      test('Tarama işlemi isScanned=true olarak kaydediliyor mu?', () async {
        await addToHistory(data: 'Taranmış QR', type: 'Metin', isScanned: true);

        final history = await getHistory();
        expect(history[0].isScanned, true);
      });

      test(
        'Oluşturma işlemi isScanned=false olarak kaydediliyor mu?',
        () async {
          await addToHistory(
            data: 'Oluşturulan QR',
            type: 'Metin',
            isScanned: false,
          );

          final history = await getHistory();
          expect(history[0].isScanned, false);
        },
      );

      test('Tarama ve oluşturma karışık olarak kaydediliyor mu?', () async {
        await addToHistory(data: 'Taranmış 1', type: 'Metin', isScanned: true);
        await addToHistory(
          data: 'Oluşturulan 1',
          type: 'Metin',
          isScanned: false,
        );
        await addToHistory(data: 'Taranmış 2', type: 'Metin', isScanned: true);

        final history = await getHistory();

        expect(history[0].isScanned, true);
        expect(history[1].isScanned, false);
        expect(history[2].isScanned, true);

        final scannedCount = history.where((item) => item.isScanned).length;
        final createdCount = history.where((item) => !item.isScanned).length;

        expect(scannedCount, 2);
        expect(createdCount, 1);
      });
    });

    group('Timestamp İşlemleri', () {
      test('Timestamp otomatik olarak ayarlanıyor mu?', () async {
        final beforeTime = DateTime.now();

        await addToHistory(
          data: 'Timestamp test',
          type: 'Metin',
          isScanned: true,
        );

        final afterTime = DateTime.now();
        final history = await getHistory();

        expect(history[0].timestamp.isBefore(beforeTime), false);
        expect(history[0].timestamp.isAfter(afterTime), false);
      });

      test('Birden fazla item farklı timestamp\'i var mı?', () async {
        await addToHistory(data: 'Birinci', type: 'Metin', isScanned: true);

        // Biraz bekle
        await Future.delayed(Duration(milliseconds: 10));

        await addToHistory(data: 'İkinci', type: 'Metin', isScanned: true);

        final history = await getHistory();

        expect(history[0].timestamp.isAfter(history[1].timestamp), true);
      });
    });

    group('ID Yönetimi', () {
      test('Her item benzersiz ID\'ye sahip mi?', () async {
        final ids = <String>{};

        for (int i = 0; i < 10; i++) {
          await addToHistory(data: 'Item $i', type: 'Metin', isScanned: true);
        }

        final history = await getHistory();
        for (var item in history) {
          ids.add(item.id);
        }

        // Tüm ID\'ler benzersiz olmalı
        expect(ids.length, 10);
      });

      test('ID silinmiş item silinebiliyor mu?', () async {
        await addToHistory(data: 'Item 1', type: 'Metin', isScanned: true);
        await addToHistory(data: 'Item 2', type: 'Metin', isScanned: true);

        final history = await getHistory();
        final itemToDelete = history[0];

        await deleteHistoryItem(itemToDelete.id);

        final newHistory = await getHistory();
        expect(newHistory.any((item) => item.id == itemToDelete.id), false);
      });
    });
  });
}

// Mock HistoryService fonksiyonları
class HistoryItem {
  final String id;
  final String data;
  final String type;
  final DateTime timestamp;
  final bool isScanned;

  HistoryItem({
    required this.id,
    required this.data,
    required this.type,
    required this.timestamp,
    required this.isScanned,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isScanned': isScanned,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      data: json['data'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      isScanned: json['isScanned'],
    );
  }
}

final Map<String, List<HistoryItem>> _mockStorage = {};

Future<void> addToHistory({
  required String data,
  required String type,
  required bool isScanned,
}) async {
  final history = await getHistory();

  final newItem = HistoryItem(
    id: '${DateTime.now().microsecondsSinceEpoch}-${history.length}',
    data: data,
    type: type,
    timestamp: DateTime.now(),
    isScanned: isScanned,
  );

  history.insert(0, newItem);

  if (history.length > 100) {
    history.removeRange(100, history.length);
  }

  _mockStorage['history'] = history;
}

Future<List<HistoryItem>> getHistory() async {
  return _mockStorage['history'] ?? [];
}

Future<void> deleteHistoryItem(String id) async {
  final history = await getHistory();
  history.removeWhere((item) => item.id == id);
  _mockStorage['history'] = history;
}

Future<void> clearHistory() async {
  _mockStorage['history'] = [];
}

Future<String> exportHistoryToJson() async {
  final history = await getHistory();
  final jsonList = history.map((item) => item.toJson()).toList();
  return jsonEncode(jsonList);
}

Future<void> importHistoryFromJson(String jsonString) async {
  try {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    final history = jsonList.map((json) => HistoryItem.fromJson(json)).toList();
    _mockStorage['history'] = history;
  } catch (e) {
    rethrow;
  }
}

String determineQRType(String data) {
  if (data.startsWith('WIFI:')) return 'WiFi';
  if (data.startsWith('http://') || data.startsWith('https://')) return 'URL';
  if (data.startsWith('tel:')) return 'Telefon';
  if (data.startsWith('mailto:')) return 'E-mail';
  if (data.startsWith('sms:')) return 'SMS';
  if (data.startsWith('geo:')) return 'Konum';
  if (data.startsWith('BEGIN:VCARD')) return 'Kartvizit';
  return 'Metin';
}
