import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PriceSource {
  trendyol,
  hepsiburada,
  n11,
  gittigidiyor,
  amazon,
  sahibinden,
  ciceksepeti,
  morhipo,
}

class ProductInfo {
  final String name;
  final String brand;
  final String category;
  final String? description;
  final String? imageUrl;
  final Map<String, dynamic> attributes;

  ProductInfo({
    required this.name,
    required this.brand,
    required this.category,
    this.description,
    this.imageUrl,
    required this.attributes,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      attributes: json['attributes'] ?? {},
    );
  }
}

class PriceInfo {
  final PriceSource source;
  final String sourceName;
  final double price;
  final String currency;
  final String productUrl;
  final bool inStock;
  final String? seller;
  final double? originalPrice;
  final int? discountPercentage;
  final double? rating;
  final int? reviewCount;
  final String? deliveryInfo;
  final DateTime lastUpdated;

  PriceInfo({
    required this.source,
    required this.sourceName,
    required this.price,
    required this.currency,
    required this.productUrl,
    required this.inStock,
    this.seller,
    this.originalPrice,
    this.discountPercentage,
    this.rating,
    this.reviewCount,
    this.deliveryInfo,
    required this.lastUpdated,
  });

  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      source: PriceSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => PriceSource.trendyol,
      ),
      sourceName: json['sourceName'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'TRY',
      productUrl: json['productUrl'] ?? '',
      inStock: json['inStock'] ?? false,
      seller: json['seller'],
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountPercentage: json['discountPercentage'],
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'],
      deliveryInfo: json['deliveryInfo'],
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class PriceComparisonResult {
  final bool success;
  final ProductInfo? productInfo;
  final List<PriceInfo> prices;
  final String? error;
  final String? barcode;
  final PriceInfo? lowestPrice;
  final PriceInfo? highestPrice;
  final double? averagePrice;

  PriceComparisonResult({
    required this.success,
    this.productInfo,
    required this.prices,
    this.error,
    this.barcode,
    this.lowestPrice,
    this.highestPrice,
    this.averagePrice,
  });
}

class PriceComparisonService {
  static const String _channelName = 'qr_app/price_comparison';
  static const MethodChannel _methodChannel = MethodChannel(_channelName);
  static const Duration _cacheTimeout = Duration(hours: 1);
  static final Map<String, PriceComparisonResult> _cache = {};

  /// Barkod ile fiyat karşılaştırması yap
  static Future<PriceComparisonResult> compareProductPrices(
    String barcode,
  ) async {
    try {
      // Cache kontrolü
      if (_cache.containsKey(barcode)) {
        final cachedResult = _cache[barcode]!;
        final cacheAge = DateTime.now().difference(
          cachedResult.prices.first.lastUpdated,
        );
        if (cacheAge < _cacheTimeout) {
          return cachedResult;
        }
      }

      // Ürün bilgisini al
      final productInfo = await _getProductInfo(barcode);
      if (productInfo == null) {
        return PriceComparisonResult(
          success: false,
          prices: [],
          error: 'Ürün bilgisi bulunamadı',
          barcode: barcode,
        );
      }

      // Fiyat bilgilerini paralel olarak çek
      final futures = <Future<PriceInfo?>>[];
      for (final source in PriceSource.values) {
        futures.add(_getPriceFromSource(source, barcode, productInfo));
      }

      final results = await Future.wait(futures);
      final prices = results
          .where((price) => price != null)
          .cast<PriceInfo>()
          .toList();

      if (prices.isEmpty) {
        return PriceComparisonResult(
          success: false,
          productInfo: productInfo,
          prices: [],
          error: 'Hiçbir sitede fiyat bulunamadı',
          barcode: barcode,
        );
      }

      // Fiyatları sırala
      prices.sort((a, b) => a.price.compareTo(b.price));

      final lowestPrice = prices.first;
      final highestPrice = prices.last;
      final averagePrice =
          prices.map((p) => p.price).reduce((a, b) => a + b) / prices.length;

      final result = PriceComparisonResult(
        success: true,
        productInfo: productInfo,
        prices: prices,
        barcode: barcode,
        lowestPrice: lowestPrice,
        highestPrice: highestPrice,
        averagePrice: averagePrice,
      );

      // Cache'e kaydet
      _cache[barcode] = result;

      return result;
    } catch (e) {
      return PriceComparisonResult(
        success: false,
        prices: [],
        error: 'Fiyat karşılaştırma hatası: $e',
        barcode: barcode,
      );
    }
  }

  /// Ürün bilgisini barkoddan al
  static Future<ProductInfo?> _getProductInfo(String barcode) async {
    try {
      // Mock data - gerçek uygulamada bir ürün veritabanı API'si kullanılır
      await Future.delayed(const Duration(milliseconds: 500));

      final mockProducts = {
        '8690504000001': ProductInfo(
          name: 'Samsung Galaxy S24 256GB',
          brand: 'Samsung',
          category: 'Akıllı Telefon',
          description:
              'Son teknoloji kamera ve işlemci ile donatılmış premium akıllı telefon',
          imageUrl: 'https://example.com/samsung-s24.jpg',
          attributes: {
            'model': 'Galaxy S24',
            'storage': '256GB',
            'color': 'Phantom Black',
            'warranty': '2 Yıl',
          },
        ),
        '8690504000002': ProductInfo(
          name: 'Apple iPhone 15 Pro 512GB',
          brand: 'Apple',
          category: 'Akıllı Telefon',
          description:
              'Pro kamera sistemi ve A17 Pro çip ile güçlendirilmiş iPhone',
          imageUrl: 'https://example.com/iphone-15-pro.jpg',
          attributes: {
            'model': 'iPhone 15 Pro',
            'storage': '512GB',
            'color': 'Titanyum',
            'warranty': '1 Yıl',
          },
        ),
        '8690504000003': ProductInfo(
          name: 'Sony WH-1000XM5 Bluetooth Kulaklık',
          brand: 'Sony',
          category: 'Kulaklık',
          description:
              'Gelişmiş gürültü engelleme teknolojisi ile premium kulaklık',
          imageUrl: 'https://example.com/sony-wh1000xm5.jpg',
          attributes: {
            'model': 'WH-1000XM5',
            'type': 'Over-ear',
            'connectivity': 'Bluetooth 5.2',
            'battery': '30 saat',
          },
        ),
      };

      return mockProducts[barcode];
    } catch (e) {
      debugPrint('Ürün bilgisi alma hatası: $e');
      return null;
    }
  }

  /// Belirli bir kaynaktan fiyat bilgisi al
  static Future<PriceInfo?> _getPriceFromSource(
    PriceSource source,
    String barcode,
    ProductInfo product,
  ) async {
    try {
      await Future.delayed(
        Duration(milliseconds: 300 + (source.index * 100)),
      ); // Simulate API delay

      // Mock fiyat verileri
      final mockPrices = {
        PriceSource.trendyol: {
          '8690504000001': 45999.0,
          '8690504000002': 65999.0,
          '8690504000003': 8499.0,
        },
        PriceSource.hepsiburada: {
          '8690504000001': 46499.0,
          '8690504000002': 66999.0,
          '8690504000003': 8799.0,
        },
        PriceSource.n11: {
          '8690504000001': 44999.0,
          '8690504000002': 64999.0,
          '8690504000003': 8299.0,
        },
        PriceSource.amazon: {
          '8690504000001': 47999.0,
          '8690504000002': 67999.0,
          '8690504000003': 8999.0,
        },
      };

      final sourceNames = {
        PriceSource.trendyol: 'Trendyol',
        PriceSource.hepsiburada: 'Hepsiburada',
        PriceSource.n11: 'N11',
        PriceSource.gittigidiyor: 'GittiGidiyor',
        PriceSource.amazon: 'Amazon',
        PriceSource.sahibinden: 'Sahibinden',
        PriceSource.ciceksepeti: 'Çiçeksepeti',
        PriceSource.morhipo: 'Morhipo',
      };

      final price = mockPrices[source]?[barcode];
      if (price == null) return null;

      return PriceInfo(
        source: source,
        sourceName: sourceNames[source] ?? source.name,
        price: price,
        currency: 'TRY',
        productUrl: 'https://${source.name}.com/product/$barcode',
        inStock: true,
        seller: sourceNames[source],
        originalPrice: price * 1.1, // %10 indirim simülasyonu
        discountPercentage: 10,
        rating: 4.0 + (source.index * 0.1),
        reviewCount: 100 + (source.index * 50),
        deliveryInfo: source == PriceSource.amazon
            ? 'Ücretsiz Kargo'
            : 'Kargo: ₺9,90',
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('${source.name} fiyat alma hatası: $e');
      return null;
    }
  }

  /// Fiyat geçmişini getir
  static Future<List<Map<String, dynamic>>> getPriceHistory(
    String barcode,
    PriceSource source,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock fiyat geçmişi
      final now = DateTime.now();
      return List.generate(30, (index) {
        final date = now.subtract(Duration(days: 29 - index));
        final basePrice = 45999.0;
        final variation = (index % 7) * 1000.0; // Haftalık fiyat dalgalanması

        return {
          'date': date.toIso8601String(),
          'price': basePrice + variation,
          'currency': 'TRY',
        };
      });
    } catch (e) {
      debugPrint('Fiyat geçmişi alma hatası: $e');
      return [];
    }
  }

  /// Fiyat uyarısı oluştur
  static Future<bool> createPriceAlert(
    String barcode,
    double targetPrice,
    PriceSource? preferredSource,
  ) async {
    try {
      final result = await _methodChannel.invokeMethod('createPriceAlert', {
        'barcode': barcode,
        'targetPrice': targetPrice,
        'preferredSource': preferredSource?.name,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Fiyat uyarısı oluşturma hatası: ${e.message}');
      return false;
    }
  }

  /// Aktif fiyat uyarılarını getir
  static Future<List<Map<String, dynamic>>> getActivePriceAlerts() async {
    try {
      final result = await _methodChannel.invokeMethod('getActivePriceAlerts');
      return List<Map<String, dynamic>>.from(result ?? []);
    } on PlatformException catch (e) {
      debugPrint('Aktif uyarılar alma hatası: ${e.message}');
      return [];
    }
  }

  /// Fiyat uyarısını sil
  static Future<bool> deletePriceAlert(String alertId) async {
    try {
      final result = await _methodChannel.invokeMethod('deletePriceAlert', {
        'alertId': alertId,
      });
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Fiyat uyarısı silme hatası: ${e.message}');
      return false;
    }
  }

  /// Ürünü favorilere ekle
  static Future<bool> addToFavorites(
    String barcode,
    ProductInfo product,
  ) async {
    try {
      final result = await _methodChannel.invokeMethod('addToFavorites', {
        'barcode': barcode,
        'productName': product.name,
        'productBrand': product.brand,
        'productCategory': product.category,
        'addedAt': DateTime.now().toIso8601String(),
      });
      return result == true;
    } on PlatformException catch (e) {
      debugPrint('Favorilere ekleme hatası: ${e.message}');
      return false;
    }
  }

  /// Favori ürünleri getir
  static Future<List<Map<String, dynamic>>> getFavoriteProducts() async {
    try {
      final result = await _methodChannel.invokeMethod('getFavoriteProducts');
      return List<Map<String, dynamic>>.from(result ?? []);
    } on PlatformException catch (e) {
      debugPrint('Favoriler alma hatası: ${e.message}');
      return [];
    }
  }

  /// Fiyat karşılaştırma geçmişini kaydet
  static Future<void> savePriceComparisonHistory(
    PriceComparisonResult result,
  ) async {
    try {
      await _methodChannel.invokeMethod('savePriceComparisonHistory', {
        'barcode': result.barcode,
        'productName': result.productInfo?.name,
        'productBrand': result.productInfo?.brand,
        'lowestPrice': result.lowestPrice?.price,
        'highestPrice': result.highestPrice?.price,
        'averagePrice': result.averagePrice,
        'priceCount': result.prices.length,
        'comparedAt': DateTime.now().toIso8601String(),
      });
    } on PlatformException catch (e) {
      debugPrint('Karşılaştırma geçmişi kaydetme hatası: ${e.message}');
    }
  }

  /// Demo fiyat karşılaştırma sonucu oluştur (test amaçlı)
  static PriceComparisonResult createDemoResult() {
    final product = ProductInfo(
      name: 'Samsung Galaxy S24 256GB',
      brand: 'Samsung',
      category: 'Akıllı Telefon',
      description:
          'Son teknoloji kamera ve işlemci ile donatılmış premium akıllı telefon',
      imageUrl: 'https://example.com/samsung-s24.jpg',
      attributes: {
        'model': 'Galaxy S24',
        'storage': '256GB',
        'color': 'Phantom Black',
        'warranty': '2 Yıl',
      },
    );

    final prices = [
      PriceInfo(
        source: PriceSource.n11,
        sourceName: 'N11',
        price: 44999.0,
        currency: 'TRY',
        productUrl: 'https://n11.com/product/samsung-s24',
        inStock: true,
        seller: 'N11',
        originalPrice: 49999.0,
        discountPercentage: 10,
        rating: 4.3,
        reviewCount: 150,
        deliveryInfo: 'Kargo: ₺9,90',
        lastUpdated: DateTime.now(),
      ),
      PriceInfo(
        source: PriceSource.trendyol,
        sourceName: 'Trendyol',
        price: 45999.0,
        currency: 'TRY',
        productUrl: 'https://trendyol.com/product/samsung-s24',
        inStock: true,
        seller: 'Trendyol',
        originalPrice: 50999.0,
        discountPercentage: 10,
        rating: 4.5,
        reviewCount: 250,
        deliveryInfo: 'Ücretsiz Kargo',
        lastUpdated: DateTime.now(),
      ),
      PriceInfo(
        source: PriceSource.hepsiburada,
        sourceName: 'Hepsiburada',
        price: 46499.0,
        currency: 'TRY',
        productUrl: 'https://hepsiburada.com/product/samsung-s24',
        inStock: true,
        seller: 'Hepsiburada',
        originalPrice: 51499.0,
        discountPercentage: 10,
        rating: 4.4,
        reviewCount: 200,
        deliveryInfo: 'Ücretsiz Kargo',
        lastUpdated: DateTime.now(),
      ),
    ];

    prices.sort((a, b) => a.price.compareTo(b.price));

    return PriceComparisonResult(
      success: true,
      productInfo: product,
      prices: prices,
      barcode: '8690504000001',
      lowestPrice: prices.first,
      highestPrice: prices.last,
      averagePrice:
          prices.map((p) => p.price).reduce((a, b) => a + b) / prices.length,
    );
  }

  /// Cache'i temizle
  static void clearCache() {
    _cache.clear();
  }
}
