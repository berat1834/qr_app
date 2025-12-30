import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class FeedbackService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Başarılı tarama için titreşim
  static Future<void> successVibration() async {
    if (await Vibration.hasVibrator()) {
      // Kısa çift titreşim
      await Vibration.vibrate(duration: 100);
      await Future.delayed(const Duration(milliseconds: 100));
      await Vibration.vibrate(duration: 100);
    }
  }

  // Hata için titreşim
  static Future<void> errorVibration() async {
    if (await Vibration.hasVibrator()) {
      // Uzun tek titreşim
      await Vibration.vibrate(duration: 500);
    }
  }

  // Haptic feedback (dokunsal geri bildirim)
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  // Başarılı tarama sesi (sistem sesi)
  static void playSuccessSound() {
    SystemSound.play(SystemSoundType.click);
  }

  // Ses dosyası çalma (gelecekte özel ses dosyası için)
  static Future<void> playCustomSound(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // Ses çalınamazsa sistem sesini çal
      playSuccessSound();
    }
  }

  // QR kod tarama başarılı - tam feedback
  static Future<void> scanSuccessFeedback() async {
    lightHaptic();
    playSuccessSound();
    await successVibration();
  }

  // QR kod tarama hatası - hata feedback
  static Future<void> scanErrorFeedback() async {
    heavyHaptic();
    await errorVibration();
  }

  // Buton tıklama feedback
  static void buttonTapFeedback() {
    selectionHaptic();
  }

  // QR kod oluşturma başarılı
  static void qrGeneratedFeedback() {
    mediumHaptic();
    playSuccessSound();
  }
}
