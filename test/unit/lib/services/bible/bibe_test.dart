import 'package:flutter_test/flutter_test.dart';
import 'package:interprep/services/bible/bible.dart';
import 'package:interprep/services/bible/korean_bible.dart';
import 'package:interprep/services/bible/nkjv_bible.dart';
import 'package:interprep/services/bible/verse.dart';

void main() {
  group('defaultParseLine()', () {
    test('successfully parses usual line', () {
      final line = '창1:1 태초에 하나님이 천지를 창조하시니라';
      expect(KoreanBible().defaultParseLine(line),
          Verse('창세기', 0, 1, 1, '태초에 하나님이 천지를 창조하시니라'));
    });

    test('successfully parses line with numbered book', () {
      final line = '1John1:1 That which was from the beginning--';
      expect(NkjvBible().defaultParseLine(line),
          Verse('1 John', 61, 1, 1, 'That which was from the beginning--'));
    });

    test('throws ArgumentError with weird line', () {
      final line = '창1창1:1 태초에 하나님이 천지를 창조하시니라';
      expect(
          () => KoreanBible().defaultParseLine(line),
          throwsA(allOf(
              isArgumentError,
              predicate((e) =>
                  e.message == 'line does not fit the standard format'))));
    });
  });

  group('constant', () {
    test('numBooks is correct', () {
      expect(Bible.numBooks, 66);
    });

    test('bookToNumChapters is correct', () {
      expect(Bible.bookToNumChapters, [
        50,
        40,
        27,
        36,
        34,
        24,
        21,
        4,
        31,
        24,
        22,
        25,
        29,
        36,
        10,
        13,
        10,
        42,
        150,
        31,
        12,
        8,
        66,
        52,
        5,
        48,
        12,
        14,
        3,
        9,
        1,
        4,
        7,
        3,
        3,
        3,
        2,
        14,
        4,
        28,
        16,
        24,
        21,
        28,
        16,
        16,
        13,
        6,
        6,
        4,
        4,
        5,
        3,
        6,
        4,
        3,
        1,
        13,
        5,
        5,
        3,
        5,
        1,
        1,
        1,
        22,
      ]);
    });
  });
}
