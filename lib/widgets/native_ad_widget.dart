import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// NativeAdWidget, AdMob native reklamını göstermek için kullanılır.
/// Ad unit ID'yi kendi AdMob panelinden almalısın.
class NativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final double height;
  const NativeAdWidget({super.key, required this.adUnitId, this.height = 110});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: widget.adUnitId,
      factoryId: 'listTile', // Android/iOS için platform tarafında tanımlanmalı
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: widget.height,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
