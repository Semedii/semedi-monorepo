import 'package:get_it/get_it.dart';
import 'package:semedi/authentication/auth_provider.dart';
import 'package:semedi/services/auth_service.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/services/secure_storage_service.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  getIt.registerSingleton<SecureStorageService>(SecureStorageService());
  getIt.registerSingleton<OrderService>(OrderService());
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<AuthProvider>(AuthProvider());
}
