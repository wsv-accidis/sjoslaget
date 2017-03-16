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
	Function _onSubmitListener;

	String firstName;
	String lastName;
	String phoneNo;
	String email;
	String lunch;
	bool acceptToc;

	void submitDetails() {
		if (null != _onSubmitListener) {
			_onSubmitListener(this);
		}
	}

	void setOnSubmitListener(Function fun) {
		_onSubmitListener = fun;
	}
}
