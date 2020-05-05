class Verse {
  String bookNameInLine;
  int book;
  int chapter;
  int verse;
  String text;

  Verse(String line, BookNameProcessor processor) {
    if (processor == null) throw ArgumentError('book name processor cannot be null!');
    processDefaultFormat(line, processor);
  }

  void processDefaultFormat(String line, BookNameProcessor bnProcessor) {
    int firstSpace = line.indexOf(" ");
    String info = line.substring(0, firstSpace);
    text = line.substring(firstSpace + 1);

    List<String> parts = info.replaceAll(RegExp(r"[^0-9]+"), " ").split(" ");
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
    chapter = int.parse(ch);
    verse = int.parse(v);

    // What comes before the chapter number is the book name.
    bookNameInLine = info.substring(0, info.indexOf(ch, 1)).replaceAll(RegExp(r"\\."), "");
    book = bnProcessor.getBookIndex(bookNameInLine);
  }

  String getBookNameInLine() {
    return bookNameInLine;
  }

  int getBook() {
    return book;
  }

  int getChapter() {
    return chapter;
  }

  int getVerse() {
    return verse;
  }

  String getText() {
    return text;
  }
}

abstract class BookNameProcessor {
  int getBookIndex(String bookName);
}