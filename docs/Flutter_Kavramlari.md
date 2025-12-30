# 🧠 Flutter Kavramları - Hızlı Referans

Bu dosya Flutter geliştirme sürecinde öğrendiğiniz temel kavramları içerir.

---

## 🏗️ Widget Hierarchy (Widget Hiyerarşisi)

### Widget Tree Yapısı
```
MaterialApp (Kök)
├── Scaffold (Sayfa İskelet)
│   ├── AppBar (Üst Bar)
│   └── Body (Ana İçerik)
│       ├── Column/Row (Sıralama)
│       ├── Container (Kutu)
│       ├── Card (Kart)
│       └── ListView (Liste)
```

### Temel Widget Kategorileri
- **Layout Widgets:** Column, Row, Container, Padding, Expanded
- **Input Widgets:** TextField, Button, Dropdown, Checkbox
- **Display Widgets:** Text, Image, Icon, Card
- **Interactive Widgets:** InkWell, GestureDetector, Dismissible

---

## 🔄 State Management (Durum Yönetimi)

### StatelessWidget (Durumu olmayan)
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(); // UI değişmez
  }
}
```

### StatefulWidget (Durumu olan)
```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  String data = ''; // Değişebilir durum
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### setState() Kullanımı
```dart
setState(() {
  // Durum değişikliği
  variable = newValue;
}); // UI otomatik güncellenir
```

---

## 🧭 Navigation (Sayfa Geçişi)

### Temel Navigation
```dart
// Yeni sayfa aç
Navigator.push(context, MaterialPageRoute(
  builder: (context) => NewScreen(),
));

// Geri dön
Navigator.pop(context);

// Sayfa değiştir
Navigator.pushReplacement(context, MaterialPageRoute(
  builder: (context) => NewScreen(),
));
```

### Veri Gönderme
```dart
// Veri ile sayfa aç
Navigator.push(context, MaterialPageRoute(
  builder: (context) => DetailScreen(data: myData),
));

// Constructor ile veri al
class DetailScreen extends StatelessWidget {
  final String data;
  
  DetailScreen({required this.data});
}
```

---

## 📱 Layout Kavramları

### Flex System
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,    // Dikey hizalama
  crossAxisAlignment: CrossAxisAlignment.start,   // Yatay hizalama
  children: [...],
)

Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Yatay hizalama
  crossAxisAlignment: CrossAxisAlignment.center,    // Dikey hizalama
  children: [...],
)
```

### Expanded ve Flexible
```dart
Row(
  children: [
    Expanded(flex: 2, child: widget1), // 2/3 alan
    Expanded(flex: 1, child: widget2), // 1/3 alan
  ],
)
```

### Padding ve Margin
```dart
Padding(
  padding: EdgeInsets.all(16),        // Her taraftan 16px
  child: widget,
)

Container(
  margin: EdgeInsets.symmetric(        // Simetrik margin
    horizontal: 16,
    vertical: 8,
  ),
  child: widget,
)
```

---

## 🎨 Styling (Stil Verme)

### Theme Kullanımı
```dart
Theme.of(context).textTheme.headlineSmall
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.secondary
```

### Decoration
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 3),
      ),
    ],
  ),
)
```

### Text Styling
```dart
Text(
  'Merhaba',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    letterSpacing: 1.2,
  ),
)
```

---

## 📝 Input Handling (Giriş İşleme)

### TextField
```dart
TextField(
  controller: textController,
  decoration: InputDecoration(
    labelText: 'Etiket',
    hintText: 'İpucu metni',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (value) => print(value),
  onSubmitted: (value) => submitForm(),
)
```

### Button'lar
```dart
ElevatedButton(
  onPressed: () => doSomething(),
  child: Text('Buton'),
)

TextButton(
  onPressed: () => doSomething(),
  child: Text('Metin Buton'),
)

IconButton(
  onPressed: () => doSomething(),
  icon: Icon(Icons.favorite),
)
```

### Dropdown
```dart
DropdownButton<String>(
  value: selectedValue,
  items: items.map((item) => DropdownMenuItem(
    value: item,
    child: Text(item),
  )).toList(),
  onChanged: (value) => setState(() => selectedValue = value),
)
```

---

## 📋 Lists (Listeler)

### ListView.builder (Performanslı)
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].title),
      subtitle: Text(items[index].subtitle),
      onTap: () => selectItem(index),
    );
  },
)
```

### ListView (Basit)
```dart
ListView(
  children: [
    ListTile(title: Text('Öğe 1')),
    ListTile(title: Text('Öğe 2')),
    ListTile(title: Text('Öğe 3')),
  ],
)
```

---

## 💬 Dialogs ve Feedback

### AlertDialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Başlık'),
    content: Text('Mesaj içeriği'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('İptal'),
      ),
      ElevatedButton(
        onPressed: () {
          doAction();
          Navigator.pop(context);
        },
        child: Text('Tamam'),
      ),
    ],
  ),
);
```

### SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('İşlem tamamlandı'),
    duration: Duration(seconds: 2),
    action: SnackBarAction(
      label: 'Geri Al',
      onPressed: () => undoAction(),
    ),
  ),
);
```

### BottomSheet
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    height: 200,
    child: Column(
      children: [
        ListTile(title: Text('Seçenek 1')),
        ListTile(title: Text('Seçenek 2')),
      ],
    ),
  ),
);
```

---

## ⚡ Asenkron İşlemler

### Future ve async/await
```dart
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Veri yüklendi';
}

void loadData() async {
  try {
    String result = await fetchData();
    setState(() {
      data = result;
    });
  } catch (e) {
    print('Hata: $e');
  }
}
```

### FutureBuilder
```dart
FutureBuilder<String>(
  future: fetchData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Hata: ${snapshot.error}');
    } else {
      return Text('Veri: ${snapshot.data}');
    }
  },
)
```

---

## 🔧 Controllers ve Lifecycle

### TextEditingController
```dart
class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _controller.text = 'Başlangıç değeri';
  }
  
  @override
  void dispose() {
    _controller.dispose(); // Bellek sızıntısını önle
    super.dispose();
  }
}
```

### Lifecycle Methods
```dart
@override
void initState() {
  super.initState();
  // Widget ilk oluşturulduğunda bir kez çalışır
}

@override
void didUpdateWidget(MyWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  // Widget güncellendiğinde çalışır
}

@override
void dispose() {
  // Widget silindiğinde çalışır
  super.dispose();
}
```

---

## 🎯 İyi Pratikler

### Widget Organizasyonu
```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // 1. Değişkenler
  String data = '';
  
  // 2. Lifecycle methods
  @override
  void initState() {
    super.initState();
  }
  
  // 3. build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
  
  // 4. Helper methods
  Widget _buildBody() {
    return Container();
  }
  
  // 5. Event handlers
  void _handleButtonPress() {
    setState(() {
      data = 'Updated';
    });
  }
}
```

### Performance İpuçları
- `const` anahtar kelimesini kullanın
- `ListView.builder` kullanın (büyük listeler için)
- Gereksiz `setState()` çağrılarından kaçının
- Widget'ları küçük parçalara bölün
- Controllers'ı dispose edin

### Kod Düzeni
- Widget metodlarını `_build` ile başlatın
- Event handler'ları `_handle` ile başlatın
- Private metodları `_` ile başlatın
- Açıklayıcı isimler kullanın

---

## 📱 Platform Özellikleri

### İzin İsteme
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}
```

### Cihaz Bilgileri
```dart
import 'dart:io';

if (Platform.isAndroid) {
  // Android özel kod
} else if (Platform.isIOS) {
  // iOS özel kod
}
```

---

## 🐛 Debug İpuçları

### Print Kullanımı
```dart
print('Debug: $variable');
debugPrint('Flutter debug mesajı');
```

### Error Handling
```dart
try {
  await riskyOperation();
} catch (e) {
  print('Hata yakalandı: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Bir hata oluştu')),
  );
}
```

### Widget Inspector
- Flutter Inspector'ı kullanın
- Widget ağacını görselleştirin
- Layout sorunlarını tespit edin

---

*Bu referans Flutter geliştirme sürecinde hızlı erişim için hazırlanmıştır.*  
*Hazırlayan: GitHub Copilot - 6 Ekim 2025*