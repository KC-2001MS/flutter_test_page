import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/content_screens.dart';
import 'screens/hero_screens.dart';
import 'screens/product_list_screen.dart';
import 'site/site_theme.dart';

void main() {
  runApp(const MyApp());
}

/// ページの切り替えはウェブページと同じくアニメーションしない
Page<void> _page(GoRouterState state, Widget child) =>
    NoTransitionPage(key: state.pageKey, child: child);

String _slug(GoRouterState state) => state.pathParameters['slug']!;

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _page(state, const HomeScreen()),
    ),
    GoRoute(
      path: '/product',
      pageBuilder: (context, state) => _page(state, const ProductListScreen()),
      routes: [
        GoRoute(
          path: 'tips/:slug',
          pageBuilder: (context, state) => _page(
            state,
            MarkdownScreen(
              name: 'tips/${_slug(state)}',
              defaultTitle: 'いろいろのTips',
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
              defaultTitle: 'いろいろの製品詳細',
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/blog',
      pageBuilder: (context, state) => _page(
        state,
        const ArticleListScreen(
          directory: 'blog',
          heading: 'Blog',
          title: 'いろいろのブログ',
          emptyMessage: '現在、ブログ記事はありません。',
        ),
      ),
      routes: [
        GoRoute(
          path: ':slug',
          pageBuilder: (context, state) => _page(
            state,
            MarkdownScreen(
              name: 'blog/${_slug(state)}',
              defaultTitle: 'いろいろのブログ',
              showDonation: true,
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/newsroom',
      pageBuilder: (context, state) => _page(
        state,
        const ArticleListScreen(
          directory: 'newsroom',
          heading: 'Newsroom',
          title: 'ニュースルーム',
          emptyMessage: '現在、ニュースはありません。',
        ),
      ),
      routes: [
        GoRoute(
          path: ':slug',
          pageBuilder: (context, state) => _page(
            state,
            MarkdownScreen(
              name: 'newsroom/${_slug(state)}',
              defaultTitle: 'ニュースルーム',
              showDonation: true,
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/contact',
      pageBuilder: (context, state) => _page(
        state,
        const MarkdownScreen(name: 'contact', defaultTitle: 'いろいろへのお問い合わせ'),
      ),
    ),
    GoRoute(
      path: '/privacy',
      pageBuilder: (context, state) => _page(
        state,
        const HtmlPageScreen(name: 'privacy', title: 'プライバシーポリシー'),
      ),
    ),
    GoRoute(
      path: '/agreement',
      pageBuilder: (context, state) =>
          _page(state, const HtmlPageScreen(name: 'agreement', title: '利用規約')),
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
