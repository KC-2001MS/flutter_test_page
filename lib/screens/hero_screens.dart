import 'package:flutter/material.dart';

import '../site/language.dart';
import '../site/site_layout.dart';

/// トップページ
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = SiteLanguage.of(context).strings;
    return HeroPage(
      title: strings.homeTitle,
      heading: strings.homeHeading,
      subtitle: strings.homeSubtitle,
    );
  }
}

/// 存在しないページ
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = SiteLanguage.of(context).strings;
    return HeroPage(
      title: strings.notFoundTitle,
      heading: '404',
      subtitle: strings.notFoundSubtitle,
    );
  }
}
