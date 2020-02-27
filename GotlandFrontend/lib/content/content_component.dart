import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'about_component.template.dart';
import 'booking_page.template.dart';
import 'contact_page.template.dart';
import 'content_routes.dart';
import 'not_found_page.template.dart';
import 'pricing_page.template.dart';
import 'solo_booking_page.template.dart';
import 'start_page.template.dart';

@Component(selector: 'content-component', styleUrls: ['content_component.css'], templateUrl: 'content_component.html', directives: <dynamic>[routerDirectives], exports: [ContentRoutes])
class ContentComponent {
  final List<RouteDefinition> routes = [
    RouteDefinition(routePath: ContentRoutes.start, component: StartPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.about, component: AboutComponentNgFactory),
    RouteDefinition(routePath: ContentRoutes.booking, component: BookingPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.contact, component: ContactPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.pricing, component: PricingPageNgFactory),
    RouteDefinition(routePath: ContentRoutes.solo, component: SoloBookingPageNgFactory),
    RouteDefinition(path: '.+', component: NotFoundPageNgFactory),
  ];
}
