import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/model/booking_result.dart';

import '../admin/solo_component.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/event_repository.dart';
import '../model/event.dart';
import '../model/solo_booking_source.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'content_routes.dart';

@Component(
    selector: 'solo-booking-page',
    templateUrl: 'solo_booking_page.html',
    styleUrls: ['content_styles.css', 'solo_booking_page.css'],
    directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives, routerDirectives, SoloComponent, SpinnerWidget],
    exports: [ContentRoutes])
class SoloBookingPage implements OnInit {
  final BookingRepository _bookingRepository;
  final ClientFactory _clientFactory;
  final EventRepository _eventRepository;
  final Router _router;

  @ViewChild('booking')
  SoloComponent booking;

  bool hasError = false;
  bool isSaving = false;

  bool get canSubmit => booking.isValid && !isSaving;

  SoloBookingPage(this._bookingRepository, this._clientFactory, this._eventRepository, this._router);

  @override
  Future<void> ngOnInit() async {
    try {
      final client = _clientFactory.getClient();
      final Event evnt = await _eventRepository.getActiveEvent(client);

      // No countdown on this page; just refuse entry if event is not yet open
      if (!evnt.hasOpened) {
        await _router.navigateByUrl(ContentRoutes.start.toUrl());
      }
    } catch (e) {
      print('Failed to load active event: ${e.toString()}');
    }
  }

  Future<void> submit() async {
    isSaving = true;
    hasError = false;
    try {
      final source = SoloBookingSource.fromSoloView(booking.view);
      final client = _clientFactory.getClient();
      final BookingResult result = await _bookingRepository.saveSoloBooking(client, source);
      print('Created a booking with ref: ${result.reference}');
    } catch (e) {
      print('Failed to save booking: ${e.toString()}');
      hasError = true;
    } finally {
      if (!hasError) {
        await _router.navigateByUrl(ContentRoutes.start.toUrl());
      }
      isSaving = false;
    }
  }
}
