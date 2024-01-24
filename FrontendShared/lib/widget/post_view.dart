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

  String get dateFormatted {
    if (null == post.created) return '';

    final sinceCreated = DateTime.now().difference(post.created);
    if (!sinceCreated.isNegative && sinceCreated < Duration(minutes: 5)) {
      return 'alldeles nyss.';
    }
    if (!sinceCreated.isNegative && sinceCreated < Duration(minutes: 60)) {
      return 'för ${sinceCreated.inMinutes} min sedan.';
    }
    if (!sinceCreated.isNegative && sinceCreated < Duration(hours: 24)) {
      final minutes = sinceCreated.inMinutes -
          sinceCreated.inHours * Duration.minutesPerHour;
      return 'för ${sinceCreated.inHours} tim och $minutes min sedan.';
    }
    if (!sinceCreated.isNegative && sinceCreated < Duration(days: 7)) {
      final minutes = sinceCreated.inMinutes -
          sinceCreated.inHours * Duration.minutesPerHour;
      final hours =
          sinceCreated.inHours - sinceCreated.inDays * Duration.hoursPerDay;
      return 'för ${sinceCreated.inDays} dag${sinceCreated.inDays > 1 ? 'ar' : ''}, $hours tim och $minutes min sedan.';
    }

    return DateTimeFormatter.format(post.created) + '.';
  }

  String get fullDateFormatted =>
      null != post.created ? DateTimeFormatter.format(post.created) : '';
}
