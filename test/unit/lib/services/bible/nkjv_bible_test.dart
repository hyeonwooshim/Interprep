import 'package:flutter_test/flutter_test.dart';
import 'package:interprep/services/bible/nkjv_bible.dart';
import 'package:interprep/services/bible/verse.dart';

void main() {
  test('language is English', () {
    expect(NkjvBible().language, 'English');
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
