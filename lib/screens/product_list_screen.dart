import 'package:flutter/material.dart';

import '../content/content_repository.dart';
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

    return SitePage(
      title: 'いろいろが開発したアプリや貢献したプロジェクト・サービス',
      child: FutureBuilder(
        future: Future.wait([repository.products(), repository.prices()]),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) return LoadingContent(error: snapshot.error);
          return _ProductList(
            products: data[0],
            prices: data[1] as Map<String, String>,
          );
        },
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final Map<String, dynamic> products;
  final Map<String, String> prices;

  const _ProductList({required this.products, required this.prices});

  List<Map<String, dynamic>> _list(Object? value) =>
      (value as List? ?? const []).cast<Map<String, dynamic>>();

  @override
  Widget build(BuildContext context) {
    final apps = products['apps'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CardH1('アプリケーション'),
        const CardH2('開発'),
        AppGrid(
          children: [
            for (final app in _list(apps['development']))
              AppCard(app: app, prices: prices, extraHtml: _cmHtml(app)),
          ],
        ),
        const CardH2('移植'),
        AppGrid(
          children: [
            for (final app in _list(apps['transplanting']))
              AppCard(
                app: app,
                prices: prices,
                extraHtml: _mediaHtml(app) + _originalSourceHtml(app),
              ),
          ],
        ),
        const CardH2('翻訳'),
        AppGrid(
          children: [
            for (final app in _list(apps['translation']))
              AppCard(
                app: app,
                prices: prices,
                // 説明文の先頭のアプリ名を太字にする
                descriptionHtml:
                    '<strong>${escapeHtml(app['title'])}</strong>'
                    '${escapeHtml((app['description'] as String).replaceFirst('${app['title']}は', 'は'))}',
                extraHtml: _mediaHtml(app),
              ),
          ],
        ),
        for (final item in _list(products['others'])) ...[
          CardH1(item['label']),
          CardH2(item['title']),
          RichContent(
            item['label'] == 'テンプレート'
                ? '<div>${escapeHtml(item['description'])}'
                      '概要は<a href="${item['repositoryUrl']}">${escapeHtml(item['title'])}リポジトリ</a>からご確認ください。'
                      '${item['downloadUrl'] != null ? '<p><a href="${item['downloadUrl']}">ダウンロード</a></p>' : ''}</div>'
                : '<p>${escapeHtml(item['description'])}'
                      '${item['moreInfoUrl'] != null ? '概要は<a href="${item['moreInfoUrl']}">${escapeHtml(item['label'])} ${escapeHtml(item['title'])}【公式】</a>からご確認ください。' : ''}</p>',
            variant: RichContentVariant.card,
          ),
        ],
        const CardH1('フレームワーク・パッケージ'),
        for (final framework in _list(products['frameworks'])) ...[
          CardH2(framework['title']),
          RichContent(
            '<p>${escapeHtml(framework['description'])}'
            '概要は<a href="${framework['repositoryUrl']}">${escapeHtml(framework['title'])}リポジトリ</a>からご確認ください。</p>',
            variant: RichContentVariant.card,
          ),
        ],
        const CardH1('シェルスクリプト'),
        for (final script in _list(products['shellScripts'])) ...[
          CardH2(script['title']),
          RichContent(
            '<div>${escapeHtml(script['description'])}'
            '概要は<a href="${script['repositoryUrl']}">${escapeHtml(script['title'])}リポジトリ</a>からご確認ください。'
            '${script['downloadUrl'] != null ? '<a href="${script['downloadUrl']}">ダウンロード</a>' : ''}</div>',
            variant: RichContentVariant.card,
          ),
        ],
        const CardH1('ウェブサイト'),
        for (final website in _list(products['websites'])) ...[
          CardH2(website['title']),
          RichContent(
            '<p>${escapeHtml(website['description'])}</p>',
            variant: RichContentVariant.card,
          ),
        ],
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
    );
  }

  // CM（YouTube）はリンクとして表示する（埋め込みの再生には対応しない）
  static String _cmHtml(Map<String, dynamic> app) {
    final cm = app['cm'];
    if (cm is! List || cm.isEmpty) return '';
    return '<h4>CM</h4>${cm.map((item) => '<p><a href="https://www.youtube.com/watch?v=${item['url']}">${escapeHtml(item['name'])}</a></p>').join()}';
  }

  static String _mediaHtml(Map<String, dynamic> app) {
    final media = app['media'];
    if (media is! List || media.isEmpty) return '';
    return '<h4>メディア</h4>${media.map((item) => '<p><a href="${escapeHtml(item['url'])}">${escapeHtml(item['title'])}</a></p>').join()}';
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
