import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdProvider extends ChangeNotifier {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  bool get isBannerAdLoaded => _isBannerAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  final String _adUnitId =
      kReleaseMode
          ? 'ca-app-pub-2399613365902133/5306369784' // Your Real Ad Unit ID
          : 'ca-app-pub-3940256099942544/6300978111'; // Test Ad Unit ID

  AdProvider() {
    loadBannerAd();
  }

  void loadBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAd loaded successfully via Provider.');
          _bannerAd = ad as BannerAd;
          _isBannerAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load via Provider: $error');
          _isBannerAdLoaded = false;
          ad.dispose();
          _bannerAd = null;
          notifyListeners();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }
}
