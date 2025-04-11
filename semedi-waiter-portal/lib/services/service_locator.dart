import 'package:get_it/get_it.dart';
import 'package:semedi/services/auth_service.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/services/secure_storage_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static void setup() {
    getIt.registerSingleton<AuthService>(AuthService());
    getIt.registerSingleton<OrderService>(OrderService());
    getIt.registerSingleton<SecureStorageService>(SecureStorageService());
  }
}
