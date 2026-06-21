import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../web_services.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
    ),
  );

  @lazySingleton
  WebServices getWebServices(Dio dio) => WebServices(dio);
}
