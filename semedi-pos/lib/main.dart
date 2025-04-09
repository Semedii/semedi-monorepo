import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi_pos/cubit/login/login_cubit.dart';
import 'package:semedi_pos/firebase_options.dart';
import 'package:semedi_pos/screens/login_screen.dart';
import 'package:semedi_pos/screens/main_screen.dart';
import 'package:semedi_pos/service/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData && snapshot.data != null) {
              return MainScreen();
            } else {
              return BlocProvider.value(
                value: BlocProvider.of<LoginCubit>(context),
                child: const LoginScreen(),
              );
            }
          },
        ),
      ),
    );
  }
}
