import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:gotland_frontend/data/article/article_repository.dart';
import 'package:gotland_frontend/service_locator.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ArticleWidget extends StatefulWidget {
  const ArticleWidget({super.key, required this.articleId});

  final String articleId;

  @override
  State<StatefulWidget> createState() => ArticleWidgetState();
}

class ArticleWidgetState extends State<ArticleWidget> {
  @override
  Widget build(BuildContext context) {
    log('Loading article: ${widget.articleId}');
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
        child: Html(
          data: htmlData,
          onLinkTap: (url, _, _) async {
            if (_isExternalUrl(url!)) {
              await _navigateToExternal(url);
            } else {
              _navigateToLocal(context, url);
            }
          },
        ),
      ),
    );
  }

  bool _isExternalUrl(String url) =>
      url.startsWith('mailto:') || url.startsWith('http://') || url.startsWith('https://');

  Future<String> _loadHtml(BuildContext context, String id) {
    final articleRepository = serviceLocator<ArticleRepository>();
    return articleRepository.loadAssetById(id, DefaultAssetBundle.of(context));
  }

  Future<void> _navigateToExternal(String url) async {
    try {
      await launchUrlString(url);
    } catch (e) {
      log('Failed to launch external URL: $url', error: e);
    }
  }

  void _navigateToLocal(BuildContext context, String url) {
    context.go('/article/$url');
  }
}
