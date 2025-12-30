# 💻 Flutter QR Kod Projesi - Kod Örnekleri

Bu dosya projedeki tüm önemli kod parçacıklarını içerir.

---

## 📁 main.dart - Uygulama Başlangıcı

```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const QRCodeApp());
}

class QRCodeApp extends StatelessWidget {
  const QRCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Kod Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      home: const HomeScreen(),
    );
  }
}
```

---

## 🏠 home_screen.dart - Ana Sayfa

```dart
import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'qr_generator_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Kod Uygulaması',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // Logo ve başlık alanı
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'QR Kod Uygulaması',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'QR kodları okuyun ve oluşturun',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // QR Kod Tarama Butonu
            _buildMenuButton(
              context: context,
              icon: Icons.qr_code_scanner,
              title: 'QR Kod Tara',
              subtitle: 'Kamerayı kullanarak QR kod okuyun',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // QR Kod Oluşturma Butonu
            _buildMenuButton(
              context: context,
              icon: Icons.qr_code,
              title: 'QR Kod Oluştur',
              subtitle: 'Metin, URL, WiFi bilgisi için QR kod üretin',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRGeneratorScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Geçmiş Butonu
            _buildMenuButton(
              context: context,
              icon: Icons.history,
              title: 'Geçmiş',
              subtitle: 'Taranmış ve oluşturulmuş QR kodları görün',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            // Alt bilgi
            Text(
              'Hızlı ve güvenli QR kod çözümleri',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 📷 qr_scanner_screen.dart - QR Tarayıcı

```dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? result;
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tarayıcı'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {
                isFlashOn = !isFlashOn;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  setState(() {
                    result = barcode.rawValue;
                  });
                  break;
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Tarama Sonucu:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            result!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        'QR kodu kameranın görüş alanına getirin',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await cameraController.start();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Başlat'),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await cameraController.stop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Durdur'),
                        ),
                      ),
                      if (result != null)
                        Container(
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              _showResultDialog(context, result!);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Detaylar'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tarama Sonucu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('QR Kod İçeriği:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  result,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Kapat'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Geçmişe kaydedildi')),
                );
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
```

---

## 🔧 qr_generator_screen.dart - QR Oluşturucu (Ana Bölümler)

```dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _wifiNameController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  String _qrData = '';
  int _selectedIndex = 0;
  String _wifiSecurity = 'WPA';

  final List<String> _qrTypes = ['Metin', 'URL', 'WiFi', 'Telefon'];
  final List<String> _wifiSecurityTypes = ['WPA', 'WEP', 'nopass'];

  // Dropdown için widget
  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        value: _selectedIndex,
        isExpanded: true,
        underline: Container(),
        items: _qrTypes.asMap().entries.map((entry) {
          return DropdownMenuItem<int>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedIndex = value!;
            _qrData = '';
          });
        },
      ),
    );
  }

  // QR görselleştirme widget
  Widget _buildQRPreview() {
    if (_qrData.isEmpty) return Container();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'QR Kod Önizleme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          QrImageView(
            data: _qrData,
            version: QrVersions.auto,
            size: 200.0,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'İçerik: $_qrData',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // WiFi QR string oluşturma
  void _updateWiFiQR() {
    final ssid = _wifiNameController.text;
    final password = _wifiPasswordController.text;

    if (ssid.isNotEmpty) {
      setState(() {
        if (_wifiSecurity == 'nopass') {
          _qrData = 'WIFI:T:$_wifiSecurity;S:$ssid;;';
        } else {
          _qrData = 'WIFI:T:$_wifiSecurity;S:$ssid;P:$password;;';
        }
      });
    }
  }

  // WiFi girişi widget
  Widget _buildWiFiInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WiFi Bilgileri:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _wifiNameController,
          decoration: const InputDecoration(
            labelText: 'WiFi Adı (SSID)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wifi),
          ),
          onChanged: (value) => _updateWiFiQR(),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _wifiSecurity,
            isExpanded: true,
            underline: Container(),
            items: _wifiSecurityTypes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value == 'nopass' ? 'Şifresiz' : value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _wifiSecurity = value!;
                _updateWiFiQR();
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        if (_wifiSecurity != 'nopass')
          TextField(
            controller: _wifiPasswordController,
            decoration: const InputDecoration(
              labelText: 'WiFi Şifresi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            onChanged: (value) => _updateWiFiQR(),
          ),
      ],
    );
  }

  // Kaydetme fonksiyonu
  void _saveQRCode() {
    if (_qrData.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR kod başarıyla kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('QR Kod Kaydedildi'),
            content: const Text(
              'QR kod içeriğini panoya kopyalamak ister misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hayır'),
              ),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _qrData));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Panoya kopyalandı!')),
                  );
                },
                child: const Text('Kopyala'),
              ),
            ],
          );
        },
      );
    }
  }
}
```

---

## 📋 history_screen.dart - Geçmiş Yönetimi (Ana Bölümler)

```dart
import 'package:flutter/material.dart';

// Veri modeli
class HistoryItem {
  final String content;
  final String type;
  final DateTime timestamp;
  final bool isScanned;

  HistoryItem({
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isScanned,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Test verileri
  final List<HistoryItem> _historyItems = [
    HistoryItem(
      content: 'https://www.google.com',
      type: 'URL',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isScanned: true,
    ),
    HistoryItem(
      content: 'WIFI:T:WPA;S:MyWiFi;P:password123;;',
      type: 'WiFi',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isScanned: false,
    ),
  ];

  // Boş durum widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz geçmiş yok',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'QR kod tarayıp oluşturdukça burada görünecek',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // İkon seçimi
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'url': return Icons.link;
      case 'wifi': return Icons.wifi;
      case 'telefon': return Icons.phone;
      case 'metin':
      default: return Icons.text_fields;
    }
  }

  // İçerik formatlaması
  String _getDisplayContent(String content) {
    if (content.startsWith('WIFI:')) {
      final regex = RegExp(r'S:([^;]+)');
      final match = regex.firstMatch(content);
      return match != null ? 'WiFi: ${match.group(1)}' : 'WiFi Bilgisi';
    } else if (content.startsWith('tel:')) {
      return content.replaceFirst('tel:', 'Tel: ');
    } else if (content.startsWith('http')) {
      return content;
    } else {
      return content;
    }
  }

  // Zaman formatı
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  // Liste öğesi widget
  Widget _buildHistoryItem(HistoryItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: item.isScanned ? Colors.green[100] : Colors.blue[100],
          child: Icon(
            _getIconForType(item.type),
            color: item.isScanned ? Colors.green[700] : Colors.blue[700],
          ),
        ),
        title: Text(
          _getDisplayContent(item.content),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.isScanned ? Colors.green[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.isScanned ? Colors.green[200]! : Colors.blue[200]!,
                    ),
                  ),
                  child: Text(
                    item.isScanned ? 'Tarandı' : 'Oluşturuldu',
                    style: TextStyle(
                      fontSize: 12,
                      color: item.isScanned ? Colors.green[700] : Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.type,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(item.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'copy': _copyToClipboard(item.content); break;
              case 'share': _shareContent(item.content); break;
              case 'delete': _deleteItem(index); break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'copy',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Kopyala'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Paylaş'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Sil', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _showItemDetails(item),
      ),
    );
  }

  // Silme konfirmasyonu
  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Öğeyi Sil'),
          content: const Text(
            'Bu öğeyi geçmişten silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _historyItems.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Öğe silindi')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Panoya kopyalandı!')),
    );
  }

  void _shareContent(String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
    );
  }

  void _showItemDetails(HistoryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${item.type} Detayları'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('İçerik:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SelectableText(
                item.content,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              const Text('Tarih:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(item.timestamp.toString().split('.')[0]),
              const SizedBox(height: 16),
              const Text('Durum:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(item.isScanned ? 'Tarandı' : 'Oluşturuldu'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }
}
```

---

## 🎯 Önemli Widget Örnekleri

### Navigation (Sayfa Geçişleri)
```dart
// Yeni sayfa aç
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);

// Önceki sayfaya dön
Navigator.pop(context);

// Sayfayı değiştir (geri tuşu ile dönülemez)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);
```

### Dialog Kullanımları
```dart
// Alert Dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Başlık'),
    content: Text('İçerik'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Tamam'),
      ),
    ],
  ),
);

// SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Mesaj')),
);
```

### Layout Örnekleri
```dart
// Column - Dikey sıralama
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [widget1, widget2, widget3],
)

// Row - Yatay sıralama
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [widget1, widget2, widget3],
)

// Container - Çok amaçlı kutu
Container(
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [BoxShadow(...)],
  ),
  child: widget,
)
```

### State Management
```dart
// State değiştirme
setState(() {
  variable = newValue;
});

// Controller kullanımı
final TextEditingController controller = TextEditingController();

// Lifecycle
@override
void initState() {
  super.initState();
  // Widget oluşturulduğunda
}

@override
void dispose() {
  controller.dispose();
  super.dispose();
  // Widget silindiğinde
}
```

---

*Bu dosya projedeki tüm önemli kod parçacıklarını içermektedir.*  
*Hazırlayan: GitHub Copilot - 6 Ekim 2025*