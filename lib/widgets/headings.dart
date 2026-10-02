import 'package:flutter/material.dart';

import '../site/site_theme.dart';

/// .card>h1（左に印の付いた大見出し）
class CardH1 extends StatelessWidget {
  final String text;

  const CardH1(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = SiteTypography.of(context).h2;

    return Padding(
      // h1 の上下の余白（0.67em）
      padding: EdgeInsets.symmetric(vertical: size * 0.67),
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                width: 4,
                height: size * 0.9,
                margin: EdgeInsets.only(right: size * 0.45),
                decoration: BoxDecoration(
                  color: accentColor3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            TextSpan(text: text),
          ],
        ),
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          height: 1.4,
          letterSpacing: size * 0.02,
        ),
      ),
    );
  }
}

/// .card>h2（下に薄い線を引いた中見出し）
class CardH2 extends StatelessWidget {
  final String text;

  const CardH2(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = SiteTypography.of(context).h3;
    final colors = SiteColors.of(context);

    return Container(
      // h2 の上下の余白（0.83em）
      margin: EdgeInsets.symmetric(vertical: size * 0.83),
      padding: EdgeInsets.only(bottom: size * 0.3),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.mix(25))),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          height: 1.4,
          letterSpacing: size * 0.02,
        ),
      ),
    );
  }
}

/// hr（文字色を薄くした区切り線）
class SiteDivider extends StatelessWidget {
  const SiteDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16 * 3, bottom: 10),
      height: 1,
      color: SiteColors.of(context).mix(15),
    );
  }
}
