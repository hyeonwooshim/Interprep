import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:interprep/services/bible/korean_bible.dart';
import 'package:interprep/services/bible/nkjv_bible.dart';
import 'package:interprep/services/bible/passage.dart';
import 'package:interprep/services/bible/verse.dart';
import 'package:interprep/services/formatter/two_line_format.dart';

import '../../../../test_helper.dart';

void main() {
  group('formatPassagePair()', () {
    TwoLineFormat format;
    Passage passage1;
    Passage passage2;

    KoreanBible bible1;
    NkjvBible bible2;

    setUpAll(() {
      format = TwoLineFormat();

      bible1 = newKoreanBible();
      bible2 = newNkjvBible();

      final v1 = Verse('', 0, 1, 1, '');
      final v2 = Verse('', 0, 1, 2, '');
      passage1 = Passage(bible1, v1, v2);
      passage2 = Passage(bible2, v1, v2);
    });

    test('returns formatted verses with default inputs', () {
      final expected =
          '(창세기 1:1-2) 태초에 하나님이 천지를 창조하시니라 땅이 혼돈하고 공허하며 흑암이 깊음 위에 있고 하나님의 신은 수면에 운행하시니라\n' +
              '(Genesis 1:1-2) In the beginning God created the heavens and the earth. The earth was without form, and void; and darkness was on the face of the deep. And the Spirit of God was hovering over the face of the waters.';
      expect(format.formatPassagePair(passage1, passage2), expected);
    });

    test('returns formatted verses with location coming after', () {
      final expected =
          '태초에 하나님이 천지를 창조하시니라 땅이 혼돈하고 공허하며 흑암이 깊음 위에 있고 하나님의 신은 수면에 운행하시니라 (창세기 1:1-2)\n' +
              'In the beginning God created the heavens and the earth. The earth was without form, and void; and darkness was on the face of the deep. And the Spirit of God was hovering over the face of the waters. (Genesis 1:1-2)';
      expect(format.formatPassagePair(passage1, passage2, locationFirst: false),
          expected);
    });

    test('returns formatted verses with abbreviated book name', () {
      final expected =
          '(창 1:1-2) 태초에 하나님이 천지를 창조하시니라 땅이 혼돈하고 공허하며 흑암이 깊음 위에 있고 하나님의 신은 수면에 운행하시니라\n' +
              '(Genesis 1:1-2) In the beginning God created the heavens and the earth. The earth was without form, and void; and darkness was on the face of the deep. And the Spirit of God was hovering over the face of the waters.';
      expect(
          format.formatPassagePair(passage1, passage2, useAbbreviation1: true),
          expected);
    });

    test('returns formatted verses showing verse numbers', () {
      final expected =
          '(창세기 1:1-2) 1. 태초에 하나님이 천지를 창조하시니라 2. 땅이 혼돈하고 공허하며 흑암이 깊음 위에 있고 하나님의 신은 수면에 운행하시니라\n' +
              '(Genesis 1:1-2) 1. In the beginning God created the heavens and the earth. 2. The earth was without form, and void; and darkness was on the face of the deep. And the Spirit of God was hovering over the face of the waters.';
      expect(format.formatPassagePair(passage1, passage2, showVerseNums: true),
          expected);
    });
  });
}
