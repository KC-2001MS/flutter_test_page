// GitHub Pagesで、URLに "#" を付けないルーティング（パス形式）を使えるようにする
//
// GitHub Pagesにはファイルが存在しないパスをindex.htmlに振り向ける設定がないため、
// ビルド後の build/web に、ページごとの index.html と 404.html を配置する。
// - 既知のページ（/product・/blog/xxx など）: 各ディレクトリに index.html を置き、200で返す
// - それ以外のパス: 404.html でアプリを起動し、アプリの404ページを表示する
//
// 使い方: flutter build web の後に dart run tool/generate_route_pages.dart
import 'dart:io';

const _content = 'assets/content/ja';
const _output = 'build/web';

void main() {
  final index = File('$_output/index.html');
  if (!index.existsSync()) {
    stderr.writeln('$_output/index.html がありません。先に flutter build web を実行してください。');
    exit(1);
  }

  final routes = <String>[
    'product',
    'blog',
    'newsroom',
    'contact',
    'privacy',
    'agreement',
    ..._slugs('product').map((slug) => 'product/$slug'),
    ..._slugs('tips').map((slug) => 'product/tips/$slug'),
    ..._slugs('blog').map((slug) => 'blog/$slug'),
    ..._slugs('newsroom').map((slug) => 'newsroom/$slug'),
  ];

  for (final route in routes) {
    final directory = Directory('$_output/$route')..createSync(recursive: true);
    index.copySync('${directory.path}/index.html');
  }
  index.copySync('$_output/404.html');

  stdout.writeln('${routes.length}ページ分の index.html と 404.html を配置しました');
}

/// `content/ja/<directory>` にあるMarkdownのファイル名（拡張子なし）
List<String> _slugs(String directory) {
  final dir = Directory('$_content/$directory');
  if (!dir.existsSync()) return const [];
  return dir
      .listSync()
      .whereType<File>()
      .map((file) => file.uri.pathSegments.last)
      .where((name) => name.endsWith('.md'))
      .map((name) => name.substring(0, name.length - 3))
      .toList()
    ..sort();
}
