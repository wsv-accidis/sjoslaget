import 'package:angular/angular.dart';

import '../model/post_image_view.dart';
import '../model/post_source.dart';
import '../util/datetime_formatter.dart';
import 'real_safe_inner_html_directive.dart';

@Component(
    selector: 'post-view',
    templateUrl: 'post_view.html',
    styleUrls: ['post_view.css'],
    directives: <dynamic>[coreDirectives, RealSafeInnerHtmlDirective])
class PostView {
  @Input()
  PostSource post;

  @Input()
  List<PostImageView> images;

  String get dateFormatted =>
      null != post.created ? DateTimeFormatter.format(post.created) : '';
}
