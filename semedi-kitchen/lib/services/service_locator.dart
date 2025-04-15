import 'package:get_it/get_it.dart';
import 'package:semedi_kitchen/services/auth_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static void setup() {
    getIt.registerSingleton<SecureStorageService>(SecureStorageService());
    getIt.registerSingleton<AuthService>(AuthService());
  }
}
