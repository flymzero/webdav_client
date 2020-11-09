import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:webdav_client/src/auth.dart';
import 'package:webdav_client/src/client.dart';
import 'package:webdav_client/src/utils.dart';

import 'error.dart';

const t = '''<d:propfind xmlns:d='DAV:'>
			<d:prop>
				<d:displayname/>
				<d:resourcetype/>
				<d:getcontentlength/>
				<d:getcontenttype/>
				<d:getetag/>
				<d:getlastmodified/>
			</d:prop>
		</d:propfind>''';

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

    self.headers.forEach((key, value) {
      request.headers.set(key, value);
    });

    String str = self.auth.authorize(method, path);
    request.headers.set('Authorization', str);

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
        // TODO
      }
      return this.req(self, method, path,
          data: data, intercept: intercept, cancelToken: cancelToken);
    } else if (response.statusCode == 401) {
      // TODO
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
}
