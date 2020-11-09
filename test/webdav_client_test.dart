import 'package:test/test.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

void main() {
  test('ping', () async {
    var client = webdav.newClient('http://192.168.0.103:8080/',//'http://localhost:6688',
        user: 'flyzero', password: '123456');
    try {
      await client.ping();
      await client.readDir('/');
    } catch (e, s) {
      print(e);
      print(s);
    }
  });
}
