import 'package:interprep/services/bible/bible.dart';
import 'package:interprep/services/bible/verse.dart';

class Passage {
  List<Verse> verses;

  Verse startVerse;
  Verse endVerse;

  Passage(Bible bible, Verse start, Verse end) {
    this.startVerse = start;
    this.endVerse = end;

    if (!bible.hasVerse(start.book, start.chapter, start.verse)) {
      throw ArgumentError('start verse is invalid');
    }
    if (!bible.hasVerse(end.book, end.chapter, end.verse)) {
      throw ArgumentError('end verse is invalid');
    }

    if (start.compareTo(end) > 0) {
      throw ArgumentError('start cannot come later than the end verse');
    }

    verses = bible.versesInRange(
        start.book, start.chapter, start.verse, end.chapter, end.verse);
  }
}
