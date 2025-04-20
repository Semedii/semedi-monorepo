import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:semedi/firebase_options.dart';
import 'package:semedi/pages/home_page.dart';
import 'package:semedi/pages/login_page.dart';
import 'package:semedi/services/app_session_service.dart';
import 'package:semedi/services/auth_service.dart';
import 'package:semedi/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    final session = getIt<AppSessionService>();
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          session.hasInitializedAfterLogin = true;
        }
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
