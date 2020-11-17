import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:webdav_client/src/interceptors.dart';

import 'auth.dart';
import 'client.dart';
import 'utils.dart';

class WdDio extends DioForNative {
  // Request config
  BaseOptions baseOptions;

  // 拦截器
  final List<Interceptor> interceptorList;

  // debug
  final bool debug;

  WdDio({
    this.baseOptions,
    this.interceptorList,
    this.debug,
  }) : super(baseOptions) {
    // 禁止重定向
    this.options.followRedirects = false;

    // 拦截器
    this.interceptors.add(WdInterceptor());

    if (interceptorList != null) {
      for (var item in interceptorList) {
        this.interceptors.add(item);
      }
    }

    // debug
    if (debug == true) {
      this.interceptors.add(LogInterceptor(responseBody: true));
    }
  }

  // methods-------------------------
  Future<Response> req(
    Client self,
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic> headers,
    CancelToken cancelToken,
  }) async {
    // options
    Options options = Options(method: method);

    // headers
    if (headers != null) {
      headers.forEach((key, value) => options.headers[key] = value);
    }

    // authorization
    String str = self.auth.authorize(method, path);
    if (str != null) {
      options.headers['authorization'] = str;
    }

    var resp = await this.requestUri(Uri.parse('${join(self.uri, path)}'),
        options: options, data: data, cancelToken: cancelToken);

    if (resp.statusCode == 401 && self.auth.type == AuthType.NoAuth) {
      String w3AHeader = resp.headers.value('Www-Authenticate');
      // Digest
      if (w3AHeader.toLowerCase().contains('digest')) {
        self.auth = DigestAuth(
            user: self.auth.user,
            pwd: self.auth.pwd,
            dParts: DigestParts(w3AHeader));
      }
      // Basic
      else if (w3AHeader.toLowerCase().contains('basic')) {
        self.auth = BasicAuth(user: self.auth.user, pwd: self.auth.pwd);
      }
      // error
      else {
        throw _newError(resp);
      }

      // retry
      return this.req(self, method, path,
          data: data, headers: headers, cancelToken: cancelToken);
    } else if (resp.statusCode == 401) {
      throw _newError(resp);
    }

    return resp;
  }

  // create error
  DioError _newError(Response resp) {
    return DioError(
        request: resp.request,
        response: resp,
        type: DioErrorType.RESPONSE,
        error: resp.statusMessage);
  }

  // OPTIONS
  Future<Response> wdOptions(Client self, String path,
      {CancelToken cancelToken}) {
    return this.req(self, 'OPTIONS', path,
        headers: {'Depth': '0'}, cancelToken: cancelToken);
  }
}
