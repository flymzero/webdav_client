import 'package:test/test.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

void main() {
  test('adds one to input values', () {
    var client = webdav.newClient(uri: 'http://192.168.0.103:8080/', user: 'flyzero', password: '123456');
    client.req(method: 'PROPFIND', path: '/');
  });
}
