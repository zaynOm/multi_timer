import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  static BannerAd? _bannerAd;
  static bool _adLoaded = false;

  final adUnitId =
      kReleaseMode
          ? 'ca-app-pub-2399613365902133/5306369784' // Real Ad Unit ID
          : 'ca-app-pub-3940256099942544/6300978111'; // Test Ad Unit ID

  @override
  void initState() {
    super.initState();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _adLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    // do not dispose shared ad to keep it alive on navigation
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdSize adSize = AdSize.banner;

    return SafeArea(
      child: SizedBox(
        width: adSize.width.toDouble(),
        height: adSize.height.toDouble(),
        child:
            (_adLoaded && _bannerAd != null) ? AdWidget(ad: _bannerAd!) : const SizedBox.shrink(),
      ),
    );
  }
}
