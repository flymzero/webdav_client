import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:webdav_client/src/auth.dart';
import 'package:webdav_client/src/error.dart';
import 'package:webdav_client/src/requests.dart';
import 'package:webdav_client/src/utils.dart';
import 'package:webdav_client/src/xml.dart';
import 'package:xml/xml.dart';

class Client {
  final String uri;
  Auth auth;
  Map<String, Object> headers;
  HttpClient c;

  Client({
    @required this.uri,
    this.auth,
    this.headers,
    this.c,
  });

  // methods--------------------------------

  //
  void setHeader(String key, String value) => this.headers[key] = value;

  //
  void setTimeout(Duration timeout) => this.c.connectionTimeout = timeout;

  //
  Future<void> ping([CancelToken cancelToken]) async {
    var resp = await c.options(this, '/');
    if (resp.statusCode != 200) {
      throw WebdavError(error: '${resp.reasonPhrase}(${resp.statusCode})');
    }
  }

  //
  Future<List<File>> readDir(String path, [CancelToken cancelToken]) async {
    // path = fixSlashes(path);
    //
    // var resp =
    //     await this.c.propfind(this, path, true, t, cancelToken: cancelToken);
    //
    // String str = await resp.transform(utf8.decoder).join();
    String str = '''<?xml version="1.0" encoding="utf-8" ?><D:multistatus xmlns:D="DAV:">
<D:response><D:href>/</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2019-06-04T23:44:56+00:00</D:creationdate><D:getlastmodified>Fri, 6 Nov 2020 16:45:18 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/svgcleaner</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2018-04-09T23:20:54+00:00</D:creationdate><D:getlastmodified>Mon, 9 Apr 2018 23:20:54 GMT</D:getlastmodified><D:getcontentlength>1852668</D:getcontentlength><D:getetag>5acbf556-1c44fc</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/API%E6%8E%A5%E5%85%A5.svg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T02:41:02+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 02:41:02 GMT</D:getlastmodified><D:getcontentlength>1058</D:getcontentlength><D:getetag>5f4b11be-422</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Adobe_Illustrator_2020_v24.2.3__TNT_app4mac.net.dmg.dmg_2.23G.torrent</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-17T09:26:06+00:00</D:creationdate><D:getlastmodified>Mon, 17 Aug 2020 09:26:06 GMT</D:getlastmodified><D:getcontentlength>11683</D:getcontentlength><D:getetag>5f3a4d2e-2da3</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/googlechrome.dmg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-09-13T14:09:54+00:00</D:creationdate><D:getlastmodified>Sun, 13 Sep 2020 14:10:18 GMT</D:getlastmodified><D:getcontentlength>95169881</D:getcontentlength><D:getetag>5f5e284a-5ac2d59</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/testflutter</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-07-02T13:48:53+00:00</D:creationdate><D:getlastmodified>Mon, 5 Oct 2020 14:18:15 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/%E7%BD%AE%E6%8D%A2.svg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T02:56:26+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 02:56:26 GMT</D:getlastmodified><D:getcontentlength>629</D:getcontentlength><D:getetag>5f4b155a-275</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/flutter_macos_1.17.5-stable.zip</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-07-02T13:13:43+00:00</D:creationdate><D:getlastmodified>Thu, 2 Jul 2020 13:13:47 GMT</D:getlastmodified><D:getcontentlength>17849</D:getcontentlength><D:getetag>5efddd8b-45b9</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/file_add_btn_folder.png</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-24T09:58:38+00:00</D:creationdate><D:getlastmodified>Mon, 24 Aug 2020 09:58:38 GMT</D:getlastmodified><D:getcontentlength>4857</D:getcontentlength><D:getetag>5f438f4e-12f9</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/package-FBA15N3D12BK.pdf</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-06-13T01:39:37+00:00</D:creationdate><D:getlastmodified>Sat, 13 Jun 2020 01:39:37 GMT</D:getlastmodified><D:getcontentlength>23592</D:getcontentlength><D:getetag>5ee42e59-5c28</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Material_Theme-5.3.4.zip.crdownload</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-09-22T13:35:37+00:00</D:creationdate><D:getlastmodified>Tue, 22 Sep 2020 14:18:31 GMT</D:getlastmodified><D:getcontentlength>938306</D:getcontentlength><D:getetag>5f6a07b7-e5142</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/%E4%B8%8A%E4%BC%A0%E4%B8%8B%E8%BD%BD.svg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T03:08:12+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 03:08:12 GMT</D:getlastmodified><D:getcontentlength>1055</D:getcontentlength><D:getetag>5f4b181c-41f</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/package-FBA15MTYXNX6%20(1).pdf</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-06-13T00:53:14+00:00</D:creationdate><D:getlastmodified>Sat, 13 Jun 2020 00:53:14 GMT</D:getlastmodified><D:getcontentlength>21401</D:getcontentlength><D:getetag>5ee4237a-5399</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/llllllllllllllll.jpg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-11-01T13:39:21+00:00</D:creationdate><D:getlastmodified>Sun, 1 Nov 2020 13:39:21 GMT</D:getlastmodified><D:getcontentlength>2461</D:getcontentlength><D:getetag>5f9eba89-99d</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/.DS_Store</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-05-19T14:39:53+00:00</D:creationdate><D:getlastmodified>Tue, 20 Oct 2020 15:59:15 GMT</D:getlastmodified><D:getcontentlength>10244</D:getcontentlength><D:getetag>5f8f0953-2804</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/file_type_icon</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-08-24T09:58:38+00:00</D:creationdate><D:getlastmodified>Wed, 16 Sep 2020 16:41:10 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/gradle-5.6.2-all.zip</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-07-03T15:40:09+00:00</D:creationdate><D:getlastmodified>Fri, 3 Jul 2020 15:42:10 GMT</D:getlastmodified><D:getcontentlength>139632144</D:getcontentlength><D:getetag>5eff51d2-8529e10</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/svgcleaner_macos_0.9.5.zip</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-09T10:03:40+00:00</D:creationdate><D:getlastmodified>Sun, 9 Aug 2020 10:03:41 GMT</D:getlastmodified><D:getcontentlength>701408</D:getcontentlength><D:getetag>5f2fc9fd-ab3e0</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/.localized</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2019-06-04T23:44:56+00:00</D:creationdate><D:getlastmodified>Tue, 19 May 2020 13:08:39 GMT</D:getlastmodified><D:getcontentlength>0</D:getcontentlength><D:getetag>5ec3da57-0</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Material_Theme-5.3.4.zip%20(2).crdownload</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-09-22T14:39:42+00:00</D:creationdate><D:getlastmodified>Tue, 22 Sep 2020 15:01:19 GMT</D:getlastmodified><D:getcontentlength>1346034</D:getcontentlength><D:getetag>5f6a11bf-1489f2</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Material_Theme-5.3.4.zip%20(1).crdownload</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-09-22T16:26:50+00:00</D:creationdate><D:getlastmodified>Tue, 22 Sep 2020 16:35:39 GMT</D:getlastmodified><D:getcontentlength>3066764</D:getcontentlength><D:getetag>5f6a27db-2ecb8c</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/475d78a0c86695e2d5f7b51ce0e38cfc.png</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-10-05T07:47:23+00:00</D:creationdate><D:getlastmodified>Mon, 5 Oct 2020 07:47:47 GMT</D:getlastmodified><D:getcontentlength>102404</D:getcontentlength><D:getetag>5f7acfa3-19004</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/%E7%99%BE%E5%BA%A6%E7%BD%91%E7%9B%98_11.1.9</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-08-30T06:55:48+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 06:56:45 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Material%20Theme</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-07-06T06:53:54+00:00</D:creationdate><D:getlastmodified>Tue, 22 Sep 2020 16:43:11 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/QC-Noviland-10-7948611911.pdf</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-06-13T00:38:51+00:00</D:creationdate><D:getlastmodified>Sat, 13 Jun 2020 00:42:14 GMT</D:getlastmodified><D:getcontentlength>4083499</D:getcontentlength><D:getetag>5ee420e6-3e4f2b</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/%E9%97%AA%E7%94%B5%E4%B8%8B%E8%BD%BDv1.2.3.0</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-07-16T13:09:24+00:00</D:creationdate><D:getlastmodified>Thu, 16 Jul 2020 13:09:33 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/%E5%8A%9F%E8%83%BD%E5%AE%9A%E4%B9%89.svg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T02:59:26+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 02:59:26 GMT</D:getlastmodified><D:getcontentlength>1202</D:getcontentlength><D:getetag>5f4b160e-4b2</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Surfboard_v1.2.4%20(Build%2069)_apkpure.com.apk</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-10-08T13:06:28+00:00</D:creationdate><D:getlastmodified>Thu, 8 Oct 2020 13:07:44 GMT</D:getlastmodified><D:getcontentlength>17445282</D:getcontentlength><D:getetag>5f7f0f20-10a31a2</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/15%20%E9%A1%B9%E7%9B%AE%E5%AE%9E%E6%88%9802.mp4</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-07-27T14:23:22+00:00</D:creationdate><D:getlastmodified>Fri, 24 Jul 2020 02:11:39 GMT</D:getlastmodified><D:getcontentlength>3080554637</D:getcontentlength><D:getetag>5f1a435b-b79d888d</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/%E4%B8%8B%E8%BD%BD.png</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-09-20T16:44:58+00:00</D:creationdate><D:getlastmodified>Sun, 20 Sep 2020 16:44:58 GMT</D:getlastmodified><D:getcontentlength>3410</D:getcontentlength><D:getetag>5f67870a-d52</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/icon_%E5%85%A5%E5%8F%A3.svg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T02:56:58+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 02:56:58 GMT</D:getlastmodified><D:getcontentlength>787</D:getcontentlength><D:getetag>5f4b157a-313</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/%E7%99%BE%E5%BA%A6%E7%BD%91%E7%9B%98_11.1.9.zip</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T06:54:42+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 06:55:00 GMT</D:getlastmodified><D:getcontentlength>127518134</D:getcontentlength><D:getetag>5f4b4d44-799c5b6</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/GoogleService-Info.plist</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-08T02:56:41+00:00</D:creationdate><D:getlastmodified>Sat, 8 Aug 2020 02:56:41 GMT</D:getlastmodified><D:getcontentlength>1174</D:getcontentlength><D:getetag>5f2e1469-496</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/thunder_3.4.1.4368.dmg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-09-03T15:21:35+00:00</D:creationdate><D:getlastmodified>Thu, 3 Sep 2020 15:21:39 GMT</D:getlastmodified><D:getcontentlength>22738049</D:getcontentlength><D:getetag>5f510a03-15af481</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/file_type_icon.zip</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T16:24:46+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 16:24:46 GMT</D:getlastmodified><D:getcontentlength>192006</D:getcontentlength><D:getetag>5f4bd2ce-2ee06</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/package-FBA15MTYXNX6.pdf</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-06-13T00:41:15+00:00</D:creationdate><D:getlastmodified>Sat, 13 Jun 2020 00:41:15 GMT</D:getlastmodified><D:getcontentlength>21401</D:getcontentlength><D:getetag>5ee420ab-5399</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/JetBrainsMono-1.0.3</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-08-01T09:02:55+00:00</D:creationdate><D:getlastmodified>Sat, 1 Aug 2020 09:03:02 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Docker.dmg.crdownload</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-11-06T16:45:14+00:00</D:creationdate><D:getlastmodified>Fri, 6 Nov 2020 17:34:04 GMT</D:getlastmodified><D:getcontentlength>47226464</D:getcontentlength><D:getetag>5fa5890c-2d09e60</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/RDM-2.2%20(1).dmg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-24T13:37:37+00:00</D:creationdate><D:getlastmodified>Mon, 24 Aug 2020 13:49:01 GMT</D:getlastmodified><D:getcontentlength>921600</D:getcontentlength><D:getetag>5f43c54d-e1000</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/JetBrainsMono-1.0.3.zip</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-01T09:02:14+00:00</D:creationdate><D:getlastmodified>Sat, 1 Aug 2020 09:02:15 GMT</D:getlastmodified><D:getcontentlength>1918755</D:getcontentlength><D:getetag>5f252f97-1d4723</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/font_2004119_y40wkin087g</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-08-30T03:11:41+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 03:11:41 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/font_2004119_o8z7xvx73sc</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-08-30T03:16:28+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 03:16:28 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Material_Theme-5.3.4.zip</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-07-06T12:08:24+00:00</D:creationdate><D:getlastmodified>Mon, 6 Jul 2020 12:08:24 GMT</D:getlastmodified><D:getcontentlength>12266604</D:getcontentlength><D:getetag>5f031438-bb2c6c</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/testcontext</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-09-04T15:15:16+00:00</D:creationdate><D:getlastmodified>Fri, 4 Sep 2020 16:08:02 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Adobe_Illustrator_2020_v24.2.3__TNT_app4mac.net.dmg.dmg_2.23G.zip</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-09-03T15:16:54+00:00</D:creationdate><D:getlastmodified>Thu, 3 Sep 2020 15:16:56 GMT</D:getlastmodified><D:getcontentlength>11544</D:getcontentlength><D:getetag>5f5108e8-2d18</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/TencentMeeting_0300000000_1.9.0.433.publish.dmg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-26T13:48:51+00:00</D:creationdate><D:getlastmodified>Wed, 26 Aug 2020 13:49:03 GMT</D:getlastmodified><D:getcontentlength>76105085</D:getcontentlength><D:getetag>5f46684f-489457d</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Adobe_Illustrator_2020_v24.2.3__TNT_Torrentmac.net.dmg</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-09-03T15:22:46+00:00</D:creationdate><D:getlastmodified>Fri, 4 Sep 2020 15:03:25 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/API%E8%BE%93%E5%87%BA.svg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T02:41:14+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 02:41:14 GMT</D:getlastmodified><D:getcontentlength>1084</D:getcontentlength><D:getetag>5f4b11ca-43c</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/cartonlabel.pdf</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-06-13T00:46:29+00:00</D:creationdate><D:getlastmodified>Sat, 13 Jun 2020 00:46:29 GMT</D:getlastmodified><D:getcontentlength>33705</D:getcontentlength><D:getetag>5ee421e5-83a9</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/Magnet_2.4.6_MAS__TNT_xclient.info.dmg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-09-05T12:36:35+00:00</D:creationdate><D:getlastmodified>Sat, 5 Sep 2020 12:36:36 GMT</D:getlastmodified><D:getcontentlength>3589632</D:getcontentlength><D:getetag>5f538654-36c600</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/RDM-2.2.dmg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-24T13:36:52+00:00</D:creationdate><D:getlastmodified>Mon, 24 Aug 2020 13:49:00 GMT</D:getlastmodified><D:getcontentlength>921600</D:getcontentlength><D:getetag>5f43c54c-e1000</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/%E9%97%AA%E7%94%B5%E4%B8%8B%E8%BD%BDv1.2.3.0.apk</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-07-16T13:08:53+00:00</D:creationdate><D:getlastmodified>Thu, 16 Jul 2020 13:08:56 GMT</D:getlastmodified><D:getcontentlength>24037662</D:getcontentlength><D:getetag>5f105168-16ec91e</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/%E4%BC%A0%E8%BE%93.svg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T02:50:05+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 02:50:05 GMT</D:getlastmodified><D:getcontentlength>1573</D:getcontentlength><D:getetag>5f4b13dd-625</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/download.zip</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T03:11:41+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 03:11:41 GMT</D:getlastmodified><D:getcontentlength>21824</D:getcontentlength><D:getetag>5f4b18ed-5540</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/android-studio-ide-193.6514223-mac.dmg</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-07-02T16:07:59+00:00</D:creationdate><D:getlastmodified>Thu, 2 Jul 2020 16:21:53 GMT</D:getlastmodified><D:getcontentlength>897708611</D:getcontentlength><D:getetag>5efe09a1-3581f243</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/16%E9%A1%B9%E7%9B%AE%E5%AE%9E%E6%88%9803.mp4</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-07-27T14:24:48+00:00</D:creationdate><D:getlastmodified>Mon, 27 Jul 2020 07:13:32 GMT</D:getlastmodified><D:getcontentlength>2238438444</D:getcontentlength><D:getetag>5f1e7e9c-856bdc2c</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/flutterlib</D:href><D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype><D:creationdate>2020-07-02T14:36:33+00:00</D:creationdate><D:getlastmodified>Thu, 2 Jul 2020 14:36:33 GMT</D:getlastmodified></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
<D:response><D:href>/download%20(1).zip</D:href><D:propstat><D:prop><D:resourcetype/><D:creationdate>2020-08-30T03:16:28+00:00</D:creationdate><D:getlastmodified>Sun, 30 Aug 2020 03:16:28 GMT</D:getlastmodified><D:getcontentlength>21721</D:getcontentlength><D:getetag>5f4b1a0c-54d9</D:getetag></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>
</D:multistatus>''';
    WebdavXml.fileTree(str);
    // var xmlDocument = XmlDocument.parse(str);
    // // xmlDocument.print(str);
    // List<XmlElement> x =
    //     xmlDocument.findAllElements('response', namespace: '*').toList();

    return null;
  }
}

// create new client
Client newClient(String uri, {String user = '', String password = ''}) {
  return Client(
    uri: fixSlash(uri),
    auth: Auth(user: user, pwd: password),
    headers: {},
    c: HttpClient(),
  );
}

class CancelToken {}
