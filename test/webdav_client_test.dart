import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

void main() {
  var client = webdav.newClient(
    'http://127.0.0.1:80/',
    user: 'alice',
    password: 'secret1234',
    debug: true,
  );

  // test ping
  test('common settings', () async {
    client.setHeaders({'accept-charset': 'utf-8'});
    client.setConnectTimeout(8000);
    client.setSendTimeout(8000);
    client.setReceiveTimeout(8000);

    try {
      await client.ping();
    } catch (e) {
      print('$e');
    }
  });

  // make folder
  test('make folder', () async {
    await client.mkdir('/新建文件夹');
  });

  // make all folder
  test('make all folder', () async {
    await client.mkdirAll('/new folder/new folder2');
  });

  // test readDir
  group('readDir', () {
    test('read root path', () async {
      var list = await client.readDir('/');
      list.forEach((f) {
        print('${f.name} ${f.path}');
      });
    });

    test('read sub path', () async {
      // need change real folder name
      var list = await client.readDir('/new folder');
      list.forEach((f) {
        print(f.path);
        print(f.name);
        print(f.mTime.toString());
      });
    });
  });

  // remove
  group('remove', () {
    test('remove a folder', () async {
      await client.remove('/new folder/new folder2/');
    });

    test('remove a file', () async {
      await client.remove('/new folder/新建文本文档.txt');
    });
  });

  // rename
  group('rename', () {
    test('rename a folder', () async {
      await client.rename('/新建文件夹/', '/新建文件夹2/', true);
    });

    test('rename a file', () async {
      await client.rename('/新建文件夹/test.dart.txt', '/新建文件夹/test2.dart', true);
    });
  });

  group('copy', () {
    // 如果是文件夹，有些webdav服务，会把文件夹A内的所有复制到B文件夹内且删除B文件夹内的所有数据
    test('copy a folder', () async {
      await client.copy('/新建文件夹/新建文件夹2/', '/new folder/folder/', true);
    });

    test('copy a file', () async {
      await client.copy('/新建文件夹/test2.dart', '/new folder/copy.bmp', true);
    });
  });

  group('read', () {
    test('read remote file', () async {
      await client.read('/f/vpn2.exe');
    });

    test('read remote file 2 local file', () async {
      await client.read2File('/f/vpn2.exe', 'F:/Users/STAR-X/Desktop/vpn2.exe');
    });
  });

  test('write', () async {
    CancelToken cancel = CancelToken();

    client
        .writeFromFile('C:/ToolLog.txt', '/f/ToolLog.txt', cancel)
        .catchError((err) {
      prints(err.toString());
    });

    await Future.delayed(Duration(seconds: 5))
        .then((_) => cancel.cancel('reason'));
  }, timeout: Timeout(Duration(minutes: 2)));
}
