import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:multi_timer/providers/ad_provider.dart';
import 'package:provider/provider.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the AdProvider
    final adProvider = context.watch<AdProvider>();
    final bannerAd = adProvider.bannerAd;
    final isAdLoaded = adProvider.isBannerAdLoaded;
    final AdSize adSize = AdSize.banner;

    return SafeArea(
      child: SizedBox(
        width: adSize.width.toDouble(),
        height: adSize.height.toDouble(),
        child: (isAdLoaded && bannerAd != null) ? AdWidget(ad: bannerAd) : const SizedBox.shrink(),
      ),
    );
  }
}
