import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:webdav_client/src/auth.dart';
import 'package:webdav_client/src/error.dart';
import 'package:webdav_client/src/requests.dart';
import 'package:webdav_client/src/utils.dart';
import 'package:xml/xml.dart';

class Client {
  final String uri;
  Auth auth;
  Map<String, Object> headers;
  HttpClient c;

  Client({
    @required this.uri,
    this.auth,
    this.headers,
    this.c,
  });

  // methods--------------------------------

  //
  void setHeader(String key, String value) => this.headers[key] = value;

  //
  void setTimeout(Duration timeout) => this.c.connectionTimeout = timeout;

  //
  Future<void> ping([CancelToken cancelToken]) async {
    var resp = await c.options(this, '/');
    if (resp.statusCode != 200) {
      throw WebdavError(error: '${resp.reasonPhrase}(${resp.statusCode})');
    }
  }

  //
  Future<List<File>> readDir(String path, [CancelToken cancelToken]) async {
    path = fixSlashes(path);

    var resp =
        await this.c.propfind(this, path, true, t, cancelToken: cancelToken);

    String str = await resp.transform(utf8.decoder).join();
    var xmlDocument = XmlDocument.parse(str);
    // xmlDocument.print(str);
    List<XmlElement> x =
        xmlDocument.findAllElements('response', namespace: '*').toList();

    return null;
  }
}

// create new client
Client newClient(String uri, {String user = '', String password = ''}) {
  return Client(
    uri: fixSlash(uri),
    auth: Auth(user: user, pwd: password),
    headers: {},
    c: HttpClient(),
  );
}

class CancelToken {}
