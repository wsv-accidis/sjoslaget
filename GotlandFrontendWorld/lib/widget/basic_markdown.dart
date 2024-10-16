import 'package:flutter/material.dart';

class BasicMarkdown extends StatelessWidget {
  const BasicMarkdown({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return SingleChildScrollView(child: SelectionArea(child: Text.rich(TextSpan(style: style, text: text))));
  }
}
