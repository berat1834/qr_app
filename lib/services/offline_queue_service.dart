import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'ai_vision_service.dart';
import 'history_service.dart';
import '../utils/qr_helpers.dart';

class OfflineQueueService {
  static const String _queueKey = 'offline_scan_queue';

  /// Enqueue a scan item (metadata map). imagePath should be a local file path.
  static Future<void> enqueueScan(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_queueKey) ?? <String>[];
    raw.add(jsonEncode(item));
    await prefs.setStringList(_queueKey, raw);
  }

  /// Return the queued items as List<Map>
  static Future<List<Map<String, dynamic>>> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_queueKey) ?? <String>[];
    return raw
        .map((s) {
          try {
            final m = jsonDecode(s);
            return Map<String, dynamic>.from(m);
          } catch (e) {
            return <String, dynamic>{};
          }
        })
        .where((m) => m.isNotEmpty)
        .toList();
  }

  static Future<void> _saveQueue(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = items.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList(_queueKey, raw);
  }

  /// Save an image file into app documents directory and return new path.
  static Future<String> saveImageToAppDir(File src) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final dst = File(
      '${dir.path}/queued_scan_$timestamp${_extensionFromPath(src.path)}',
    );
    await dst.create(recursive: true);
    await src.copy(dst.path);
    return dst.path;
  }

  static String _extensionFromPath(String path) {
    try {
      return path.contains('.')
          ? path.substring(path.lastIndexOf('.'))
          : '.jpg';
    } catch (_) {
      return '.jpg';
    }
  }

  /// Try to synchronize queued scans by re-uploading their images to the AI endpoint.
  /// Removes successful items from queue.
  static Future<void> syncQueuedScans() async {
    final queue = await _loadQueue();
    if (queue.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];

    for (final item in queue) {
      try {
        final imagePath = item['imagePath'] as String?;
        if (imagePath == null) {
          // nothing to do
          continue;
        }

        final file = File(imagePath);
        if (!await file.exists()) {
          continue;
        }

        // Upload to the same endpoint used by AIVisionService
        final uri = Uri.parse(
          '${AIVisionService.baseUrl}/process-damaged-image',
        );
        final request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath('file', file.path));

        final streamed = await request.send().timeout(
          const Duration(seconds: 15),
        );
        final resp = await http.Response.fromStream(streamed);
        if (resp.statusCode == 200) {
          // success: delete local file
          try {
            await file.delete();
          } catch (_) {}

          // Sunucudan dönen sonucu (onarılan QR kod) okuyup geçmişe (History) kaydedelim
          try {
            final responseData = jsonDecode(resp.body);
            final decodedData = responseData['decoded_data'] as String?;
            if (decodedData != null && decodedData.isNotEmpty) {
              final qrType = QRCodeUtils.determineQRType(decodedData);
              await HistoryService.addToHistory(
                data: decodedData,
                type: qrType,
                isScanned: true,
              );
            }
          } catch (_) {}
          continue; // do not add to remaining
        } else {
          remaining.add(item);
        }
      } catch (e) {
        // keep item for later
        remaining.add(item);
      }
    }

    await _saveQueue(remaining);
  }
}
