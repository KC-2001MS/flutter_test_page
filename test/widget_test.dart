import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_flutter_page/content/content_repository.dart';
import 'package:test_flutter_page/main.dart';
import 'package:test_flutter_page/site/language.dart';
import 'package:test_flutter_page/site/links.dart';

void main() {
  testWidgets('トップページにサイト名・見出し・タブが表示される', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('いろいろポートフォリオ'), findsOneWidget);
    expect(find.text('より効率的に。'), findsOneWidget);
    for (final tab in ['ホーム', 'コンテンツ', 'ブログ', 'ニュースルーム', '問い合わせ']) {
      expect(find.text(tab), findsOneWidget);
    }
  });

  test('英語版のパス・相対リンクを解決できる', () {
    expect(SiteLanguage.fromPath('/en/product'), SiteLanguage.english);
    expect(SiteLanguage.fromPath('/product'), SiteLanguage.japanese);
    expect(SiteLanguage.english.path('/'), '/en');
    expect(SiteLanguage.english.path('/blog'), '/en/blog');
    // 元サイトの "./product/xxx" は、ブラウザと同じく現在のページを基準にする
    expect(
      internalPath('./product/mywordx', from: Uri.parse('/en/product')),
      '/en/product/mywordx',
    );
    expect(
      internalPath('./product/mywordx', from: Uri.parse('/product')),
      '/product/mywordx',
    );
  });

  test('Markdownの段落内の改行は改行（br）になる', () {
    expect(markdownToHtml('一行目\n二行目'), contains('一行目<br />'));
  });
}
