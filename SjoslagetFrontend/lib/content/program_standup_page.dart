import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'content_routes.dart';

@Component(
    selector: 'program-standup-page',
    styleUrls: ['content_styles.css'],
    templateUrl: 'program_standup_page.html',
    directives: <dynamic>[routerDirectives],
    exports: [ContentRoutes])
class ProgramStandupPage {}
