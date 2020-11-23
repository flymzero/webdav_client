import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'dart:io' as io;
import 'auth.dart';
import 'file.dart';
import 'utils.dart';
import 'webdav_dio.dart';
import 'xml.dart';

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

  // Set the public request headers
  void setHeaders(Map<String, dynamic> headers) =>
      this.c.options.headers = headers;

  // Set the connection server timeout time in milliseconds.
  void setConnectTimeout(int timout) => this.c.options.connectTimeout = timout;

  // Set send data timeout time in milliseconds.
  void setSendTimeout(int timout) => this.c.options.sendTimeout = timout;

  // Set transfer data time in milliseconds.
  void setReceiveTimeout(int timout) => this.c.options.receiveTimeout = timout;

  // Test whether the service can connect
  Future<void> ping([CancelToken cancelToken]) async {
    var resp = await c.wdOptions(this, '/', cancelToken: cancelToken);
    if (resp.statusCode != 200) {
      throw newResponseError(resp);
    }
  }

  // Future<void> getQuota([CancelToken cancelToken]) async {
  //   var resp = await c.wdQuota(this, quotaXmlStr, cancelToken: cancelToken);
  //   print(resp);
  // }

  // Read all files in a folder
  Future<List<File>> readDir(String path, [CancelToken cancelToken]) async {
    path = fixSlashes(path);
    var resp = await this
        .c
        .wdPropfind(this, path, true, fileXmlStr, cancelToken: cancelToken);

    String str = resp.data;
    return WebdavXml.toFiles(path, str);
  }

  // Create a folder
  Future<void> mkdir(String path, [CancelToken cancelToken]) async {
    path = fixSlashes(path);
    var resp = await this.c.wdMkcol(this, path, cancelToken: cancelToken);
    var status = resp.statusCode;
    if (status != 201 && status != 405) {
      throw newResponseError(resp);
    }
  }

  // Recursively create folders
  Future<void> mkdirAll(String path, [CancelToken cancelToken]) async {
    path = fixSlashes(path);
    var resp = await this.c.wdMkcol(this, path, cancelToken: cancelToken);
    var status = resp.statusCode;
    if (status == 201 || status == 405) {
      return;
    } else if (status == 409) {
      var paths = path.split('/');
      var sub = '/';
      for (var e in paths) {
        if (e == '') {
          continue;
        }
        sub += e + '/';
        resp = await this.c.wdMkcol(this, sub, cancelToken: cancelToken);
        status = resp.statusCode;
        if (status != 201 && status != 405) {
          throw newResponseError(resp);
        }
      }
      return;
    }
    throw newResponseError(resp);
  }

  // Remove a folder or file
  // If you remove the folder, some webdav services require a '/' at the end of the path.
  Future<void> remove(String path, [CancelToken cancelToken]) {
    return removeAll(path, cancelToken);
  }

  // Remove files
  Future<void> removeAll(String path, [CancelToken cancelToken]) async {
    var resp = await this.c.wdDelete(this, path, cancelToken: cancelToken);
    if (resp.statusCode == 200 ||
        resp.statusCode == 204 ||
        resp.statusCode == 404) {
      return;
    }
    throw newResponseError(resp);
  }

  // Rename a folder or file
  // If you rename the folder, some webdav services require a '/' at the end of the path.
  Future<void> rename(String oldPath, String newPath, bool overwrite,
      [CancelToken cancelToken]) {
    return this.c.wdCopyMove(this, oldPath, newPath, false, overwrite);
  }

  // Copy a file / folder from A to B
  // If copied the folder (A > B), it will copy all the contents of folder A to folder B.
  // Some webdav services have been tested and found to delete the original contents of the B folder!!!
  Future<void> copy(String oldPath, String newPath, bool overwrite,
      [CancelToken cancelToken]) {
    return this.c.wdCopyMove(this, oldPath, newPath, true, overwrite);
  }

  // Read the bytes of a file
  Future<List<int>> read(String path, [CancelToken cancelToken]) {
    return this.c.wdRead(this, path, cancelToken: cancelToken);
  }

  // Read the bytes of a file and write to a local file
  Future<void> read2File(String path, String localFilePath,
      [CancelToken cancelToken]) async {
    var bytes = await this.c.wdRead(this, path, cancelToken: cancelToken);
    await io.File(localFilePath).writeAsBytes(bytes);
  }

  // Write the bytes to remote path
  Future<void> write(String path, Uint8List data, [CancelToken cancelToken]) {
    return this.c.wdWrite(this, path, data, cancelToken: cancelToken);
  }

  // Read local file bytes and write to remote file
  Future<void> writeFromFile(String localFilePath, String path,
      [CancelToken cancelToken]) async {
    var data = await io.File(localFilePath).readAsBytes();
    return this.c.wdWrite(this, path, data, cancelToken: cancelToken);
  }
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
