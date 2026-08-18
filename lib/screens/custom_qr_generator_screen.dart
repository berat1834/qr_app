// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/history_service.dart';

class CustomQRGeneratorScreen extends StatefulWidget {
  final String data;

  const CustomQRGeneratorScreen({super.key, required this.data});

  @override
  State<CustomQRGeneratorScreen> createState() =>
      _CustomQRGeneratorScreenState();
}

class _CustomQRGeneratorScreenState extends State<CustomQRGeneratorScreen> {
  // QR Özelleştirme seçenekleri
  Color foregroundColor = Colors.black;
  Color backgroundColor = Colors.white;
  double borderRadius = 0.0;
  bool hasLogo = false;
  String selectedLogo = 'flutter';
  double logoSize = 40.0;
  int errorCorrectLevel = QrErrorCorrectLevel.M;

  // Hazır renk paletleri
  final List<Map<String, dynamic>> colorPresets = [
    {'name': 'Klasik', 'fg': Colors.black, 'bg': Colors.white},
    {'name': 'Mavi', 'fg': Colors.blue, 'bg': Colors.blue.shade50},
    {'name': 'Yeşil', 'fg': Colors.green, 'bg': Colors.green.shade50},
    {'name': 'Kırmızı', 'fg': Colors.red, 'bg': Colors.red.shade50},
    {'name': 'Mor', 'fg': Colors.purple, 'bg': Colors.purple.shade50},
    {'name': 'Turuncu', 'fg': Colors.orange, 'bg': Colors.orange.shade50},
    {'name': 'Pembe', 'fg': Colors.pink, 'bg': Colors.pink.shade50},
    {'name': 'Koyu', 'fg': Colors.white, 'bg': Colors.black},
    {
      'name': 'Gradient Blue',
      'fg': Colors.blue.shade800,
      'bg': Colors.blue.shade100,
    },
    {
      'name': 'Gradient Green',
      'fg': Colors.green.shade800,
      'bg': Colors.green.shade100,
    },
  ];

  // Logo seçenekleri
  final Map<String, IconData> logoOptions = {
    'flutter': Icons.flutter_dash,
    'qr': Icons.qr_code,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'home': Icons.home,
    'business': Icons.business,
    'location': Icons.location_on,
    'phone': Icons.phone,
    'email': Icons.email,
    'wifi': Icons.wifi,
    'lock': Icons.lock,
    'verified': Icons.verified,
    'diamond': Icons.diamond,
    'bolt': Icons.bolt,
    'circle': Icons.circle,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customQrTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCustomQR,
            tooltip: AppLocalizations.of(context)!.customQrShareTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _saveCustomQR,
            tooltip: AppLocalizations.of(context)!.customQrSaveTooltip,
          ),
        ],
      ),
      body: Column(
        children: [
          // QR Preview
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(child: _buildCustomQR()),
            ),
          ),
          // Özelleştirme Paneli
          Expanded(flex: 3, child: _buildCustomizationPanel()),
        ],
      ),
    );
  }

  Widget _buildCustomQR() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: QrImageView(
        data: widget.data,
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: backgroundColor,
        errorCorrectionLevel: errorCorrectLevel,
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor,
        ),
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor,
        ),
      ),
    );
  }

  Widget _buildCustomizationPanel() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.palette),
                text: AppLocalizations.of(context)!.customQrTabColors,
              ),
              Tab(
                icon: const Icon(Icons.image),
                text: AppLocalizations.of(context)!.customQrTabLogo,
              ),
              Tab(
                icon: const Icon(Icons.tune),
                text: AppLocalizations.of(context)!.customQrTabStyle,
              ),
              Tab(
                icon: const Icon(Icons.settings),
                text: AppLocalizations.of(context)!.customQrTabSettings,
              ),
            ],
            isScrollable: true,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildColorTab(),
                _buildLogoTab(),
                _buildStyleTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.customQrPresetColors,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colorPresets.map((preset) {
              final isSelected =
                  preset['fg'] == foregroundColor &&
                  preset['bg'] == backgroundColor;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    foregroundColor = preset['fg'];
                    backgroundColor = preset['bg'];
                  });
                },
                child: Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: preset['bg'],
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: preset['fg'],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.customQrCustomColors,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.customQrColorFg),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showColorPicker(true),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: foregroundColor,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.customQrColorBg),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showColorPicker(false),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.customQrAddLogo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Switch(
                value: hasLogo,
                onChanged: (value) {
                  setState(() {
                    hasLogo = value;
                  });
                },
              ),
            ],
          ),
          if (hasLogo) ...[
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.customQrLogoSize),
            Slider(
              value: logoSize,
              min: 20,
              max: 80,
              divisions: 6,
              label: logoSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  logoSize = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.customQrSelectLogo),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: logoOptions.length,
                itemBuilder: (context, index) {
                  final entry = logoOptions.entries.elementAt(index);
                  final isSelected = selectedLogo == entry.key;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLogo = entry.key;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade100
                            : Colors.grey.shade100,
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        entry.value,
                        size: 30,
                        color: isSelected ? Colors.blue : Colors.grey.shade600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStyleTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.customQrCornerRadius,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: borderRadius,
            min: 0,
            max: 30,
            divisions: 6,
            label: borderRadius.round().toString(),
            onChanged: (value) {
              setState(() {
                borderRadius = value;
              });
            },
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.customQrErrorLevel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: errorCorrectLevel,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              DropdownMenuItem(
                value: QrErrorCorrectLevel.L,
                child: Text(AppLocalizations.of(context)!.customQrErrorLow),
              ),
              DropdownMenuItem(
                value: QrErrorCorrectLevel.M,
                child: Text(AppLocalizations.of(context)!.customQrErrorMid),
              ),
              DropdownMenuItem(
                value: QrErrorCorrectLevel.Q,
                child: Text(AppLocalizations.of(context)!.customQrErrorHigh),
              ),
              DropdownMenuItem(
                value: QrErrorCorrectLevel.H,
                child: Text(AppLocalizations.of(context)!.customQrErrorMax),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  errorCorrectLevel = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.customQrErrorTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.customQrErrorDesc,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.customQrInfo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.customQrInfoData(widget.data),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.customQrInfoCharCount(widget.data.length),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.customQrInfoErrorLevel(
                    _getErrorCorrectionName(errorCorrectLevel),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.customQrPresets,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetButton(
                AppLocalizations.of(context)!.customQrPresetClassic,
                () {
                  setState(() {
                    foregroundColor = Colors.black;
                    backgroundColor = Colors.white;
                    borderRadius = 0;
                    hasLogo = false;
                    errorCorrectLevel = QrErrorCorrectLevel.M;
                  });
                },
              ),
              _buildPresetButton(
                AppLocalizations.of(context)!.customQrPresetModern,
                () {
                  setState(() {
                    foregroundColor = Colors.blue.shade800;
                    backgroundColor = Colors.blue.shade50;
                    borderRadius = 16;
                    hasLogo = false;
                    errorCorrectLevel = QrErrorCorrectLevel.H;
                  });
                },
              ),
              _buildPresetButton(
                AppLocalizations.of(context)!.customQrPresetMinimal,
                () {
                  setState(() {
                    foregroundColor = Colors.grey.shade800;
                    backgroundColor = Colors.white;
                    borderRadius = 8;
                    hasLogo = false;
                    errorCorrectLevel = QrErrorCorrectLevel.L;
                  });
                },
              ),
              _buildPresetButton(
                AppLocalizations.of(context)!.customQrPresetPremium,
                () {
                  setState(() {
                    foregroundColor = Colors.deepPurple;
                    backgroundColor = Colors.deepPurple.shade50;
                    borderRadius = 20;
                    hasLogo = true;
                    selectedLogo = 'verified';
                    errorCorrectLevel = QrErrorCorrectLevel.H;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(String name, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(name),
    );
  }

  void _showColorPicker(bool isForeground) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isForeground
                ? AppLocalizations.of(context)!.customQrColorPickerFg
                : AppLocalizations.of(context)!.customQrColorPickerBg,
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: isForeground ? foregroundColor : backgroundColor,
              onColorChanged: (Color color) {
                setState(() {
                  if (isForeground) {
                    foregroundColor = color;
                  } else {
                    backgroundColor = color;
                  }
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.commonOk),
            ),
          ],
        );
      },
    );
  }

  String _getErrorCorrectionName(int level) {
    final loc = AppLocalizations.of(context)!;
    switch (level) {
      case QrErrorCorrectLevel.L:
        return loc.customQrErrorLowName;
      case QrErrorCorrectLevel.M:
        return loc.customQrErrorMidName;
      case QrErrorCorrectLevel.Q:
        return loc.customQrErrorHighName;
      case QrErrorCorrectLevel.H:
        return loc.customQrErrorMaxName;
      default:
        return loc.customQrErrorMidName;
    }
  }

  Future<void> _shareCustomQR() async {
    final loc = AppLocalizations.of(context)!;
    try {
      // QR kodunu bir resim olarak oluştur
      final qrValidationResult = QrValidator.validate(
        data: widget.data,
        version: QrVersions.auto,
        errorCorrectionLevel: errorCorrectLevel,
      );
      if (qrValidationResult.status != QrValidationStatus.valid) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.customQrErrorCreate)));
        return;
      }

      final painter = QrPainter(
        data: widget.data,
        version: QrVersions.auto,
        errorCorrectionLevel: errorCorrectLevel,
        color: foregroundColor,
        emptyColor: backgroundColor,
        gapless: true,
      );

      final picData = await painter.toImageData(
        800,
        format: ui.ImageByteFormat.png,
      );
      if (picData == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.customQrErrorImage)));
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/custom_qr.png').create();
      await file.writeAsBytes(picData.buffer.asUint8List());

      await Share.shareXFiles([
        XFile(file.path, mimeType: 'image/png'),
      ], text: loc.customQrShareText);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.customQrShareError(e.toString()))),
      );
    }
  }

  void _saveCustomQR() async {
    try {
      // QR kod geçmişe kaydet
      await HistoryService.addToHistory(
        data: widget.data,
        type: HistoryService.determineQRType(widget.data),
        isScanned: false, // Oluşturulan QR kod
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.customQrSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.customQrSaveError(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Basit renk seçici widget
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.black,
      Colors.white,
      Colors.grey,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lime,
      Colors.yellow,
      Colors.orange,
      Colors.brown,
      Colors.indigo,
    ];

    return Wrap(
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: pickerColor == color ? Colors.black : Colors.grey,
                width: pickerColor == color ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }).toList(),
    );
  }
}
