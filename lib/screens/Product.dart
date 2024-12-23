import 'package:flutter/material.dart';
import '../components/SecondCard.dart';
import '../components/FirstCard.dart';

class Product extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FirstCard(title: Text("アプリケーション"), children: [
              SecondCard(title: Text("開発"), children: [Text("仮置きのテキスト")]),
              SecondCard(title: Text("移植"), children: [Text("仮置きのテキスト")]),
              SecondCard(title: Text("翻訳"), children: [Text("仮置きのテキスト")]),
            ]),
            FirstCard(title: Text("テンプレートファイル"), children: [
              SecondCard(
                  title: Text("Word-Filter-X-Templates"),
                  children: [Text("仮置きのテキスト")]),
            ]),
            FirstCard(title: Text("Blueskyフィード"), children: [
              SecondCard(title: Text("Swift"), children: [Text("仮置きのテキスト")]),
            ]),
            FirstCard(title: Text("Brave Goggle"), children: [
              SecondCard(title: Text("Swift"), children: [Text("仮置きのテキスト")]),
            ]),
            FirstCard(title: Text("フレームワーク・パッケージ"), children: [
              SecondCard(
                  title: Text("SwiftStorage"), children: [Text("仮置きのテキスト")]),
              SecondCard(title: Text("SwiftLI"), children: [Text("仮置きのテキスト")]),
              SecondCard(title: Text("OnboardingUI"), children: [Text("現在")]),
              SecondCard(title: Text("AboutUI"), children: [Text("現在作成中")]),
              SecondCard(title: Text("ArticleUI"), children: [Text("仮置きの")]),
            ]),
            FirstCard(title: Text("シェルスクリプト"), children: [
              SecondCard(
                  title: Text("Shell-Config-Setup"),
                  children: [Text("仮置きのテキスト")]),
            ]),
            FirstCard(title: Text("ウェブサイト"), children: [
              SecondCard(title: Text("いろいろポートフォリオ"), children: [
                Text("こちらのホームページです。公開したサービスの紹介とサポート等を目的としたサイトです。"),
                Text(
                    "Webアプリケーションに詳しくなく、今後もメインとする予定がないため最低限の作りとなっております。このホームページを頻繁に更新する予定はありませんが、フィードバックが多ければ対応します。")
              ]),
            ]),
          ],
        ),
      ),
    );
  }
}
