import 'package:flutter/services.dart';

import 'test_helper.dart';

class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    String name;
    if (key == 'assets/KoreanVer.txt') {
      name = 'KoreanVer.txt';
    } else if (key == 'assets/NKJVer.txt') {
      name = 'NKJVer.txt';
    }
    print(name);
    if (name != null)
      return ByteData.view(assetFile(name).readAsBytesSync().buffer);
    return null;
  }
}
