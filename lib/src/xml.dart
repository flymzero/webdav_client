import 'package:xml/xml.dart';
import 'package:intl/intl.dart';

import 'file.dart';

class WebdavXml{
  static List<XmlElement> findAllElements(XmlDocument document, String tag) => document.findAllElements(tag, namespace: '*').toList();

  static List<XmlElement> findElements(XmlElement element, String tag) => element.findElements(tag, namespace: '*').toList();

  static fileTree(String xmlStr){

    var tree = List<File>();

    var xmlDocument = XmlDocument.parse(xmlStr);
    List<XmlElement> list = findAllElements(xmlDocument, 'response');
    list.forEach((element) {
      // name
      String name = findElements(element, 'href').single.text;
      findElements(findElements(element, 'propstat').first, 'prop').forEach((element) {
        // mimeType
        final mimeTypeElements = findElements(element, 'getcontenttype');
        String mimeType = mimeTypeElements.isNotEmpty ? mimeTypeElements.single.text : '';

        // size
        final sizeElements = findElements(element, 'getcontentlength');
        int size = sizeElements.isNotEmpty ? int.parse(sizeElements.single.text) : 0;

        // eTag
        final eTagElements = findElements(element, 'getetag');
        String eTag = eTagElements.isNotEmpty ? eTagElements.single.text : '';

        // create time
        final cTimeElements = findElements(element, 'creationdate');
        DateTime cTime = cTimeElements.isNotEmpty ? DateTime.parse(cTimeElements.single.text) : null;

        // modified time
        final mTimeElements = findElements(element, 'getlastmodified');
        DateTime mTime = mTimeElements.isNotEmpty ? DateFormat('E, d MMM yyyy HH:mm:ss Z')
            .parse(mTimeElements.single.text) : null;

        tree.add(File(
          path: '',
          isDir: false,
          name: name,
          mimeType: mimeType,
          size: size,
          eTag: eTag,
          cTime: cTime,
          mTime: mTime,
        ));
        print(cTime.millisecondsSinceEpoch);
        print(mTime.millisecondsSinceEpoch);
        print(tree);
      });
    });
  }
}