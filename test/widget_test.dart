import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_flutter_page/content/content_repository.dart';
import 'package:test_flutter_page/main.dart';

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

  test('Markdownの段落内の改行は改行（br）になる', () {
    expect(markdownToHtml('一行目\n二行目'), contains('一行目<br />'));
  });
}
