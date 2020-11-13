import 'package:test/test.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

void main() {
  var client = webdav.newClient('https://dav.jianguoyun.com/dav/',
      user: 'flymzero@gmail.com', password: 'a7ij5ru5qp3hpydf');

  // var client = webdav.newClient('http://localhost:6688',
  //     user: 'flyzero', password: '123456');

  // test ping
  test('ping', () async {
    await client.ping();
  });

  // make folder
  test('make folder', () async {
    await client.mkdir('/新建文件夹');
  });

  // make all folder
  test('make all folder', () async {
    await client.mkdirAll('/newFolder2/newFolder3/newFolder4');
  });

  // test readDir
  group('readDir', () {
    test('read root path', () async {
      var list = await client.readDir('/');
      list.forEach((f) {
        print(f.name);
        print(f.mTime.toString());
      });
    });

    test('read sub path', () async {
      // need change real folder name
      var list = await client.readDir('/newFolder2');
      expect(list.length, equals(1));
      expect(list[0].name, equals('newFolder3'));
    });
  });

  // remove
  group('remove', () {
    test('remove a folder', () async {
      await client.remove('/newFolder2/newFolder3');
    });

    test('remove a file', () async {
      await client.remove('/新建文件夹/file.txt');
    });
  });
}
