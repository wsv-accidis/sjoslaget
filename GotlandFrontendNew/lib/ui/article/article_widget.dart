import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';
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
    // See: https://github.com/daohoangson/flutter_widget_from_html/tree/master/packages/core
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.only(start: 20.0, end: 20.0, bottom: 20.0),
      child: SelectionArea(
        child: HtmlWidget(
          htmlData,          
          factoryBuilder: () => ArticleWidgetFactory(),
          onTapImage: (imageMetadata) async {
            final fullUrl = imageMetadata.sources.first.url;
            final relativeUrl = fullUrl.replaceFirst('asset:img/', 'assets/img/');
            log('Opening image in new tab: $relativeUrl');
            await _navigateToExternal(relativeUrl);
          },
          onTapUrl: (url) {
            final shouldHandle = !_isExternalUrl(url);
            if (shouldHandle) _navigateToLocal(context, url);
            return shouldHandle;
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

class ArticleWidgetFactory extends WidgetFactory with UrlLauncherFactory {}
