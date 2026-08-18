import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'permission_explanation_service.dart';

class GalleryQRService {
  static final ImagePicker _picker = ImagePicker();

  /// Galeriden resim seç ve QR kod tara (izin açıklaması ile)
  static Future<String?> scanQRFromGallery({BuildContext? context}) async {
    try {
      // Galeri izni açıklaması göster (eğer context varsa)
      if (context != null) {
        final hasPermission =
            await PermissionExplanationService.requestGalleryPermissionWithExplanation(
              context,
            );
        if (!hasPermission) {
          return null; // Kullanıcı izin vermedi
        }
      }
      debugPrint('🖼️ Galeri QR tarama başlatıldı...');

      // Galeriden resim seç
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) {
        debugPrint('❌ Kullanıcı resim seçmedi');
        return null;
      }

      debugPrint('✅ Resim seçildi: ${image.path}');
      debugPrint('📁 Dosya boyutu: ${await File(image.path).length()} bytes');

      // MobileScanner ile analiz et
      final result = await _analyzeMobileScanner(image.path);

      if (result != null) {
        debugPrint('🎉 QR kod başarıyla okundu: $result');
      } else {
        debugPrint('😞 QR kod okunamadı');
      }

      return result;
    } catch (e) {
      debugPrint('💥 Galeri QR tarama hatası: $e');
      return null;
    }
  }

  /// Kamera ile çekilen resimden QR tara
  static Future<String?> scanQRFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (image == null) return null;

      final result = await _analyzeMobileScanner(image.path);

      return result;
    } catch (e) {
      debugPrint('Kamera QR tarama hatası: $e');
      return null;
    }
  }

  /// MobileScanner ile resim analizi - GERÇEK QR OKUMA
  static Future<String?> _analyzeMobileScanner(String imagePath) async {
    MobileScannerController? controller;
    try {
      debugPrint('🔍 Gerçek QR analizi başlatıldı...');
      debugPrint('📂 Seçilen dosya: $imagePath');

      // Dosya mevcut mu kontrol edelim
      final file = File(imagePath);
      final exists = file.existsSync();
      debugPrint('📋 Dosya mevcut: $exists');

      if (!exists) {
        debugPrint('❌ Dosya bulunamadı');
        return null;
      }

      final size = await file.length();
      debugPrint('📏 Dosya boyutu: $size bytes');

      // MobileScannerController oluştur
      controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      debugPrint('🤖 MobileScannerController oluşturuldu');

      // Resmi analiz et
      try {
        final BarcodeCapture? result = await controller.analyzeImage(imagePath);
        debugPrint('✅ Analiz tamamlandı');

        if (result != null && result.barcodes.isNotEmpty) {
          debugPrint('📋 Bulunan kod sayısı: ${result.barcodes.length}');

          for (int i = 0; i < result.barcodes.length; i++) {
            final barcode = result.barcodes[i];
            debugPrint(
              '📋 Kod $i: Format=${barcode.format}, Value="${barcode.displayValue}", Raw="${barcode.rawValue}"',
            );
          }

          final firstBarcode = result.barcodes.first;
          final qrData =
              firstBarcode.displayValue ?? firstBarcode.rawValue ?? '';

          if (qrData.isNotEmpty) {
            debugPrint('🎯 QR kod bulundu: $qrData');
            return qrData;
          }
        }
      } catch (analyzeError) {
        debugPrint('💥 Analiz hatası: $analyzeError');
      }

      debugPrint('❌ QR kod bulunamadı');
      return null;
    } catch (e) {
      debugPrint('💥 Genel QR analiz hatası: $e');
      debugPrint('📋 Hata detayları: ${e.toString()}');
      return null;
    } finally {
      // Controller'ı temizle
      try {
        await controller?.dispose();
        debugPrint('🔒 Controller kapatıldı');
      } catch (e) {
        debugPrint('⚠️ Controller kapatma hatası: $e');
      }
    }
  }

  /// Galeriden resim seçme özelliği var mı kontrol et
  static Future<bool> isGalleryAvailable() async {
    try {
      // Android ve iOS'ta genellikle galeri mevcuttur
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  /// Kamera mevcut mu kontrol et
  static Future<bool> isCameraAvailable() async {
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }
}
