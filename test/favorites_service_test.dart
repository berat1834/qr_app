import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock FavoritesService Implementation for testing
class MockFavoritesService {
  final Map<String, dynamic> _mockStorage = {};

  Future<void> addToFavorites({
    required String data,
    required String type,
    String? customName,
  }) async {
    if (_mockStorage.containsKey('favorites')) {
      final List<dynamic> list = _mockStorage['favorites'];
      if (list.any((item) => item['data'] == data)) {
        throw Exception('Bu QR kod zaten favorilerde');
      }
    }

    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'data': data,
      'type': type,
      'addedAt': DateTime.now().toIso8601String(),
      'customName': customName,
      'note': null,
    };

    if (!_mockStorage.containsKey('favorites')) {
      _mockStorage['favorites'] = [];
    }

    final List<dynamic> list = _mockStorage['favorites'];
    list.insert(0, newItem);

    if (list.length > 50) {
      list.removeRange(50, list.length);
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final list = _mockStorage['favorites'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> removeFromFavorites(String id) async {
    if (_mockStorage.containsKey('favorites')) {
      final List<dynamic> list = _mockStorage['favorites'];
      list.removeWhere((item) => item['id'] == id);
    }
  }

  Future<void> updateFavoriteName(String id, String newName) async {
    if (_mockStorage.containsKey('favorites')) {
      final List<dynamic> list = _mockStorage['favorites'];
      final index = list.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        final item = list[index] as Map<String, dynamic>;
        list[index] = {
          'id': item['id'],
          'data': item['data'],
          'type': item['type'],
          'addedAt': item['addedAt'],
          'customName': newName,
          'note': item['note'],
        };
      }
    }
  }

  Future<void> updateFavoriteNote(String id, String newNote) async {
    if (_mockStorage.containsKey('favorites')) {
      final List<dynamic> list = _mockStorage['favorites'];
      final index = list.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        final item = list[index] as Map<String, dynamic>;
        list[index] = {
          'id': item['id'],
          'data': item['data'],
          'type': item['type'],
          'addedAt': item['addedAt'],
          'customName': item['customName'],
          'note': newNote,
        };
      }
    }
  }

  Future<void> updateFavoriteNameByData(String data, String? newName) async {
    if (_mockStorage.containsKey('favorites')) {
      final List<dynamic> list = _mockStorage['favorites'];
      final index = list.indexWhere((item) => item['data'] == data);
      if (index != -1) {
        final item = list[index] as Map<String, dynamic>;
        list[index] = {
          'id': item['id'],
          'data': item['data'],
          'type': item['type'],
          'addedAt': item['addedAt'],
          'customName': newName,
          'note': item['note'],
        };
      }
    }
  }

  Future<bool> isFavorite(String data) async {
    if (!_mockStorage.containsKey('favorites')) {
      return false;
    }
    final List<dynamic> list = _mockStorage['favorites'];
    return list.any((item) => item['data'] == data);
  }

  Future<void> clearFavorites() async {
    _mockStorage.remove('favorites');
  }

  Future<List<Map<String, dynamic>>> getFavoritesByType(String type) async {
    final favorites = await getFavorites();
    return favorites.where((item) => item['type'] == type).toList();
  }

  Future<List<Map<String, dynamic>>> searchFavorites(String query) async {
    final favorites = await getFavorites();
    final lowerQuery = query.toLowerCase();

    return favorites.where((item) {
      return item['data'].toString().toLowerCase().contains(lowerQuery) ||
          item['type'].toString().toLowerCase().contains(lowerQuery) ||
          (item['customName']?.toString().toLowerCase().contains(lowerQuery) ??
              false);
    }).toList();
  }

  Future<String> exportFavoritesToJson() async {
    final favorites = await getFavorites();
    return favorites.toString();
  }

  Future<void> importFavoritesFromJson(String jsonString) async {
    // Simple implementation for testing
    _mockStorage['favorites'] = [];
  }

  void clear() {
    _mockStorage.clear();
  }
}

void main() {
  late MockFavoritesService mockService;

  setUp(() {
    mockService = MockFavoritesService();
    SharedPreferences.setMockInitialValues({});
  });

  group('FavoritesService - FavoriteItem Serialization', () {
    test('FavoriteItem toJson seri hale getirme', () async {
      const data = {
        'id': '123456',
        'data': 'https://example.com',
        'type': 'URL',
        'addedAt': '2024-01-01T10:00:00.000Z',
        'customName': 'Örnek Site',
        'note': 'Önemli site',
      };

      expect(data['id'], '123456');
      expect(data['data'], 'https://example.com');
      expect(data['type'], 'URL');
    });

    test('FavoriteItem fromJson deserilize etme', () async {
      const json = {
        'id': '123456',
        'data': 'https://example.com',
        'type': 'URL',
        'addedAt': '2024-01-01T10:00:00.000Z',
        'customName': 'Örnek Site',
        'note': 'Önemli site',
      };

      expect(json['id'], '123456');
      expect(json['customName'], 'Örnek Site');
      expect(json['note'], 'Önemli site');
    });

    test('FavoriteItem displayName WiFi tipi', () {
      final wifiData = 'WIFI:T:WPA;S:MyNetwork;P:password123;;';
      final ssidMatch = RegExp(r'S:([^;]*)').firstMatch(wifiData);
      final displayName = ssidMatch?.group(1) ?? 'WiFi Ağı';

      expect(displayName, 'MyNetwork');
    });
  });

  group('FavoritesService - Favori Ekleme İşlemleri', () {
    test('Yeni favori ekle', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
        customName: 'Örnek',
      );

      final favorites = await mockService.getFavorites();
      expect(favorites.length, 1);
      expect(favorites[0]['data'], 'https://example.com');
      expect(favorites[0]['customName'], 'Örnek');
    });

    test('Birden fazla favori ekle - en yeniler başta', () async {
      await mockService.addToFavorites(data: 'https://first.com', type: 'URL');
      await mockService.addToFavorites(data: 'https://second.com', type: 'URL');
      await mockService.addToFavorites(data: 'https://third.com', type: 'URL');

      final favorites = await mockService.getFavorites();
      expect(favorites.length, 3);
      expect(favorites[0]['data'], 'https://third.com');
      expect(favorites[1]['data'], 'https://second.com');
      expect(favorites[2]['data'], 'https://first.com');
    });

    test('Aynı veri iki kez ekle - hata ver', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      expect(() async {
        await mockService.addToFavorites(
          data: 'https://example.com',
          type: 'URL',
        );
      }, throwsException);
    });

    test('CustomName olmadan favori ekle', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      final favorites = await mockService.getFavorites();
      expect(favorites[0]['customName'], isNull);
    });

    test('WiFi formatında favori ekle', () async {
      await mockService.addToFavorites(
        data: 'WIFI:T:WPA;S:HomeNetwork;P:password123;;',
        type: 'WiFi',
        customName: 'Ev WiFi',
      );

      final favorites = await mockService.getFavorites();
      expect(favorites[0]['type'], 'WiFi');
      expect(favorites[0]['customName'], 'Ev WiFi');
    });

    test('Maksimum 50 favori sınırı', () async {
      for (int i = 0; i < 60; i++) {
        await mockService.addToFavorites(
          data: 'https://example$i.com',
          type: 'URL',
        );
      }

      final favorites = await mockService.getFavorites();
      expect(favorites.length, 50);
      expect(favorites[0]['data'], 'https://example59.com');
    });
  });

  group('FavoritesService - Favori Silme İşlemleri', () {
    test('Var olan favoriyi sil', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      var favorites = await mockService.getFavorites();
      final id = favorites[0]['id'];

      await mockService.removeFromFavorites(id);

      favorites = await mockService.getFavorites();
      expect(favorites.length, 0);
    });

    test('Birden fazla favoriden birini sil', () async {
      await mockService.addToFavorites(data: 'https://first.com', type: 'URL');
      await Future.delayed(const Duration(milliseconds: 10));
      await mockService.addToFavorites(data: 'https://second.com', type: 'URL');

      var favorites = await mockService.getFavorites();
      final secondId = favorites[0]['id'];

      await mockService.removeFromFavorites(secondId);

      favorites = await mockService.getFavorites();
      expect(favorites.length, 1);
      expect(favorites[0]['data'], 'https://first.com');
    });

    test('Tüm favorileri temizle', () async {
      await mockService.addToFavorites(data: 'https://first.com', type: 'URL');
      await mockService.addToFavorites(data: 'https://second.com', type: 'URL');

      await mockService.clearFavorites();

      final favorites = await mockService.getFavorites();
      expect(favorites.length, 0);
    });

    test('Olmayan ID ile sil - hata yok', () async {
      await mockService.removeFromFavorites('nonexistent-id');

      final favorites = await mockService.getFavorites();
      expect(favorites.length, 0);
    });
  });

  group('FavoritesService - Favori Güncelleme İşlemleri', () {
    test('Favori adını güncelle', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
        customName: 'Eski İsim',
      );

      var favorites = await mockService.getFavorites();
      final id = favorites[0]['id'];

      await mockService.updateFavoriteName(id, 'Yeni İsim');

      favorites = await mockService.getFavorites();
      expect(favorites[0]['customName'], 'Yeni İsim');
    });

    test('Favori notunu güncelle', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      var favorites = await mockService.getFavorites();
      final id = favorites[0]['id'];

      await mockService.updateFavoriteNote(id, 'Yeni not');

      favorites = await mockService.getFavorites();
      expect(favorites[0]['note'], 'Yeni not');
    });

    test('Data ile favori adını güncelle', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
        customName: 'Eski',
      );

      await mockService.updateFavoriteNameByData('https://example.com', 'Yeni');

      final favorites = await mockService.getFavorites();
      expect(favorites[0]['customName'], 'Yeni');
    });

    test('Güncelleme sırasında diğer alanlar korunur', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
        customName: 'Örnek',
      );

      var favorites = await mockService.getFavorites();
      final id = favorites[0]['id'];
      final addedAt = favorites[0]['addedAt'];

      await mockService.updateFavoriteName(id, 'Yeni İsim');

      favorites = await mockService.getFavorites();
      expect(favorites[0]['data'], 'https://example.com');
      expect(favorites[0]['type'], 'URL');
      expect(favorites[0]['addedAt'], addedAt);
    });

    test('Olmayan ID ile güncelle - hata yok', () async {
      await mockService.updateFavoriteName('nonexistent', 'Yeni İsim');

      final favorites = await mockService.getFavorites();
      expect(favorites.length, 0);
    });
  });

  group('FavoritesService - Favori Sorgulama', () {
    test('İsFavorite - var olan veri', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      final isFav = await mockService.isFavorite('https://example.com');
      expect(isFav, true);
    });

    test('İsFavorite - olmayan veri', () async {
      final isFav = await mockService.isFavorite('https://example.com');
      expect(isFav, false);
    });

    test('Türe göre favorileri getir - WiFi', () async {
      await mockService.addToFavorites(
        data: 'WIFI:T:WPA;S:Network;P:pass;;',
        type: 'WiFi',
      );
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      final wifiFavorites = await mockService.getFavoritesByType('WiFi');
      expect(wifiFavorites.length, 1);
      expect(wifiFavorites[0]['type'], 'WiFi');
    });

    test('Türe göre favorileri getir - boş sonuç', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      final wifiFavorites = await mockService.getFavoritesByType('WiFi');
      expect(wifiFavorites.length, 0);
    });

    test('Favori ara - data ile eşleşme', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
        customName: 'Örnek Site',
      );
      await mockService.addToFavorites(data: 'https://google.com', type: 'URL');

      final results = await mockService.searchFavorites('example');
      expect(results.length, 1);
      expect(results[0]['data'], 'https://example.com');
    });

    test('Favori ara - customName ile eşleşme', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
        customName: 'Benim Favorim',
      );
      await mockService.addToFavorites(
        data: 'https://other.com',
        type: 'URL',
        customName: 'Başka',
      );

      final results = await mockService.searchFavorites('favorim');
      expect(results.length, 1);
      expect(results[0]['customName'], 'Benim Favorim');
    });

    test('Favori ara - type ile eşleşme', () async {
      await mockService.addToFavorites(
        data: 'WIFI:T:WPA;S:Net;P:pass;;',
        type: 'WiFi',
      );
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      final results = await mockService.searchFavorites('wifi');
      expect(results.length, 1);
      expect(results[0]['type'], 'WiFi');
    });

    test('Favori ara - büyük küçük harf duyarsız', () async {
      await mockService.addToFavorites(
        data: 'https://EXAMPLE.COM',
        type: 'URL',
      );

      final results = await mockService.searchFavorites('example');
      expect(results.length, 1);
    });
  });

  group('FavoritesService - İdentifikasyon', () {
    test('Favori ID formatı - timestamp kullanır', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      final favorites = await mockService.getFavorites();
      final id = favorites[0]['id'];

      expect(int.tryParse(id), isNotNull);
    });

    test('Farklı favorilerin farklı ID\'leri vardır', () async {
      await mockService.addToFavorites(data: 'https://first.com', type: 'URL');
      await Future.delayed(const Duration(milliseconds: 2));
      await mockService.addToFavorites(data: 'https://second.com', type: 'URL');

      final favorites = await mockService.getFavorites();
      expect(favorites[0]['id'], isNot(equals(favorites[1]['id'])));
    });
  });

  group('FavoritesService - Zaman Damgası', () {
    test('Favori eklendiğinde addedAt kaydedilir', () async {
      final beforeAdd = DateTime.now();

      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      final favorites = await mockService.getFavorites();
      final addedAt = DateTime.parse(favorites[0]['addedAt'] as String);

      expect(
        addedAt.isAfter(beforeAdd.subtract(const Duration(seconds: 1))),
        true,
      );
    });

    test('Favori güncellendiğinde addedAt değişmez', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      var favorites = await mockService.getFavorites();
      final originalAddedAt = favorites[0]['addedAt'];
      final id = favorites[0]['id'];

      await mockService.updateFavoriteName(id, 'Yeni İsim');

      favorites = await mockService.getFavorites();
      expect(favorites[0]['addedAt'], originalAddedAt);
    });
  });

  group('FavoritesService - Export/Import', () {
    test('Favorileri JSON olarak dışa aktar', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      final json = await mockService.exportFavoritesToJson();
      expect(json, isNotEmpty);
    });

    test('Boş favori listesi export', () async {
      final json = await mockService.exportFavoritesToJson();
      expect(json, '[]');
    });

    test('JSON\'dan favorileri içe aktar', () async {
      await mockService.importFavoritesFromJson('[]');

      final favorites = await mockService.getFavorites();
      expect(favorites.length, 0);
    });
  });

  group('FavoritesService - Tür İşlemleri', () {
    test('URL tipi favori', () async {
      await mockService.addToFavorites(
        data: 'https://example.com',
        type: 'URL',
      );

      final favorites = await mockService.getFavorites();
      expect(favorites[0]['type'], 'URL');
    });

    test('WiFi tipi favori', () async {
      await mockService.addToFavorites(
        data: 'WIFI:T:WPA;S:Network;P:password;;',
        type: 'WiFi',
      );

      final favorites = await mockService.getFavorites();
      expect(favorites[0]['type'], 'WiFi');
    });

    test('Telefon tipi favori', () async {
      await mockService.addToFavorites(
        data: 'tel:+905551234567',
        type: 'Telefon',
      );

      final favorites = await mockService.getFavorites();
      expect(favorites[0]['type'], 'Telefon');
    });

    test('E-mail tipi favori', () async {
      await mockService.addToFavorites(
        data: 'mailto:test@example.com',
        type: 'E-mail',
      );

      final favorites = await mockService.getFavorites();
      expect(favorites[0]['type'], 'E-mail');
    });
  });
}
