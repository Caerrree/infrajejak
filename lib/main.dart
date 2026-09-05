import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'services/app_config.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    AppConfig.useMockBackend = false;
  } catch (e) {
    debugPrint('Firebase not configured yet — running Infra Jejak in demo/mock mode. ($e)');
    AppConfig.useMockBackend = true;
  }

  runApp(const InfraJejakApp());
}
