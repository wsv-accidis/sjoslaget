import 'package:angular_router/angular_router.dart';

import '../app_routes.dart';

class ContentRoutes {
  static final RoutePath start = RoutePath(path: '', useAsDefault: true);
  static final RoutePath about = RoutePath(path: 'allt-om', parent: AppRoutes.content);
  static final RoutePath booking = RoutePath(path: 'bokning', parent: AppRoutes.content);
  static final RoutePath pricing = RoutePath(path: 'priser', parent: AppRoutes.content);
  static final RoutePath program = RoutePath(path: 'program', parent: AppRoutes.content);
}
