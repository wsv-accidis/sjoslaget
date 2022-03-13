import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import '../booking/booking_validator.dart';
import '../content/about_routes.dart';
import '../model/solo_booking_view.dart';
import '../util/food.dart';
import '../util/gender.dart';
import '../widgets/components.dart';

@Component(
    selector: 'solo-component',
    styleUrls: ['../content/content_styles.css', '../content/booking_styles.css', 'solo_component.css'],
    templateUrl: 'solo_component.html',
    directives: <dynamic>[coreDirectives, formDirectives, gotlandMaterialDirectives, routerDirectives],
    providers: <dynamic>[materialProviders],
    exports: [AboutRoutes])
class SoloComponent implements OnInit {
  final BookingValidator _bookingValidator;

  SoloBookingView view = SoloBookingView();
  bool acceptRules = false;
  bool acceptToc = false;

  SelectionOptions<String> get foodOptions => Food.getOptions();

  SelectionOptions<String> get genderOptions => Gender.getOptions();

  bool get isEmpty => view.isEmpty;

  bool get isValid => _bookingValidator.validateSolo(view) && acceptRules && acceptToc;

  SoloComponent(this._bookingValidator);

  void clear() {
    view.clear();
    acceptRules = acceptToc = false;
  }

  @override
  void ngOnInit() {
    view.foodSelection.selectionChanges.listen((ignored) => validate(null));
    view.genderSelection.selectionChanges.listen((ignored) => validate(null));
  }

  String foodToString(dynamic f) => Food.asString(f);

  String genderToString(dynamic g) => Gender.asString(g);

  void validate(Event event) {
    _bookingValidator.validateSolo(view);
  }
}
