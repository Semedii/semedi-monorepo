import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semedi/cubits/auth/auth_cubit.dart';
import 'package:semedi/cubits/login/login_cubit.dart';
import 'package:semedi/firebase_options.dart';
import 'package:semedi/pages/home_page.dart';
import 'package:semedi/pages/login_page.dart';
import 'package:semedi/services/auth_service.dart';

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
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(
          create: (context) => LoginCubit(AuthService()),
        ),
      ],
      child: MaterialApp(
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return HomePage();
            } else {
              return BlocProvider.value(
                value: BlocProvider.of<LoginCubit>(context),
                child: LoginPage(),
              );
            }
          },
        ),
      ),
    );
  }
}
