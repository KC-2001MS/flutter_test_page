import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../site/links.dart';
import '../site/site_theme.dart';
import 'measured_layouts.dart';
import 'rich_content.dart';

/// アプリ一覧のカード
class AppCard extends StatelessWidget {
  /// product.json のアプリの項目
  final Map<String, dynamic> app;

  /// 説明文の下に表示する内容（HTML）
  final String extraHtml;

  /// 説明文（HTML）。省略時は product.json の description
  final String? descriptionHtml;

  /// App Storeの価格（App Store IDごと）
  final Map<String, String> prices;

  const AppCard({
    super.key,
    required this.app,
    required this.prices,
    this.extraHtml = '',
    this.descriptionHtml,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SiteColors.of(context);
    final id = app['id'] as String;
    final appStoreId = id.startsWith('id') ? id : 'id$id';
    final appStoreUrl = 'https://apps.apple.com/app/$appStoreId';
    final title = app['title'] as String;
    final icon = (colors.isDark ? app['darkIcon'] : null) ?? app['icon'];
    final platforms = (app['supportedPlatforms'] as List).cast<Map>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(color: colors.surfaceBorder),
      ),
      // 高さを揃えたときは、下段（リンク・価格）をカードの下端に寄せる
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                spacing: 16,
                children: [
                  if (icon is String)
                    SiteLink(
                      href: appStoreUrl,
                      child: Image.asset(
                        _iconAsset(icon),
                        width: 88,
                        height: 88,
                        semanticLabel: '$titleアイコン',
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: SiteTypography.of(context).h3,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final platform in platforms)
                              _PlatformLabel(
                                '${platform['os']} ${platform['version']}~',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 本文（.appBody>p の上下の余白 16px）
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: RichContent(
                  '<p>${descriptionHtml ?? escapeHtml(app['description'] as String)}</p>$extraHtml',
                  variant: RichContentVariant.appBody,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.mix(12))),
            ),
            // 1行に収まらない場合は、リンクを左・価格とApp Storeのボタンを右に、2行で並べる
            child: LayoutBuilder(
              builder: (context, constraints) {
                final links = Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 20,
                  children: [
                    _TextLink(app['supportPage'] as String, 'サポートページ'),
                    _TextLink(app['feedback'] as String, 'フィードバック'),
                  ],
                );
                final actions = Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    _PriceTag(prices[appStoreId.substring(2)]),
                    _AppStoreBadge(url: appStoreUrl),
                  ],
                );
                if (constraints.maxWidth >= 450) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [links, actions],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    Align(alignment: Alignment.centerLeft, child: links),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// "/images/My Word X Light.avif" → 同梱したPNG
  static String _iconAsset(String path) {
    final name = path.split('/').last.replaceFirst(RegExp(r'\.avif$'), '');
    return 'assets/images/icons/$name.png';
  }
}

/// アプリのカードを並べるグリッド（PCでは2列。行ごとに高さを揃える）
class AppGrid extends StatelessWidget {
  final List<Widget> children;

  const AppGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 20.0;
          final narrow = MediaQuery.sizeOf(context).width <= 560;
          // grid-template-columns: repeat(auto-fill, minmax(460px, 1fr))
          final columns = narrow
              ? 1
              : ((constraints.maxWidth + gap) / (460 + gap)).floor().clamp(
                  1,
                  99,
                );

          final rows = [
            for (var start = 0; start < children.length; start += columns)
              EqualHeightRow(
                columns: columns,
                spacing: gap,
                children: children.sublist(
                  start,
                  (start + columns).clamp(0, children.length),
                ),
              ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: rows,
          );
        },
      ),
    );
  }
}

/// 対応プラットフォームのラベル
class _PlatformLabel extends StatelessWidget {
  final String text;

  const _PlatformLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SiteColors.of(context).mix(25)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4)),
    );
  }
}

class _TextLink extends StatelessWidget {
  final String href;
  final String label;

  const _TextLink(this.href, this.label);

  @override
  Widget build(BuildContext context) {
    return SiteLink(
      href: href,
      child: Text(label, style: const TextStyle(color: linkColor)),
    );
  }
}

/// 価格（元サイトではビルド時にiTunes Search APIから取得している）
class _PriceTag extends StatelessWidget {
  final String? price;

  const _PriceTag(this.price);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: '価格：'),
          TextSpan(
            text: price ?? '―',
            style: const TextStyle(color: priceColor),
          ),
          const TextSpan(text: '（税込）'),
        ],
      ),
      style: const TextStyle(fontSize: 13),
    );
  }
}

/// 「App Storeからダウンロード」のバッジ
class _AppStoreBadge extends StatelessWidget {
  final String url;

  const _AppStoreBadge({required this.url});

  @override
  Widget build(BuildContext context) {
    const base =
        'assets/images/Download-on-the-App-Store/JP/Download_on_App_Store';
    final asset = SiteColors.of(context).isDark
        ? '$base/White_lockup/SVG/Download_on_the_App_Store_Badge_JP_RGB_wht_100317.svg'
        : '$base/Black_lockup/SVG/Download_on_the_App_Store_Badge_JP_RGB_blk_100317.svg';

    return SiteLink(
      href: url,
      child: SvgPicture.asset(
        asset,
        height: 40,
        semanticsLabel: 'App Storeからダウンロード',
      ),
    );
  }
}

/// HTMLに埋め込む文字列をエスケープする
String escapeHtml(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
