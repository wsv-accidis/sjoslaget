import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'about_page.template.dart';
import 'booking_page.template.dart';
import 'contact_page.template.dart';
import 'content_routes.dart';
import 'faq_page.template.dart';
import 'history_page.template.dart';
import 'not_found_page.template.dart';
import 'pricing_page.template.dart';
import 'privacy_page.template.dart';
import 'program_page.template.dart';
import 'rules_page.template.dart';
import 'start_page.template.dart';

@Component(
    selector: 'content-component',
    styleUrls: ['content_component.css'],
    templateUrl: 'content_component.html',
    directives: <dynamic>[routerDirectives],
    exports: [ContentRoutes])
class ContentComponent {
  final List<RouteDefinition> routes = [
    RouteDefinition(routePath: ContentRoutes.start, component: StartPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.about, component: AboutPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.booking, component: BookingPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.contact, component: ContactPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.faq, component: FaqPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.history, component: HistoryPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.pricing, component: PricingPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.privacy, component: PrivacyPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.program, component: ProgramPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.rules, component: RulesPageNgFactory),
    RouteDefinition(path: '.+', component: NotFoundPageNgFactory),
  ];
}
