import 'package:flutter/material.dart';

import '../content/content_repository.dart';
import '../site/links.dart';
import '../site/site_theme.dart';

/// ブログ・ニュースルーム一覧のカード（アプリのカードと同じ見た目）
class PageCard extends StatefulWidget {
  final ArticleSummary article;

  const PageCard({super.key, required this.article});

  @override
  State<PageCard> createState() => _PageCardState();
}

class _PageCardState extends State<PageCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = SiteColors.of(context);
    final article = widget.article;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: SiteLink(
          href: article.path,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: _hovering ? colors.mix(10) : colors.surface,
              borderRadius: BorderRadius.circular(cornerRadius),
              border: Border.all(color: colors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ジャンルのラベル
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: colors.mix(25)),
                  ),
                  child: Text(
                    article.genre,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Text(
                    article.title,
                    style: TextStyle(
                      fontSize: SiteTypography.of(context).h3,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
                Text(article.description),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    article.date,
                    style: TextStyle(fontSize: 13, color: colors.mix(65)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
