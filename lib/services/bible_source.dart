import 'package:flutter/material.dart';

class BibleSource {
  static Future<List<String>> loadNkjvText(BuildContext context) async {
    return await readAsLines(context, 'assets/KoreanVer.txt');
  }
  
  static Future<List<String>> loadKoreanText(BuildContext context) async {
    return await readAsLines(context, 'assets/NkjVer.txt');
  }

  static Future<List<String>> readAsLines(BuildContext context, String filePath) async{
    final str = await DefaultAssetBundle.of(context).loadString(filePath);
    return str.split('\n');
  }
}
