import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:semedi_kitchen/firebase_options.dart';
import 'package:semedi_kitchen/pages/home_page.dart';
import 'package:semedi_kitchen/pages/login_page.dart';
import 'package:semedi_kitchen/services/auth_service.dart';
import 'package:semedi_kitchen/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ServiceLocator.setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        return MaterialApp(
          home: snapshot.connectionState == ConnectionState.waiting
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : snapshot.hasData
                  ? HomePage()
                  : LoginPage(),
        );
      },
    );
  }
}
