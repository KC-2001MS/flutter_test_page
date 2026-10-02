import 'package:flutter/material.dart';

import '../content/content_repository.dart';
import '../site/language.dart';
import '../site/site_layout.dart';
import '../widgets/donation.dart';
import '../widgets/headings.dart';
import '../widgets/page_card.dart';
import '../widgets/rich_content.dart';
import 'hero_screens.dart';
import 'loading.dart';

/// 言語ごとの文言から、ページのタイトルなどを選ぶ
typedef StringSelector = String Function(SiteStrings strings);

/// Markdownで書かれたページ（アプリの詳細・Tips・ブログ・ニュースルーム・問い合わせ）
class MarkdownScreen extends StatelessWidget {
  /// content/<言語> からのパス（拡張子なし）
  final String name;

  /// フロントマターにタイトルがない場合のタイトル
  final StringSelector defaultTitle;

  /// 末尾に寄付の案内を表示するか
  final bool showDonation;

  const MarkdownScreen({
    super.key,
    required this.name,
    required this.defaultTitle,
    this.showDonation = false,
  });

  @override
  Widget build(BuildContext context) {
    final language = SiteLanguage.of(context);
    final fallbackTitle = defaultTitle(language.strings);

    return FutureBuilder(
      future: ContentRepository.instance.markdown(language, name),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SitePage(title: fallbackTitle, child: const LoadingContent());
        }
        final document = snapshot.data;
        if (document == null) return const NotFoundScreen();

        return SitePage(
          title: document.title ?? fallbackTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RichContent(document.html),
              if (showDonation) const DonationSection(),
            ],
          ),
        );
      },
    );
  }
}

/// ブログ・ニュースルームの一覧
class ArticleListScreen extends StatelessWidget {
  final String directory;
  final String heading;
  final StringSelector title;
  final StringSelector emptyMessage;

  const ArticleListScreen({
    super.key,
    required this.directory,
    required this.heading,
    required this.title,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final language = SiteLanguage.of(context);

    return SitePage(
      title: title(language.strings),
      child: FutureBuilder(
        future: ContentRepository.instance.articles(language, directory),
        builder: (context, snapshot) {
          final articles = snapshot.data;
          if (articles == null) return LoadingContent(error: snapshot.error);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardH1(heading),
              if (articles.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    emptyMessage(language.strings),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                for (final article in articles) PageCard(article: article),
            ],
          );
        },
      ),
    );
  }
}

/// HTMLで書かれたページ（プライバシーポリシー・利用規約）
class HtmlPageScreen extends StatelessWidget {
  final String name;
  final StringSelector title;

  const HtmlPageScreen({super.key, required this.name, required this.title});

  @override
  Widget build(BuildContext context) {
    final language = SiteLanguage.of(context);

    return SitePage(
      title: title(language.strings),
      child: FutureBuilder(
        future: ContentRepository.instance.htmlPage(language, name),
        builder: (context, snapshot) {
          final html = snapshot.data;
          if (html == null) return LoadingContent(error: snapshot.error);
          return RichContent(html, variant: RichContentVariant.card);
        },
      ),
    );
  }
}
