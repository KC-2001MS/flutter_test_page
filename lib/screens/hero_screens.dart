import 'package:flutter/material.dart';

import '../site/site_layout.dart';

/// トップページ
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HeroPage(
      title: '【SwiftUIアプリ開発】いろいろポートフォリオ',
      heading: 'より効率的に。',
      subtitle: '私のほしいものを\n私自身の手で作り出します',
    );
  }
}

/// 存在しないページ
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HeroPage(
      title: 'このページは存在しない',
      heading: '404',
      subtitle: 'このページは存在しません。\nこのページは作られていないようです。URLが正しいかどうかを確認してください。',
    );
  }
}
