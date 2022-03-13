import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:frontend_shared/admin/payment_history_component.dart';
import 'package:frontend_shared/model.dart' show BookingResult;
import 'package:frontend_shared/util.dart';
import 'package:frontend_shared/widget/modal_dialog.dart';
import 'package:quiver/strings.dart' show isNotEmpty;

import '../model/day_booking_source.dart';
import '../client/booking_repository.dart';
import '../client/client_factory.dart';
import '../client/day_booking_repository.dart';
import '../model/booking_pax_view.dart';
import '../model/booking_source.dart';
import '../model/cabin_class.dart';
import '../model/day_booking_type.dart';
import '../util/temp_credentials_store.dart';
import '../widgets/components.dart';
import '../widgets/spinner_widget.dart';
import 'admin_routes.dart';
import 'allocation_component.dart';
import 'pax_component.dart';
import 'payment_component.dart';

@Component(
    selector: 'admin-day-booking-page',
    templateUrl: 'admin_day_booking_page.html',
    styleUrls: ['../content/content_styles.css', 'admin_styles.css', 'admin_day_booking_page.css'],
    directives: <dynamic>[coreDirectives, routerDirectives, formDirectives, gotlandMaterialDirectives, SpinnerWidget],
    providers: <dynamic>[materialProviders],
    exports: <dynamic>[AdminRoutes])
class AdminDayBookingPage implements OnActivate {
  final DayBookingRepository _dayBookingRepository;
  final ClientFactory _clientFactory;
  final Router _router;

  DayBookingSource booking;
  List<DayBookingType> types;
  bool isSaving = false;
  String loadingError;

  bool get hasLoadingError => isNotEmpty(loadingError);

  bool get isLoading => null == booking || null == types;

  AdminDayBookingPage(this._dayBookingRepository, this._clientFactory, this._router);

  @override
  Future<void> onActivate(_, RouterState routerState) async {
    final String id = routerState.parameters['id'];

    try {
      final client = _clientFactory.getClient();
      booking = await _dayBookingRepository.getBooking(client, id);
      types = await _dayBookingRepository.getTypes(client);
    } catch (e) {
      print('Failed to load day booking: ${e.toString()}');
      loadingError = 'Någonting gick fel och dagbiljetten kunde inte hämtas. Ladda om sidan och försök igen.';
    }
  }
}
