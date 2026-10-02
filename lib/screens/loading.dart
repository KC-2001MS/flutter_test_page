import 'package:flutter/material.dart';

import '../site/language.dart';

/// コンテンツの読み込み中・読み込み失敗の表示
class LoadingContent extends StatelessWidget {
  final Object? error;

  const LoadingContent({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: error == null
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(SiteLanguage.of(context).strings.loadFailed),
      ),
    );
  }
}
