// App Storeの価格をiTunes Search APIから取得し、assets/content/ja/prices.json に書き出す
//
// 元サイト（Next.js）がビルド時に価格を取得しているのに合わせ、GitHub Actions のビルド前に実行する。
// 使い方: dart run tool/fetch_prices.dart
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final products = jsonDecode(
    await File('assets/content/ja/product.json').readAsString(),
  ) as Map<String, dynamic>;
  final apps = (products['apps'] as Map<String, dynamic>)
      .values
      .expand((list) => list as List)
      .cast<Map<String, dynamic>>();
  final ids = apps
      .map((app) => (app['id'] as String).replaceFirst('id', ''))
      .toList();

  final client = HttpClient();
  final prices = <String, String>{};
  for (final id in ids) {
    try {
      final request = await client.getUrl(
        Uri.parse('https://itunes.apple.com/lookup?id=$id&country=jp'),
      );
      final response = await request.close();
      final data = jsonDecode(await response.transform(utf8.decoder).join())
          as Map<String, dynamic>;
      final results = data['results'] as List;
      prices[id] = results.isEmpty
          ? 'App not found'
          : (results.first['formattedPrice'] as String?) ?? 'Free';
    } catch (error) {
      stderr.writeln('Error fetching price for id $id: $error');
      prices[id] = 'Error fetching price';
    }
  }
  client.close();

  await File('assets/content/ja/prices.json')
      .writeAsString(const JsonEncoder.withIndent('  ').convert(prices));
  stdout.writeln('${prices.length}件の価格を書き出しました');
}
