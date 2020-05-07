import 'package:interprep/services/bible/verse.dart';

abstract class Bible {
  List<List<List<Verse>>> indexedBible;

  Bible();

  Bible.fromLines(dynamic lines, [Verse parseLine(String line)]) {
    indexedBible = _indexAllLines(lines, parseLine);
  }

  String get language;
  List<String> get bookNames;
  List<String> get shortenedBookNames;

  /// Returns book index given [book], a string of the name or search string for the name.
  /// Returns a -1 if not found. Default behavior is to check for lower-case substrings.
  int getBookIndex(String book) {
    if (book.isEmpty) return -1;

    var bookNames = this.bookNames;

    String lower = book.toLowerCase();
    for (int i = 0; i < bookNames.length; i++) {
      String bookName = bookNames[i].toLowerCase();
      if (bookName.contains(lower)) return i;
    }
    return -1;
  }

  /// Checks if a chapter is valid given the [book] and [chapter].
  bool hasChapter(int book, int chapter) {
    return (book >= 0 && book < numBooks) &&
        (chapter > 0 && chapter <= bookToNumChapters[book]);
  }

  /// Checks if a verse is valid given [book], [chapter], and [verse].
  bool hasVerse(int book, int chapter, int verse) {
    return hasChapter(book, chapter) &&
        verse > 0 &&
        verse <= chapterAt(book, chapter).length;
  }

  /// Returns list of verses in given [book] and [chapter].
  List<Verse> chapterAt(int book, int chapter) {
    return indexedBible[book][chapter - 1];
  }

  /// Returns the verse at [book], [chapter], and [verse].
  Verse verseAt(int book, int chapter, int verse) {
    return indexedBible[book][chapter - 1][verse - 1];
  }

  /// Returns list of verses in given [book] and [chapter] and in between [verse1] and [verse2] inclusively.
  List<Verse> versesInRange(int book, int chapter, int verse1, int verse2) {
    return versesFrom(book, chapter, verse1, verse2 - verse1 + 1);
  }

  /// Returns list of [count] verses starting from given [book], [chapter], and [verse1].
  List<Verse> versesFrom(int book, int chapter, int verse, int count) {
    final verses = List<Verse>(count);
    for (int i = 0; i <= count; i++) {
      verses[i] = verseAt(book, chapter, verse + i);
    }
    return verses;
  }

  List<List<List<Verse>>> _indexAllLines(
      dynamic lines, Verse parseLine(String line)) {
    final book = List<List>(numBooks);
    for (int i = 0; i < numBooks; i++) {
      // Assign correct number of chapters
      final chapterCount = bookToNumChapters[i];
      book[i] = List<List<Verse>>.generate(chapterCount, (_) => []);
    }

    lines.forEach((line) {
      Verse v = parseLine(line);
      book[v.book][v.chapter - 1][v.verse - 1] = v.text;
    });

    return book;
  }

  Verse defaultParseLine(String line) {
    int firstSpace = line.indexOf(' ');
    String info = line.substring(0, firstSpace);
    String text = line.substring(firstSpace + 1);

    List<String> parts = info.replaceAll(RegExp('[^0-9]+'), ' ').split(' ');
    String ch;
    String v;
    if (parts.length == 2) {
      ch = parts[0];
      v = parts[1];
    } else if (parts.length == 3) {
      ch = parts[1];
      v = parts[2];
    } else {
      throw ArgumentError('line does not fit the standard format');
    }
    int chapter = int.parse(ch);
    int verse = int.parse(v);

    // What comes before the chapter number is the book name.
    String bookNameInLine =
        info.substring(0, info.indexOf(ch, 1)).replaceAll(RegExp(r'\.'), '');
    int book = getBookIndex(bookNameInLine);
    String bookName = bookNames[book];

    return Verse(bookName, book, chapter, verse, text);
  }

  static const int numBooks = 66;
  static const bookToNumChapters = [
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
  ];
}
