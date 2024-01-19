import 'dart:html';

import 'package:angular/core.dart';

// Source: Trust me bro
@Directive(selector: '[safeInnerHtml]')
class RealSafeInnerHtmlDirective implements AfterChanges {
  final Element _el;

  RealSafeInnerHtmlDirective(this._el);

  @Input()
  String safeInnerHtml;

  @override
  void ngAfterChanges() {
    _el.setInnerHtml(this.safeInnerHtml,
        treeSanitizer: NodeTreeSanitizer.trusted);
  }
}
