class ChallengeFailedException implements Exception {
  ChallengeFailedException() {
    print('Challenge response was not valid.');
  }
}
