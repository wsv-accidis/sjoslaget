class SearchResult {
  const SearchResult({
    required this.articleId,
    required this.extract,
    required this.matchStart,
    required this.matchEnd,
  });

  final String articleId;
  final String extract;
  final int matchStart;
  final int matchEnd;
}
