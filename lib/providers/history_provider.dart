import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';

/// Geçmiş verilerini yönetmek ve UI'ı güncellemek için bir `ChangeNotifier`.
///
/// Bu provider, geçmiş listesini yükleme, ekleme, silme ve temizleme
/// gibi operasyonları yönetir ve bu değişiklikleri dinleyen widget'lara
/// haber verir.
class HistoryProvider with ChangeNotifier {
  List<HistoryItem> _history = [];
  bool _isLoading = false;

  /// Değiştirilemez bir geçmiş listesi sunar.
  UnmodifiableListView<HistoryItem> get history =>
      UnmodifiableListView(_history);

  /// Yükleme durumunu belirtir.
  bool get isLoading => _isLoading;

  HistoryProvider() {
    loadHistory();
  }

  /// Geçmiş listesini [HistoryService] üzerinden yükler.
  Future<void> loadHistory() async {
    _setLoading(true);
    _history = await HistoryService.getHistory();
    _setLoading(false);
  }

  /// Belirtilen ID'ye sahip bir öğeyi geçmişten siler.
  Future<void> deleteItem(String id) async {
    // Önce UI'dan anında kaldır (iyimser güncelleme)
    _history.removeWhere((item) => item.id == id);
    notifyListeners();
    // Sonra servisten kalıcı olarak sil
    await HistoryService.deleteHistoryItem(id);
  }

  /// Birden çok öğeyi ID'lerine göre geçmişten siler.
  Future<void> deleteMultipleItems(Set<String> ids) async {
    _history.removeWhere((item) => ids.contains(item.id));
    notifyListeners();
    // Servisten toplu olarak sil
    await Future.wait(ids.map((id) => HistoryService.deleteHistoryItem(id)));
  }

  /// Tüm geçmişi temizler.
  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    await HistoryService.clearHistory();
  }
  
  /// Bir öğeyi günceller (şimdilik silip yeniden ekleyerek).
  /// Daha verimli bir `update` metodu servise eklenebilir.
  Future<void> updateItem({
    required HistoryItem oldItem,
    required String newData,
    String? newCustomName,
  }) async {
    await HistoryService.deleteHistoryItem(oldItem.id);
    await HistoryService.addToHistory(
      data: newData,
      type: HistoryService.determineQRType(newData),
      isScanned: oldItem.isScanned,
      customName: newCustomName,
    );
    // Değişikliğin UI'a yansıması için listeyi yeniden yükle
    await loadHistory();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
