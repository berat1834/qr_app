# 📚 Flutter QR Kod Projesi - Komple Ders Notları

**Tarih:** 6 Ekim 2025  
**Proje:** QR Kod Uygulaması  
**Teknoloji:** Flutter & Dart

---

## 📑 İçindekiler

1. [Proje Yapısı ve Temel Kavramlar](#1-proje-yapısı-ve-temel-kavramlar)
2. [main.dart - Uygulamanın Kalbi](#2-maindart---uygulamanın-kalbi)
3. [home_screen.dart - Ana Sayfa](#3-home_screendart---ana-sayfa)
4. [qr_scanner_screen.dart - Kamera ile QR Okuma](#4-qr_scanner_screendart---kamera-ile-qr-okuma)
5. [qr_generator_screen.dart - QR Kod Oluşturma](#5-qr_generator_screendart---qr-kod-oluşturma)
6. [history_screen.dart - Geçmiş Ekranı](#6-history_screendart---geçmiş-ekranı)
7. [Önemli Flutter Kavramları](#7-önemli-flutter-kavramları)
8. [Sonuç ve İleri Adımlar](#8-sonuç-ve-ileri-adımlar)

---

## 1. Proje Yapısı ve Temel Kavramlar

### 🏗️ Proje Klasör Yapısı
```
lib/
├── main.dart              # Ana dosya - uygulamanın başlangıcı
└── screens/               # Ekranlar klasörü
    ├── home_screen.dart          # Ana sayfa
    ├── qr_scanner_screen.dart    # QR okuma ekranı
    ├── qr_generator_screen.dart  # QR oluşturma ekranı
    └── history_screen.dart       # Geçmiş ekranı
```

### 🧩 Kullanılan Ana Paketler
- `flutter/material.dart` - Material Design UI bileşenleri
- `mobile_scanner` - QR kod tarama
- `qr_flutter` - QR kod görselleştirme
- `permission_handler` - İzin yönetimi
- `flutter/services.dart` - Sistem servisleri

---

## 2. main.dart - Uygulamanın Kalbi

### 🚀 Başlangıç Fonksiyonu
```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const QRCodeApp());  // Uygulamayı başlat
}
```

**🔍 Açıklama:**
- `main()`: Her Dart programının başlangıç noktası
- `runApp()`: Flutter uygulamasını çalıştırır
- `import`: Başka dosyaları kullanmak için dahil ederiz

### 🎨 Uygulama Konfigürasyonu
```dart
class QRCodeApp extends StatelessWidget {
  const QRCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Kod Uygulaması',
      debugShowCheckedModeBanner: false,  // DEBUG yazısını gizle
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,               // Google'ın yeni tasarım dili
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),           // İlk açılacak sayfa
    );
  }
}
```

**🔍 Önemli Kavramlar:**
- `StatelessWidget`: Değişmeyen UI bileşeni
- `MaterialApp`: Uygulamanın kök widget'ı
- `Theme`: Uygulamanın görsel teması
- `ColorScheme`: Renk paleti sistemi

---

## 3. home_screen.dart - Ana Sayfa

### 🏠 Ana Sayfa Yapısı
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(              // Sayfanın iskelet yapısı
      appBar: AppBar(...),        // Üst bar
      body: Padding(...),         // Ana içerik
    );
  }
}
```

### 📱 AppBar (Üst Bar)
```dart
appBar: AppBar(
  title: const Text(
    'QR Kod Uygulaması',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
),
```

### 🎨 Logo Container
```dart
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primaryContainer,
    borderRadius: BorderRadius.circular(15),  // Köşeleri yuvarla
  ),
  child: Column(
    children: [
      Icon(Icons.qr_code, size: 80, color: ...),
      Text('QR Kod Uygulaması'),
      Text('QR kodları okuyun ve oluşturun'),
    ],
  ),
),
```

### 🔘 Özel Menü Butonları
```dart
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
    child: InkWell(              // Tıklama efekti
      onTap: onTap,
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
                  Text(title, style: titleStyle),
                  Text(subtitle, style: subtitleStyle),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    ),
  );
}
```

### 🧭 Navigasyon (Sayfa Geçişi)
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const QRScannerScreen(),
  ),
);
```

**🔍 Önemli Kavramlar:**
- `Scaffold`: Sayfa iskelet yapısı
- `Column/Row`: Dikey/yatay sıralama
- `Container`: Kutular oluşturma
- `Card`: Material Design kartı
- `InkWell`: Tıklama efekti
- `Navigator`: Sayfa geçiş yöneticisi

---

## 4. qr_scanner_screen.dart - Kamera ile QR Okuma

### 📷 StatefulWidget Kullanımı
```dart
class QRScannerScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? result;        // Tarama sonucu (null olabilir)
  bool isFlashOn = false; // Flaş durumu
```

### ⚡ Lifecycle Methodları
```dart
@override
void initState() {              // Widget ilk oluşturulduğunda
  super.initState();
  _requestCameraPermission();   // Kamera izni iste
}

@override
void dispose() {                // Widget silindiğinde
  cameraController.dispose();   // Kaynakları temizle
  super.dispose();
}
```

### 🔐 İzin Yönetimi
```dart
Future<void> _requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}
```

### 📹 Kamera ve QR Tarama
```dart
MobileScanner(
  controller: cameraController,
  onDetect: (capture) {                     // QR bulunduğunda
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      setState(() {
        result = barcode.rawValue;          // Sonucu kaydet
      });
      break;
    }
  },
),
```

### 🎛️ Flaş Kontrolü
```dart
IconButton(
  icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
  onPressed: () async {
    await cameraController.toggleTorch();
    setState(() {
      isFlashOn = !isFlashOn;
    });
  },
),
```

### 💬 Dialog Kullanımı
```dart
void _showResultDialog(BuildContext context, String result) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Tarama Sonucu'),
        content: SelectableText(result),  // Kopyalanabilir metin
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
```

**🔍 Önemli Kavramlar:**
- `StatefulWidget`: Değişebilen durumlu widget
- `async/await`: Asenkron programlama
- `Future<T>`: Gelecekte tamamlanacak işlem
- `setState()`: UI güncelleme
- `showDialog()`: Modal dialog gösterme

---

## 5. qr_generator_screen.dart - QR Kod Oluşturma

### 📊 Controller'lar ve State Variables
```dart
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
```

### 📋 Dropdown (Açılır Menü)
```dart
DropdownButton<int>(
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
```

### 🔄 Switch Case ile Dinamik Widget
```dart
Widget _buildInputSection() {
  switch (_selectedIndex) {
    case 0: return _buildTextInput();
    case 1: return _buildURLInput();
    case 2: return _buildWiFiInput();
    case 3: return _buildPhoneInput();
    default: return _buildTextInput();
  }
}
```

### 📝 TextField Kullanımı
```dart
TextField(
  controller: _textController,
  maxLines: 4,
  decoration: const InputDecoration(
    hintText: 'QR koda dönüştürmek istediğiniz metni girin...',
    border: OutlineInputBorder(),
  ),
  onChanged: (value) {
    setState(() {
      _qrData = value;
    });
  },
),
```

### 📶 WiFi QR String Oluşturma
```dart
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
```

### 🖼️ QR Kod Görselleştirme
```dart
if (_qrData.isNotEmpty) ...[
  Container(
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
    child: QrImageView(
      data: _qrData,
      version: QrVersions.auto,
      size: 200.0,
      backgroundColor: Colors.white,
    ),
  ),
]
```

### 💾 Kaydetme ve Kopyalama
```dart
void _saveQRCode() {
  if (_qrData.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR kod başarıyla kaydedildi!')),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Kod Kaydedildi'),
        content: const Text('QR kod içeriğini panoya kopyalamak ister misiniz?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _qrData));
              Navigator.pop(context);
            },
            child: const Text('Kopyala'),
          ),
        ],
      ),
    );
  }
}
```

**🔍 Önemli Kavramlar:**
- `TextEditingController`: Metin girişi kontrolü
- `switch-case`: Çoklu koşul kontrolü
- `String interpolation`: `'text $variable'`
- `Spread operator`: `...[widget1, widget2]`
- `Clipboard`: Sistem panosu işlemleri

---

## 6. history_screen.dart - Geçmiş Ekranı

### 🏗️ Veri Modeli
```dart
class HistoryItem {
  final String content;      // QR kod içeriği
  final String type;         // QR kod türü
  final DateTime timestamp;  // Zaman damgası
  final bool isScanned;      // Tarandı mı, oluşturuldu mu?

  HistoryItem({
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isScanned,
  });
}
```

### 📋 ListView.builder - Dinamik Liste
```dart
ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: _historyItems.length,
  itemBuilder: (context, index) {
    return _buildHistoryItem(_historyItems[index], index);
  },
),
```

### 🎨 Koşullu UI - Boş Durum
```dart
body: _historyItems.isEmpty
    ? _buildEmptyState()
    : ListView.builder(...),

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history, size: 80, color: Colors.grey[400]),
        Text('Henüz geçmiş yok'),
        Text('QR kod tarayıp oluşturdukça burada görünecek'),
      ],
    ),
  );
}
```

### 🔗 Dinamik İkon Seçimi
```dart
IconData _getIconForType(String type) {
  switch (type.toLowerCase()) {
    case 'url': return Icons.link;
    case 'wifi': return Icons.wifi;
    case 'telefon': return Icons.phone;
    case 'metin':
    default: return Icons.text_fields;
  }
}
```

### 🎭 Akıllı İçerik Gösterimi
```dart
String _getDisplayContent(String content) {
  if (content.startsWith('WIFI:')) {
    final regex = RegExp(r'S:([^;]+)');
    final match = regex.firstMatch(content);
    return match != null ? 'WiFi: ${match.group(1)}' : 'WiFi Bilgisi';
  } else if (content.startsWith('tel:')) {
    return content.replaceFirst('tel:', 'Tel: ');
  } else {
    return content;
  }
}
```

### ⏰ Zaman Formatı
```dart
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
```

### 📱 PopupMenuButton
```dart
PopupMenuButton<String>(
  onSelected: (value) {
    switch (value) {
      case 'copy': _copyToClipboard(item.content); break;
      case 'share': _shareContent(item.content); break;
      case 'delete': _deleteItem(index); break;
    }
  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'copy',
      child: ListTile(
        leading: Icon(Icons.copy),
        title: Text('Kopyala'),
      ),
    ),
    // ... diğer menü öğeleri
  ],
),
```

### ⚠️ Silme Konfirmasyonu
```dart
void _deleteItem(int index) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Öğeyi Sil'),
      content: const Text('Bu öğeyi silmek istediğinizden emin misiniz?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _historyItems.removeAt(index);
            });
            Navigator.pop(context);
          },
          child: const Text('Sil'),
        ),
      ],
    ),
  );
}
```

**🔍 Önemli Kavramlar:**
- Veri modelleme (Data Classes)
- Liste işlemleri (`removeAt`, `clear`, `isEmpty`)
- Zaman işlemleri (`DateTime`, `Duration`)
- String işlemleri ve Regex
- Conditional rendering

---

## 7. Önemli Flutter Kavramları

### 🌳 Widget Tree (Widget Ağacı)
```
MaterialApp
├── Scaffold
    ├── AppBar
    └── Body
        └── Column
            ├── Container
            ├── Card
            └── ListView
```

### 🔄 State Management
```dart
// StatelessWidget - Değişmeyen
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// StatefulWidget - Değişebilen
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String data = '';
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### 🧭 Navigation
```dart
// Yeni sayfa aç
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);

// Önceki sayfaya dön
Navigator.pop(context);

// Sayfayı değiştir
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);
```

### 🎨 Layout Widgets
```dart
// Dikey sıralama
Column(children: [widget1, widget2])

// Yatay sıralama  
Row(children: [widget1, widget2])

// Esnek alan
Expanded(child: widget)

// Boşluk
SizedBox(height: 10, width: 20)

// Padding
Padding(
  padding: EdgeInsets.all(16),
  child: widget,
)

// Container - çok amaçlı kutu
Container(
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
  ),
  child: widget,
)
```

### 📝 Input Widgets
```dart
// Metin girişi
TextField(
  controller: textController,
  decoration: InputDecoration(
    hintText: 'Metin girin',
    border: OutlineInputBorder(),
  ),
  onChanged: (value) => print(value),
)

// Buton
ElevatedButton(
  onPressed: () => print('Tıklandı'),
  child: Text('Buton'),
)

// Açılır menü
DropdownButton<String>(
  value: selectedValue,
  items: items.map((item) => DropdownMenuItem(
    value: item,
    child: Text(item),
  )).toList(),
  onChanged: (value) => setState(() => selectedValue = value),
)
```

### 🔔 User Feedback
```dart
// SnackBar - alt bildirim
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Mesaj')),
);

// Dialog - popup
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
```

### ⚡ Asenkron Programlama
```dart
// Future - gelecekte tamamlanacak işlem
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Veri yüklendi';
}

// Kullanımı
void loadData() async {
  String result = await fetchData();
  print(result);
}

// Error handling
try {
  String result = await fetchData();
  print(result);
} catch (e) {
  print('Hata: $e');
}
```

---

## 8. Sonuç ve İleri Adımlar

### 🎉 Öğrendikleriniz
✅ Flutter proje yapısı  
✅ Widget Tree konsepti  
✅ State Management  
✅ Navigation sistemi  
✅ UI/UX tasarım prensipleri  
✅ Asenkron programlama  
✅ Veri modelleme  
✅ Third-party paket kullanımı  
✅ Platform entegrasyonu (kamera, izinler)  

### 🚀 İleri Adımlar
1. **Veritabanı Entegrasyonu** - SQLite, Hive veya Firebase
2. **State Management** - Provider, Riverpod, Bloc
3. **Network İşlemleri** - HTTP istekleri, REST API
4. **Animasyonlar** - Hero animations, Lottie
5. **Platform Özellikleri** - Native kod entegrasyonu
6. **Test Yazma** - Unit, Widget, Integration testler
7. **Deployment** - Play Store/App Store yayımlama

### 📚 Önerilen Kaynaklar
- **Flutter Dokümantasyonu:** https://flutter.dev/docs
- **Dart Dili:** https://dart.dev/guides
- **Flutter Widget Kataloğu:** https://flutter.dev/docs/development/ui/widgets
- **pub.dev:** https://pub.dev (Paket deposu)

---

**Bu doküman ile Flutter QR Kod projenizin tüm detaylarını öğrendiniz! 🎓**

*Hazırlayan: GitHub Copilot*  
*Tarih: 6 Ekim 2025*