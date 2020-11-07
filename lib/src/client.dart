import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:webdav_client/src/auth.dart';
import 'package:webdav_client/src/utils.dart';
import 'package:meta/meta.dart';

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
  void readDir(String path){

  }

  //
  void req({
    @required String method,
    @required String path,
    Uint8List data,
    Function() intercept ,
  }) async {
    HttpClientRequest request = await this.c.openUrl(method, Uri.parse('${this.uri}'));
    request
      ..followRedirects = false
      ..persistentConnection = true;

    request.headers.set('Depth', '1');
    request.headers.set('Content-Type', 'application/xml;charset=UTF-8');
    request.headers.set('Accept', 'application/xml,text/xml');
    request.headers.set('Accept-Charset', 'utf-8');
    request.headers.set('Accept-Encoding', '');
    this.headers.forEach((key, value) {
      request.headers.set(key, value);
    });

    HttpClientResponse response = await request.close();
    if (response.statusCode == 401){
      String wwwAuthenticateHeader = response.headers.value('Www-Authenticate').toLowerCase();
      if (wwwAuthenticateHeader.contains('digest')){
        this.auth = DigestAuth(user: this.auth.user, pwd: this.auth.pwd, dParts: DigestParts(response.headers.value('Www-Authenticate')));
        var s = this.auth.authorize(method, path);
        this.headers['Authorization'] = s;
        return this.req(method: method, path: path);
      }
    }else {
      var s = await response.transform(utf8.decoder).join();
      print(s);
      // response.headers.forEach((name, values) {
      //   print(name);
      //   print(values);
      // });
    }
  }
}

// create new client
Client newClient({@required String uri, String user = '', String password = ''}) {
  return Client(
      uri: fixSlash(uri),
      auth: Auth(user: user, pwd: password),
      headers: {},
      c: HttpClient());
}
