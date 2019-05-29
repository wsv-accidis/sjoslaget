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
import '../util/gender.dart';
import '../widgets/components.dart';

@Component(
	selector: 'pax-component',
	styleUrls: ['../content/content_styles.css', 'pax_component.css'],
	templateUrl: 'pax_component.html',
	directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives],
	providers: <dynamic>[materialProviders]
)
class PaxComponent implements OnInit {
	static const int MAX_NO_OF_PAX = 20;

	final BookingValidator _bookingValidator;
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;
	final _onCountChange = StreamController<int>.broadcast();

	@Input()
	bool hidePricing = false;

	@Output()
	Stream get onCountChange => _onCountChange.stream;

	List<BookingPaxView> paxViews = <BookingPaxView>[];
	List<CabinClass> cabinClasses;
	SelectionOptions<CabinClass> cabinClassOptions;
	bool isReadOnly = false;

	int get count => paxViews.length;

	SelectionOptions<String> get genderOptions => Gender.getOptions();

	bool get hasPrice => priceOfPaxPreferred > 0;

	bool get isEmpty => paxViews.isEmpty || paxViews.every((p) => p.isEmpty);

	bool get isLoaded => null != cabinClasses;

	bool get isValid => paxViews.every((p) => p.isValid);

	int get priceOfPaxMax => paxViews.fold(0, (sum, a) => sum + a.priceMax);

	int get priceOfPaxMin => paxViews.fold(0, (sum, a) => sum + a.priceMin);

	int get priceOfPaxPreferred => paxViews.fold(0, (sum, a) => sum + a.pricePreferred);

	String get priceMaxFormatted => CurrencyFormatter.formatIntAsSEK(priceOfPaxMax);

	String get priceMinFormatted => CurrencyFormatter.formatIntAsSEK(priceOfPaxMin);

	String get pricePreferredFormatted => CurrencyFormatter.formatIntAsSEK(priceOfPaxPreferred);

	set emptyPax(int count) {
		paxViews.clear();
		for (int i = 0; i < count; i++) {
			addEmptyPax();
		}
	}

	set pax(List<BookingPaxView> list) {
		list.forEach(_addListeners);
		paxViews = list;
		_onCountChange.add(count);
	}

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
		_addListeners(view);
		paxViews.add(view);
		_onCountChange.add(count);
	}

	String cabinClassToString(dynamic c) => '${c.name} (${CurrencyFormatter.formatDecimalAsSEK(c.pricePerPax)})';

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

	void deletePax(int idx) {
		paxViews.removeAt(idx);
		_onCountChange.add(count);
	}

	String genderToString(dynamic g) {
		if (null == g)
			return 'Kön';

		return Gender.asString(g);
	}

	String uniqueId(String prefix, int pax) => '${prefix}_${pax.toString()}';

	void validate(Event event) {
		final idx = _findBookingIndex(event.target);
		if (idx >= 0 && idx < paxViews.length) {
			_bookingValidator.validatePax(paxViews[idx]);
		}
	}

	void _addListeners(BookingPaxView view) {
		// Change detection for <material-dropdown-select> is annoying
		view.genderSelection.selectionChanges.listen(_validateAll);
		view.cabinClassMinSelection.selectionChanges.listen(_validateAll);
		view.cabinClassPreferredSelection.selectionChanges.listen(_validateAll);
		view.cabinClassMaxSelection.selectionChanges.listen(_validateAll);
	}

	int _findBookingIndex(HtmlElement target) {
		if (!target.dataset.containsKey('idx')) {
			return null == target.parent ? -1 : _findBookingIndex(target.parent);
		}
		return int.parse(target.dataset['idx']);
	}

	void _validateAll(dynamic ignored) {
		paxViews.forEach(_bookingValidator.validatePax);
	}
}
