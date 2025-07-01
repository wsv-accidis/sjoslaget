import 'package:flutter/material.dart';
import 'package:gotland_frontend/ui/article/article_widget.dart';

import '../../data/article/article_repository.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: ArticleWidget(articleId: ARTICLE_BOOKING)),
      );
  }
}
