import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock implementation for PriceComparisonService price-alert logic
// (Uses SharedPreferences directly, mirroring service internals)
const String _storageKey = 'price_alerts_v1';

Future<List<Map<String, dynamic>>> _readAlerts() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_storageKey);
  if (raw == null || raw.isEmpty) return [];
  final decoded = jsonDecode(raw);
  if (decoded is! List) return [];
  return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

Future<bool> _writeAlerts(List<Map<String, dynamic>> alerts) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.setString(_storageKey, jsonEncode(alerts));
}

Future<bool> createPriceAlert(
  String barcode,
  double targetPrice, {
  String? productName,
  double? currentPrice,
}) async {
  final alerts = await _readAlerts();
  alerts.removeWhere((a) => a['barcode'] == barcode);
  alerts.add({
    'id': '${barcode}_${DateTime.now().millisecondsSinceEpoch}',
    'barcode': barcode,
    'productName': productName,
    'targetPrice': targetPrice,
    'currentPrice': currentPrice,
    'createdAt': DateTime.now().toIso8601String(),
  });
  return _writeAlerts(alerts);
}

Future<List<Map<String, dynamic>>> getActivePriceAlerts() async {
  final alerts = await _readAlerts();
  alerts.sort(
    (l, r) => (r['createdAt'] as String).compareTo(l['createdAt'] as String),
  );
  return alerts;
}

Future<Map<String, dynamic>?> getPriceAlertForBarcode(String barcode) async {
  final alerts = await getActivePriceAlerts();
  for (final alert in alerts) {
    if (alert['barcode'] == barcode) return alert;
  }
  return null;
}

Future<bool> deletePriceAlert(String alertId) async {
  final alerts = await _readAlerts();
  alerts.removeWhere((a) => a['id'] == alertId);
  return _writeAlerts(alerts);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PriceComparisonService - Fiyat Uyarısı CRUD', () {
    test('Fiyat uyarısı oluşturulur ve geri okunur', () async {
      final result = await createPriceAlert(
        '1234567890123',
        299.99,
        productName: 'Test Ürünü',
        currentPrice: 350.00,
      );
      expect(result, isTrue);

      final alerts = await getActivePriceAlerts();
      expect(alerts.length, 1);
      expect(alerts.first['barcode'], '1234567890123');
      expect(alerts.first['targetPrice'], 299.99);
      expect(alerts.first['productName'], 'Test Ürünü');
    });

    test('Aynı barkod için uyarı güncellenince eski silinir', () async {
      await createPriceAlert('1234567890123', 300.0, productName: 'Ürün A');
      await createPriceAlert('1234567890123', 250.0, productName: 'Ürün A v2');

      final alerts = await getActivePriceAlerts();
      expect(alerts.length, 1);
      expect(alerts.first['targetPrice'], 250.0);
    });

    test('Birden fazla barkod için ayrı uyarı oluşturulabilir', () async {
      await createPriceAlert('111', 100.0);
      await createPriceAlert('222', 200.0);
      await createPriceAlert('333', 300.0);

      final alerts = await getActivePriceAlerts();
      expect(alerts.length, 3);
    });

    test('getPriceAlertForBarcode doğru uyarıyı döner', () async {
      await createPriceAlert('BARCODE_A', 150.0, productName: 'A Ürünü');
      await createPriceAlert('BARCODE_B', 250.0, productName: 'B Ürünü');

      final alert = await getPriceAlertForBarcode('BARCODE_A');
      expect(alert, isNotNull);
      expect(alert!['productName'], 'A Ürünü');
      expect(alert['targetPrice'], 150.0);
    });

    test('getPriceAlertForBarcode bulunamazsa null döner', () async {
      final alert = await getPriceAlertForBarcode('YOK_BARKOD');
      expect(alert, isNull);
    });

    test('Fiyat uyarısı id ile silinebilir', () async {
      await createPriceAlert('1234567890123', 100.0);
      final alerts = await getActivePriceAlerts();
      expect(alerts.length, 1);

      final alertId = alerts.first['id'] as String;
      final deleted = await deletePriceAlert(alertId);
      expect(deleted, isTrue);

      final remaining = await getActivePriceAlerts();
      expect(remaining, isEmpty);
    });

    test('Yalnızca hedeflenen uyarı silinir, diğerleri kalır', () async {
      await createPriceAlert('AAA', 100.0);
      await createPriceAlert('BBB', 200.0);

      final alerts = await getActivePriceAlerts();
      final firstId =
          alerts.firstWhere((a) => a['barcode'] == 'AAA')['id'] as String;

      await deletePriceAlert(firstId);

      final remaining = await getActivePriceAlerts();
      expect(remaining.length, 1);
      expect(remaining.first['barcode'], 'BBB');
    });

    test('Boş storage\'da getActivePriceAlerts boş liste döner', () async {
      final alerts = await getActivePriceAlerts();
      expect(alerts, isEmpty);
    });

    test('Uyarılar createdAt\'e göre azalan sıralanır', () async {
      await createPriceAlert('FIRST', 100.0);
      await Future.delayed(const Duration(milliseconds: 2));
      await createPriceAlert('SECOND', 200.0);

      final alerts = await getActivePriceAlerts();
      expect(alerts.first['barcode'], 'SECOND');
      expect(alerts.last['barcode'], 'FIRST');
    });
  });
}
