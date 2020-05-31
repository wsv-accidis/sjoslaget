import 'package:angular_router/angular_router.dart';

import '../app_routes.dart';

class ContentRoutes {
  static final RoutePath start = RoutePath(path: '', useAsDefault: true);
  static final RoutePath about = RoutePath(path: 'allt-om', parent: AppRoutes.content);
  static final RoutePath artists = RoutePath(path: 'program/artister', parent: AppRoutes.content);
  static final RoutePath booking = RoutePath(path: 'bokning', parent: AppRoutes.content);
  static final RoutePath contact = RoutePath(path: 'kontakt', parent: AppRoutes.content);
  static final RoutePath faq = RoutePath(path: 'allt-om/fragor', parent: AppRoutes.content);
  static final RoutePath history = RoutePath(path: 'allt-om/historik', parent: AppRoutes.content);
  static final RoutePath pricing = RoutePath(path: 'priser', parent: AppRoutes.content);
  static final RoutePath privacy = RoutePath(path: 'allt-om/integritet', parent: AppRoutes.content);
  static final RoutePath program = RoutePath(path: 'program', parent: AppRoutes.content);
  static final RoutePath rules = RoutePath(path: 'allt-om/regler', parent: AppRoutes.content);
  static final RoutePath standup = RoutePath(path: 'program/standup', parent: AppRoutes.content);
}
