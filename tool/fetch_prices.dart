// App Storeの価格をiTunes Search APIから取得し、assets/content/<言語>/prices.json に書き出す
//
// 元サイト（Next.js）がビルド時に価格を取得しているのに合わせ、GitHub Actions のビルド前に実行する。
// 日本語版は日本（jp）、英語版はアメリカ（us）のApp Storeの価格を使う。
// 使い方: dart run tool/fetch_prices.dart
import 'dart:convert';
import 'dart:io';

const _stores = {'ja': 'jp', 'en': 'us'};

Future<void> main() async {
  final client = HttpClient();
  for (final MapEntry(key: language, value: country) in _stores.entries) {
    final prices = <String, String>{};
    for (final id in await _appIds(language)) {
      prices[id] = await _fetchPrice(client, id, country);
    }
    await File(
      'assets/content/$language/prices.json',
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(prices));
    stdout.writeln('$language: ${prices.length}件の価格を書き出しました');
  }
  client.close();
}

/// product.json に載っているアプリのApp Store ID（"id" を除いた数字）
Future<List<String>> _appIds(String language) async {
  final products =
      jsonDecode(
            await File('assets/content/$language/product.json').readAsString(),
          )
          as Map<String, dynamic>;
  return (products['apps'] as Map<String, dynamic>).values
      .expand((list) => list as List)
      .cast<Map<String, dynamic>>()
      .map((app) => (app['id'] as String).replaceFirst('id', ''))
      .toList();
}

/// 元サイトの AppStorePriceTag と同じく、取得できない場合の文言も合わせる
Future<String> _fetchPrice(HttpClient client, String id, String country) async {
  try {
    final request = await client.getUrl(
      Uri.parse('https://itunes.apple.com/lookup?id=$id&country=$country'),
    );
    final response = await request.close();
    final data =
        jsonDecode(await response.transform(utf8.decoder).join())
            as Map<String, dynamic>;
    final results = data['results'] as List;
    if (results.isEmpty) return 'App not found';
    return (results.first['formattedPrice'] as String?) ?? 'Free';
  } catch (error) {
    stderr.writeln('Error fetching price for id $id: $error');
    return 'Error fetching price';
  }
}
