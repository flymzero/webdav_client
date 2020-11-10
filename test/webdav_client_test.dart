import 'package:test/test.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

void main() {
  test('ping', () async {
    var client = webdav.newClient('http://localhost:6688',
        user: 'flyzero', password: '123456');

    try {
      await client.ping();
      await client.readDir('/我的坚果云/');
    } catch (e, s) {
      print(e);
      print(s);
    }
  });
}
