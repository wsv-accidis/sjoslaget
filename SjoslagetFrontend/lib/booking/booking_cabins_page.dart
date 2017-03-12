import 'dart:async';
import 'dart:html' show window;

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';

@Component(
	selector: 'booking-cabins-page',
	templateUrl: 'booking_cabins_page.html',
	styleUrls: const ['../content/content_styles.css']
)
class BookingCabinsPage extends OnInit {
	final Router _router;

	BookingCabinsPage(this._router);

	Future<Null> ngOnInit() async {

	}
}
