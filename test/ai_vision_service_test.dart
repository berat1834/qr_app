import 'package:flutter_test/flutter_test.dart';
import 'package:qr_app/services/ai_vision_service.dart';

void main() {
  group('AIVisionService - Temel Testler', () {
    test('Base URL tanımlanmış ve geçerli formatta', () {
      expect(AIVisionService.baseUrl, startsWith('http'));
    });

    test('processDamagedImage metodu mevcut ve çağrılabilir', () {
      // Servisin metodunun erişilebilir (Function) olduğunu doğrularız.
      // Gerçek HTTP talebi atmamak için yapısal kontrol yapıyoruz.
      expect(AIVisionService.processDamagedImage, isA<Function>());
    });
  });
}
