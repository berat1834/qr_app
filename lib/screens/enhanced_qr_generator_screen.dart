import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_theme_provider.dart';
import '../services/feedback_service.dart';
import '../services/share_service.dart';
import '../services/history_service.dart';
import '../utils/qr_helpers.dart';

class EnhancedQRGeneratorScreen extends StatefulWidget {
  const EnhancedQRGeneratorScreen({super.key});

  @override
  State<EnhancedQRGeneratorScreen> createState() =>
      _EnhancedQRGeneratorScreenState();
}

class _EnhancedQRGeneratorScreenState extends State<EnhancedQRGeneratorScreen>
    with TickerProviderStateMixin {
  String qrData = '';
  String selectedType = 'Metin';
  final List<String> qrTypes = [
    'Metin',
    'URL',
    'WiFi',
    'Telefon',
    'E-mail',
    'SMS',
    'Konum',
    'Kartvizit',
  ];

  // Form controllers
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  final TextEditingController _smsMessageController = TextEditingController();

  // WiFi controllers
  final TextEditingController _wifiSsidController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController();
  String _wifiSecurity = 'WPA';

  // Location controllers
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  // vCard controllers
  final TextEditingController _vCardNameController = TextEditingController();
  final TextEditingController _vCardPhoneController = TextEditingController();
  final TextEditingController _vCardEmailController = TextEditingController();
  final TextEditingController _vCardOrgController = TextEditingController();
  final TextEditingController _vCardUrlController = TextEditingController();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _textController.addListener(_generateQR);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Üretici'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Yardım',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 20),
            _buildInputForm(),
            const SizedBox(height: 20),
            if (qrData.isNotEmpty) ...[
              _buildQRPreview(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QR Kod Türü Seçin:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: qrTypes.map((type) {
                final isSelected = selectedType == type;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        FeedbackService.buttonTapFeedback();
                        setState(() {
                          selectedType = type;
                          qrData = '';
                        });
                        _clearAllControllers();
                      }
                    },
                    backgroundColor: isSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                        : null,
                    selectedColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.3),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildFormForSelectedType(),
        ),
      ),
    );
  }

  Widget _buildFormForSelectedType() {
    switch (selectedType) {
      case 'Metin':
        return _buildTextForm();
      case 'URL':
        return _buildUrlForm();
      case 'WiFi':
        return _buildWiFiForm();
      case 'Telefon':
        return _buildPhoneForm();
      case 'E-mail':
        return _buildEmailForm();
      case 'SMS':
        return _buildSmsForm();
      case 'Konum':
        return _buildLocationForm();
      case 'Kartvizit':
        return _buildVCardForm();
      default:
        return _buildTextForm();
    }
  }

  Widget _buildTextForm() {
    return Column(
      key: const ValueKey('text'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metin Girişi:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: 'QR kod olacak metni yazın...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.text_fields),
          ),
          maxLines: 3,
          onChanged: (value) => _generateQR(),
        ),
      ],
    );
  }

  Widget _buildUrlForm() {
    return Column(
      key: const ValueKey('url'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('URL Girişi:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: 'https://www.example.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                _urlController.text = 'https://';
                _generateQR();
              },
              icon: const Icon(Icons.https),
              label: const Text('HTTPS'),
            ),
            TextButton.icon(
              onPressed: () {
                _urlController.text = 'http://';
                _generateQR();
              },
              icon: const Icon(Icons.http),
              label: const Text('HTTP'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWiFiForm() {
    return Column(
      key: const ValueKey('wifi'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('WiFi Bilgileri:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('wifi_ssid_field'),
          controller: _wifiSsidController,
          decoration: const InputDecoration(
            labelText: 'Ağ Adı (SSID)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wifi),
            hintText: 'WiFi ağ adını girin',
          ),
          textInputAction: TextInputAction.next,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('wifi_password_field'),
          controller: _wifiPasswordController,
          decoration: const InputDecoration(
            labelText: 'Şifre',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
            hintText: 'WiFi şifresini girin',
          ),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const ValueKey('wifi_security_dropdown'),
          initialValue: _wifiSecurity,
          decoration: const InputDecoration(
            labelText: 'Güvenlik Türü',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.security),
          ),
          items: ['WPA', 'WEP', 'nopass'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value == 'nopass' ? 'Açık Ağ' : value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _wifiSecurity = newValue!;
            });
            _generateQR();
          },
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Telefon Numarası:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            hintText: '+90 555 123 45 67',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) => _generateQR(),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('E-mail Adresi:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'ornek@email.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => _generateQR(),
        ),
      ],
    );
  }

  Widget _buildSmsForm() {
    return Column(
      key: const ValueKey('sms'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SMS Bilgileri:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        TextField(
          controller: _smsController,
          decoration: const InputDecoration(
            labelText: 'Telefon Numarası',
            hintText: '+90 555 123 45 67',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _smsMessageController,
          decoration: const InputDecoration(
            labelText: 'Mesaj',
            hintText: 'SMS mesajınızı yazın...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.message),
          ),
          maxLines: 3,
          onChanged: (value) => _generateQR(),
        ),
      ],
    );
  }

  Widget _buildLocationForm() {
    return Column(
      key: const ValueKey('location'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Konum Bilgileri:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        TextField(
          controller: _latitudeController,
          decoration: const InputDecoration(
            labelText: 'Enlem (Latitude)',
            hintText: '41.0082',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _longitudeController,
          decoration: const InputDecoration(
            labelText: 'Boylam (Longitude)',
            hintText: '28.9784',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _getCurrentLocation,
          icon: const Icon(Icons.my_location),
          label: const Text('Mevcut Konumu Al'),
        ),
      ],
    );
  }

  Widget _buildVCardForm() {
    return Column(
      key: const ValueKey('vcard'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kartvizit Bilgileri:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _vCardNameController,
          decoration: const InputDecoration(
            labelText: 'Ad Soyad',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _vCardPhoneController,
          decoration: const InputDecoration(
            labelText: 'Telefon',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _vCardEmailController,
          decoration: const InputDecoration(
            labelText: 'E-mail',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _vCardOrgController,
          decoration: const InputDecoration(
            labelText: 'Şirket/Organizasyon',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _vCardUrlController,
          decoration: const InputDecoration(
            labelText: 'Web Sitesi',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.web),
          ),
          keyboardType: TextInputType.url,
          onChanged: (value) => _generateQR(),
        ),
      ],
    );
  }

  Widget _buildQRPreview() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 6,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'QR Kod Önizleme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: context.watch<ThemeProvider>().isDarkMode
                          ? Colors.black
                          : Colors.black,
                    ),
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: context.watch<ThemeProvider>().isDarkMode
                          ? Colors.black
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FutureBuilder<bool>(
      future: qrData.isNotEmpty
          ? FavoritesService.isFavorite(qrData)
          : Future.value(false),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy),
                label: const Text('Kopyala'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _shareQR,
                icon: const Icon(Icons.share),
                label: const Text('Paylaş'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _saveToHistory,
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: (qrData.isEmpty || isFavorite)
                    ? null
                    : () async {
                        String? note = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            final controller = TextEditingController();
                            return AlertDialog(
                              title: const Text('Favori Notu/Etiği'),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Kısa not veya etiket (isteğe bağlı)',
                                ),
                                maxLength: 40,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('İptal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(
                                    context,
                                    controller.text.trim(),
                                  ),
                                  child: const Text('Ekle'),
                                ),
                              ],
                            );
                          },
                        );
                        try {
                          final qrType = QRCodeUtils.determineQRType(qrData);
                          await FavoritesService.addToFavorites(
                            data: qrData,
                            type: qrType,
                            customName: (note != null && note.isNotEmpty)
                                ? note
                                : null,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⭐ Favorilere eklendi!'),
                              ),
                            );
                            setState(() {}); // Favori durumu güncellensin
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Zaten favorilerde veya hata: ${e.toString()}',
                                ),
                              ),
                            );
                          }
                        }
                      },
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text(isFavorite ? 'Favoride' : 'Favorilere Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _generateQR() {
    String data = '';

    switch (selectedType) {
      case 'Metin':
        data = _textController.text;
        break;
      case 'URL':
        data = _urlController.text;
        break;
      case 'WiFi':
        if (_wifiSsidController.text.isNotEmpty) {
          data =
              'WIFI:T:$_wifiSecurity;S:${_wifiSsidController.text};P:${_wifiPasswordController.text};;';
        }
        break;
      case 'Telefon':
        data = 'tel:${_phoneController.text}';
        break;
      case 'E-mail':
        data = 'mailto:${_emailController.text}';
        break;
      case 'SMS':
        if (_smsController.text.isNotEmpty) {
          data = 'sms:${_smsController.text}';
          if (_smsMessageController.text.isNotEmpty) {
            data += ':${_smsMessageController.text}';
          }
        }
        break;
      case 'Konum':
        if (_latitudeController.text.isNotEmpty &&
            _longitudeController.text.isNotEmpty) {
          data = 'geo:${_latitudeController.text},${_longitudeController.text}';
        }
        break;
      case 'Kartvizit':
        if (_vCardNameController.text.isNotEmpty) {
          data = _generateVCard();
        }
        break;
    }

    if (data != qrData && data.isNotEmpty) {
      setState(() {
        qrData = data;
      });

      // QR kod oluşturuldu feedback
      FeedbackService.qrGeneratedFeedback();

      // Animasyonları başlat
      _fadeController.forward();
      _scaleController.forward();
    } else if (data.isEmpty) {
      setState(() {
        qrData = '';
      });
      _fadeController.reset();
      _scaleController.reset();
    }
  }

  String _generateVCard() {
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:${_vCardNameController.text}');
    if (_vCardPhoneController.text.isNotEmpty) {
      buffer.writeln('TEL:${_vCardPhoneController.text}');
    }
    if (_vCardEmailController.text.isNotEmpty) {
      buffer.writeln('EMAIL:${_vCardEmailController.text}');
    }
    if (_vCardOrgController.text.isNotEmpty) {
      buffer.writeln('ORG:${_vCardOrgController.text}');
    }
    if (_vCardUrlController.text.isNotEmpty) {
      buffer.writeln('URL:${_vCardUrlController.text}');
    }
    buffer.writeln('END:VCARD');
    return buffer.toString();
  }

  void _clearAllControllers() {
    _textController.clear();
    _urlController.clear();
    _phoneController.clear();
    _emailController.clear();
    _smsController.clear();
    _smsMessageController.clear();
    _wifiSsidController.clear();
    _wifiPasswordController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _vCardNameController.clear();
    _vCardPhoneController.clear();
    _vCardEmailController.clear();
    _vCardOrgController.clear();
    _vCardUrlController.clear();
  }

  void _getCurrentLocation() {
    // Örnek koordinatlar (İstanbul)
    _latitudeController.text = '41.0082';
    _longitudeController.text = '28.9784';
    _generateQR();
    FeedbackService.buttonTapFeedback();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Örnek konum bilgileri yüklendi (İstanbul)'),
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: qrData));
    FeedbackService.buttonTapFeedback();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR kod verisi panoya kopyalandı')),
    );
  }

  void _shareQR() {
    FeedbackService.buttonTapFeedback();
    ShareService.shareText(qrData);
  }

  void _saveToHistory() async {
    if (qrData.isNotEmpty) {
      final qrType = QRCodeUtils.determineQRType(qrData);
      await HistoryService.addToHistory(
        data: qrData,
        type: qrType,
        isScanned: false, // Bu oluşturulmuş bir QR
      );
      FeedbackService.qrGeneratedFeedback();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR kod geçmişe kaydedildi')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir QR kod oluşturun')),
      );
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Kod Türleri Hakkında'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpItem('📝 Metin', 'Basit metin içeriği'),
                _buildHelpItem('🔗 URL', 'Web sitesi bağlantıları'),
                _buildHelpItem('📶 WiFi', 'WiFi ağ bilgileri (SSID, şifre)'),
                _buildHelpItem('📞 Telefon', 'Telefon numaraları'),
                _buildHelpItem('📧 E-mail', 'E-mail adresleri'),
                _buildHelpItem('💬 SMS', 'SMS gönderme bilgileri'),
                _buildHelpItem('📍 Konum', 'GPS koordinatları'),
                _buildHelpItem('👤 Kartvizit', 'Kişi iletişim bilgileri'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: description),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _textController.dispose();
    _urlController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _smsController.dispose();
    _smsMessageController.dispose();
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _vCardNameController.dispose();
    _vCardPhoneController.dispose();
    _vCardEmailController.dispose();
    _vCardOrgController.dispose();
    _vCardUrlController.dispose();
    super.dispose();
  }
}
