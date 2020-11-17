import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';

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

    // 状态码错误视为成功
    this.options.validateStatus = (status)=>true;

    // 拦截器
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
    Function(Options) optionsHandler,
    CancelToken cancelToken,
  }) async {
    // options
    Options options = Options(method: method);

    // 二次处理options
    if (optionsHandler != null) {
      optionsHandler(options);
    }

    // authorization
    String str = self.auth.authorize(method, path);
    if (str != null) {
      options.headers['Authorization'] = str;
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
        throw newResponseError(resp);
      }

      // retry
      return this.req(self, method, path,
          data: data, optionsHandler: optionsHandler, cancelToken: cancelToken);
    } else if (resp.statusCode == 401) {
      throw newResponseError(resp);
    }

    return resp;
  }

  // OPTIONS
  Future<Response> wdOptions(Client self, String path,
      {CancelToken cancelToken}) {
    return this.req(self, 'OPTIONS', path, optionsHandler: (options)=>options.headers['Depth'] = '0', cancelToken: cancelToken);
  }

  // PROPFIND
  Future<Response> wdPropfind(Client self, String path, bool depth, String dataStr,
      {CancelToken cancelToken}) async{
    var resp = await this.req(self, 'PROPFIND', path, data: utf8.encode(dataStr), optionsHandler: (options){
      options.headers['Depth'] = depth ? '1' : '0';
      options.headers['Content-Type'] = 'application/xml;charset=UTF-8';
      options.headers['Accept'] = 'application/xml,text/xml';
      options.headers['Accept-Charset'] = 'utf-8';
      options.headers['Accept-Encoding'] = '';
    }, cancelToken: cancelToken);

    if (resp.statusCode != 207) {
      throw newResponseError(resp);
    }

    return resp;
  }

  // MKCOL
  Future<Response> wdMkcol(Client self, String path, {CancelToken cancelToken}){
    return this.req(self, 'MKCOL', path, cancelToken: cancelToken);
  }

  // DELETE
  Future<Response> wdDelete(Client self, String path, {CancelToken cancelToken}){
    return this.req(self, 'DELETE', path, cancelToken: cancelToken);
  }

  // COPY OR MOVE
  Future<void> wdCopyMove(Client self, String oldPath, String newPath, bool isCopy, bool overwrite,
      {CancelToken cancelToken})async{
    var method = isCopy == true ? 'COPY' : 'MOVE';
    var resp = await this.req(self, method, oldPath, optionsHandler: (options){
      options.headers['Destination'] = Uri.encodeFull(join(self.uri, newPath));
      options.headers['Overwrite'] = overwrite == true ? 'T' : 'F';
    }, cancelToken: cancelToken);

    var status = resp.statusCode;
    // TODO 207
    if (status == 201 || status == 204 || status == 207) {
      return;
    } else if (status == 409) {
      await this._createParent(self, newPath, cancelToken: cancelToken);
      return this.wdCopyMove(self, oldPath, newPath, isCopy, overwrite,
          cancelToken: cancelToken);
    } else {
      throw newResponseError(resp);
    }
  }

  // create parent folder
  Future<void> _createParent(Client self, String path,
      {CancelToken cancelToken}) {
    var parentPath = path.substring(0, path.lastIndexOf('/') + 1);
    ;
    if (parentPath == '' || parentPath == '/') {
      return null;
    }
    return self.mkdirAll(path, cancelToken);
  }

  // read a file
  Future<List<int>> wdRead(Client self, String path,
      {CancelToken cancelToken}) async {
    var resp = await this.req(self, 'GET', path, optionsHandler: (options)=>options.responseType = ResponseType.bytes, cancelToken: cancelToken);
    if (resp.statusCode != 200) {
      throw newResponseError(resp);
    }
    return resp.data;
  }

  // write a file
  Future<void> wdWrite(Client self, String path, Uint8List data,
      {CancelToken cancelToken}) async{
    var resp =
    await this.req(self, 'PUT', path, data: data, cancelToken: cancelToken);
    var status = resp.statusCode;
    if (status == 200 || status == 201 || status == 204) {
      return;
    } else if (status == 409) {
      await this._createParent(self, path, cancelToken: cancelToken);
      return this.wdWrite(self, path, data, cancelToken: cancelToken);
    }
    throw newResponseError(resp);
  }
}
