import 'dart:convert';
import 'dart:developer' show log;
import 'dart:math' show max, min;

import 'package:flutter/material.dart' show AssetBundle;
import 'package:gotland_frontend/data/article/article_repository.dart';
import 'package:gotland_frontend/model/article.dart';
import 'package:gotland_frontend/model/search_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

const SEARCH_INDEX_KEY = 'searchIndex';
const SEARCH_INDEX_CREATED_KEY = 'searchIndexCreated';
const SEARCH_INDEX_MAX_AGE_MS = 1000 * 3600 * 24; // 24 hours
const SEARCH_EXTRACT_OFFSET = 60;

/// Finds articles matching a query string and returns search results.
/// Will build a simple search index and cache it in local storage on first call.
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
    if (_sharedPreferences.containsKey(SEARCH_INDEX_CREATED_KEY) && _sharedPreferences.containsKey(SEARCH_INDEX_KEY)) {
      final indexCreated = _sharedPreferences.getInt(SEARCH_INDEX_CREATED_KEY) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - indexCreated < SEARCH_INDEX_MAX_AGE_MS) {
        // Index exists and is not stale, let's try to decode it        
        try {
          final indexJson = jsonDecode(_sharedPreferences.getString(SEARCH_INDEX_KEY) ?? '') as Map<String, dynamic>?;
          if (null != indexJson && indexJson.isNotEmpty) {
            return Map.castFrom(indexJson);
          }
        } on FormatException {
          /* ignore */
        }
      }
    }

    await _removeIndex();
    log('Search index needs rebuilding.');
    final Map<String, String> index = await _rebuildIndex(assets);
    await _storeIndex(index);
    return index;
  }

  Future<Map<String, String>> _rebuildIndex(AssetBundle assets) async {
    final searchIndexFutures = _articleRepository.getAll().map((article) => _createIndexFromArticle(article, assets));
    return {for (var record in await Future.wait(searchIndexFutures)) record.$1: record.$2};
  }

  Future<void> _removeIndex() async {
    await _sharedPreferences.remove(SEARCH_INDEX_KEY);
    await _sharedPreferences.remove(SEARCH_INDEX_CREATED_KEY);
  }

  Future<void> _storeIndex(Map<String, String> index) async {
    final indexJson = jsonEncode(index);
    await _sharedPreferences.setString(SEARCH_INDEX_KEY, indexJson);
    await _sharedPreferences.setInt(SEARCH_INDEX_CREATED_KEY, DateTime.now().millisecondsSinceEpoch);
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
