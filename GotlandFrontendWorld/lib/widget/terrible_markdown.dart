import 'package:flutter/material.dart';

/*
 * The worst Markdown parser implementation known to mankind since I will _not_ pull in the
 * massive flutter_markdown dependency, nor will I format longer texts by creating each 
 * TextSpan instance manually like a madman.
 * 
 * Supported:
 * - Emphasis (bold, italic or both)
 * - Links (TODO)
 * - Headings (TODO)
 * - Unordered lists (TODO)
 * 
 * Not supported:
 * - Everything else
 * - Error handling, this falls over on the tiniest of syntax errors
 */
class TerribleMarkdown extends StatelessWidget {
  const TerribleMarkdown({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final children = _parseText(Theme.of(context));
    return SingleChildScrollView(child: SelectionArea(child: Text.rich(TextSpan(children: children))));
  }

  List<InlineSpan> _parseText(ThemeData theme) {
    final children = List<InlineSpan>.empty(growable: true);
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      switch (text[i]) {
        case "*":
        case "_":
          _createPlainSpanIfNotEmpty(buffer, children, theme);
          i = _createEmphasisSpan(i, children, theme);
          break;
        default:
          buffer.write(text[i]);
      }
    }

    _createPlainSpanIfNotEmpty(buffer, children, theme);
    return children;
  }

  int _createEmphasisSpan(int i, List<InlineSpan> children, ThemeData theme) {
    // Count the number of markers and advance the index to where they end
    var c = 1;
    var m = text[i++];
    for (; text[i] == m; i++, c++) {}

    // Create the appropriate inner span depending on the number of markers
    switch (c) {
      case 1:
        final italic = _defaultTextStyle(theme).copyWith(fontStyle: FontStyle.italic);
        i = _createEmphasisSpanInner(italic, m, i, children);
        break;
      case 2:
        final bold = _defaultTextStyle(theme).copyWith(fontWeight: FontWeight.bold);
        i = _createEmphasisSpanInner(bold, m, i, children);
        break;
      case >= 3:
        final boldItalic = _defaultTextStyle(theme).copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold);
        i = _createEmphasisSpanInner(boldItalic, m, i, children);
        break;
    }

    return i;
  }

  int _createEmphasisSpanInner(TextStyle style, String m, int i, List<InlineSpan> children) {
    // Count the number of characters until the first end marker
    final buffer = StringBuffer();
    for (; text[i] != m; i++) {
      buffer.write(text[i]);
    }

    // Create the span from the buffer we collected
    children.add(TextSpan(style: style, text: buffer.toString()));

    // Advance the pointer to past the end marker (tolerates unbalanced markers)
    for (; text[i] == m; i++) {}
    return i - 1;
  }

  void _createPlainSpanIfNotEmpty(StringBuffer buffer, List<InlineSpan> children, ThemeData theme) {
    // Just create a plain text span from whatever's in the buffer
    if (buffer.isEmpty) return;
    children.add(TextSpan(style: _defaultTextStyle(theme), text: buffer.toString()));
    buffer.clear();
  }

  TextStyle _defaultTextStyle(ThemeData theme) {
    return theme.textTheme.bodyMedium!;
  }
}
