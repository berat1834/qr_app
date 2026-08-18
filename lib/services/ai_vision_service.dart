import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AIVisionService {
  // Backend URL'si.
  // Gerçek cihazda test ederken bilgisayarın yerel ağ IP'sini girmelisin (örn: 192.168.1.x)
  // Emülatör (Android) üzerinden test ediyorsan genellikle 10.0.2.2 kullanılır.
  // Fiziksel cihazda çalıştırırken: flutter run --dart-define=AI_API_URL=http://192.168.1.175:8000/api/v1
  static const String baseUrl = String.fromEnvironment(
    'AI_API_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  /// Bulanık veya hasarlı resmi FastAPI backend'ine gönderir ve onarılmış/okunmuş sonucu döner.
  static Future<Map<String, dynamic>> processDamagedImage(
    File imageFile,
  ) async {
    try {
      var uri = Uri.parse('$baseUrl/process-damaged-image');
      var request = http.MultipartRequest('POST', uri);

      // İsteğe dosya ekleme (multipart/form-data)
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // NOT: Eğer uç nokta Authentication istiyorsa, token'ı buraya ekleyebilirsin:
      // request.headers['Authorization'] = 'Bearer JWT_TOKEN';

      // İsteği gönder ve yanıtı bekle
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Bağlantı zaman aşımına uğradı (Timeout).');
        },
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        var errorData = json.decode(response.body);
        throw Exception(
          errorData['detail'] ??
              'Bilinmeyen bir hata oluştu. (Durum Kodu: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception(
        'Yapay Zeka Sunucusuna ulaşılamadı. Lütfen internet bağlantınızı kontrol edin. Detay: $e',
      );
    }
  }
}
