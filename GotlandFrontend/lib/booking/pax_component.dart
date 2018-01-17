import 'dart:async';
import 'dart:html' show Event, HtmlElement;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:frontend_shared/util.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../booking/booking_validator.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/booking_pax_view.dart';
import '../model/cabin_class.dart';
import '../model/trip.dart';

@Component(
	selector: 'pax-component',
	styleUrls: const ['../content/content_styles.css', 'pax_component.css'],
	templateUrl: 'pax_component.html',
	directives: const <dynamic>[CORE_DIRECTIVES, formDirectives, materialDirectives],
	providers: const <dynamic>[materialProviders]
)
class PaxComponent implements OnInit {
	static const GENDER_FEMALE = 'f';
	static const GENDER_MALE = 'm';
	static const GENDER_OTHER = 'x';
	static const MAX_NO_OF_PAX = 20;

	static final DateFormat _tripDateFormat = new DateFormat('d/M kk:mm');

	final BookingValidator _bookingValidator;
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;

	int initialEmptyPax = 0;
	bool isReadOnly = false; // TODO Support this

	List<BookingPaxView> paxViews = new List<BookingPaxView>();
	List<CabinClass> cabinClasses;
	SelectionOptions<CabinClass> cabinClassOptions;
	List<Trip> inboundTrips;
	SelectionOptions<Trip> inboundTripOptions;
	List<Trip> outboundTrips;
	SelectionOptions<Trip> outboundTripOptions;

	SelectionOptions<String> get genderOptions => new SelectionOptions.fromList(<String>[GENDER_FEMALE, GENDER_MALE, GENDER_OTHER]);

	bool get isLoaded => null != cabinClasses && null != inboundTrips && null != outboundTrips;

	PaxComponent(this._bookingValidator, this._clientFactory, this._eventRepository);

	Future<Null> ngOnInit() async {
		try {
			final client = _clientFactory.getClient();
			cabinClasses = await _eventRepository.getCabinClasses(client);
			inboundTrips = await _eventRepository.getInboundTrips(client);
			outboundTrips = await _eventRepository.getOutboundTrips(client);
		} catch (e) {
			// Ignore this here - we will be stuck in the loading state until the user refreshes
			print('Failed to get data due to an exception: ' + e.toString());
			return;
		}

		cabinClassOptions = new SelectionOptions.fromList(cabinClasses);
		inboundTripOptions = new SelectionOptions.fromList(inboundTrips);
		outboundTripOptions = new SelectionOptions.fromList(outboundTrips);

		if (initialEmptyPax > 0)
			_createInitialEmptyPax(initialEmptyPax);
	}

	String cabinClassToString(CabinClass c) {
		return c.name + ' (' + CurrencyFormatter.formatDecimalAsSEK(c.pricePerPax) + ')';
	}

	String cabinClassToStringLabel(CabinClass c, String which) {
		if (null == c) {
			switch(which) {
				case 'min': return 'Lägsta boende';
				case 'max': return 'Högsta boende';
				case 'pref': return 'Önskat boende';
				default: return '';
			}
		}
		else
			return cabinClassToString(c);
	}

	void deletePax(int idx) {
		final BookingPaxView pax = paxViews[idx];

		// TODO Pending delete

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

	String tripToString(Trip t) {
		if(null == t.departure)
			return t.name;

		return _tripDateFormat.format(t.departure) + ' ' + t.name;
	}

	String tripToStringLabel(Trip t, bool isInbound) {
		if (null == t && isInbound)
			return 'Välj hemresa';
		else if (null == t && !isInbound)
			return 'Välj utresa';
		else
			return tripToString(t);
	}

	String uniqueId(String prefix, int pax) {
		return prefix + '_' + pax.toString();
	}

	void validate(Event event) {
		final idx = _findBookingIndex(event.target);
		if (idx >= 0 && idx < paxViews.length) {
			_bookingValidator.validatePax(paxViews[idx]);
		}
	}

	void validateAll(dynamic ignored) {
		for(BookingPaxView pax in paxViews) {
			_bookingValidator.validatePax(pax);
		}
	}

	void _createInitialEmptyPax(int count) {
		paxViews.clear();
		for (int i = 0; i < count; i++)
		{
			BookingPaxView view = new BookingPaxView.createEmpty();

			// Change detection for <material-dropdown-select> is annoying
			view.outboundTripSelection.selectionChanges.listen(validateAll);
			view.inboundTripSelection.selectionChanges.listen(validateAll);
			view.cabinClassMinSelection.selectionChanges.listen(validateAll);
			view.cabinClassPreferredSelection.selectionChanges.listen(validateAll);
			view.cabinClassMaxSelection.selectionChanges.listen(validateAll);

			paxViews.add(view);
		}
	}

	int _findBookingIndex(HtmlElement target) {
		if (!target.dataset.containsKey('idx')) {
			return null == target.parent ? -1 : _findBookingIndex(target.parent);
		}
		return int.parse(target.dataset['idx']);
	}
}
