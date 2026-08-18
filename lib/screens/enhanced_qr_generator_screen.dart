import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/favorites_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/enhanced_theme_provider.dart';
import '../services/feedback_service.dart';
import '../services/share_service.dart';
import '../services/history_service.dart';
import '../utils/qr_helpers.dart';
import '../l10n/app_localizations.dart';

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

  // Advanced Settings
  int _errorCorrectionLevel = QrErrorCorrectLevel.M; // Varsayılan Medium
  File? _embeddedImage;

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

  // --- YARDIMCI FONKSİYONLAR BURADA ---
  // ... (tüm _buildX, _generateX, _clearAllControllers, _showHelpDialog, vs. fonksiyonları buraya taşınacak) ...

  @override
  Widget build(BuildContext context) {
    final Color shadowColor = Colors.black.withValues(alpha: 0.06);
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.enhancedQrGenTitle),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHelpDialog,
            tooltip: loc.enhancedQrGenHelpTooltip,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üstte büyük kart başlık
            Card(
              elevation: 8,
              shadowColor: shadowColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Icon(
                        Icons.qr_code_2,
                        size: 36,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.enhancedQrGenHeaderTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.enhancedQrGenHeaderSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tür seçici kartı
            _buildTypeSelector(),
            const SizedBox(height: 16),
            // Giriş formu kartı
            _buildInputForm(),
            const SizedBox(height: 16),
            // Gelişmiş ayarlar kartı
            _buildAdvancedOptions(),
            const SizedBox(height: 16),
            if (qrData.isNotEmpty) ...[
              // QR önizleme kartı
              _buildQRPreview(),
              const SizedBox(height: 16),
              // Aksiyon butonları kartı
              Card(
                elevation: 4,
                shadowColor: shadowColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  child: _buildActionButtons(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.enhancedQrGenTypeSelect,
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
                    label: Text(_typeDisplayLabel(type, loc)),
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('text'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.enhancedQrGenTextInput,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: loc.enhancedQrGenTextHint,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.text_fields),
          ),
          maxLines: 3,
          onChanged: (value) => _generateQR(),
        ),
      ],
    );
  }

  Widget _buildUrlForm() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('url'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.enhancedQrGenUrlInput,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: loc.enhancedQrGenUrlHint,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.link),
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
              label: Text(loc.enhancedQrGenHttps),
            ),
            TextButton.icon(
              onPressed: () {
                _urlController.text = 'http://';
                _generateQR();
              },
              icon: const Icon(Icons.http),
              label: Text(loc.enhancedQrGenHttp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWiFiForm() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('wifi'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.enhancedQrGenWifiInfo,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('wifi_ssid_field'),
          controller: _wifiSsidController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenWifiSsid,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.wifi),
            hintText: loc.enhancedQrGenWifiSsidHint,
          ),
          textInputAction: TextInputAction.next,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('wifi_password_field'),
          controller: _wifiPasswordController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenWifiPassword,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock),
            hintText: loc.enhancedQrGenWifiPasswordHint,
          ),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const ValueKey('wifi_security_dropdown'),
          initialValue: _wifiSecurity,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenWifiSecurity,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.security),
          ),
          items: ['WPA', 'WEP', 'nopass'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value == 'nopass' ? loc.enhancedQrGenWifiOpenNetwork : value,
              ),
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
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.enhancedQrGenPhoneNumber,
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
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.enhancedQrGenEmailAddress,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: loc.enhancedQrGenEmailHint,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => _generateQR(),
        ),
      ],
    );
  }

  Widget _buildSmsForm() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('sms'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.enhancedQrGenSmsInfo,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _smsController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenPhoneNumberLabel,
            hintText: '+90 555 123 45 67',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _smsMessageController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenSmsMessage,
            hintText: loc.enhancedQrGenSmsHint,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.message),
          ),
          maxLines: 3,
          onChanged: (value) => _generateQR(),
        ),
      ],
    );
  }

  Widget _buildLocationForm() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('location'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.enhancedQrGenLocationInfo,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _latitudeController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenLatitude,
            hintText: '41.0082',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _longitudeController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenLongitude,
            hintText: '28.9784',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => _generateQR(),
        ),
      ],
    );
  }

  Widget _buildVCardForm() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('vcard'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.enhancedQrGenVcardInfo,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _vCardNameController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenFullName,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person),
          ),
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _vCardPhoneController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenPhone,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _vCardEmailController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenEmail,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _vCardOrgController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenCompany,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.business),
          ),
          onChanged: (value) => _generateQR(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _vCardUrlController,
          decoration: InputDecoration(
            labelText: loc.enhancedQrGenWebsite,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.web),
          ),
          keyboardType: TextInputType.url,
          onChanged: (value) => _generateQR(),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ExpansionTile(
          title: Text(
            loc.enhancedQrGenAdvancedSettings,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          leading: const Icon(Icons.settings_suggest),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Hata Düzeltme Seviyesi Seçimi
                  DropdownButtonFormField<int>(
                    initialValue: _errorCorrectionLevel,
                    decoration: InputDecoration(
                      labelText: loc.enhancedQrGenErrorCorrection,
                      border: const OutlineInputBorder(),
                      helperText: loc.enhancedQrGenErrorCorrectionHint,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: QrErrorCorrectLevel.L,
                        child: Text(loc.enhancedQrGenErrorLow),
                      ),
                      DropdownMenuItem(
                        value: QrErrorCorrectLevel.M,
                        child: Text(loc.enhancedQrGenErrorMedium),
                      ),
                      DropdownMenuItem(
                        value: QrErrorCorrectLevel.Q,
                        child: Text(loc.enhancedQrGenErrorQuality),
                      ),
                      DropdownMenuItem(
                        value: QrErrorCorrectLevel.H,
                        child: Text(loc.enhancedQrGenErrorHigh),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _errorCorrectionLevel = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Logo Seçimi
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickEmbeddedImage,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(
                            _embeddedImage == null
                                ? loc.enhancedQrGenAddLogo
                                : loc.enhancedQrGenChangeLogo,
                          ),
                        ),
                      ),
                      if (_embeddedImage != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _embeddedImage = null;
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: loc.enhancedQrGenRemoveLogo,
                        ),
                        const SizedBox(width: 8),
                        Image.file(
                          _embeddedImage!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRPreview() {
    final loc = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  loc.enhancedQrGenPreview,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    errorCorrectionLevel: _errorCorrectionLevel,
                    embeddedImage: _embeddedImage != null
                        ? FileImage(_embeddedImage!)
                        : null,
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(40, 40), // Logo boyutu
                    ),
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
    final loc = AppLocalizations.of(context)!;
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
                label: Text(loc.enhancedQrGenCopy),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _shareQR,
                icon: const Icon(Icons.share),
                label: Text(loc.enhancedQrGenShare),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _saveToHistory,
                icon: const Icon(Icons.save),
                label: Text(loc.enhancedQrGenSave),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: (qrData.isEmpty || isFavorite)
                    ? null
                    : () async {
                        final String? note = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            final controller = TextEditingController();
                            return AlertDialog(
                              title: Text(
                                AppLocalizations.of(
                                  context,
                                )!.enhancedQrGenFavoriteNoteTitle,
                              ),
                              content: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.enhancedQrGenFavoriteNoteHint,
                                ),
                                maxLength: 40,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    AppLocalizations.of(context)!.commonCancel,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(
                                    context,
                                    controller.text.trim(),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.enhancedQrGenAdd,
                                  ),
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
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  loc.enhancedQrGenAddedToFavorites,
                                ),
                              ),
                            );
                            setState(() {}); // Favori durumu güncellensin
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  loc.enhancedQrGenFavoriteError(e.toString()),
                                ),
                              ),
                            );
                          }
                        }
                      },
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text(
                  isFavorite
                      ? loc.enhancedQrGenFavorited
                      : loc.enhancedQrGenAddToFavorites,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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

  Future<void> _pickEmbeddedImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _embeddedImage = File(image.path);
        // Logo eklendiğinde hata düzeltme seviyesini otomatik yükseltmek iyi bir pratiktir
        if (_errorCorrectionLevel == QrErrorCorrectLevel.L) {
          _errorCorrectionLevel = QrErrorCorrectLevel.Q;
        }
      });
    }
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

  void _copyToClipboard() {
    final loc = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: qrData));
    FeedbackService.buttonTapFeedback();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.enhancedQrGenCopiedToClipboard)));
  }

  void _shareQR() {
    FeedbackService.buttonTapFeedback();
    ShareService.shareText(qrData);
  }

  void _saveToHistory() async {
    final loc = AppLocalizations.of(context)!;
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
          SnackBar(content: Text(loc.enhancedQrGenSavedToHistory)),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.enhancedQrGenCreateFirst)));
    }
  }

  void _showHelpDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.enhancedQrGenHelpTitle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpItem(
                  loc.enhancedQrGenHelpTextTitle,
                  loc.enhancedQrGenHelpTextDesc,
                ),
                _buildHelpItem(
                  loc.enhancedQrGenHelpUrlTitle,
                  loc.enhancedQrGenHelpUrlDesc,
                ),
                _buildHelpItem(
                  loc.enhancedQrGenHelpWifiTitle,
                  loc.enhancedQrGenHelpWifiDesc,
                ),
                _buildHelpItem(
                  loc.enhancedQrGenHelpPhoneTitle,
                  loc.enhancedQrGenHelpPhoneDesc,
                ),
                _buildHelpItem(
                  loc.enhancedQrGenHelpEmailTitle,
                  loc.enhancedQrGenHelpEmailDesc,
                ),
                _buildHelpItem(
                  loc.enhancedQrGenHelpSmsTitle,
                  loc.enhancedQrGenHelpSmsDesc,
                ),
                _buildHelpItem(
                  loc.enhancedQrGenHelpLocationTitle,
                  loc.enhancedQrGenHelpLocationDesc,
                ),
                _buildHelpItem(
                  loc.enhancedQrGenHelpVcardTitle,
                  loc.enhancedQrGenHelpVcardDesc,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.commonOk),
            ),
          ],
        );
      },
    );
  }

  String _typeDisplayLabel(String type, AppLocalizations loc) {
    switch (type) {
      case 'Metin':
        return loc.enhancedQrGenTypeText;
      case 'URL':
        return loc.enhancedQrGenTypeUrl;
      case 'WiFi':
        return loc.enhancedQrGenTypeWifi;
      case 'Telefon':
        return loc.enhancedQrGenTypePhone;
      case 'E-mail':
        return loc.enhancedQrGenTypeEmail;
      case 'SMS':
        return loc.enhancedQrGenTypeSms;
      case 'Konum':
        return loc.enhancedQrGenTypeLocation;
      case 'Kartvizit':
        return loc.enhancedQrGenTypeVcard;
      default:
        return type;
    }
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
