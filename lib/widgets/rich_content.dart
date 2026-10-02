import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as dom;

import '../site/language.dart';
import '../site/links.dart';
import '../site/site_theme.dart';
import 'donation.dart';
import 'headings.dart';
import 'measured_layouts.dart';

/// HTMLを表示する場所（場所によって見出しの余白などが異なる）
enum RichContentVariant {
  /// Markdownの本文（.card.markdown）
  markdown,

  /// HTMLで書かれたページ（.card）
  card,

  /// アプリのカードの本文（.appBody）
  appBody,
}

/// 元サイトの CSS（foundation.css・content.css）に合わせてHTMLを表示する
class RichContent extends StatelessWidget {
  final String html;
  final RichContentVariant variant;

  const RichContent(
    this.html, {
    super.key,
    this.variant = RichContentVariant.markdown,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SiteColors.of(context);
    final typography = SiteTypography.of(context);
    final markdown = variant == RichContentVariant.markdown;

    String css(Color color) =>
        'rgba(${(color.r * 255).round()}, ${(color.g * 255).round()}, '
        '${(color.b * 255).round()}, ${color.a.toStringAsFixed(3)})';

    String? previousTag(dom.Element element) =>
        element.previousElementSibling?.localName;

    Map<String, String>? styles(dom.Element element) {
      final classes = element.classes;
      switch (element.localName) {
        case 'h2':
          final top = markdown
              ? (previousTag(element) == 'h1' ? '0.8em' : '2em')
              : '0.83em';
          return {
            'font-size': '${typography.h3}px',
            'font-weight': 'bold',
            'line-height': '1.4',
            'padding-bottom': '0.3em',
            'border-bottom': '1px solid ${css(colors.mix(25))}',
            'margin': markdown ? '$top 0 0.6em' : '$top 0',
          };
        case 'h3':
          final top = markdown
              ? (previousTag(element) == 'h2' ? '0.8em' : '2em')
              : '1em';
          return {
            'font-size': '${typography.h4}px',
            'font-weight': 'bold',
            'line-height': '1.4',
            'margin': markdown ? '$top 0 0.5em' : '$top 0',
          };
        case 'h4':
          return {
            'font-size': '${typography.h4}px',
            'margin': variant == RichContentVariant.appBody
                ? '16px 0 4px'
                : '1.33em 0',
          };
        case 'p':
          if (classes.contains('mahjongTiles')) {
            return {
              'font-size': '2em',
              'line-height': '1.4',
              'letter-spacing': '0.05em',
            };
          }
          if (previousTag(element) == 'h4' &&
              variant == RichContentVariant.appBody) {
            return {'margin-top': '0'};
          }
          if (element.parent?.localName == 'li' &&
              element.parent?.parent?.parent?.classes.contains('footnotes') ==
                  true) {
            return {'margin': '0.5em 0'};
          }
          return null;
        case 'a':
          return {'color': css(linkColor), 'text-decoration': 'none'};
        case 'code':
          return {
            'font-family': 'RobotoMono',
            'font-size': '0.9em',
            'background-color': css(colors.mix(10)),
          };
        case 'span':
          if (classes.contains('tile')) {
            return {'font-size': '1.6em', 'line-height': '1'};
          }
          return null;
        case 'blockquote':
          // ツイートやBlueskyの埋め込み（スクリプトが読み込まれる前の表示）をカードにする
          if (classes.contains('twitter-tweet') ||
              classes.contains('bluesky-embed')) {
            return {
              'margin': '16px 0',
              'padding': '4px 20px',
              'border': '1px solid ${css(colors.surfaceBorder)}',
              'border-radius': '${cornerRadius}px',
              'background-color': css(colors.surface),
            };
          }
          return null;
        case 'div':
          // ライトモード用・ダークモード用に二重に書かれた埋め込みは片方だけ表示する
          if (classes.contains(colors.isDark ? 'isLightMode' : 'isDarkMode')) {
            return {'display': 'none'};
          }
          return null;
        case 'section':
          if (classes.contains('footnotes')) {
            return {
              'margin-top': '3em',
              'padding-top': '10px',
              'border-top': '1px solid ${css(colors.mix(15))}',
              'font-size': '12px',
              'color': css(colors.mix(55)),
            };
          }
          return null;
      }
      return null;
    }

    Widget? widgets(dom.Element element) {
      switch (element.localName) {
        case 'h1':
          return CardH1(element.text.trim());
        case 'hr':
          return const SiteDivider();
        case 'pre':
          return CodeBlock(code: element.text);
        case 'table':
          return ContentTable(
            table: element,
            mahjong: _hasAncestorClass(element, 'mahjongTable'),
          );
        case 'div':
          if (element.classes.contains('donationButtons')) {
            return const DonationButtons();
          }
          return null;
        case 'img':
          final src = element.attributes['src'] ?? '';
          if (src.startsWith('/images/')) {
            return _MarkdownImage(
              asset: 'assets/images/articles/${src.substring(8)}',
              label: element.attributes['alt'],
            );
          }
          return null;
        case 'script':
          return const SizedBox.shrink();
      }
      return null;
    }

    return HtmlWidget(
      html,
      textStyle: DefaultTextStyle.of(context).style,
      customStylesBuilder: styles,
      customWidgetBuilder: widgets,
      onTapUrl: (url) => openHref(context, url),
    );
  }
}

bool _hasAncestorClass(dom.Element element, String className) {
  for (var node = element.parent; node != null; node = node.parent) {
    if (node.classes.contains(className)) return true;
  }
  return false;
}

/// Markdown内の画像（幅90%・最大500px）
class _MarkdownImage extends StatelessWidget {
  final String asset;
  final String? label;

  const _MarkdownImage({required this.asset, this.label});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: (constraints.maxWidth * 0.9).clamp(0, 500).toDouble(),
            ),
            child: Image.asset(asset, semanticLabel: label),
          ),
        ),
      ),
    );
  }
}

/// コードブロック（右上にコピーボタンを置く）
class CodeBlock extends StatefulWidget {
  final String code;

  const CodeBlock({super.key, required this.code});

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;
  bool _hovering = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = SiteColors.of(context);
    final code = widget.code.endsWith('\n')
        ? widget.code.substring(0, widget.code.length - 1)
        : widget.code;
    final strings = SiteLanguage.of(context).strings;
    final label = _copied ? strings.copied : strings.copyCode;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(color: colors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 20, 56, 20),
              child: Text(
                code,
                softWrap: false,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Tooltip(
              message: label,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hovering = true),
                onExit: (_) => setState(() => _hovering = false),
                child: GestureDetector(
                  onTap: _copy,
                  child: AnimatedOpacity(
                    opacity: _hovering ? 1 : 0.6,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.surfaceBorder),
                      ),
                      child: Icon(
                        _copied ? Icons.check : Icons.content_copy_outlined,
                        size: 18,
                        color: colors.text,
                        semanticLabel: label,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 表（角丸の枠で囲み、行の区切りだけを薄い線で示す。収まらない場合は表だけ横にスクロールする）
class ContentTable extends StatelessWidget {
  final dom.Element table;

  /// 麻雀牌の一覧（.mahjongTable）。牌を大きく、中央揃えで表示する
  final bool mahjong;

  const ContentTable({super.key, required this.table, this.mahjong = false});

  @override
  Widget build(BuildContext context) {
    final colors = SiteColors.of(context);
    final narrow = MediaQuery.sizeOf(context).width <= 560;
    final baseStyle = DefaultTextStyle.of(context).style.copyWith(height: 1.5);

    final headerRows = table.querySelectorAll('thead tr');
    final bodyRows = table.querySelectorAll('tbody tr');
    final allRows = [...headerRows, ...bodyRows];
    final columnCount = allRows.fold<int>(
      0,
      (count, row) => row.children.length > count ? row.children.length : count,
    );
    if (columnCount == 0) return const SizedBox.shrink();

    final cells = <Widget>[];
    for (final row in allRows) {
      final isHeader = headerRows.contains(row);
      final rowCells = row.children
          .where((cell) => cell.localName == 'td' || cell.localName == 'th')
          .toList();
      for (var column = 0; column < columnCount; column++) {
        cells.add(
          column < rowCells.length
              ? _cell(
                  context,
                  rowCells[column],
                  column,
                  isHeader,
                  narrow,
                  baseStyle,
                )
              : const SizedBox.shrink(),
        );
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerRadius),
          border: Border.all(color: colors.surfaceBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: CellTable(
            columns: columnCount,
            rowColors: [
              for (final row in allRows)
                headerRows.contains(row) ? colors.mix(8) : null,
            ],
            dividerColor: colors.mix(12),
            children: cells,
          ),
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    dom.Element cell,
    int column,
    bool isHeader,
    bool narrow,
    TextStyle baseStyle,
  ) {
    var style = baseStyle;
    if (isHeader) style = style.copyWith(fontWeight: FontWeight.bold);
    if (mahjong && !isHeader && column > 0) {
      style = style.copyWith(
        fontSize: (style.fontSize ?? 16) * (narrow ? 1.4 : 1.8),
        height: 1.2,
      );
    }

    final padding = mahjong && narrow
        ? const EdgeInsets.symmetric(vertical: 6, horizontal: 4)
        : const EdgeInsets.symmetric(vertical: 8, horizontal: 16);

    return Padding(
      padding: padding,
      child: Text.rich(
        TextSpan(
          children: _InlineHtml(context, mahjong: mahjong).spans(cell.nodes),
        ),
        style: style,
        textAlign: mahjong ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}

/// 表のセルの中身（文字・リンク・コード・色付きの文字など）を TextSpan に変換する
///
/// 表の列幅は中身の幅から決めるため、HtmlWidget ではなく文字だけで組み立てる。
class _InlineHtml {
  final BuildContext context;
  final bool mahjong;

  _InlineHtml(this.context, {required this.mahjong});

  List<InlineSpan> spans(List<dom.Node> nodes) => [
    for (final node in nodes) ..._span(node),
  ];

  List<InlineSpan> _span(dom.Node node) {
    if (node is dom.Text) return [TextSpan(text: node.text)];
    if (node is! dom.Element) return const [];

    final children = spans(node.nodes);
    final colors = SiteColors.of(context);

    switch (node.localName) {
      case 'br':
        return const [TextSpan(text: '\n')];
      case 'strong':
      case 'b':
        return [
          TextSpan(
            style: const TextStyle(fontWeight: FontWeight.bold),
            children: children,
          ),
        ];
      case 'code':
        return [
          TextSpan(
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize:
                  (DefaultTextStyle.of(context).style.fontSize ?? 16) * 0.9,
              backgroundColor: colors.mix(10),
            ),
            children: children,
          ),
        ];
      case 'a':
        final href = node.attributes['href'] ?? '';
        return [
          TextSpan(
            style: const TextStyle(color: linkColor),
            recognizer: TapGestureRecognizer()
              ..onTap = () => openHref(context, href),
            mouseCursor: SystemMouseCursors.click,
            children: children,
          ),
        ];
      case 'small':
        // 麻雀牌の一覧では、牌の下に小さく字を添える
        return [
          if (mahjong) const TextSpan(text: '\n'),
          TextSpan(
            style: TextStyle(fontSize: mahjong ? 12 : null, height: 1.5),
            children: children,
          ),
        ];
      case 'span':
        final tile = node.classes.contains('tile');
        final red = (node.attributes['style'] ?? '').contains('color:red');
        return [
          TextSpan(
            style: TextStyle(
              fontSize: tile ? 16 * 1.6 : null,
              height: tile ? 1 : null,
              color: red ? Colors.red : null,
            ),
            children: children,
          ),
        ];
    }
    return children;
  }
}
