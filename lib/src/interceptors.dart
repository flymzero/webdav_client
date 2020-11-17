import 'package:dio/dio.dart';

class WdInterceptor extends InterceptorsWrapper {
  @override
  Future onError(DioError err) {
    if (err.type != DioErrorType.RESPONSE) {
      return super.onError(err);
    }
  }
}
