import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'price_comparison_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PriceNotificationService {
  static final PriceNotificationService _instance =
      PriceNotificationService._internal();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Tetiklenen alarmları takip etmek için (bildirimi gösterilmiş)
  static final Set<String> _notifiedAlertIds = {};

  // Deep linking için navigator key
  static GlobalKey<NavigatorState>? _navigatorKey;

  factory PriceNotificationService() {
    return _instance;
  }

  PriceNotificationService._internal();

  bool _isIgnorableTestError(Object error) {
    final text = error.toString();
    return error is MissingPluginException ||
        text.contains('MissingPluginException') ||
        text.contains('LateInitializationError');
  }

  /// Notification service'i initialize et ve navigator key'i set et
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Notifications başlat ve configure et
  Future<void> initialize() async {
    try {
      tz_data.initializeTimeZones();

      // Android için ayarlar
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS için ayarlar
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // iOS için izin iste
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      debugPrint('[PriceNotificationService] Initialize başarılı');
    } catch (e) {
      if (!_isIgnorableTestError(e)) {
        debugPrint('[PriceNotificationService] Initialize hatası: $e');
      }
    }
  }

  /// Notification response handler (bildirimlere tıklanıldığında)
  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint(
      '[PriceNotificationService] Notification tapped: ${response.payload}',
    );

    // Payload format: "alertId:productName:barcode"
    if (response.payload?.isNotEmpty ?? false) {
      final parts = response.payload!.split(':');
      if (parts.isNotEmpty) {
        final alertId = parts[0];
        _navigatorKey?.currentState?.pushNamed('/alert/$alertId');
        debugPrint(
          '[PriceNotificationService] Deep link açıldı: /alert/$alertId',
        );
      }
    }
  }

  /// Aktif alarmları kontrol et ve tetiklenen olanlar için bildirim gönder
  Future<void> checkTriggeredAlerts() async {
    try {
      final alerts = await PriceComparisonService.getActivePriceAlerts();

      for (final alert in alerts) {
        final currentPrice = alert['currentPrice'] as num?;
        final targetPrice = alert['targetPrice'] as num?;
        final alertId = alert['id'] as String?;

        // Tetiklenmiş olup daha sonra tetiklenmiş olduğunu kontrol et
        if (currentPrice != null &&
            targetPrice != null &&
            alertId != null &&
            currentPrice.toDouble() <= targetPrice.toDouble() &&
            !_notifiedAlertIds.contains(alertId)) {
          await _sendTriggeredNotification(alert);
          _notifiedAlertIds.add(alertId);
        }
      }
    } catch (e) {
      if (!_isIgnorableTestError(e)) {
        debugPrint(
          '[PriceNotificationService] checkTriggeredAlerts hatası: $e',
        );
      }
    }
  }

  /// Mevcut alarmlardan birini kullanarak manuel test bildirimi gönder
  /// false dönerse test için aktif alarm bulunamamıştır.
  Future<bool> sendManualTestNotification() async {
    try {
      final alerts = await PriceComparisonService.getActivePriceAlerts();
      if (alerts.isEmpty) {
        return false;
      }

      final alert = Map<String, dynamic>.from(alerts.first);
      final current = (alert['currentPrice'] as num?)?.toDouble() ?? 90;
      final target = (alert['targetPrice'] as num?)?.toDouble() ?? 100;

      // Test bildirimi için koşulu garanti altına al
      alert['targetPrice'] = target >= current ? target : current + 1;
      alert['currentPrice'] = current;

      await _sendTriggeredNotification(alert);
      return true;
    } catch (e) {
      if (!_isIgnorableTestError(e)) {
        debugPrint(
          '[PriceNotificationService] Manuel test bildirimi hatası: $e',
        );
      }
      return false;
    }
  }

  /// Tetiklenen alarm için bildirim gönder
  Future<void> _sendTriggeredNotification(Map<String, dynamic> alert) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'price_alerts_channel',
            'Fiyat Alarmları',
            channelDescription: 'Fiyat hedefine ulaşıldığında bildirim alın',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            ongoing: false,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final alertId = alert['id'] as String?;
      final productName = alert['productName'] as String? ?? 'Ürün';
      final barcode = alert['barcode'] as String? ?? '';
      final currentPrice = alert['currentPrice'] as num?;
      final targetPrice = alert['targetPrice'] as num?;
      final payload = '$alertId:$productName:$barcode';

      await _notificationsPlugin.show(
        (alertId ?? '').hashCode,
        '🎉 Fiyat Hedefine Ulaştı!',
        '$productName\n${currentPrice?.toString()} ₺ → ${targetPrice?.toString()} ₺',
        notificationDetails,
        payload: payload,
      );

      debugPrint(
        '[PriceNotificationService] Bildirim gönderildi: $productName',
      );
    } catch (e) {
      if (!_isIgnorableTestError(e)) {
        debugPrint('[PriceNotificationService] Bildirim gönderme hatası: $e');
      }
    }
  }

  /// Periyodik olarak alarmları kontrol etmek for task schedule
  /// (Not: Bu method background isolate'de çalışabilir)
  static Future<void> backgroundCheckTriggeredAlerts() async {
    final service = PriceNotificationService();
    await service.checkTriggeredAlerts();
  }

  /// Tetiklenen alarmları sıfırla (uygulama başlangıcında çağrıl)
  void resetNotifiedAlerts() {
    _notifiedAlertIds.clear();
    debugPrint('[PriceNotificationService] Tetiklenen alarmlar sıfırlandı');
  }

  /// Specific alert notification'ı sil
  Future<void> cancelNotification(String alertId) async {
    try {
      await _notificationsPlugin.cancel(alertId.hashCode);
      _notifiedAlertIds.remove(alertId);
      debugPrint('[PriceNotificationService] Bildirim iptal edildi: $alertId');
    } catch (e) {
      debugPrint('[PriceNotificationService] Bildirim iptal hatası: $e');
    }
  }

  /// Tüm notifications sil
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      _notifiedAlertIds.clear();
      debugPrint('[PriceNotificationService] Tüm bildirimler iptal edildi');
    } catch (e) {
      debugPrint(
        '[PriceNotificationService] Tüm bildirimleri iptal hatası: $e',
      );
    }
  }
}
