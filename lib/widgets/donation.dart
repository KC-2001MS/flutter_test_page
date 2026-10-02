import 'package:flutter/material.dart';

import '../site/language.dart';
import '../site/links.dart';
import '../site/site_theme.dart';
import 'headings.dart';

/// 記事の末尾に置く寄付の案内（ブログ・ニュースルーム・Tips）
class DonationSection extends StatelessWidget {
  const DonationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = SiteTypography.of(context).h3;
    final strings = SiteLanguage.of(context).strings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SiteDivider(),
        Padding(
          padding: EdgeInsets.only(top: size * 1.5, bottom: size * 0.5),
          child: Text(
            strings.donationTitle,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
              letterSpacing: size * 0.02,
            ),
          ),
        ),
        Text(strings.donationBody),
        const DonationButtons(),
      ],
    );
  }
}

/// 寄付のボタン（Buy Me a Coffee・PayPal・GitHub Sponsors）
///
/// 幅が640px以下では縦に並べる。
class DonationButtons extends StatelessWidget {
  const DonationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width <= 640;
    const buttons = [_BuyMeACoffeeButton(), _PayPalButton(), _SponsorButton()];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Flex(
        direction: narrow ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: buttons,
      ),
    );
  }
}

class _BuyMeACoffeeButton extends StatelessWidget {
  const _BuyMeACoffeeButton();

  @override
  Widget build(BuildContext context) {
    return SiteLink(
      href: 'https://www.buymeacoffee.com/iroiro',
      child: Image.network(
        'https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png',
        width: 217,
        height: 60,
        semanticLabel: 'Buy Me A Coffee',
        // 画像の配信元がCORSに対応していない場合は img 要素で表示する
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        errorBuilder: (_, _, _) => Container(
          width: 217,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFDD00),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Buy me a coffee',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// PayPalには公式のリンクボタンがないため、Buy Me a Coffeeのボタンと同じ大きさにする
class _PayPalButton extends StatefulWidget {
  const _PayPalButton();

  @override
  State<_PayPalButton> createState() => _PayPalButtonState();
}

class _PayPalButtonState extends State<_PayPalButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SiteLink(
        href: 'https://paypal.me/iroiroWork',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 217,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovering
                ? const Color(0xFF005EA6)
                : const Color(0xFF0070BA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Pay by PayPal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// GitHub Sponsorsのボタン（元サイトでは GitHub の iframe を埋め込んでいる）
class _SponsorButton extends StatelessWidget {
  const _SponsorButton();

  @override
  Widget build(BuildContext context) {
    final dark = SiteColors.of(context).isDark;

    return SiteLink(
      href: 'https://github.com/sponsors/KC-2001MS',
      child: Container(
        width: 114,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: dark ? const Color(0xFF363B42) : const Color(0xFFD1D9E0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 16,
              color: Color(0xFFBF3989),
            ),
            Text(
              'Sponsor',
              style: TextStyle(
                fontSize: 14,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: dark ? const Color(0xFFF0F6FC) : const Color(0xFF25292E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
