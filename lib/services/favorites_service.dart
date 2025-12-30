import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteItem {
  final String id;
  final String data;
  final String type;
  final DateTime addedAt;
  final String? customName; // Kullanıcı özel adı
  final String? note; // Ekstra not

  FavoriteItem({
    required this.id,
    required this.data,
    required this.type,
    required this.addedAt,
    this.customName,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'type': type,
      'addedAt': addedAt.toIso8601String(),
      'customName': customName,
      'note': note,
    };
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'],
      data: json['data'],
      type: json['type'],
      addedAt: DateTime.parse(json['addedAt']),
      customName: json['customName'],
      note: json['note'],
    );
  }

  String get displayName {
    if (customName != null && customName!.isNotEmpty) {
      return customName!;
    }

    // QR türüne göre otomatik isim
    switch (type) {
      case 'WiFi':
        final ssidMatch = RegExp(r'S:([^;]*)').firstMatch(data);
        return ssidMatch?.group(1) ?? 'WiFi Ağı';
      case 'URL':
        final uri = Uri.tryParse(data);
        return uri?.host ?? 'Web Sitesi';
      case 'Telefon':
        return data.replaceFirst('tel:', '');
      case 'E-mail':
        return data.replaceFirst('mailto:', '');
      default:
        return data.length > 30 ? '${data.substring(0, 30)}...' : data;
    }
  }
}

class FavoritesService {
  /// Favorileri JSON olarak dışa aktar (cihazda dosyaya kaydetmek için)
  static Future<String> exportFavoritesToJson() async {
    final favorites = await getFavorites();
    final jsonList = favorites.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// Favorileri JSON'dan içe aktar (cihazdan dosya seçerek geri yükleme için)
  static Future<void> importFavoritesFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final favorites = jsonList
          .map((json) => FavoriteItem.fromJson(json))
          .toList();
      await _saveFavorites(List<FavoriteItem>.from(favorites));
    } catch (e) {
      // Hatalı dosya veya veri
      rethrow;
    }
  }

  /// Favori notunu güncelle
  static Future<void> updateFavoriteNote(String id, String newNote) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((item) => item.id == id);
    if (index != -1) {
      final oldItem = favorites[index];
      final updatedItem = FavoriteItem(
        id: oldItem.id,
        data: oldItem.data,
        type: oldItem.type,
        addedAt: oldItem.addedAt,
        customName: oldItem.customName,
        note: newNote,
      );
      favorites[index] = updatedItem;
      await _saveFavorites(favorites);
    }
  }

  /// data ile favori notunu güncelle
  static Future<void> updateFavoriteNameByData(
    String data,
    String? newName,
  ) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((item) => item.data == data);
    if (index != -1) {
      final oldItem = favorites[index];
      final updatedItem = FavoriteItem(
        id: oldItem.id,
        data: oldItem.data,
        type: oldItem.type,
        addedAt: oldItem.addedAt,
        customName: newName,
      );
      favorites[index] = updatedItem;
      await _saveFavorites(favorites);
    }
  }

  static const String _favoritesKey = 'qr_favorites';

  /// Favorilere ekle
  static Future<void> addToFavorites({
    required String data,
    required String type,
    String? customName,
  }) async {
    final favorites = await getFavorites();

    // Aynı veri zaten favorilerde mi kontrol et
    if (favorites.any((item) => item.data == data)) {
      throw Exception('Bu QR kod zaten favorilerde');
    }

    final newItem = FavoriteItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: data,
      type: type,
      addedAt: DateTime.now(),
      customName: customName,
    );

    favorites.insert(0, newItem); // En yeniler başta

    // Maksimum 50 favori tut
    if (favorites.length > 50) {
      favorites.removeRange(50, favorites.length);
    }

    await _saveFavorites(favorites);
  }

  /// Favorileri getir
  static Future<List<FavoriteItem>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => FavoriteItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Favorilerden sil
  static Future<void> removeFromFavorites(String id) async {
    final favorites = await getFavorites();
    favorites.removeWhere((item) => item.id == id);
    await _saveFavorites(favorites);
  }

  /// Favori adını güncelle
  static Future<void> updateFavoriteName(String id, String newName) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((item) => item.id == id);

    if (index != -1) {
      final oldItem = favorites[index];
      final updatedItem = FavoriteItem(
        id: oldItem.id,
        data: oldItem.data,
        type: oldItem.type,
        addedAt: oldItem.addedAt,
        customName: newName,
      );

      favorites[index] = updatedItem;
      await _saveFavorites(favorites);
    }
  }

  /// Favorilerde mi kontrol et
  static Future<bool> isFavorite(String data) async {
    final favorites = await getFavorites();
    return favorites.any((item) => item.data == data);
  }

  /// Tüm favorileri temizle
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }

  /// Favorileri kaydet
  static Future<void> _saveFavorites(List<FavoriteItem> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      favorites.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_favoritesKey, jsonString);
  }

  /// Favorileri türe göre filtrele
  static Future<List<FavoriteItem>> getFavoritesByType(String type) async {
    final favorites = await getFavorites();
    return favorites.where((item) => item.type == type).toList();
  }

  /// Favorileri arama
  static Future<List<FavoriteItem>> searchFavorites(String query) async {
    final favorites = await getFavorites();
    final lowerQuery = query.toLowerCase();

    return favorites.where((item) {
      return item.data.toLowerCase().contains(lowerQuery) ||
          item.type.toLowerCase().contains(lowerQuery) ||
          (item.customName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
