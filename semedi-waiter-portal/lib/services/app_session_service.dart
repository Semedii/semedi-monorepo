class AppSessionService {
  bool hasInitializedAfterLogin = false;

  void reset() {
    hasInitializedAfterLogin = false;
  }
}
