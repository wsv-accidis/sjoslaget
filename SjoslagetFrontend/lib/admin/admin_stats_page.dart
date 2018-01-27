import 'dart:html';
import 'dart:js' as js;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

@Component(
	selector: 'admin-stats-page',
	templateUrl: 'admin_stats_page.html',
	styleUrls: const ['../content/content_styles.css', 'admin_styles.css', 'admin_stats_page.css'],
	directives: const<dynamic>[CORE_DIRECTIVES, ROUTER_DIRECTIVES, materialDirectives],
	providers: const<dynamic>[materialProviders]
)
class AdminStatsPage {
	void refresh() {
		var element = querySelector('#stats-frame') as IFrameElement;
		if(null != element) {
			// Dart does not expose the reload() method for some reason, so need to proxy through JS :(
			var jsObj = new js.JsObject.fromBrowserObject(element.contentWindow.location);
			jsObj.callMethod('reload');
		}
	}
}
