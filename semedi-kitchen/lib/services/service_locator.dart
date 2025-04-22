import 'package:get_it/get_it.dart';
import 'package:semedi_kitchen/services/app_session_service.dart';
import 'package:semedi_kitchen/services/auth_service.dart';
import 'package:semedi_kitchen/services/secure_storage_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static void setup() {
    getIt.registerSingleton<AppSessionService>(AppSessionService());
    getIt.registerSingleton<SecureStorageService>(SecureStorageService());
    getIt.registerSingleton<AuthService>(AuthService());
  }
}
