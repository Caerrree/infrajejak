import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/hazard_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

class InfraJejakApp extends StatelessWidget {
  const InfraJejakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HazardProvider()),
      ],
      child: MaterialApp(
        title: 'Infra Jejak',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
