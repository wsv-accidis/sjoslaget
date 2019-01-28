import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/model/booking_result.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../booking/pax_component.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../content/content_routes.dart';
import '../model/booking_pax_view.dart';
import '../model/booking_queue_stats.dart';
import '../model/booking_source.dart';
import '../model/cabin_class.dart';
import '../model/team_size.dart';
import '../util/temp_credentials_store.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';

@Component(
	selector: 'booking-page',
	styleUrls: ['../content/content_styles.css', 'booking_edit_page.css'],
	templateUrl: 'booking_edit_page.html',
	directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives, PaxComponent, SpinnerWidget],
	providers: <dynamic>[materialProviders]
)
class BookingEditPage implements OnInit {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;
	final Router _router;
	final TempCredentialsStore _tempCredentialsStore;

	@ViewChild('pax')
	PaxComponent pax;

	BookingSource booking;
	String bookingError; // TODO
	List<CabinClass> cabinClasses;
	BookingResult credentials;
	bool isSaving = false;
	String loadingError;
	BookingQueueStats queueStats;

	bool get canAddPax => pax.count < TEAM_SIZE_MAX;

	bool get canSave => !pax.isEmpty && pax.isValid && !isSaving;

	bool get hasCredentials => null != credentials;

	bool get hasLoaded => null != booking;

	bool get hasLoadingError => isNotEmpty(loadingError);

	bool get hasQueueStats => null != queueStats && !queueStats.isEmpty;

	bool get isNewBooking => false; // TODO

	String get queueLatencyFormatted => _formatQueueLatency(queueStats.queueLatencyMs);

	BookingEditPage(this._bookingRepository, this._clientFactory, this._eventRepository, this._router, this._tempCredentialsStore);

	@override
	Future<void> ngOnInit() async {
		if (!_clientFactory.hasCredentials || _clientFactory.isAdmin) {
			print('Booking page opened without credentials or while logged in as admin.');
			await _router.navigateByUrl(ContentRoutes.booking.toUrl());
			return;
		}

		final String reference = _clientFactory.authenticatedUser;
		try {
			final client = _clientFactory.getClient();
			//event = await _eventRepository.getActiveEvent(client);
			cabinClasses = await _eventRepository.getActiveCabinClasses(client);
			booking = await _bookingRepository.getBooking(client, reference);
			queueStats = await _bookingRepository.getQueueStats(client, reference);
		} catch (e) {
			print('Failed to get booking due to an exception: ${e.toString()}');
			loadingError = 'Någonting gick fel och bokningen kunde inte hämtas. Ladda om sidan och försök igen. Om felet kvarstår, kontakta oss.';
			return;
		}

		credentials = _tempCredentialsStore.load();

		// TODO Handle read-only
		// readonly = event.isLocked ... (this field doesn't exist on the backend yet)

		if (booking.pax.isEmpty) {
			// For new bookings, helpfully create a bunch of empty rows
			final int teamSize = queueStats.teamSize <= 0 || queueStats.teamSize > TEAM_SIZE_MAX ? TEAM_SIZE_DEFAULT : queueStats.teamSize;
			pax.createInitialEmptyPax(teamSize);
		} else {
			pax.paxViews = BookingPaxView.listOfBookingPaxToList(booking.pax, cabinClasses);
		}
	}

	void addEmptyPax() {
		if (canAddPax) {
			pax.addEmptyPax();
		}
	}

	Future<void> saveAndExit() async {
		await saveBooking();

		if (null == bookingError) {
			_clientFactory.clear();
			await _router.navigateByUrl(ContentRoutes.booking.toUrl());
		}
	}

	Future<void> saveBooking() async {
		_tempCredentialsStore.clear();

		if (isSaving)
			return;

		isSaving = true;

		try {
			bookingError = null;

			booking.pax = BookingPaxView.listToListOfBookingPax(pax.paxViews);
			try {
				final client = _clientFactory.getClient();
				await _bookingRepository.saveBooking(client, booking);
			} catch (e) {
				// TODO We could have different messages depending on the type of error here
				bookingError = 'Någonting gick fel när din bokning skulle sparas. Kontrollera att alla uppgifter är riktigt angivna och försök igen. Om problemet kvarstår, kontakta oss.';
			}
		} finally {
			isSaving = false;
		}
	}

	String _formatQueueLatency(int latencyMs) {
		final result = StringBuffer();
		bool includeSmallUnits = true;

		if (latencyMs >= Duration.millisecondsPerDay) {
			final int days = (latencyMs / Duration.millisecondsPerDay).floor();
			latencyMs %= Duration.millisecondsPerDay;
			final String suffix = 1 == days ? '' : 'ar';
			result.write('$days dag$suffix');
			includeSmallUnits = false;
		}

		if (latencyMs >= Duration.millisecondsPerHour) {
			if (result.isNotEmpty) {
				result.write(', ');
			}
			final int hours = (latencyMs / Duration.millisecondsPerHour).floor();
			latencyMs %= Duration.millisecondsPerHour;
			final String suffix = 1 == hours ? 'e' : 'ar';
			result.write('$hours timm$suffix');
			includeSmallUnits = false;
		}

		if (latencyMs >= Duration.millisecondsPerMinute) {
			if (result.isNotEmpty) {
				result.write(', ');
			}
			final int mins = (latencyMs / Duration.millisecondsPerMinute).floor();
			latencyMs %= Duration.millisecondsPerMinute;
			final String suffix = 1 == mins ? '' : 'er';
			result.write('$mins minut$suffix');
		}

		if (includeSmallUnits) {
			if (latencyMs >= Duration.millisecondsPerSecond) {
				if (result.isNotEmpty) {
					result.write(', ');
				}
				final int secs = (latencyMs / Duration.millisecondsPerSecond).floor();
				latencyMs %= Duration.millisecondsPerSecond;
				final String suffix = 1 == secs ? '' : 'er';
				result.write('$secs sekund$suffix');
			}

			if (latencyMs > 0) {
				if (result.isNotEmpty) {
					result.write(', ');
				}
				result.write('$latencyMs ms');
			}
		}

		return result.toString();
	}
}
