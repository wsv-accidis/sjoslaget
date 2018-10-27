import 'package:angular_router/angular_router.dart';

import 'content_routes.dart';

class AboutRoutes {
	static final RoutePath start = RoutePath(
		path: 'sjoslaget',
		useAsDefault: true,
		parent: ContentRoutes.about
	);
	static final RoutePath booking = RoutePath(path: 'bokning', parent: ContentRoutes.about);
	static final RoutePath faq = RoutePath(path: 'vanliga-fragor', parent: ContentRoutes.about);
	static final RoutePath history = RoutePath(path: 'historik', parent: ContentRoutes.about);
	static final RoutePath program = RoutePath(path: 'program', parent: ContentRoutes.about);
	static final RoutePath rules = RoutePath(path: 'regler-ombord', parent: ContentRoutes.about);
	static final RoutePath privacy = RoutePath(path: 'integritet', parent: ContentRoutes.about);
}
