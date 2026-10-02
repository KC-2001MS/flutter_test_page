import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// 元サイトのリンク（"./product/xxx" や "/privacy"、外部URL）を開く
///
/// サイト内のパスはルーターで遷移し、それ以外はブラウザで開く。
Future<bool> openHref(BuildContext context, String href) async {
  // 脚注の戻りリンクなどページ内のアンカーは何もしない
  if (href.isEmpty || href.startsWith('#')) return true;

  final current = GoRouter.of(context).state.uri;
  final internal = internalPath(href, from: current);
  if (internal != null) {
    context.go(internal);
    return true;
  }

  final uri = Uri.tryParse(href);
  if (uri == null) return false;
  return launchUrl(uri, webOnlyWindowName: '_self');
}

/// サイト内のパスであれば、ルーターで扱えるパスに変換する
///
/// "./product/xxx" のような相対パスは、ブラウザと同じく現在のページ [from] を基準にする
/// （英語版の /en/product からは /en/product/xxx になる）。
String? internalPath(String href, {Uri? from}) {
  if (href.startsWith('./')) {
    href = (from ?? Uri.parse('/')).resolve(href).path;
  }
  if (!href.startsWith('/') || href.startsWith('//')) return null;
  // "/privacy.html" のような旧URLにも対応する
  return href.replaceFirst(RegExp(r'\.html$'), '');
}

/// テキストのリンク（a要素）
class SiteLink extends StatelessWidget {
  final String href;
  final Widget child;

  const SiteLink({super.key, required this.href, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => openHref(context, href),
        child: child,
      ),
    );
  }
}
