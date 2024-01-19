import 'dart:async';

import 'package:angular/angular.dart';
import 'package:frontend_shared/client.dart';
import 'package:frontend_shared/model/booking_result.dart';
import 'package:http/http.dart';

import '../model/booking_details.dart';
import '../model/candidate_response.dart';
import '../model/queue_response.dart';
import 'booking_exception.dart';
import 'client_factory.dart' show GOTLAND_API_ROOT;

@Injectable()
class QueueRepository {
  final String _apiRoot;

  QueueRepository(@Inject(GOTLAND_API_ROOT) this._apiRoot);

  Future<CandidateResponse> createCandidate(Client client, BookingDetails candidate) async {
    final headers = ClientUtil.createJsonHeaders();

    Response response;
    try {
      response = await client.post('$_apiRoot/queue/create', headers: headers, body: candidate.toJson());
    } catch (e) {
      throw IOException.fromException(e);
    }

    if (HttpStatus.OK == response.statusCode)
      return CandidateResponse.fromJson(response.body);
    else if (HttpStatus.BAD_REQUEST == response.statusCode)
      throw BookingException();
    else
      throw IOException.fromResponse(response);
  }

  Future<QueueResponse> go(Client client, String candidateId) async {
    Response response;
    try {
      response = await client.put('$_apiRoot/queue/claim?c=$candidateId');
    } catch (e) {
      throw IOException.fromException(e);
    }

    if (HttpStatus.OK == response.statusCode)
      return QueueResponse.fromJson(response.body);
    else if (HttpStatus.BAD_REQUEST == response.statusCode)
      // Countdown not elapsed yet
      throw BookingException();
    else
      throw IOException.fromResponse(response);
  }

  Future<CandidateResponse> ping(Client client, String candidateId) async {
    Response response;
    try {
      response = await client.put('$_apiRoot/queue/ping?c=$candidateId');
    } catch (e) {
      throw IOException.fromException(e);
    }

    if (HttpStatus.OK == response.statusCode)
      return CandidateResponse.fromJson(response.body);
    else if (HttpStatus.NOT_FOUND == response.statusCode)
      // The candidate has timed out
      throw BookingException();
    else
      throw IOException.fromResponse(response);
  }

  Future<BookingResult> toBooking(Client client, String candidateId) async {
    Response response;
    try {
      response = await client.post('$_apiRoot/queue/toBooking?c=$candidateId');
    } catch (e) {
      throw IOException.fromException(e);
    }

    if (HttpStatus.OK == response.statusCode)
      return BookingResult.fromJson(response.body);
    else if (HttpStatus.BAD_REQUEST == response.statusCode)
      // Something went wrong when creating the booking
      throw BookingException();
    else
      throw IOException.fromResponse(response);
  }
}
