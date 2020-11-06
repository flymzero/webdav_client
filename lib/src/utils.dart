import 'dart:convert';
import 'dart:math' as math;
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

// md5
String md5Hash(String data) {
  var content = Utf8Encoder().convert(data);
  var md5 = crypto.md5;
  var digest = md5.convert(content).toString();
  return digest;
}

// 16进制字符串随机数
String computeNonce() {
  final rnd = math.Random.secure();
  final values = List<int>.generate(16, (i) => rnd.nextInt(256));
  return hex.encode(values).substring(0, 16);
}

// 添加 '/' 后缀
String fixSlash(String s) {
  if (!s.endsWith('/')) {
    return s + '/';
  }
  return s;
}
