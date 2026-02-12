import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:my_api_client/my_api_client.dart' show DefaultApi, OrdersApi;
import 'package:semedi/authentication/auth_provider.dart';
import 'package:semedi/services/auth_service.dart';
import 'package:semedi/services/order_service.dart';
import 'package:semedi/services/secure_storage_service.dart';

import '../network/dio_client.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  getIt.registerLazySingleton(() => DioClient());
  getIt.registerLazySingleton(() => getIt<DioClient>().dio);
  getIt.registerSingleton<SecureStorageService>(SecureStorageService());
  getIt.registerLazySingleton(() => DefaultApi(getIt<Dio>()));
  getIt.registerLazySingleton(() => OrdersApi(getIt<Dio>()));
  getIt.registerLazySingleton(() => AuthProvider());
  getIt.registerLazySingleton(
      () => AuthService(getIt<DefaultApi>(), getIt<DioClient>()));
}
