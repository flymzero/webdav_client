import 'dart:convert';
import 'dart:io';
import 'package:webdav_client/src/utils.dart';
import 'package:meta/meta.dart';

// Auth
class Auth {
  final String user;

  final String pwd;

  Auth({
    this.user,
    this.pwd,
  });

  String get type => 'NoAuth';

  void authorize(HttpClientRequest req, String method, String path) {}
}

// BasicAuth
class BasicAuth extends Auth {
  BasicAuth({
    @required String user,
    @required String pwd,
  }) : super(
          user: user,
          pwd: pwd,
        );

  @override
  String get type => 'BasicAuth';

  @override
  void authorize(HttpClientRequest req, String method, String path) {
    List<int> bytes = utf8.encode('${this.user}:${this.pwd}');
    String auth = 'Basic ${base64Encode(bytes)}';
    req.headers.add('Authorization', auth);
  }
}

// DigestParts
class DigestParts {
  String uri = '';
  String method = '';
  String username = '';
  String password = '';

  String nonce = '';
  String realm = '';
  String qop = '';
  String opaque = '';
  String algorithm = '';
  String entityBody = '';
}

// DigestAuth
class DigestAuth extends Auth {
  DigestParts digestParts;

  DigestAuth({
    @required String user,
    @required String pwd,
    this.digestParts,
  }) : super(
          user: user,
          pwd: pwd,
        );

  @override
  String get type => 'DigestAuth';

  @override
  void authorize(HttpClientRequest req, String method, String path) {
    this.digestParts.uri = path;
    this.digestParts.method = method;
    this.digestParts.username = this.user;
    this.digestParts.password = this.pwd;
    this._getDigestAuthorization();
  }

  String _getDigestAuthorization() {
    int nonceCount = 1;
    String cnonce = computeNonce();
    String ha1 = _computeHA1(nonceCount, cnonce);
    String ha2 = _computeHA2();
    String response = _computeResponse(ha1, ha2, nonceCount, cnonce);
  }

  //
  String _computeHA1(int nonceCount, String cnonce) {
    String algorithm = this.digestParts.algorithm ?? 'MD5';

    if (algorithm == 'MD5' || algorithm.isEmpty) {
      return md5Hash('${this.user}:${this.digestParts.realm}:${this.pwd}');
    } else if (algorithm == 'MD5-sess') {
      String md5Str =
          md5Hash('${this.user}:${this.digestParts.realm}:${this.pwd}');
      return md5Hash('$md5Str:$nonceCount:$cnonce');
    }

    return '';
  }

  //
  String _computeHA2() {
    String qop = this.digestParts.qop;

    if (qop == 'auth' || qop.isEmpty) {
      return md5Hash('${this.digestParts.method}:${this.digestParts.uri}');
    } else if (qop == 'auth-int' &&
        this.digestParts.entityBody.isEmpty == false) {
      return md5Hash(
          '${this.digestParts.method}:${this.digestParts.uri}:${md5Hash(this.digestParts.entityBody)}');
    }

    return '';
  }

  //
  String _computeResponse(
      String ha1, String ha2, int nonceCount, String cnonce) {
    String qop = this.digestParts.qop;

    if (qop == null) {
      return md5Hash('$ha1:${this.digestParts.nonce}:$ha2');
    } else if (qop == 'auth' || qop == 'auth-int') {
      return md5Hash(
          '$ha1:${this.digestParts.nonce}:$nonceCount:$cnonce:$qop:$ha2');
    }

    return '';
  }
}
