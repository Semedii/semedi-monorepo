import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient() : dio = Dio(BaseOptions(baseUrl: "http://192.168.0.198:8000")) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🚀 ${options.method} ${options.uri}');
        handler.next(options);
      },
      onError: (e, handler) {
        print('❌ API Error: ${e.response?.statusCode}');
        handler.next(e);
      },
    ));
  }

  void addAuthInterceptor(String token) {
    dio.interceptors.removeWhere((i) => i is _AuthInterceptor);
    dio.interceptors.add(_AuthInterceptor(token));
  }

  void updateToken(String? token) {
    dio.interceptors.removeWhere((i) => i is _AuthInterceptor);
    if (token != null) dio.interceptors.add(_AuthInterceptor(token));
  }
}

class _AuthInterceptor extends Interceptor {
  final String token;

  _AuthInterceptor(this.token);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $token';
    super.onRequest(options, handler);
  }
}
