// this is to delay logging in to give the app enough time to read from secure storage

class AppSessionService {
  bool hasInitializedAfterLogin = false;

  void reset() {
    hasInitializedAfterLogin = false;
  }
}
