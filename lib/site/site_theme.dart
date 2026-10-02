import 'package:flutter/material.dart';

// 元サイトの var.css の値
const defaultBlack = Color.fromRGBO(25, 25, 25, 1);
const defaultWhite = Color.fromRGBO(230, 230, 230, 1);
const erDark = Color.fromRGBO(55, 55, 55, 1);
const erLight = Color.fromRGBO(200, 200, 200, 1);
const linkColor = Color.fromRGBO(100, 100, 255, 1);
const accentColor3 = Color.fromRGBO(100, 100, 200, 1);
const priceColor = Color.fromRGBO(255, 80, 80, 1);
const cornerRadius = 16.0;

/// 現在のテーマ（ライト・ダーク）に応じたサイトの色
class SiteColors {
  final Brightness brightness;

  const SiteColors(this.brightness);

  factory SiteColors.of(BuildContext context) =>
      SiteColors(Theme.of(context).brightness);

  bool get isDark => brightness == Brightness.dark;

  /// body の背景（ヘッダー・フッターの部分）
  Color get body => isDark ? erDark : erLight;

  /// main の背景
  Color get main => isDark ? defaultBlack : defaultWhite;

  /// 文字色（currentColor）
  Color get text => isDark ? defaultWhite : defaultBlack;

  /// color-mix(in srgb, currentColor N%, transparent) に相当する色
  Color mix(double percent) => text.withValues(alpha: percent / 100);

  /// カード・表・コードブロック共通の面
  Color get surface => mix(6);
  Color get surfaceBorder => mix(10);
}

/// 画面幅に応じた見出しの大きさ（var.css の --h1size など）
class SiteTypography {
  final double h1;
  final double h2;
  final double h3;
  final double h4;
  final double p;
  final double h5;

  const SiteTypography._(this.h1, this.h2, this.h3, this.h4, this.p, this.h5);

  static const _wide = SiteTypography._(35, 30, 22, 18, 16, 12);
  static const _narrow = SiteTypography._(30, 26, 20, 17, 16, 12);

  factory SiteTypography.of(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 800 ? _wide : _narrow;
}

ThemeData buildTheme(Brightness brightness) {
  final colors = SiteColors(brightness);
  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: colors.body,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentColor3,
      brightness: brightness,
    ),
    textTheme: Typography.material2021().black.apply(
      bodyColor: colors.text,
      displayColor: colors.text,
    ),
    // ブラウザの表示に合わせて、ホバー時の波紋などは出さない
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
  );
}
