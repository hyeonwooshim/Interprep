import 'dart:io';

import 'package:interprep/services/bible/korean_bible.dart';
import 'package:interprep/services/bible/nkjv_bible.dart';

File assetFile(String name) {
  var dir = Directory.current.path;
  if (dir.endsWith('/test')) {
    dir = dir.replaceAll('/test', '');
  }
  return File('$dir/assets/$name');
}

KoreanBible newKoreanBible() {
  final lines = assetFile('KoreanVer.txt').readAsLinesSync();
  return KoreanBible.fromLines(lines);
}

NkjvBible newNkjvBible() {
  final lines = assetFile('NKJVer.txt').readAsLinesSync();
  return NkjvBible.fromLines(lines);
}
