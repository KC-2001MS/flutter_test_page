import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../widgets/measured_layouts.dart';
import 'footer.dart';
import 'header.dart';
import 'language.dart';
import 'links.dart';
import 'site_theme.dart';

/// 通常のページ（ヘッダー・本文・フッターを縦に並べ、ページ全体をスクロールする）
class SitePage extends StatelessWidget {
  final String title;
  final Widget child;

  const SitePage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = SiteColors.of(context);

    return Title(
      title: title,
      color: colors.text,
      child: Scaffold(
        backgroundColor: colors.body,
        body: SelectionArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SiteHeader(color: colors.text),
                  ConstrainedBox(
                    // main の min-height: calc(100vh - 195px)
                    constraints: BoxConstraints(
                      minHeight: math.max(0, constraints.maxHeight - 195),
                    ),
                    child: ColoredBox(
                      color: colors.main,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        child: MainCard(child: child),
                      ),
                    ),
                  ),
                  SiteFooter(color: colors.text),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 本文の領域（#maincard。1200px以上では幅1200pxで中央に置く）
class MainCard extends StatelessWidget {
  final Widget child;

  const MainCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = SiteColors.of(context);
    final width = MediaQuery.sizeOf(context).width;

    final content = DefaultTextStyle.merge(
      style: TextStyle(color: colors.text, fontSize: 16, height: 1.8),
      child: child,
    );

    if (width >= 1200) {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 1200, child: content),
      );
    }
    return Padding(padding: const EdgeInsets.all(10), child: content);
  }
}

/// 写真を背景にしたページ（トップページ・404ページ）
class HeroPage extends StatelessWidget {
  final String title;
  final String heading;
  final String subtitle;

  const HeroPage({
    super.key,
    required this.title,
    required this.heading,
    required this.subtitle,
  });

  static const _textShadows = [
    Shadow(offset: Offset(0, 2), blurRadius: 24, color: Color(0x8C000000)),
    Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x66000000)),
  ];
  static const _barShadows = [
    Shadow(offset: Offset(0, 1), blurRadius: 8, color: Color(0x66000000)),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final portrait = size.height >= size.width;

    return Title(
      title: title,
      color: defaultWhite,
      child: Scaffold(
        // 写真の読み込み前に表示する色（写真の上端の平均色）
        backgroundColor: portrait
            ? const Color(0xFF384038)
            : const Color(0xFF60665F),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              backgroundImage(size, pixelRatio),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _GlassBar(
                  border: Border(bottom: _glassLine),
                  child: SiteHeader(color: defaultWhite, shadows: _barShadows),
                ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 画面の高さが足りない場合は、見出しの部分だけをスクロールする
                      SingleChildScrollView(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: _Goal(
                            heading: heading,
                            subtitle: subtitle,
                            shadows: _textShadows,
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 15,
                        bottom: 12,
                        child: _LanguageSwitch(),
                      ),
                    ],
                  ),
                ),
                const _GlassBar(
                  border: Border(top: _glassLine),
                  child: SiteFooter(color: defaultWhite, shadows: _barShadows),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 画面の大きさ・向き・解像度に合わせて背景の写真を選ぶ（home.module.css のメディアクエリ）
  static String backgroundImage(Size size, double pixelRatio) {
    final width = size.width;
    final portrait = size.height >= size.width;
    final retina = pixelRatio >= 2;
    final String name;

    if (width <= 1080) {
      name = portrait ? '607P' : '1080';
    } else if (width <= 1620) {
      name = portrait
          ? (retina ? '1440P' : '1080P')
          : (retina ? '2160' : '1920');
    } else if (width <= 3456) {
      name = retina ? '3456' : '1920';
    } else {
      name = retina ? '5120' : '3840';
    }
    return 'assets/images/出雲大社$name.webp';
  }
}

const _glassLine = BorderSide(color: Color(0x33FFFFFF), width: 0.5);

/// すりガラスの面（ホバー時は少しだけ不透明にする）
class _GlassBar extends StatefulWidget {
  final Widget child;
  final Border? border;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;

  const _GlassBar({
    required this.child,
    this.border,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<_GlassBar> createState() => _GlassBarState();
}

class _GlassBarState extends State<_GlassBar> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: _hovering
                  ? const Color.fromRGBO(20, 20, 20, 0.4)
                  : const Color.fromRGBO(20, 20, 20, 0.25),
              border: widget.border,
              borderRadius: widget.borderRadius,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 見出しと副題（下線は一番長い行の幅に合わせる）
class _Goal extends StatelessWidget {
  final String heading;
  final String subtitle;
  final List<Shadow> shadows;

  const _Goal({
    required this.heading,
    required this.subtitle,
    required this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // CSS の clamp() と同じ計算
    double clamp(double min, double value, double max) =>
        value.clamp(min, max).toDouble();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        clamp(24, size.width * 0.06, 96),
        clamp(32, size.height * 0.08, 96),
        clamp(24, size.width * 0.06, 96),
        0,
      ),
      child: FitContentColumn(
        children: [
          Text(
            heading,
            style: TextStyle(
              color: defaultWhite,
              fontSize: clamp(40, size.width * 0.06, 72),
              fontWeight: FontWeight.bold,
              height: 1.2,
              letterSpacing: clamp(40, size.width * 0.06, 72) * 0.04,
              fontFeatures: const [FontFeature.enable('palt')],
              shadows: shadows,
            ),
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: 0.92,
            child: Text(
              subtitle,
              style: TextStyle(
                color: defaultWhite,
                fontSize: clamp(18, size.width * 0.02, 22),
                height: 1.7,
                letterSpacing: clamp(18, size.width * 0.02, 22) * 0.06,
                fontFeatures: const [FontFeature.enable('palt')],
                shadows: shadows,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 幅0で計測させ、見出し・副題の幅に引き伸ばす
          Container(
            width: 0,
            height: 1,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.45),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Color.fromRGBO(0, 0, 0, 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 右下の言語切り替え（日本語版から英語版、英語版から日本語版へ）
class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch();

  @override
  Widget build(BuildContext context) {
    final language = SiteLanguage.of(context);
    final other = language.isEnglish
        ? SiteLanguage.japanese
        : SiteLanguage.english;

    return _GlassBar(
      border: Border.fromBorderSide(_glassLine),
      borderRadius: BorderRadius.circular(10),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: DefaultTextStyle(
        style: const TextStyle(color: defaultWhite, fontSize: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(language.strings.languageLabel),
            SiteLink(
              href: other.path('/'),
              child: Text(language.strings.otherLanguageName),
            ),
          ],
        ),
      ),
    );
  }
}
