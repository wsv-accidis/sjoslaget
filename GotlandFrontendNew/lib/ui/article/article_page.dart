import 'package:flutter/material.dart';
import 'package:gotland_frontend/ui/article/article_widget.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context) {
    // TODO: Check if article exists and handle error
    return Scaffold(
      body: Center(child: ArticleWidget(articleId: articleId)),
    );
  }
}
