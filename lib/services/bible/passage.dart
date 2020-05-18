import 'package:interprep/services/bible/bible.dart';
import 'package:interprep/services/bible/verse.dart';

class Passage {
  Bible bible;
  List<Verse> verses;

  Verse startVerse;
  Verse endVerse;

  Passage(Bible bible, Verse start, Verse end) {
    this.bible = bible;
    this.startVerse = start;
    this.endVerse = end;

    final errorMsg = validatePassage(bible, start, end);
    if (errorMsg != null) throw ArgumentError(errorMsg);

    verses = bible.versesInRange(
        start.book, start.chapter, start.verse, end.chapter, end.verse);
  }

  String locationString(
      {String rangeSymbol = '-', bool useAbbreviation = false}) {
    final bookNames =
        useAbbreviation ? bible.shortenedBookNames : bible.bookNames;

    String left = '${bookNames[startVerse.book]} ';
    String right;

    if (right != null || startVerse.book != endVerse.book) {
      right = '${bookNames[endVerse.book]} ';
    }

    left += '${startVerse.chapter}:';
    if (right != null || startVerse.chapter != endVerse.chapter) {
      right = (right ?? '') + '${endVerse.chapter}:';
    }

    left += '${startVerse.verse}';
    if (right != null || startVerse.verse != endVerse.verse) {
      right = (right ?? '') + '${endVerse.verse}';
    }

    if (right != null) {
      return '$left$rangeSymbol$right';
    } else {
      return left;
    }
  }

  static String validatePassage(Bible bible, Verse start, Verse end) {
    if (!bible.hasVerse(start.book, start.chapter, start.verse)) {
      return 'start verse is invalid';
    }

    if (!bible.hasVerse(end.book, end.chapter, end.verse)) {
      return 'end verse is invalid';
    }

    if (start.compareTo(end) > 0) {
      return 'start cannot come later than the end verse';
    }

    return null;
  }
}
