# flutter_test_page

[いろいろポートフォリオ（iroiro.dev）](https://iroiro.dev)を、Flutter Web でどこまで再現できるかを試す検証用のページです。
本番サイトを置き換える予定はありません。

## 再現している範囲

元サイト（Next.js）の日本語版を対象にしています。

| ページ | パス | 内容の出どころ |
| ---- | ---- | ---- |
| トップ | `/` | （固定の文言） |
| コンテンツ | `/product` | `assets/content/ja/product.json` |
| アプリの詳細 | `/product/:slug` | `assets/content/ja/product/*.md` |
| Tips | `/product/tips/:slug` | `assets/content/ja/tips/*.md` |
| ブログ | `/blog`・`/blog/:slug` | `assets/content/ja/blog/*.md` |
| ニュースルーム | `/newsroom`・`/newsroom/:slug` | `assets/content/ja/newsroom/*.md` |
| 問い合わせ | `/contact` | `assets/content/ja/contact.md` |
| プライバシーポリシー・利用規約 | `/privacy`・`/agreement` | `assets/content/ja/pages/*.html` |
| 404 | 上記以外 | （固定の文言） |

`assets/content/ja` は元サイトの `content/ja` をそのまま同梱したものです。
Markdown は `markdown` パッケージで HTML に変換し（remark-gfm・remark-breaks 相当）、
`flutter_widget_from_html_core` で元サイトの CSS に合わせたウィジェットとして表示します。

## 元サイトとの違い

- 英語版はありません（トップの「English」は本番サイトの英語版へのリンクです）。
- ツイート・Bluesky の埋め込みは、埋め込み用スクリプトを読み込む前の引用（カード）として表示します。
- GitHub Sponsors のボタンは iframe ではなく、同じ見た目のリンクです。
- AVIF は Flutter で表示できないため、アプリのアイコンは PNG、トップの背景写真は WebP に変換して同梱しています。
- 価格は元サイトと同じくビルド時に取得します（`dart run tool/fetch_prices.dart`）。取得していない場合は「―」と表示します。

## Flutter Web で気づいたこと

- CanvasKit では、フォールバックフォントで描く日本語の固有サイズ（intrinsic size）が実際より小さく見積もられ、
  `IntrinsicWidth`・`IntrinsicHeight`・`IntrinsicColumnWidth` を使うと折り返しや高さがずれました。
  そのため、子を実際にレイアウトして大きさを揃える RenderObject（`lib/widgets/measured_layouts.dart`）を使っています。
- 端末のフォントを使えないため、コードブロック用の等幅フォント（Roboto Mono、SIL Open Font License）を同梱しています。
- 画面全体を canvas に描くため、Lighthouse では LCP を測定できません（NO_LCP）。
  起動までの間は `web/index.html` の読み込み中の表示（HTML）を出し、起動後に `web/flutter_bootstrap.js` で消しています。
- Flutter の Service Worker は非推奨のため、`web/flutter_bootstrap.js` で登録しないようにしています。

## 開発

```bash
flutter pub get
flutter run -d chrome
flutter test
```
