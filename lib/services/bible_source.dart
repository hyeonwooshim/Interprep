import 'package:flutter/material.dart';

import 'bible/korean_bible.dart';
import 'bible/nkjv_bible.dart';

class BibleSource {
  static Future<KoreanBible> loadKoreanBible(BuildContext context) async {
    return readAsLines(context, 'assets/KoreanVer.txt')
        .then((lines) => KoreanBible.fromLines(lines));
  }

  static Future<NkjvBible> loadNkjvBible(BuildContext context) async {
    return readAsLines(context, 'assets/NKJVer.txt')
        .then((lines) => NkjvBible.fromLines(lines));
  }

  static Future<List<String>> readAsLines(
      BuildContext context, String filePath) async {
    return DefaultAssetBundle.of(context)
        .loadString(filePath)
        .then((str) => str.split('\n'));
  }
}
