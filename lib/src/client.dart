import 'dart:io';
import 'dart:typed_data';

import 'package:webdav_client/src/auth.dart';
import 'package:webdav_client/src/utils.dart';
import 'package:meta/meta.dart';

class Client {
  final String uri;
  Auth auth;
  Map<String, Object> headers;
  HttpClient c;
  String a = 'hhh';

  Client({
    @required this.uri,
    this.auth,
    this.headers,
    this.c,
  });

  // methods--------------------------------

  //
  Future<HttpClientResponse> req(
      String method, String path, Uint8List data) async {
    this.a = '666';
    HttpClientRequest request =
        await this.c.openUrl('PROPFIND', Uri.parse(this.uri));
    this.auth.authorize(request, method, path);
    HttpClientResponse response = await request.close();
    if (response.statusCode == 401 && this.auth.type == 'NoAuth') {
      // String wwwAuthenticateHeader = response.headers.value('Www-Authenticate').toLowerCase();
      var a = DigestAuth(
          user: this.auth.user, pwd: this.auth.pwd, digestParts: DigestParts());
      a.authorize(request, method, path);
    }
  }

  // Future<HttpClientResponse> ReadDir(String user, String password) async {
  //   HttpClient httpClient = new HttpClient();
  //   httpClient.addCredentials(
  //       Uri.parse(this.uri), "", HttpClientBasicCredentials(user, password));
  //   Map userHeader = {"Depth": 1};

  //   HttpClientRequest request =
  //       await httpClient.openUrl('PROPFIND', Uri.parse(this.uri));
  //   request
  //     ..followRedirects = false
  //     ..persistentConnection = true;

  //   userHeader.forEach((k, v) => request.headers.add(k, v));

  //   HttpClientResponse response = await request.close();
  //   return response;
  // }
}

// create new client
Client newClient({@required String uri, String user, String password}) {
  return Client(
      uri: fixSlash(uri),
      auth: Auth(user: user, pwd: password),
      headers: {},
      c: HttpClient());
}
