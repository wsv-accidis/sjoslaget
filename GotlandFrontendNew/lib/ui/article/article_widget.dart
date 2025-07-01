import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gotland_frontend/service_locator.dart';

import '../../data/article/article_repository.dart';

class ArticleWidget extends StatefulWidget {
  const ArticleWidget({super.key, required this.articleId});

  final String articleId;

  @override
  State<StatefulWidget> createState() => ArticleWidgetState();
}

final staticAnchorKey = GlobalKey();

class ArticleWidgetState extends State<ArticleWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadHtml(context, widget.articleId),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return _buildContentView(context, snapshot.requireData);
        } else {
          return const SizedBox(width: 60, height: 60, child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildContentView(BuildContext context, String htmlData) {
    // See: https://pub.dev/packages/flutter_html
    return SingleChildScrollView(
      child: SelectionArea(
        child: Html(anchorKey: staticAnchorKey, data: htmlData),
      ),
    );
  }

  Future<String> _loadHtml(BuildContext context, String id) {
    final articleRepository = serviceLocator<ArticleRepository>();
    return articleRepository.loadAssetById(id, DefaultAssetBundle.of(context));
  }
}
