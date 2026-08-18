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
    String? category,
  }) async {
    final history = await getHistory();

    final newItem = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: data,
      type: type,
      date: DateTime.now(),
      isScanned: isScanned,
      customName: customName,
      category: category,
      isArchived: false,
    );

    history.insert(0, newItem); // En yeniler başta

    // Maksimum 1000 item tut (Kullanıcı verisi kaybını en aza indirir)
    if (history.length > 1000) {
      history.removeRange(1000, history.length);
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

  /// Kayıt öğesinin özel ismini güncelle
  static Future<void> updateCustomName(String id, String? newName) async {
    final history = await getHistory();
    final index = history.indexWhere((item) => item.id == id);

    if (index != -1) {
      final oldItem = history[index];
      final updatedItem = HistoryItem(
        id: oldItem.id,
        data: oldItem.data,
        type: oldItem.type,
        date: oldItem.date,
        isScanned: oldItem.isScanned,
        isArchived: oldItem.isArchived,
        category: oldItem.category,
        customName: newName?.isEmpty ?? true ? null : newName,
      );
      history[index] = updatedItem;
      await _saveHistory(history);
    }
  }

  /// Seçili kayıtlar için toplu isim güncelle
  static Future<void> updateCustomNameForIds(
    Set<String> ids,
    String? newName,
  ) async {
    if (ids.isEmpty) return;

    final history = await getHistory();
    final normalizedName = newName?.isEmpty ?? true ? null : newName;

    for (var i = 0; i < history.length; i++) {
      final item = history[i];
      if (!ids.contains(item.id)) continue;

      history[i] = HistoryItem(
        id: item.id,
        data: item.data,
        type: item.type,
        date: item.date,
        isScanned: item.isScanned,
        isArchived: item.isArchived,
        category: item.category,
        customName: normalizedName,
      );
    }

    await _saveHistory(history);
  }

  /// Kayıt öğesini arşivle/geri al
  static Future<void> setArchived(String id, bool archived) async {
    final history = await getHistory();
    final index = history.indexWhere((item) => item.id == id);

    if (index != -1) {
      final item = history[index];
      history[index] = HistoryItem(
        id: item.id,
        data: item.data,
        type: item.type,
        date: item.date,
        isScanned: item.isScanned,
        customName: item.customName,
        category: item.category,
        isArchived: archived,
      );
      await _saveHistory(history);
    }
  }

  /// Seçili kayıtlar için toplu arşivleme
  static Future<void> setArchivedForIds(Set<String> ids, bool archived) async {
    if (ids.isEmpty) return;
    final history = await getHistory();

    for (var i = 0; i < history.length; i++) {
      final item = history[i];
      if (!ids.contains(item.id)) continue;
      history[i] = HistoryItem(
        id: item.id,
        data: item.data,
        type: item.type,
        date: item.date,
        isScanned: item.isScanned,
        customName: item.customName,
        category: item.category,
        isArchived: archived,
      );
    }

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

  /// Kategori güncelle (tek item)
  static Future<void> updateCategory(String id, String? category) async {
    final history = await getHistory();
    final updatedHistory = history.map((item) {
      if (item.id == id) {
        return HistoryItem(
          id: item.id,
          data: item.data,
          type: item.type,
          date: item.date,
          customName: item.customName,
          category: category,
          isScanned: item.isScanned,
          isArchived: item.isArchived,
        );
      }
      return item;
    }).toList();
    await _saveHistory(updatedHistory);
  }

  /// Kategori güncelle (çoklu)
  static Future<void> updateCategoryForIds(
    Set<String> ids,
    String? category,
  ) async {
    final history = await getHistory();
    final updatedHistory = history.map((item) {
      if (ids.contains(item.id)) {
        return HistoryItem(
          id: item.id,
          data: item.data,
          type: item.type,
          date: item.date,
          customName: item.customName,
          category: category,
          isScanned: item.isScanned,
          isArchived: item.isArchived,
        );
      }
      return item;
    }).toList();
    await _saveHistory(updatedHistory);
  }

  /// Mevcut kategorileri getir
  static Future<List<String>> getUsedCategories() async {
    final history = await getHistory();
    final categories = history
        .where((item) => item.category != null && item.category!.isNotEmpty)
        .map((item) => item.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  /// Önerilen kategoriler
  static List<String> getSuggestedCategories() {
    return [
      'İş',
      'Kişisel',
      'Faturalar',
      'WiFi Şifreleri',
      'İletişim',
      'Belgeler',
      'Alışveriş',
      'Seyahat',
      'Sağlık',
      'Eğitim',
    ];
  }
}
