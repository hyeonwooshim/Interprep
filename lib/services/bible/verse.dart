class Verse implements Comparable<Verse> {
  String bookName;
  int book;
  int chapter;
  int verse;
  String text;

  Verse(this.bookName, this.book, this.chapter, this.verse, this.text);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Verse &&
            runtimeType == other.runtimeType &&
            bookName == other.bookName &&
            book == other.book &&
            chapter == other.chapter &&
            verse == other.verse &&
            text == other.text;
  }

  @override
  int get hashCode {
    int hash = 17;
    hash = hash * 31 + bookName.hashCode;
    hash = hash * 31 + book.hashCode;
    hash = hash * 31 + chapter.hashCode;
    hash = hash * 31 + verse.hashCode;
    hash = hash * 31 + text.hashCode;
    return hash;
  }

  int compareTo(Verse other) {
    int diff = book - other.book;
    if (diff != 0) return diff;
    
    diff = chapter - other.chapter;
    if (diff != 0) return diff;

    diff = verse - other.verse;
    return diff;
  }
}
