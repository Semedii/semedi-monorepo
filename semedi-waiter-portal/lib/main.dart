import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:semedi/authentication/auth_provider.dart';
import 'package:semedi/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:semedi/pages/home_page.dart';
import 'package:semedi/pages/login_page.dart';
import 'package:semedi/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();
  await setup();
  runApp(
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => getIt(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return authProvider.isAuthenticated ? HomePage() : LoginPage();
        },
      ),
    );
  }
}
