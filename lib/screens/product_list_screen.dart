import 'package:flutter/material.dart';

import '../content/content_repository.dart';
import '../site/language.dart';
import '../site/site_layout.dart';
import '../site/site_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/headings.dart';
import '../widgets/rich_content.dart';
import 'loading.dart';

/// コンテンツ（アプリ・フレームワークなどの一覧）
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ContentRepository.instance;
    final language = SiteLanguage.of(context);

    return SitePage(
      title: language.strings.productTitle,
      child: FutureBuilder(
        future: Future.wait([
          repository.products(language),
          repository.prices(language),
        ]),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) return LoadingContent(error: snapshot.error);
          return _ProductList(
            products: data[0],
            prices: data[1] as Map<String, String>,
            english: language.isEnglish,
          );
        },
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final Map<String, dynamic> products;
  final Map<String, String> prices;

  /// 英語版（元サイトの src/app/en/product/page.tsx）か
  final bool english;

  const _ProductList({
    required this.products,
    required this.prices,
    required this.english,
  });

  List<Map<String, dynamic>> _list(Object? value) =>
      (value as List? ?? const []).cast<Map<String, dynamic>>();

  @override
  Widget build(BuildContext context) {
    final apps = products['apps'] as Map<String, dynamic>;
    // 元サイトの日本語版・英語版の page.tsx と同じ文面にする
    // （JSXでは、改行をまたぐ文字列と式の間に空白が入らない）
    final media = english ? 'Media' : 'メディア';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardH1(english ? 'App' : 'アプリケーション'),
        CardH2(english ? 'Development' : '開発'),
        AppGrid(
          children: [
            for (final app in _list(apps['development']))
              AppCard(app: app, prices: prices, extraHtml: _cmHtml(app)),
          ],
        ),
        CardH2(english ? 'Transplanting' : '移植'),
        AppGrid(
          children: [
            for (final app in _list(apps['transplanting']))
              AppCard(
                app: app,
                prices: prices,
                extraHtml:
                    _mediaHtml(app, media) +
                    (english ? '' : _originalSourceHtml(app)),
              ),
          ],
        ),
        CardH2(english ? 'Translation' : '翻訳'),
        AppGrid(
          children: [
            for (final app in _list(apps['translation']))
              english
                  ? AppCard(
                      app: app,
                      prices: prices,
                      extraHtml:
                          '<p>If you have any questions and feedback, please contact '
                          '${escapeHtml((app['feedback'] as String).replaceFirst('mailto:', ''))} in English.</p>'
                          '${_mediaHtml(app, media)}',
                    )
                  : AppCard(
                      app: app,
                      prices: prices,
                      // 説明文の先頭のアプリ名を太字にする
                      descriptionHtml:
                          '<strong>${escapeHtml(app['title'])}</strong>'
                          '${escapeHtml((app['description'] as String).replaceFirst('${app['title']}は', 'は'))}',
                      extraHtml: _mediaHtml(app, media),
                    ),
          ],
        ),
        for (final item in _list(products['others'])) ...[
          CardH1(item['label']),
          CardH2(item['title']),
          RichContent(_otherHtml(item), variant: RichContentVariant.card),
        ],
        CardH1(english ? 'Framework & Packages' : 'フレームワーク・パッケージ'),
        for (final framework in _list(products['frameworks'])) ...[
          CardH2(framework['title']),
          RichContent(
            english
                ? '<p>${escapeHtml(framework['description'])}'
                      'Please visit the <a href="${framework['repositoryUrl']}">${escapeHtml(framework['title'])} repository</a> for an overview.</p>'
                : '<p>${escapeHtml(framework['description'])}'
                      '概要は<a href="${framework['repositoryUrl']}">${escapeHtml(framework['title'])}リポジトリ</a>からご確認ください。</p>',
            variant: RichContentVariant.card,
          ),
        ],
        CardH1(english ? 'Shell Script' : 'シェルスクリプト'),
        for (final script in _list(products['shellScripts'])) ...[
          CardH2(script['title']),
          RichContent(
            english
                ? '<div>${escapeHtml(script['description'])}'
                      'An overview is available from the <a href="${script['repositoryUrl']}">${escapeHtml(script['title'])} repository</a>.'
                      '${script['downloadUrl'] != null ? '<h3><a href="${script['downloadUrl']}">Download</a></h3>' : ''}</div>'
                : '<div>${escapeHtml(script['description'])}'
                      '概要は<a href="${script['repositoryUrl']}">${escapeHtml(script['title'])}リポジトリ</a>からご確認ください。'
                      '${script['downloadUrl'] != null ? '<a href="${script['downloadUrl']}">ダウンロード</a>' : ''}</div>',
            variant: RichContentVariant.card,
          ),
        ],
        CardH1(english ? 'Website' : 'ウェブサイト'),
        for (final website in _list(products['websites'])) ...[
          CardH2(website['title']),
          RichContent(
            '<p>${escapeHtml(website['description'])}</p>',
            variant: RichContentVariant.card,
          ),
        ],
        // 商標の注釈（日本語版のみ）
        if (!english) ...[
          const SiteDivider(),
          for (final (index, notice)
              in (products['trademarkNotices'] as List? ?? const []).indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '${index + 1}.$notice',
                style: TextStyle(
                  fontSize: 10,
                  color: SiteColors.of(context).mix(55),
                ),
              ),
            ),
        ],
      ],
    );
  }

  /// テンプレート・Blueskyフィード・Brave Goggle
  String _otherHtml(Map<String, dynamic> item) {
    final description = escapeHtml(item['description']);
    final title = escapeHtml(item['title']);
    final label = escapeHtml(item['label']);
    final download = item['downloadUrl'];
    final moreInfo = item['moreInfoUrl'];

    if (english) {
      if (item['label'] == 'Template') {
        return '<div>$description'
            'An overview is available from the <a href="${item['repositoryUrl']}">$title repository</a>.'
            '${download != null ? '<a href="$download">Download</a>' : ''}</div>';
      }
      return '<p>$description'
          '${moreInfo != null ? 'Please see the <a href="$moreInfo">More about $label $title</a> for an overview.' : ''}</p>';
    }
    if (item['label'] == 'テンプレート') {
      return '<div>$description'
          '概要は<a href="${item['repositoryUrl']}">$titleリポジトリ</a>からご確認ください。'
          '${download != null ? '<p><a href="$download">ダウンロード</a></p>' : ''}</div>';
    }
    return '<p>$description'
        '${moreInfo != null ? '概要は<a href="$moreInfo">$label $title【公式】</a>からご確認ください。' : ''}</p>';
  }

  // CM（YouTube）はリンクとして表示する（埋め込みの再生には対応しない）
  static String _cmHtml(Map<String, dynamic> app) {
    final cm = app['cm'];
    if (cm is! List || cm.isEmpty) return '';
    return '<h4>CM</h4>${cm.map((item) => '<p><a href="https://www.youtube.com/watch?v=${item['url']}">${escapeHtml(item['name'])}</a></p>').join()}';
  }

  static String _mediaHtml(Map<String, dynamic> app, String heading) {
    final media = app['media'];
    if (media is! List || media.isEmpty) return '';
    return '<h4>$heading</h4>${media.map((item) => '<p><a href="${escapeHtml(item['url'])}">${escapeHtml(item['title'])}</a></p>').join()}';
  }

  static String _originalSourceHtml(Map<String, dynamic> app) {
    final source = app['originalSource'];
    if (source is! Map) return '';
    final platform = escapeHtml(source['platform']);
    return '<h4>$platform版について</h4>'
        '<p>Safari拡張機能の元となっている$platform拡張機能があります。もし、$platformで使用したい場合は'
        '<a href="${escapeHtml(source['url'])}">こちら</a>をご利用ください。</p>'
        '<p>※$platform版のサポートは<a href="mailto:${source['supportEmail']}">$platform版の製作者のメールアドレス</a>'
        'にお願いします。こちらではサポートを受け付けておりませんのでご注意ください。</p>';
  }
}
