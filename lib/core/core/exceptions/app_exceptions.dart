sealed class AppExceptions implements Exception{
  String message;
  int? statusCode;
  AppExceptions({required this.message,this.statusCode});
}
class ServerException extends AppExceptions{
  ServerException({required super.message,super.statusCode});
}
class NetworkException extends AppExceptions{
  NetworkException({required super.message,super.statusCode});
}
class UnknownException extends AppExceptions{
  UnknownException({required super.message,super.statusCode});
}