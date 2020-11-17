import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'auth.dart';
import 'error.dart';
import 'utils.dart';
import 'webdav_dio.dart';

class Client {
  final String uri;
  WdDio c;
  Auth auth;
  bool debug;

  Client({
    @required this.uri,
    @required this.c,
    @required this.auth,
    this.debug,
  });

  // methods--------------------------------

  //
  void setHeaders(Map<String, dynamic> headers) =>
      this.c.options.headers = headers;

  // 连接服务器超时时间，单位是毫秒
  void setConnectTimeout(int timout) => this.c.options.connectTimeout = timout;

  // 发送数据超时时间，单位是毫秒
  void setSendTimeout(int timout) => this.c.options.sendTimeout = timout;

  // 接送数据时时间，单位是毫秒
  void setReceiveTimeout(int timout) => this.c.options.receiveTimeout = timout;

  //
  Future<void> ping([CancelToken cancelToken]) async {
    var resp = await c.wdOptions(this, '/');
    if (resp.statusCode != 200) {
      throw WebdavError(error: '${resp.statusMessage}(${resp.statusCode})');
    }
  }

  // //
  // Future<List<File>> readDir(String path, [CancelToken cancelToken]) async {
  //   path = fixSlashes(path);
  //   var resp = await this
  //       .c
  //       .propfind(this, path, true, fileXmlStr, cancelToken: cancelToken);
  //   String str = await resp.transform(utf8.decoder).join();
  //   return WebdavXml.toFiles(path, str);
  // }
  //
  // //
  // Future<void> mkdir(String path, [CancelToken cancelToken]) async {
  //   path = fixSlashes(path);
  //   var resp = await this.c.mkcol(this, path, cancelToken: cancelToken);
  //   var status = resp.statusCode;
  //   if (status != 201 && status != 405) {
  //     throw WebdavError(error: '${resp.reasonPhrase}(${resp.statusCode})');
  //   }
  // }
  //
  // //
  // Future<void> mkdirAll(String path, [CancelToken cancelToken]) async {
  //   path = fixSlashes(path);
  //   var resp = await this.c.mkcol(this, path, cancelToken: cancelToken);
  //   var status = resp.statusCode;
  //   if (status == 201 || status == 405) {
  //     return;
  //   } else if (status == 409) {
  //     var paths = path.split('/');
  //     var sub = '/';
  //     for (var e in paths) {
  //       if (e == '') {
  //         continue;
  //       }
  //       sub += e + '/';
  //       resp = await this.c.mkcol(this, sub, cancelToken: cancelToken);
  //       status = resp.statusCode;
  //       if (status != 201 && status != 405) {
  //         throw WebdavError(error: '${resp.reasonPhrase}(${resp.statusCode})');
  //       }
  //     }
  //     return;
  //   }
  //   throw WebdavError(error: '${resp.reasonPhrase}(${resp.statusCode})');
  // }
  //
  // //
  // Future<void> remove(String path, [CancelToken cancelToken]) {
  //   return removeAll(path, cancelToken);
  // }
  //
  // //
  // Future<void> removeAll(String path, [CancelToken cancelToken]) async {
  //   var resp = await this.c.delete2(this, path, cancelToken: cancelToken);
  //   if (resp.statusCode == 200 ||
  //       resp.statusCode == 204 ||
  //       resp.statusCode == 404) {
  //     return;
  //   }
  //   throw WebdavError(error: '${resp.reasonPhrase}(${resp.statusCode})');
  // }
  //
  // //
  // Future<void> rename(String oldPath, String newPath, bool overwrite,
  //     [CancelToken cancelToken]) {
  //   return this.c.copyMove(this, oldPath, newPath, false, overwrite);
  // }
  //
  // //
  // Future<void> copy(String oldPath, String newPath, bool overwrite,
  //     [CancelToken cancelToken]) {
  //   return this.c.copyMove(this, oldPath, newPath, true, overwrite);
  // }
  //
  // //
  // Future<List<int>> read(String path, [CancelToken cancelToken]) {
  //   return this.c.read(this, path, cancelToken: cancelToken);
  // }
  //
  // //
  // Future<void> read2File(String path, String localFilePath,
  //     [CancelToken cancelToken]) async {
  //   var bytes = await this.c.read(this, path, cancelToken: cancelToken);
  //   await io.File(localFilePath).writeAsBytes(bytes);
  // }
  //
  // //
  // Future<void> write(String path, Uint8List data, [CancelToken cancelToken]) {
  //   return this.c.write(this, path, data, cancelToken: cancelToken);
  // }
  //
  // //
  // Future<void> writeFromFile(String path, String localFilePath,
  //     [CancelToken cancelToken]) async {
  //   var data = await io.File(localFilePath).readAsBytes();
  //   return this.c.write(this, path, data, cancelToken: cancelToken);
  // }
}

// create new client
Client newClient(String uri,
    {String user = '', String password = '', bool debug = false}) {
  return Client(
    uri: fixSlash(uri),
    c: WdDio(debug: debug),
    auth: Auth(user: user, pwd: password),
    debug: debug,
  );
}
