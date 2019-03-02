import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/util.dart';
import 'package:frontend_shared/widget/modal_dialog.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../booking/pax_component.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/booking_pax_view.dart';
import '../model/booking_source.dart';
import '../model/cabin_class.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';
import 'allocation_component.dart';

@Component(
	selector: 'admin-booking-page',
	templateUrl: 'admin_booking_page.html',
	styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_booking_page.css'],
	directives: <dynamic>[coreDirectives, routerDirectives, formDirectives, gotlandMaterialDirectives, AllocationComponent, PaxComponent, ModalDialog, SpinnerWidget],
	providers: <dynamic>[materialProviders],
	exports: <dynamic>[AdminRoutes, ValidationSupport]
)
class AdminBookingPage implements OnActivate {
	final BookingRepository _bookingRepository;
	final ClientFactory _clientFactory;
	final EventRepository _eventRepository;
	final Router _router;

	@ViewChild('allocation')
	AllocationComponent allocationComponent;

	@ViewChild('deleteBookingDialog')
	ModalDialog deleteBookingDialog;

	@ViewChild('pax')
	PaxComponent pax;

	BookingSource booking;
	String bookingError;
	List<CabinClass> cabinClasses;
	bool isSaving = false;
	String loadingError;

	bool get canDelete => !isSaving;

	bool get canSave => !pax.isEmpty && pax.isValid && !isSaving;

	String get confirmationSentMessage =>
		hasSentConfirmation ? 'Bekräftelse skickad ${DateTimeFormatter.format(booking.confirmationSent)}'
			: 'Bekräftelse inte skickad';

	bool get hasSentConfirmation => null != booking.confirmationSent;

	bool get hasBookingError => isNotEmpty(bookingError);

	bool get hasLoadingError => isNotEmpty(loadingError);

	bool get isLoading => null == booking;

	set noOfPax(int value) => allocationComponent.noOfPaxInBooking = value;

	AdminBookingPage(this._bookingRepository, this._clientFactory, this._eventRepository, this._router);

	void addEmptyPax() {
		pax.addEmptyPax();
		allocationComponent.noOfPaxInBooking = pax.count;
	}

	Future<void> confirmBooking() async {
		if (isSaving)
			return;

		isSaving = true;

		try {
			final client = _clientFactory.getClient();
			await _bookingRepository.confirmBooking(client, booking.reference);
			booking.confirmationSent = DateTime.now();
		} catch (e) {
			print('Failed to confirm booking: ${e.toString()}');
		} finally {
			isSaving = false;
		}
	}

	Future<void> deleteBooking() async {
		if (isSaving)
			return;
		if (!await deleteBookingDialog.openAsync())
			return;

		isSaving = true;

		try {
			final client = _clientFactory.getClient();
			await _bookingRepository.deleteBooking(client, booking.reference);
		} catch (e) {
			print('Failed to delete booking: ${e.toString()}');
		} finally {
			isSaving = false;
		}

		await _router.navigateByUrl(AdminRoutes.dashboard.toUrl());
	}

	@override
	Future<void> onActivate(_, RouterState routerState) async {
		final String reference = routerState.parameters['ref'];

		try {
			final client = _clientFactory.getClient();
			booking = await _bookingRepository.getBooking(client, reference);
			cabinClasses = await _eventRepository.getActiveCabinClasses(client);
			pax.pax = BookingPaxView.listOfBookingPaxToList(booking.pax, cabinClasses);

			allocationComponent.bookingRef = reference;
			await allocationComponent.load();
		} catch (e) {
			print('Failed to load booking: ${e.toString()}');
			loadingError = 'Någonting gick fel och bokningen kunde inte hämtas. Ladda om sidan och försök igen.';
			return;
		}
	}

	Future<void> saveBooking() async {
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
				bookingError = 'Någonting gick fel när bokningen skulle sparas. Kontrollera att alla uppgifter är riktigt angivna och försök igen.';
			}
		} finally {
			isSaving = false;
		}
	}
}
