import 'package:flutter_test/flutter_test.dart';
import 'package:interprep/services/bible/verse.dart';

void main() {
  group('Constructor', () {
    test('initializes with proper values', () {
      final verse = Verse('창세기', 1, 1, 1, '태초에 하나님이 천지를 창조하시니라');
      expect(verse.bookName, '창세기');
      expect(verse.book, 1);
      expect(verse.chapter, 1);
      expect(verse.verse, 1);
      expect(verse.text, '태초에 하나님이 천지를 창조하시니라');
    });
  });

  group('Comparable implementation', () {
    test('returns 0 when same verse', () {
      final v1 = Verse('', 1, 2, 3, '');
      final v2 = Verse('', 1, 2, 3, '');

      expect(v1.compareTo(v2), 0);
    });

    test('returns negative when in earlier book', () {
      final v1 = Verse('', 0, 2, 2, '');
      final v2 = Verse('', 1, 1, 1, '');

      expect(v1.compareTo(v2), isNegative);
    });

    test('returns positive when in later book', () {
      final v1 = Verse('', 1, 1, 1, '');
      final v2 = Verse('', 0, 2, 2, '');

      expect(v1.compareTo(v2), isPositive);
    });

    test('returns negative when in earlier chapter', () {
      final v1 = Verse('', 0, 1, 2, '');
      final v2 = Verse('', 0, 2, 1, '');

      expect(v1.compareTo(v2), isNegative);
    });

    test('returns positive when in later chapter', () {
      final v1 = Verse('', 0, 2, 1, '');
      final v2 = Verse('', 0, 1, 2, '');

      expect(v1.compareTo(v2), isPositive);
    });

    test('returns negative when an earlier verse', () {
      final v1 = Verse('', 0, 1, 10, '');
      final v2 = Verse('', 0, 1, 11, '');

      expect(v1.compareTo(v2), isNegative);
    });

    test('returns positive when a later verse', () {
      final v1 = Verse('', 0, 1, 6, '');
      final v2 = Verse('', 0, 1, 5, '');

      expect(v1.compareTo(v2), isPositive);
    });
  });
}
