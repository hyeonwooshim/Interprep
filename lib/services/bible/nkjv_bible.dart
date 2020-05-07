import 'package:interprep/services/bible/bible.dart';

class NkjvBible extends Bible {
  NkjvBible();

  NkjvBible.fromLines(dynamic lines) : super.fromLines(lines);

  @override
  String get language => 'English';

  @override
  List<String> get bookNames => fullBookNames;

  @override
  List<String> get shortenedBookNames => shortBookNames;

  @override
  int getBookIndex(String book) {
    if (book.isEmpty) return -1;

    // First check through the abbreviations.
    var shortNames = shortenedBookNames;
    for (int i = 0; i < shortNames.length; i++) {
      if (shortNames[i].toLowerCase() == book.toLowerCase()) return i;
    }
    return super.getBookIndex(book);
  }

  static const shortBookNames = [
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
  ];

  static const fullBookNames = [
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
  ];
}
