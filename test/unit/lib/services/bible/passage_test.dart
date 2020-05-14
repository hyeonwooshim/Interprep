import 'package:flutter_test/flutter_test.dart';
import 'package:interprep/services/bible/nkjv_bible.dart';
import 'package:interprep/services/bible/passage.dart';
import 'package:interprep/services/bible/verse.dart';

import '../../../../test_helper.dart';

void main() {
  group('Constructor', () {
    NkjvBible bible;

    setUpAll(() {
      bible = newNkjvBible();
    });

    test('returns new Passage', () {
      final v1 = Verse('', 0, 1, 3, '');
      final v2 = Verse('', 0, 5, 4, '');

      final passage = Passage(bible, v1, v2);
      expect(passage.startVerse, v1);
      expect(passage.endVerse, v2);
      expect(passage.verses, bible.versesInRange(0, 1, 3, 5, 4));
    });

    test('raises ArgumentError if start is invalid', () {
      final v1 = Verse('', 0, 100, 3, '');
      final v2 = Verse('', 1, 2, 3, '');

      expect(
          () => Passage(bible, v1, v2),
          throwsA(allOf(isArgumentError,
              predicate((e) => e.message == 'start verse is invalid'))));
    });

    test('raises ArgumentError if end is invalid', () {
      final v1 = Verse('', 0, 1, 1, '');
      final v2 = Verse('', 67, 1, 3, '');

      expect(
          () => Passage(bible, v1, v2),
          throwsA(allOf(isArgumentError,
              predicate((e) => e.message == 'end verse is invalid'))));
    });

    test('raises ArgumentError if start comes after end', () {
      final v1 = Verse('', 0, 10, 1, '');
      final v2 = Verse('', 0, 5, 5, '');

      expect(
          () => Passage(bible, v1, v2),
          throwsA(allOf(
              isArgumentError,
              predicate((e) =>
                  e.message == 'start cannot come later than the end verse'))));
    });
  });

  group('locationString()', () {
    NkjvBible bible;

    setUpAll(() {
      bible = newNkjvBible();
    });

    group('not using abbreviation', () {
      test('returns range string with one verse', () {
        final v1 = Verse('', 0, 1, 1, '');
        final v2 = Verse('', 0, 1, 1, '');

        final passage = Passage(bible, v1, v2);
        expect(passage.locationString(), 'Genesis 1:1');
      });

      test('returns range string within same chapter', () {
        final v1 = Verse('', 0, 1, 1, '');
        final v2 = Verse('', 0, 1, 4, '');

        final passage = Passage(bible, v1, v2);
        expect(passage.locationString(), 'Genesis 1:1-4');
      });

      test('returns range string within same book', () {
        final v1 = Verse('', 0, 1, 1, '');
        final v2 = Verse('', 0, 3, 1, '');

        final passage = Passage(bible, v1, v2);
        expect(passage.locationString(), 'Genesis 1:1-3:1');
      });

      test('returns range string in different books', () {
        final v1 = Verse('', 0, 1, 1, '');
        final v2 = Verse('', 2, 1, 1, '');

        final passage = Passage(bible, v1, v2);
        expect(passage.locationString(), 'Genesis 1:1-Leviticus 1:1');
      });
    });

    group('using abbreviation', () {
      test('returns range string with one verse', () {
        final v1 = Verse('', 0, 1, 1, '');
        final v2 = Verse('', 0, 1, 1, '');

        final passage = Passage(bible, v1, v2);
        expect(passage.locationString(useAbbreviation: true), 'Gen 1:1');
      });

      test('returns range string within same chapter', () {
        final v1 = Verse('', 0, 1, 1, '');
        final v2 = Verse('', 0, 1, 4, '');

        final passage = Passage(bible, v1, v2);
        expect(passage.locationString(useAbbreviation: true), 'Gen 1:1-4');
      });

      test('returns range string within same book', () {
        final v1 = Verse('', 0, 1, 1, '');
        final v2 = Verse('', 0, 3, 1, '');

        final passage = Passage(bible, v1, v2);
        expect(passage.locationString(useAbbreviation: true), 'Gen 1:1-3:1');
      });

      test('returns range string in different books', () {
        final v1 = Verse('', 0, 1, 1, '');
        final v2 = Verse('', 2, 1, 1, '');

        final passage = Passage(bible, v1, v2);
        expect(
            passage.locationString(useAbbreviation: true), 'Gen 1:1-Lev 1:1');
      });
    });
  });
}
