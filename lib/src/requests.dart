import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'auth.dart';
import 'client.dart';
import 'error.dart';
import 'utils.dart';

extension HttpClientExtension on HttpClient {
  //
  Future<HttpClientResponse> req(
    Client self,
    String method,
    String path, {
    Uint8List data,
    Function(HttpClientRequest) intercept,
    CancelToken cancelToken,
  }) async {
    HttpClientRequest request =
        await this.openUrl(method, Uri.parse('${join(self.uri, path)}'));

    request
      ..followRedirects = false
      ..persistentConnection = false;

    // self.headers.forEach((key, value) {
    //   request.headers.set(key, value);
    // });

    String str = self.auth.authorize(method, path);
    if (str != null) {
      request.headers.set('Authorization', str);
    }

    if (intercept != null) {
      intercept(request);
    }

    if (data != null) {
      request.add(data);
    }

    HttpClientResponse response = await request.close();

    if (response.statusCode == 401 && self.auth.type == AuthType.NoAuth) {
      String w3AHeader = response.headers.value('Www-Authenticate');
      if (w3AHeader.toLowerCase().contains('digest')) {
        self.auth = DigestAuth(
            user: self.auth.user,
            pwd: self.auth.pwd,
            dParts: DigestParts(w3AHeader));
      } else if (w3AHeader.toLowerCase().contains('basic')) {
        self.auth = BasicAuth(user: self.auth.user, pwd: self.auth.pwd);
      } else {
        throw WebdavError(
            error: '${response.reasonPhrase}(${response.statusCode})');
      }
      return this.req(self, method, path,
          data: data, intercept: intercept, cancelToken: cancelToken);
    } else if (response.statusCode == 401) {
      throw WebdavError(
          error: '${response.reasonPhrase}(${response.statusCode})');
    }

    return response;
  }

  //
  Future<HttpClientResponse> options(Client self, String path,
      {CancelToken cancelToken}) {
    return this.req(self, 'OPTIONS', path,
        intercept: (req) => req.headers.set('Depth', '0'),
        cancelToken: cancelToken);
  }

  //
  Future<HttpClientResponse> propfind(
      Client self, String path, bool depth, String dataStr,
      {CancelToken cancelToken}) async {
    HttpClientResponse resp = await this.req(
      self,
      'PROPFIND',
      path,
      data: utf8.encode(dataStr),
      intercept: (req) {
        req.headers.set('Depth', depth ? '1' : '0');
        req.headers.set('Content-Type', 'application/xml;charset=UTF-8');
        req.headers.set('Accept', 'application/xml,text/xml');
        req.headers.set('Accept-Charset', 'utf-8');
        req.headers.set('Accept-Encoding', '');
      },
      cancelToken: cancelToken,
    );

    if (resp.statusCode != 207) {
      throw WebdavError(error: '${resp.reasonPhrase}(${resp.statusCode})');
    }

    return resp;
  }

  //
  Future<HttpClientResponse> mkcol(Client self, String path,
      {CancelToken cancelToken}) {
    return this.req(self, 'MKCOL', path, cancelToken: cancelToken);
  }

  //
  Future<HttpClientResponse> delete2(Client self, String path,
      {CancelToken cancelToken}) {
    return this.req(self, 'DELETE', path, cancelToken: cancelToken);
  }

  //
  Future<void> copyMove(
      Client self, String oldPath, String newPath, bool isCopy, bool overwrite,
      {CancelToken cancelToken}) async {
    var method = isCopy == true ? 'COPY' : 'MOVE';
    var resp = await this.req(self, method, oldPath, intercept: (req) {
      req.headers.set('Destination', Uri.encodeFull(join(self.uri, newPath)));
      req.headers.set('Overwrite', overwrite == true ? 'T' : 'F');
    }, cancelToken: cancelToken);

    var status = resp.statusCode;
    // TODO 207
    if (status == 201 || status == 204 || status == 207) {
      return;
    } else if (status == 409) {
      await this._createParent(self, newPath, cancelToken: cancelToken);
      return this.copyMove(self, oldPath, newPath, isCopy, overwrite,
          cancelToken: cancelToken);
    } else {
      throw WebdavError(error: '${resp.reasonPhrase}(${resp.statusCode})');
    }
  }

  //
  Future<void> _createParent(Client self, String path,
      {CancelToken cancelToken}) {
    var parentPath = path.substring(0, path.lastIndexOf('/') + 1);
    ;
    if (parentPath == '' || parentPath == '/') {
      return null;
    }
    // return self.mkdirAll(path, cancelToken);
  }

  //
  Future<List<int>> read(Client self, String path,
      {CancelToken cancelToken}) async {
    var resp = await this.req(self, 'GET', path, cancelToken: cancelToken);
    if (resp.statusCode != 200) {
      throw WebdavError(error: '${resp.reasonPhrase}(${resp.statusCode})');
    }
    var data = List<int>();
    var list = await resp.toList();
    list.forEach((d) => data.addAll(d));

    return data;
  }

  //
  Future<void> write(Client self, String path, Uint8List data,
      {CancelToken cancelToken}) async {
    var resp =
        await this.req(self, 'PUT', path, data: data, cancelToken: cancelToken);

    var status = resp.statusCode;
    if (status == 200 || status == 201 || status == 204) {
      return;
    } else if (status == 409) {
      await this._createParent(self, path, cancelToken: cancelToken);
      return this.write(self, path, data, cancelToken: cancelToken);
    }
    throw WebdavError(error: '${resp.reasonPhrase}(${resp.statusCode})');
  }
}
