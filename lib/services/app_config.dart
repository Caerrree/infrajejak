/// Runtime flag set once in main.dart depending on whether
/// Firebase.initializeApp() succeeded (i.e. whether firebase_options /
/// google-services.json have actually been configured for this group's
/// Firebase project).
///
/// When true, AuthService/FirestoreService/StorageService transparently use
/// an in-memory mock store instead of real Firebase calls. This lets the
/// team run and demo the full Discover -> Report -> Validate -> Track flow
/// on day one, then flip to real Firebase once the project is wired up —
/// without changing any screen code.
class AppConfig {
  static bool useMockBackend = true;
}
