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
      print('🖼️ Galeri QR tarama başlatıldı...');

      // Galeriden resim seç
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) {
        print('❌ Kullanıcı resim seçmedi');
        return null;
      }

      print('✅ Resim seçildi: ${image.path}');
      print('📁 Dosya boyutu: ${await File(image.path).length()} bytes');

      // MobileScanner ile analiz et
      final result = await _analyzeMobileScanner(image.path);

      if (result != null) {
        print('🎉 QR kod başarıyla okundu: $result');
      } else {
        print('😞 QR kod okunamadı');
      }

      return result;
    } catch (e) {
      print('💥 Galeri QR tarama hatası: $e');
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
      print('Kamera QR tarama hatası: $e');
      return null;
    }
  }

  /// MobileScanner ile resim analizi - GERÇEK QR OKUMA
  static Future<String?> _analyzeMobileScanner(String imagePath) async {
    MobileScannerController? controller;
    try {
      print('🔍 Gerçek QR analizi başlatıldı...');
      print('📂 Seçilen dosya: $imagePath');

      // Dosya mevcut mu kontrol edelim
      final file = File(imagePath);
      final exists = await file.exists();
      print('📋 Dosya mevcut: $exists');

      if (!exists) {
        print('❌ Dosya bulunamadı');
        return null;
      }

      final size = await file.length();
      print('📏 Dosya boyutu: $size bytes');

      // MobileScannerController oluştur
      controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      print('🤖 MobileScannerController oluşturuldu');

      // Resmi analiz et
      try {
        final BarcodeCapture? result = await controller.analyzeImage(imagePath);
        print('✅ Analiz tamamlandı');

        if (result != null && result.barcodes.isNotEmpty) {
          print('📋 Bulunan kod sayısı: ${result.barcodes.length}');

          for (int i = 0; i < result.barcodes.length; i++) {
            final barcode = result.barcodes[i];
            print(
              '📋 Kod $i: Format=${barcode.format}, Value="${barcode.displayValue}", Raw="${barcode.rawValue}"',
            );
          }

          final firstBarcode = result.barcodes.first;
          final qrData =
              firstBarcode.displayValue ?? firstBarcode.rawValue ?? '';

          if (qrData.isNotEmpty) {
            print('🎯 QR kod bulundu: $qrData');
            return qrData;
          }
        }
      } catch (analyzeError) {
        print('💥 Analiz hatası: $analyzeError');

      }

      print('❌ QR kod bulunamadı');
      return null;
    } catch (e) {
      print('💥 Genel QR analiz hatası: $e');
      print('📋 Hata detayları: ${e.toString()}');
      return null;
    } finally {
      // Controller'ı temizle
      try {
        await controller?.dispose();
        print('🔒 Controller kapatıldı');
      } catch (e) {
        print('⚠️ Controller kapatma hatası: $e');
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
