import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:interprep/services/bible/bible.dart';
import 'package:interprep/services/bible/nkjv_bible.dart';
import 'package:interprep/services/bible/verse.dart';

void main() {
  group('Constructor fromLines', () {
    test('produces correctly indexed Bible', () {
      final lines = File('assets/NKJVer.txt').readAsLinesSync();
      final bible = NkjvBible.fromLines(lines);

      expect(bible.indexedBible.length, Bible.numBooks);
      expect(
          bible.indexedBible
              .map((b) => b.map((c) => c.length).reduce((j, k) => j + k))
              .reduce((j, k) => j + k),
          Bible.numVerses);
      expect(bible.indexedBible.map((b) => b.length), Bible.bookToNumChapters);

      bible.indexedBible.asMap().forEach((i, b) {
        b.asMap().forEach((j, c) {
          c.asMap().forEach((k, v) {
            expect(v.book, i);
            expect(v.chapter, j + 1);
            expect(v.verse, k + 1);
          });
        });
      });
    });
  });

  test('language is English', () {
    expect(NkjvBible().language, 'English');
  });

  group('hasChapter()', () {
    test('returns false if book is negative', () {
      expect(NkjvBible().hasChapter(-1, 0), false);
    });

    test('returns false if book is out of range', () {
      expect(NkjvBible().hasChapter(66, 0), false);
    });

    test('returns false if chapter is nonpositive', () {
      expect(NkjvBible().hasChapter(0, 0), false);
    });

    test('returns false if chapter is out of range', () {
      expect(NkjvBible().hasChapter(0, 51), false);
    });

    test('returns true if book and chapter are in range', () {
      expect(NkjvBible().hasChapter(0, 50), true);
    });
  });

  group('versesInRange()', () {
    NkjvBible bible;

    setUpAll(() {
      final lines = File('assets/NKJVer.txt').readAsLinesSync();
      bible = NkjvBible.fromLines(lines);
    });

    test('returns list of verses in same chapter', () {
      final list = bible.versesInRange(0, 1, 1, 1, 3);
      final expectedList = [
        Verse('Genesis', 0, 1, 1,
            'In the beginning God created the heavens and the earth.'),
        Verse('Genesis', 0, 1, 2,
            'The earth was without form, and void; and darkness was on the face of the deep. And the Spirit of God was hovering over the face of the waters.'),
        Verse('Genesis', 0, 1, 3,
            'Then God said, "Let there be light"; and there was light.')
      ];
      expect(list, expectedList);
    });

    test('returns list of verses in different chapters', () {
      final list = bible.versesInRange(0, 1, 31, 2, 2);
      final expectedList = [
        Verse('Genesis', 0, 1, 31,
            'Then God saw everything that He had made, and indeed it was very good. So the evening and the morning were the sixth day.'),
        Verse('Genesis', 0, 2, 1,
            'Thus the heavens and the earth, and all the host of them, were finished.'),
        Verse('Genesis', 0, 2, 2,
            'And on the seventh day God ended His work which He had done, and He rested on the seventh day from all His work which He had done.')
      ];
      expect(list, expectedList);
    });
  });

  group('versesFrom()', () {
    NkjvBible bible;

    setUpAll(() {
      final lines = File('assets/NKJVer.txt').readAsLinesSync();
      bible = NkjvBible.fromLines(lines);
    });

    test('returns list of verses in same chapter', () {
      final list = bible.versesFrom(0, 1, 1, 3);
      final expectedList = [
        Verse('Genesis', 0, 1, 1,
            'In the beginning God created the heavens and the earth.'),
        Verse('Genesis', 0, 1, 2,
            'The earth was without form, and void; and darkness was on the face of the deep. And the Spirit of God was hovering over the face of the waters.'),
        Verse('Genesis', 0, 1, 3,
            'Then God said, "Let there be light"; and there was light.')
      ];
      expect(list, expectedList);
    });

    test('returns list of verses in different chapters', () {
      final list = bible.versesFrom(0, 1, 31, 3);
      final expectedList = [
        Verse('Genesis', 0, 1, 31,
            'Then God saw everything that He had made, and indeed it was very good. So the evening and the morning were the sixth day.'),
        Verse('Genesis', 0, 2, 1,
            'Thus the heavens and the earth, and all the host of them, were finished.'),
        Verse('Genesis', 0, 2, 2,
            'And on the seventh day God ended His work which He had done, and He rested on the seventh day from all His work which He had done.')
      ];
      expect(list, expectedList);
    });

    test('returns list of verses in different books', () {
      final list = bible.versesFrom(0, 50, 26, 3);
      final expectedList = [
        Verse('Genesis', 0, 50, 26,
            'So Joseph died, being one hundred and ten years old; and they embalmed him, and he was put in a coffin in Egypt.'),
        Verse('Exodus', 1, 1, 1,
            'Now these are the names of the children of Israel who came to Egypt; each man and his household came with Jacob:'),
        Verse('Exodus', 1, 1, 2, 'Reuben, Simeon, Levi, and Judah;')
      ];
      expect(list, expectedList);
    });
  });

  group('getBookIndex(String book)', () {
    test('returns -1 if book is empty', () {
      expect(NkjvBible().getBookIndex(''), -1);
    });

    test('searches shortened names first', () {
      // Without that search, this will result in getting Genesis instead of Isaiah
      expect(NkjvBible().getBookIndex('is'), 22);
    });

    test('returns first index that contains string', () {
      expect(NkjvBible().getBookIndex('odu'), 1);
    });

    test('works with full book name', () {
      expect(NkjvBible().getBookIndex('1 Samuel'), 8);
    });
  });

  group('defaultParseLine()', () {
    test('successfully parses usual line', () {
      final line =
          'Gen.1:1 In the beginning God created the heavens and the earth.';
      expect(
          NkjvBible().defaultParseLine(line),
          Verse('Genesis', 0, 1, 1,
              'In the beginning God created the heavens and the earth.'));
    });

    test('successfully parses line with numbered book', () {
      final line = '1John1:1 That which was from the beginning--';
      expect(NkjvBible().defaultParseLine(line),
          Verse('1 John', 61, 1, 1, 'That which was from the beginning--'));
    });

    test('throws ArgumentError with weird line', () {
      final line =
          'G1Gen.1:1 In the beginning God created the heavens and the earth.';
      expect(
          () => NkjvBible().defaultParseLine(line),
          throwsA(allOf(
              isArgumentError,
              predicate((e) =>
                  e.message == 'line does not fit the standard format'))));
    });
  });

  group('constant', () {
    test('shortenedBookNames is correct', () {
      expect(NkjvBible().shortenedBookNames, [
        "Gen",
        "Ex",
        "Lev",
        "Num",
        "Deut",
        "Josh",
        "Judg",
        "Ruth",
        "1Sam",
        "2Sam",
        "1Kin",
        "2Kin",
        "1Chr",
        "2Chr",
        "Ezra",
        "Neh",
        "Esther",
        "Job",
        "Ps",
        "Prov",
        "Eccles",
        "Song",
        "Is",
        "Jer",
        "Lam",
        "Ezek",
        "Dan",
        "Hos",
        "Joel",
        "Amos",
        "Obad",
        "Jonah",
        "Mic",
        "Nah",
        "Hab",
        "Zeph",
        "Hag",
        "Zech",
        "Mal",
        "Matt",
        "Mark",
        "Luke",
        "John",
        "Acts",
        "Rom",
        "1Cor",
        "2Cor",
        "Gal",
        "Eph",
        "Phil",
        "Col",
        "1Thess",
        "2Thess",
        "1Tim",
        "2Tim",
        "Titus",
        "Philem",
        "Heb",
        "James",
        "1Pet",
        "2Pet",
        "1John",
        "2John",
        "3John",
        "Jude",
        "Rev",
      ]);
      expect(NkjvBible().shortenedBookNames.length, 66);
    });

    test('bookNames is correct', () {
      expect(NkjvBible().bookNames, [
        "Genesis",
        "Exodus",
        "Leviticus",
        "Numbers",
        "Deuteronomy",
        "Joshua",
        "Judges",
        "Ruth",
        "1 Samuel",
        "2 Samuel",
        "1 Kings",
        "2 Kings",
        "1 Chronicles",
        "2 Chronicles",
        "Ezra",
        "Nehemiah",
        "Esther",
        "Job",
        "Psalms",
        "Proverbs",
        "Ecclesiastes",
        "Song of Solomon",
        "Isaiah",
        "Jeremiah",
        "Lamentations",
        "Ezekiel",
        "Daniel",
        "Hosea",
        "Joel",
        "Amos",
        "Obadiah",
        "Jonah",
        "Micah",
        "Nahum",
        "Habakkuk",
        "Zephaniah",
        "Haggai",
        "Zechariah",
        "Malachi",
        "Matthew",
        "Mark",
        "Luke",
        "John",
        "Acts",
        "Romans",
        "1 Corinthians",
        "2 Corinthians",
        "Galatians",
        "Ephesians",
        "Philippians",
        "Colossians",
        "1 Thessalonians",
        "2 Thessalonians",
        "1 Timothy",
        "2 Timothy",
        "Titus",
        "Philemon",
        "Hebrews",
        "James",
        "1 Peter",
        "2 Peter",
        "1 John",
        "2 John",
        "3 John",
        "Jude",
        "Revelation",
      ]);
      expect(NkjvBible().bookNames.length, 66);
    });
  });
}
