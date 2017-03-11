import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

@Component(
	selector: 'booking-details',
	templateUrl: 'booking_details_component.html',
	styleUrls: const ['../content/content_styles.css'],
	directives: const [materialDirectives],
	providers: const [materialProviders]
)
class BookingDetailsComponent {
	String firstName;
	String lastName;
	String phoneNo;
	String email;
	bool acceptToc;
}
