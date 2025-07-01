import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../model/article.dart';

const ARTICLE_BOOKING = 'booking';

class ArticleRepository {
  final _articles = [Article(id: ARTICLE_BOOKING, title: 'Hur man bokar', asset: 'booking.html')];

  Article getArticleById(String id) => _articles.firstWhere((article) => article.id == id);

  Future<String> loadAssetById(String id, AssetBundle assets) async {
    final article = getArticleById(id);
    return await assets.loadString('articles/${article.asset}');
  }
}
