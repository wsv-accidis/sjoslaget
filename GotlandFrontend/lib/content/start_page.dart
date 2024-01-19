import 'package:angular/angular.dart';

import '../widgets/post_feed.dart';

@Component(
    selector: 'start-page',
    styleUrls: ['content_styles.css', 'start_page.css'],
    templateUrl: 'start_page.html',
    directives: <dynamic>[coreDirectives, PostFeed])
class StartPage {}
