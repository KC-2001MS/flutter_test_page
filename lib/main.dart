import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'screens/content_screens.dart';
import 'screens/hero_screens.dart';
import 'screens/product_list_screen.dart';
import 'site/language.dart';
import 'site/site_theme.dart';

void main() {
  // URLに "#" を付けない（/flutter_test_page/product の形にする）
  usePathUrlStrategy();
  runApp(const MyApp());
}

/// ページの切り替えはウェブページと同じくアニメーションしない
///
/// URLが /en で始まるページは英語版として表示する。
Page<void> _page(GoRouterState state, Widget child) => NoTransitionPage(
  key: state.pageKey,
  child: SiteLanguageScope(
    language: SiteLanguage.fromPath(state.uri.path),
    child: child,
  ),
);

String _slug(GoRouterState state) => state.pathParameters['slug']!;

/// 日本語版（/）と英語版（/en）で共通のページ
List<RouteBase> _pages() => [
  GoRoute(
    path: 'product',
    pageBuilder: (context, state) => _page(state, const ProductListScreen()),
    routes: [
      GoRoute(
        path: 'tips/:slug',
        pageBuilder: (context, state) => _page(
          state,
          MarkdownScreen(
            name: 'tips/${_slug(state)}',
            defaultTitle: (strings) => strings.tipsTitle,
            showDonation: true,
          ),
        ),
      ),
      GoRoute(
        path: ':slug',
        pageBuilder: (context, state) => _page(
          state,
          MarkdownScreen(
            name: 'product/${_slug(state)}',
            defaultTitle: (strings) => strings.productDetailTitle,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: 'blog',
    pageBuilder: (context, state) => _page(
      state,
      ArticleListScreen(
        directory: 'blog',
        heading: 'Blog',
        title: (strings) => strings.blogTitle,
        emptyMessage: (strings) => strings.emptyBlog,
      ),
    ),
    routes: [
      GoRoute(
        path: ':slug',
        pageBuilder: (context, state) => _page(
          state,
          MarkdownScreen(
            name: 'blog/${_slug(state)}',
            defaultTitle: (strings) => strings.blogTitle,
            showDonation: true,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: 'newsroom',
    pageBuilder: (context, state) => _page(
      state,
      ArticleListScreen(
        directory: 'newsroom',
        heading: 'Newsroom',
        title: (strings) => strings.newsroomTitle,
        emptyMessage: (strings) => strings.emptyNews,
      ),
    ),
    routes: [
      GoRoute(
        path: ':slug',
        pageBuilder: (context, state) => _page(
          state,
          MarkdownScreen(
            name: 'newsroom/${_slug(state)}',
            defaultTitle: (strings) => strings.newsroomTitle,
            showDonation: true,
          ),
        ),
      ),
    ],
  ),
  GoRoute(
    path: 'contact',
    pageBuilder: (context, state) => _page(
      state,
      MarkdownScreen(
        name: 'contact',
        defaultTitle: (strings) => strings.contactTitle,
      ),
    ),
  ),
  GoRoute(
    path: 'privacy',
    pageBuilder: (context, state) => _page(
      state,
      HtmlPageScreen(name: 'privacy', title: (strings) => strings.privacyTitle),
    ),
  ),
  GoRoute(
    path: 'agreement',
    pageBuilder: (context, state) => _page(
      state,
      HtmlPageScreen(
        name: 'agreement',
        title: (strings) => strings.agreementTitle,
      ),
    ),
  ),
  GoRoute(
    path: '404',
    pageBuilder: (context, state) => _page(state, const NotFoundScreen()),
  ),
];

final router = GoRouter(
  // GitHub Pagesはディレクトリへのアクセス時に末尾に "/" を付けるため、取り除いてから照合する
  redirect: (context, state) {
    final path = state.uri.path;
    if (path.length > 1 && path.endsWith('/')) {
      return state.uri
          .replace(path: path.replaceFirst(RegExp(r'/+$'), ''))
          .toString();
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/en',
      pageBuilder: (context, state) => _page(state, const HomeScreen()),
      routes: _pages(),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _page(state, const HomeScreen()),
      routes: _pages(),
    ),
  ],
  errorPageBuilder: (context, state) => _page(state, const NotFoundScreen()),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '【SwiftUIアプリ開発】いろいろポートフォリオ',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
