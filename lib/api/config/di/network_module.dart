import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../web_services.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  WebServices getWebServices(Dio dio) => WebServices(dio);
}
