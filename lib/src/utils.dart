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

String trim(String str, [String chars]) {
  RegExp pattern =
      (chars != null) ? RegExp('^[$chars]+|[$chars]+\$') : RegExp(r'^\s+|\s+$');
  return str.replaceAll(pattern, '');
}

String ltrim(String str, [String chars]) {
  var pattern = chars != null ? new RegExp('^[$chars]+') : new RegExp(r'^\s+');
  return str.replaceAll(pattern, '');
}

String rtrim(String str, [String chars]) {
  var pattern = chars != null ? new RegExp('[$chars]+\$') : new RegExp(r'\s+$');
  return str.replaceAll(pattern, '');
}

// 添加 '/' 后缀
String fixSlash(String s) {
  if (!s.endsWith('/')) {
    return s + '/';
  }
  return s;
}

// 添加 '/' 前后缀
String fixSlashes(String s) {
  if (!s.startsWith('/')) {
    s = '/${s}';
  }
  return fixSlash(s);
}

// 使用 '/' 连接path
String join(String path0, String path1) {
  return rtrim(path0, '/') + '/' + ltrim(path1, '/');
}
