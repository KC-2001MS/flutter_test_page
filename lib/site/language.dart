import 'package:flutter/widgets.dart';

/// サイトの言語（元サイトの Language.Japanese・Language.EnglishUS）
enum SiteLanguage {
  japanese(code: 'ja', pathPrefix: ''),
  english(code: 'en', pathPrefix: '/en');

  /// コンテンツのディレクトリ名（assets/content/ja など）
  final String code;

  /// URLの先頭に付けるパス（日本語版はなし、英語版は /en）
  final String pathPrefix;

  const SiteLanguage({required this.code, required this.pathPrefix});

  bool get isEnglish => this == english;

  /// この言語のページへのパス（例: "/product" → "/en/product"）
  String path(String path) {
    if (pathPrefix.isEmpty) return path;
    return path == '/' ? pathPrefix : '$pathPrefix$path';
  }

  /// URLのパスから言語を判定する
  static SiteLanguage fromPath(String path) =>
      path == '/en' || path.startsWith('/en/') ? english : japanese;

  static SiteLanguage of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<SiteLanguageScope>()
          ?.language ??
      japanese;

  /// 言語ごとの文言
  SiteStrings get strings => isEnglish ? _english : _japanese;
}

/// 子孫のウィジェットにページの言語を伝える
class SiteLanguageScope extends InheritedWidget {
  final SiteLanguage language;

  const SiteLanguageScope({
    super.key,
    required this.language,
    required super.child,
  });

  @override
  bool updateShouldNotify(SiteLanguageScope oldWidget) =>
      language != oldWidget.language;
}

/// 画面に表示する固定の文言（元サイトの各ページ・コンポーネントの日本語・英語）
class SiteStrings {
  final String siteName;
  final String home;
  final String contents;
  final String blog;
  final String newsroom;
  final String contact;

  final String homeTitle;
  final String homeHeading;
  final String homeSubtitle;
  final String notFoundTitle;
  final String notFoundSubtitle;
  final String languageLabel;
  final String otherLanguageName;

  final String productTitle;
  final String productDetailTitle;
  final String tipsTitle;
  final String blogTitle;
  final String newsroomTitle;
  final String contactTitle;
  final String privacyTitle;
  final String agreementTitle;
  final String emptyBlog;
  final String emptyNews;

  final String supportPage;
  final String feedback;
  final String pricePrefix;
  final String priceSuffix;
  final String appStoreBadge;

  /// アプリのアイコンの代替テキスト（"〇〇アイコン"・"〇〇 Icon"）
  final String iconSuffix;

  final String donationTitle;
  final String donationBody;
  final String copyCode;
  final String copied;
  final String loadFailed;

  const SiteStrings({
    required this.siteName,
    required this.home,
    required this.contents,
    required this.blog,
    required this.newsroom,
    required this.contact,
    required this.homeTitle,
    required this.homeHeading,
    required this.homeSubtitle,
    required this.notFoundTitle,
    required this.notFoundSubtitle,
    required this.languageLabel,
    required this.otherLanguageName,
    required this.productTitle,
    required this.productDetailTitle,
    required this.tipsTitle,
    required this.blogTitle,
    required this.newsroomTitle,
    required this.contactTitle,
    required this.privacyTitle,
    required this.agreementTitle,
    required this.emptyBlog,
    required this.emptyNews,
    required this.supportPage,
    required this.feedback,
    required this.pricePrefix,
    required this.priceSuffix,
    required this.appStoreBadge,
    required this.iconSuffix,
    required this.donationTitle,
    required this.donationBody,
    required this.copyCode,
    required this.copied,
    required this.loadFailed,
  });

  String appIcon(String title) => '$title$iconSuffix';
}

const _japanese = SiteStrings(
  siteName: 'いろいろポートフォリオ',
  home: 'ホーム',
  contents: 'コンテンツ',
  blog: 'ブログ',
  newsroom: 'ニュースルーム',
  contact: '問い合わせ',
  homeTitle: '【SwiftUIアプリ開発】いろいろポートフォリオ',
  homeHeading: 'より効率的に。',
  homeSubtitle: '私のほしいものを\n私自身の手で作り出します',
  notFoundTitle: 'このページは存在しない',
  notFoundSubtitle: 'このページは存在しません。\nこのページは作られていないようです。URLが正しいかどうかを確認してください。',
  languageLabel: '言語 : ',
  otherLanguageName: 'English',
  productTitle: 'いろいろが開発したアプリや貢献したプロジェクト・サービス',
  productDetailTitle: 'いろいろの製品詳細',
  tipsTitle: 'いろいろのTips',
  blogTitle: 'いろいろのブログ',
  newsroomTitle: 'ニュースルーム',
  contactTitle: 'いろいろへのお問い合わせ',
  privacyTitle: 'プライバシーポリシー',
  agreementTitle: '利用規約',
  emptyBlog: '現在、ブログ記事はありません。',
  emptyNews: '現在、ニュースはありません。',
  supportPage: 'サポートページ',
  feedback: 'フィードバック',
  pricePrefix: '価格：',
  priceSuffix: '（税込）',
  appStoreBadge: 'App Storeからダウンロード',
  iconSuffix: 'アイコン',
  donationTitle: '寄付',
  donationBody:
      '寄付をご希望の方は、こちらをクリックしてください。ご寄付いただいたお金は、私のプログラミング・スキルの向上とアプリケーションのメンテナンスに使わせていただきます。',
  copyCode: 'コードをコピー',
  copied: 'コピーしました',
  loadFailed: 'コンテンツを読み込めませんでした。',
);

const _english = SiteStrings(
  siteName: "Iroiro's portfolio",
  home: 'Home',
  contents: 'Contents',
  blog: 'Blog',
  newsroom: 'Newsroom',
  contact: 'Contact',
  homeTitle: "Iroiro's portfolio【SwiftUI】",
  homeHeading: 'More efficient.',
  homeSubtitle: 'I create what I want\nwith my own hands.',
  notFoundTitle: 'This page does not exist.',
  notFoundSubtitle:
      'This page does not exist.\nThis page does not appear to have been created; please check to see if the URL is correct.',
  languageLabel: 'Language : ',
  otherLanguageName: '日本語',
  productTitle:
      'Applications developed and projects/services contributed to by the Iroiro',
  productDetailTitle: "Iroiro's product details",
  tipsTitle: "Iroiro's Tips",
  blogTitle: "Iroiro's blog",
  newsroomTitle: 'Newsroom',
  contactTitle: 'Contact Iroiro',
  privacyTitle: 'Privacy Policy',
  agreementTitle: 'Terms of Use',
  emptyBlog: 'There are currently no blog posts.',
  emptyNews: 'There is currently no news.',
  supportPage: 'Support Page',
  feedback: 'Feedback',
  pricePrefix: 'Price：',
  priceSuffix: '',
  appStoreBadge: 'App Storeからダウンロード',
  iconSuffix: ' Icon',
  donationTitle: 'Contribution',
  donationBody:
      'If you would like to make a donation, please click here. The money you donate will be used to improve my programming skills and maintain the application.',
  copyCode: 'Copy code',
  copied: 'Copied',
  loadFailed: 'Could not load the content.',
);
