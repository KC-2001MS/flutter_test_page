import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;

const _contentRoot = 'assets/content/ja';

/// フロントマター付きのMarkdown文書
class MarkdownDocument {
  final Map<String, String> frontMatter;
  final String html;

  const MarkdownDocument({required this.frontMatter, required this.html});

  String? get title => frontMatter['title'];
}

/// ブログ・ニュースルーム一覧の項目
class ArticleSummary {
  final String title;
  final String description;
  final String genre;
  final String date;
  final String path;

  const ArticleSummary({
    required this.title,
    required this.description,
    required this.genre,
    required this.date,
    required this.path,
  });
}

/// サイトのコンテンツ（元サイトの content/ja をアセットとして同梱したもの）を読み込む
class ContentRepository {
  ContentRepository._();

  static final instance = ContentRepository._();

  final _cache = <String, Future<Object?>>{};

  Future<T> _cached<T>(String key, Future<T> Function() load) =>
      _cache.putIfAbsent(key, load).then((value) => value as T);

  /// Markdown文書（例: "product/mywordx"、"contact"）。存在しない場合は null
  Future<MarkdownDocument?> markdown(String name) =>
      _cached('md:$name', () async {
        if (!_isSafeName(name)) return null;
        final String source;
        try {
          source = await rootBundle.loadString('$_contentRoot/$name.md');
        } catch (_) {
          return null;
        }
        final (frontMatter, body) = _splitFrontMatter(source);
        return MarkdownDocument(
          frontMatter: frontMatter,
          html: markdownToHtml(body),
        );
      });

  /// HTMLで書かれたページ（プライバシーポリシー・利用規約）
  Future<String> htmlPage(String name) => _cached(
    'html:$name',
    () => rootBundle.loadString('$_contentRoot/pages/$name.html'),
  );

  /// ブログ・ニュースルームの一覧（ファイル名の順）
  Future<List<ArticleSummary>> articles(String directory) =>
      _cached('list:$directory', () async {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        final prefix = '$_contentRoot/$directory/';
        final files =
            manifest
                .listAssets()
                .where(
                  (asset) => asset.startsWith(prefix) && asset.endsWith('.md'),
                )
                .toList()
              ..sort();

        final list = <ArticleSummary>[];
        for (final file in files) {
          final slug = file.substring(prefix.length, file.length - 3);
          final document = await markdown('$directory/$slug');
          if (document == null) continue;
          final data = document.frontMatter;
          list.add(
            ArticleSummary(
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              genre: data['genre'] ?? '',
              date: data['date'] ?? '',
              path: '/$directory/$slug',
            ),
          );
        }
        return list;
      });

  /// コンテンツページのデータ（product.json）
  Future<Map<String, dynamic>> products() => _cached('products', () async {
    final source = await rootBundle.loadString('$_contentRoot/product.json');
    return jsonDecode(source) as Map<String, dynamic>;
  });

  /// App Storeの価格（ビルド時に tool/fetch_prices.dart で取得したもの）
  Future<Map<String, String>> prices() => _cached('prices', () async {
    try {
      final source = await rootBundle.loadString('$_contentRoot/prices.json');
      return (jsonDecode(source) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value.toString()),
      );
    } catch (_) {
      return <String, String>{};
    }
  });

  // "../" などで同梱していないファイルを読まないようにする
  static bool _isSafeName(String name) =>
      RegExp(r'^[A-Za-z0-9_\-]+(/[A-Za-z0-9_\-]+)*$').hasMatch(name);

  static (Map<String, String>, String) _splitFrontMatter(String source) {
    final match = RegExp(
      r'^---\r?\n([\s\S]*?)\r?\n---\r?\n?',
    ).firstMatch(source);
    if (match == null) return (<String, String>{}, source);

    final data = <String, String>{};
    for (final line in match.group(1)!.split('\n')) {
      final separator = line.indexOf(':');
      if (separator <= 0) continue;
      final key = line.substring(0, separator).trim();
      var value = line.substring(separator + 1).trim();
      if (value.length >= 2 &&
          (value.startsWith('"') && value.endsWith('"') ||
              value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      data[key] = value;
    }
    return (data, source.substring(match.end));
  }
}

/// remark + remark-gfm + remark-breaks と同じように、MarkdownをHTMLに変換する
String markdownToHtml(String source) => md.markdownToHtml(
  source,
  extensionSet: md.ExtensionSet.gitHubFlavored,
  inlineSyntaxes: [_LineBreakSyntax()],
);

/// 段落内の改行をそのまま改行（br）にする（remark-breaks 相当）
class _LineBreakSyntax extends md.InlineSyntax {
  _LineBreakSyntax() : super(r'\n');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.empty('br'));
    return true;
  }
}
