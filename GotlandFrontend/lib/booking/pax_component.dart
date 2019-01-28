import 'dart:async';
import 'dart:html' show Event, HtmlElement;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:frontend_shared/util.dart';

import '../booking/booking_validator.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/booking_pax_view.dart';
import '../model/cabin_class.dart';
import '../widgets/components.dart';

@Component(
	selector: 'pax-component',
	styleUrls: ['../content/content_styles.css', 'pax_component.css'],
	templateUrl: 'pax_component.html',
	directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives],
	providers: <dynamic>[materialProviders]
)
class PaxComponent implements OnInit {
	static const String GENDER_FEMALE = 'f';
	static const String GENDER_MALE = 'm';
	static const String GENDER_OTHER = 'x';
	static const int MAX_NO_OF_PAX = 20;

	final BookingValidator _bookingValidator;
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;

	bool isReadOnly = false; // TODO Support this

	List<BookingPaxView> paxViews = <BookingPaxView>[];
	List<CabinClass> cabinClasses;
	SelectionOptions<CabinClass> cabinClassOptions;

	int get count => paxViews.length;

	SelectionOptions<String> get genderOptions => SelectionOptions.fromList(<String>[GENDER_FEMALE, GENDER_MALE, GENDER_OTHER]);

	bool get isEmpty => paxViews.isEmpty || paxViews.every((p) => p.isEmpty);

	bool get isLoaded => null != cabinClasses;

	bool get isValid => paxViews.every((p) => p.isValid);

	PaxComponent(this._bookingValidator, this._clientFactory, this._eventRepository);

	@override
	Future<void> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			cabinClasses = await _eventRepository.getActiveCabinClasses(client);
		} catch (e) {
			// Ignore this here - we will be stuck in the loading state until the user refreshes
			print('Failed to get data due to an exception: ${e.toString()}');
			return;
		}

		cabinClassOptions = SelectionOptions.fromList(cabinClasses);
	}

	void addEmptyPax() {
		final BookingPaxView view = BookingPaxView.createEmpty();

		// Change detection for <material-dropdown-select> is annoying
		view.cabinClassMinSelection.selectionChanges.listen(validateAll);
		view.cabinClassPreferredSelection.selectionChanges.listen(validateAll);
		view.cabinClassMaxSelection.selectionChanges.listen(validateAll);

		paxViews.add(view);
	}

	String cabinClassToString(CabinClass c) => '${c.name} (${CurrencyFormatter.formatDecimalAsSEK(c.pricePerPax)})';

	String cabinClassToStringLabel(CabinClass c, String which) {
		if (null == c) {
			switch (which) {
				case 'min':
					return 'Lägsta boende';
				case 'max':
					return 'Högsta boende';
				case 'pref':
					return 'Önskat boende';
				default:
					return '';
			}
		}
		else
			return cabinClassToString(c);
	}

	void createInitialEmptyPax(int count) {
		paxViews.clear();
		for (int i = 0; i < count; i++) {
			addEmptyPax();
		}
	}

	void deletePax(int idx) {
		paxViews.removeAt(idx);
	}

	String genderToString(String g) {
		if (null == g)
			return 'Kön';

		switch (g) {
			case GENDER_FEMALE:
				return 'Kvinna';
			case GENDER_MALE:
				return 'Man';
			default:
				return 'Annat';
		}
	}

	String uniqueId(String prefix, int pax) => '${prefix}_${pax.toString()}';

	void validate(Event event) {
		final idx = _findBookingIndex(event.target);
		if (idx >= 0 && idx < paxViews.length) {
			_bookingValidator.validatePax(paxViews[idx]);
		}
	}

	void validateAll(dynamic ignored) {
		paxViews.forEach(_bookingValidator.validatePax);
	}

	int _findBookingIndex(HtmlElement target) {
		if (!target.dataset.containsKey('idx')) {
			return null == target.parent ? -1 : _findBookingIndex(target.parent);
		}
		return int.parse(target.dataset['idx']);
	}
}
