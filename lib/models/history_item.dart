import 'package:flutter/foundation.dart';

/// Geçmiş listesindeki tek bir QR kod kaydını temsil eden model sınıfı.
///
/// Bu sınıf, verilerin `Map<String, String>` yerine katı bir şekilde
/// modellenmesini sağlayarak tür güvenliği (type safety) sunar.
@immutable
class HistoryItem {
  final String id;
  final String data;
  final String type;
  final DateTime date;
  final String? customName;
  final String? category;
  final bool isScanned;
  final bool isArchived;

  const HistoryItem({
    required this.id,
    required this.data,
    required this.type,
    required this.date,
    this.customName,
    this.category,
    required this.isScanned,
    this.isArchived = false,
  });

  /// Bu nesneyi, JSON depolaması için bir Map'e dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'type': type,
      'date': date.toIso8601String(), // Tarihi standart bir formatta sakla
      'customName': customName,
      'category': category,
      'isScanned': isScanned,
      'isArchived': isArchived,
    };
  }

  /// Bir Map'i (genellikle JSON'dan gelir) bir [HistoryItem] nesnesine dönüştürür.
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      data: json['data'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String), // Standart formattan oku
      customName: json['customName'] as String?,
      category: json['category'] as String?,
      isScanned:
          json['isScanned'] as bool? ?? false, // Geriye dönük uyumluluk için
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  /// Kolay hata ayıklama ve loglama için `toString` metodunu override et.
  @override
  String toString() {
    return 'HistoryItem(id: $id, type: $type, data: "$data", date: $date)';
  }

  /// Nesnelerin karşılaştırılabilmesi için `==` ve `hashCode`'ı override et.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistoryItem &&
        other.id == id &&
        other.data == data &&
        other.type == type &&
        other.date == date &&
        other.customName == customName &&
        other.category == category &&
        other.isScanned == isScanned &&
        other.isArchived == isArchived;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        data.hashCode ^
        type.hashCode ^
        date.hashCode ^
        customName.hashCode ^
        category.hashCode ^
        isScanned.hashCode ^
        isArchived.hashCode;
  }
}
