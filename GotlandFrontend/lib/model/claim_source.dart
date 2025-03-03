import 'dart:convert';

import 'json_field.dart';

class ClaimSource {
  String candidateId;
  String challengeResponse;

  ClaimSource(this.candidateId, this.challengeResponse);

  String toJson() => json.encode({CANDIDATE_ID: candidateId, CHALLENGE_RESPONSE: challengeResponse});
}
