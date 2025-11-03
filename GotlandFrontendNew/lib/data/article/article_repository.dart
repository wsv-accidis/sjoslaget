import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gotland_frontend/model/article.dart';

const ARTICLE_BOOKING = 'booking';
const ARTICLE_RULES = 'rules';

/// Holds the set of available articles and can load their assets.
class ArticleRepository {
  final _articles = [
    Article(id: ARTICLE_BOOKING, title: 'Hur man bokar', asset: 'booking.html'),
    Article(id: ARTICLE_RULES, title: 'Regler på AG', asset: 'rules.html'),
  ];

  bool existsById(String id) => _articles.any((article) => article.id == id);

  Iterable<Article> getAll() => _articles;

  Article getById(String id) => _articles.firstWhere((article) => article.id == id);

  Future<String> loadAssetById(String id, AssetBundle assets) async {
    final article = getById(id);
    return await assets.loadString('articles/${article.asset}');
  }
}
