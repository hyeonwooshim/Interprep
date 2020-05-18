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
  return KoreanBible.fromLines(koreanBibleLines());
}

NkjvBible newNkjvBible() {
  return NkjvBible.fromLines(nkjvBibleLines());
}

List<String> koreanBibleLines() {
  return assetFile('KoreanVer.txt').readAsLinesSync();
}

List<String> nkjvBibleLines() {
  return assetFile('NKJVer.txt').readAsLinesSync();
}
