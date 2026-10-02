import 'package:flutter/material.dart';

import 'links.dart';
import 'site_theme.dart';

class _TabItem {
  final String label;
  final String path;
  final IconData icon;

  const _TabItem(this.label, this.path, this.icon);
}

const _tabs = [
  _TabItem('ホーム', '/', Icons.home_outlined),
  _TabItem('コンテンツ', '/product', Icons.apps_outlined),
  _TabItem('ブログ', '/blog', Icons.article_outlined),
  _TabItem('ニュースルーム', '/newsroom', Icons.newspaper_outlined),
  _TabItem('問い合わせ', '/contact', Icons.contact_page_outlined),
];

/// サイト共通のヘッダー（サイト名とタブ）
///
/// 横長で幅が540px以上のときは文字のタブ、それ以外はアイコンのタブを表示する。
class SiteHeader extends StatelessWidget {
  /// 文字色（トップページでは写真の上に載せるため白にする）
  final Color color;
  final List<Shadow>? shadows;

  const SiteHeader({super.key, required this.color, this.shadows});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final landscape = size.width >= 540 && size.width > size.height;
    final typography = SiteTypography.of(context);
    final titleSize = typography.h1;

    return DefaultTextStyle.merge(
      style: TextStyle(color: color, fontSize: 16, shadows: shadows),
      child: Column(
        children: [
          // h1 の上下の余白（0.67em）
          SizedBox(height: titleSize * 0.67),
          SiteLink(
            href: '/',
            child: Text(
              'いろいろポートフォリオ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: titleSize * 0.67),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (final tab in _tabs)
                landscape
                    ? _TextTab(item: tab, color: color)
                    : _IconTab(item: tab, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

/// ホバー時に左から伸びる下線（foundation.css の .underline）
class _UnderlinedTab extends StatefulWidget {
  final String path;
  final double width;
  final EdgeInsets margin;
  final Color color;
  final Widget child;

  const _UnderlinedTab({
    required this.path,
    required this.width,
    required this.margin,
    required this.color,
    required this.child,
  });

  @override
  State<_UnderlinedTab> createState() => _UnderlinedTabState();
}

class _UnderlinedTabState extends State<_UnderlinedTab> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: SiteLink(
          href: widget.path,
          child: SizedBox(
            width: widget.width,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: widget.child),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -10,
                  height: 3,
                  child: AnimatedScale(
                    scale: _hovering ? 1 : 0,
                    alignment: Alignment.centerLeft,
                    duration: const Duration(milliseconds: 300),
                    child: ColoredBox(color: widget.color),
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

class _TextTab extends StatelessWidget {
  final _TabItem item;
  final Color color;

  const _TextTab({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return _UnderlinedTab(
      path: item.path,
      width: 110,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      color: color,
      child: Text(item.label, maxLines: 1, softWrap: false),
    );
  }
}

class _IconTab extends StatelessWidget {
  final _TabItem item;
  final Color color;

  const _IconTab({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    final shadows = DefaultTextStyle.of(context).style.shadows;
    return _UnderlinedTab(
      path: item.path,
      width: 55,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: color, size: 24, shadows: shadows),
          // h4.iconLabel（8px・上下に1.33emの余白）
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8 * 1.33),
            child: Text(
              item.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
