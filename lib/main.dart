import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'services/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase using each platform's native config file
  // (google-services.json for Android, GoogleService-Info.plist for iOS).
  // Until the team has created their Firebase project and added those
  // files, this will fail gracefully and the app runs on an in-memory
  // mock backend instead — see AppConfig and services/mock_data_store.dart.
  try {
    await Firebase.initializeApp();
    AppConfig.useMockBackend = false;
  } catch (e) {
    debugPrint('Firebase not configured yet — running Infra Jejak in demo/mock mode. ($e)');
    AppConfig.useMockBackend = true;
  }

  runApp(const InfraJejakApp());
}
