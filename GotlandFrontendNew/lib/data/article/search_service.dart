import 'dart:convert';
import 'dart:developer' show log;
import 'dart:math' show max, min;

import 'package:flutter/material.dart' show AssetBundle;
import 'package:gotland_frontend/data/article/article_repository.dart';
import 'package:gotland_frontend/model/article.dart';
import 'package:gotland_frontend/model/search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

const SEARCH_INDEX = 'searchIndex';
const SEARCH_EXTRACT_OFFSET = 60;

class SearchService {
  const SearchService(this._articleRepository, this._sharedPreferences);

  final ArticleRepository _articleRepository;
  final SharedPreferencesWithCache _sharedPreferences;

  Future<List<SearchResult>> search(String query, AssetBundle assets) async {
    final index = await _getOrBuildIndex(assets);
    try {
      return index.entries
          .expand((entry) => _toSearchResultMaybe(query, entry.key, entry.value))
          .toList(growable: false);
    } on FormatException {
      log("Malformed search query: $query");
      return List.empty();
    }
  }

  Future<(String, String)> _createIndexFromArticle(Article article, AssetBundle assets) async {
    final text = await _articleRepository.loadAssetById(article.id, assets);
    // Dirty way of stripping out HTML tags and whitespace - but it works for what we need
    final stripped = text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'[\r\n]'), ' ')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
    return (article.id, stripped);
  }

  Future<Map<String, String>> _getOrBuildIndex(AssetBundle assets) async {
    if (_sharedPreferences.containsKey(SEARCH_INDEX)) {
      try {
        final indexJson = jsonDecode(_sharedPreferences.getString(SEARCH_INDEX) ?? '') as Map<String, dynamic>?;
        if (null != indexJson && indexJson.isNotEmpty) {
          return Map.castFrom(indexJson);
        }
      } on FormatException {
        /* ignore */
      }
    }

    log('Search index is missing or corrupt, rebuilding.');
    final Map<String, String> index = await _rebuildIndex(assets);
    _storeIndex(index);
    return index;
  }

  Future<Map<String, String>> _rebuildIndex(AssetBundle assets) async {
    final searchIndexFutures = _articleRepository.getAll().map((article) => _createIndexFromArticle(article, assets));
    return {for (var record in await Future.wait(searchIndexFutures)) record.$1: record.$2};
  }

  void _storeIndex(Map<String, String> index) {
    final indexJson = jsonEncode(index);
    _sharedPreferences.setString(SEARCH_INDEX, indexJson);
  }

  Iterable<SearchResult> _toSearchResultMaybe(String query, String articleId, String text) {
    final indexOfMatch = text.indexOf(RegExp(query, caseSensitive: false));
    if (-1 != indexOfMatch) {
      final clipStart = max(0, indexOfMatch - SEARCH_EXTRACT_OFFSET);
      final clipEnd = min(text.length, indexOfMatch + query.length + SEARCH_EXTRACT_OFFSET);
      final matchStart = min(indexOfMatch, SEARCH_EXTRACT_OFFSET);
      final matchEnd = matchStart + query.length;
      return [
        SearchResult(
          articleId: articleId,
          extract: text.substring(clipStart, clipEnd),
          matchStart: matchStart,
          matchEnd: matchEnd,
        ),
      ];
    }

    return [];
  }
}
