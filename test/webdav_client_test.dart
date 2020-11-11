import 'package:test/test.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

void main() {
  test('ping', () async {
    // var client = webdav.newClient('http://localhost:6688',
    //     user: 'flyzero', password: '123456');

    var client = webdav.newClient('https://dav.jianguoyun.com/dav/',
        user: 'flymzero@gmail.com', password: 'a7ij5ru5qp3hpydf');

    try {
      // for (var i = 99; i < 200; i++) {
      //   await client.mkdir('$i');
      // }

      // await client.ping();
      await client.readDir('/');
    } catch (e, s) {
      print(e);
      print(s);
    }
  });
}
