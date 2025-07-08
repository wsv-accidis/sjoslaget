import 'package:flutter/material.dart';
import 'package:gotland_frontend/data/article/article_repository.dart';
import 'package:gotland_frontend/service_locator.dart';
import 'package:gotland_frontend/ui/article/article_widget.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context) {
    final articleRepository = serviceLocator<ArticleRepository>();
    if (articleRepository.existsById(articleId)) {
      return Align(
        alignment: Alignment.topLeft,
        child: ArticleWidget(articleId: articleId),
      );
    } else {
      return Center(child: Text('Artikeln gick inte att hitta.', style: Theme.of(context).textTheme.titleMedium));
    }
  }
}
