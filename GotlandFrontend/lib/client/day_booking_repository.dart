import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:http/http.dart';

import '../model/day_booking.dart';
import '../model/day_booking_source.dart';
import '../model/day_booking_type.dart';
import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class DayBookingRepository {
  final String _apiRoot;

  DayBookingRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

  Future<List<DayBooking>> getList(Client client) async {
    Response response;
    try {
      response = await client.get('$_apiRoot/external/list');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    final List jsonBody = json.decode(response.body);
    return jsonBody.map((dynamic value) => DayBooking.fromMap(value)).toList();
  }

  Future<List<DayBookingType>> getTypes(Client client) async {
    Response response;
    try {
      response = await client.get('$_apiRoot/external/types');
    } catch (e) {
      throw IOException.fromException(e);
    }

    HttpStatus.throwIfNotSuccessful(response);
    final List jsonBody = json.decode(response.body);
    return jsonBody.map((dynamic value) => DayBookingType.fromMap(value)).toList();
  }

  Future<void> saveBooking(Client client, DayBookingSource booking) async {
    final headers = ClientUtil.createJsonHeaders();

    Response response;
    try {
      response = await client.post('$_apiRoot/external/create', headers: headers, body: booking.toJson());
    } catch (e) {
      throw IOException.fromException(e);
    }

    if (HttpStatus.OK != response.statusCode) throw IOException.fromResponse(response);
  }
}
