import 'package:get_it/get_it.dart';
import 'package:semedi_pos/authentication/auth_provider.dart';
import 'package:semedi_pos/service/auth_service.dart';

final getIt = GetIt.instance;
Future<void> setup() async {
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<AuthProvider>(AuthProvider());
}
