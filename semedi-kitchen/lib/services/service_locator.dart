import 'package:get_it/get_it.dart';
import 'package:semedi_kitchen/authentication/auth_provider.dart';
import 'package:semedi_kitchen/services/auth_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  getIt.registerSingleton<SecureStorageService>(SecureStorageService());
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<AuthProvider>(AuthProvider());
}
