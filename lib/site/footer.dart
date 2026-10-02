import 'package:flutter/material.dart';

import 'language.dart';
import 'links.dart';

/// サイト共通のフッター（著作権表示。問い合わせページへのリンク）
class SiteFooter extends StatelessWidget {
  final Color color;
  final List<Shadow>? shadows;

  const SiteFooter({super.key, required this.color, this.shadows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // #copyright の上下の余白（1.67em）
      padding: const EdgeInsets.symmetric(vertical: 12 * 1.67),
      child: Center(
        child: SiteLink(
          href: SiteLanguage.of(context).path('/contact'),
          child: Text(
            '© 2024 Keisuke Chinone',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: shadows,
            ),
          ),
        ),
      ),
    );
  }
}
