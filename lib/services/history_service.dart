import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  /// Geçmişi JSON olarak dışa aktar (cihazda dosyaya kaydetmek için)
  static Future<String> exportHistoryToJson() async {
    final history = await getHistory();
    final jsonList = history.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// Geçmişi JSON'dan içe aktar (cihazdan dosya seçerek geri yükleme için)
  static Future<void> importHistoryFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final history = jsonList
          .map((json) => HistoryItem.fromJson(json as Map<String, dynamic>))
          .toList();
      await _saveHistory(history);
    } catch (e) {
      // Hatalı dosya veya veri
      rethrow;
    }
  }

  static const String _historyKey = 'qr_history';

  /// Geçmişe yeni item ekle
  static Future<void> addToHistory({
    required String data,
    required String type,
    required bool isScanned,
    String? customName,
  }) async {
    final history = await getHistory();

    final newItem = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: data,
      type: type,
      date: DateTime.now(),
      isScanned: isScanned,
      customName: customName,
    );

    history.insert(0, newItem); // En yeniler başta

    // Maksimum 100 item tut
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }

    await _saveHistory(history);
  }

  /// Geçmişi getir
  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => HistoryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Hata durumunda veya uyumsuz veri formatında boş liste döndür
      // İsteğe bağlı: hatayı logla
      // print('Geçmiş verisi okunurken hata: $e');
      return [];
    }
  }

  /// Geçmişten item sil
  static Future<void> deleteHistoryItem(String id) async {
    final history = await getHistory();
    history.removeWhere((item) => item.id == id);
    await _saveHistory(history);
  }

  /// Tüm geçmişi temizle
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Geçmişi kaydet
  static Future<void> _saveHistory(List<HistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      history.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_historyKey, jsonString);
  }

  /// QR tip belirleme yardımcı fonksiyonu
  static String determineQRType(String data) {
    if (data.startsWith('WIFI:')) return 'WiFi';
    if (data.startsWith('http://') || data.startsWith('https://')) return 'URL';
    if (data.startsWith('tel:')) return 'Telefon';
    if (data.startsWith('mailto:')) return 'E-mail';
    if (data.startsWith('sms:')) return 'SMS';
    if (data.startsWith('geo:')) return 'Konum';
    if (data.startsWith('BEGIN:VCARD')) return 'Kartvizit';
    return 'Metin';
  }
}
