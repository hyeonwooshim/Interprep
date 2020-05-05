abstract class Bible {
  var indexedBible;
  var bns;

  /// Constructor in the case for text files with each line being a verse.
  /// The lines must have a very specific format.
  Bible(dynamic bibleReader) {
    if (bibleReader == null) throw 'bibleReader cannot be null!';
    this.bns = getBookNames();
    this.indexedBible = _readBible(bibleReader);
  }

  /// Returns English name of the language that this Bible is in
  String getLanguage();

  /// Returns Array of full book names in this Bible
  List getBookNames();

  List getShortenedBookNames() {
    return getBookNames();
  }

  String getBookName(int book) {
    return getBookNames()[book];
  }

  String getShortenedBookName(int book) {
    return getShortenedBookNames()[book];
  }

  List getFullIndexedBible() {
    return indexedBible;
  }

  /// Returns book number given a string of the name or search string for the name.
  /// Returns a -1 if book is not found. Default behavior is to check for lower-case
  /// substrings.
  /// @param book    name of the book
  /// @return the index of the book
  int getBookIndex(String book) {
    if (book.isEmpty) return -1;

    var bookNames = getBookNames();

    String lower = book.toLowerCase();
    for(int i = 0; i < bookNames.length; i++){
      String bookName = bookNames[i].toLowerCase();
      if (bookName.contains(lower)) return i;
    }
    return -1;
  }

  /// Checks if a chapter is valid given the [book] and [chapter].
  bool hasChapter(int book, int chapter) {
    return (book >= 0 && book < numBooks) && (chapter > 0 && chapter <= bookToNumChapters[book]);
  }

  /// Checks if a verse is valid given [book], [chapter], and [verse].
  bool hasVerse(int book, int chapter, int verse) {
    return hasChapter(book, chapter) && verse > 0 && verse <= chapter(book, chapter).length;
  }

  List chapter(int book, int chapter) {
    return indexedBible[book][chapter - 1];
  }

  /// Returns the verse at [book], [chapter], and [verse].
  String verse(int book, int chapter, int verse) {
    return indexedBible[book][chapter - 1][verse - 1];
  }

  List verses(int book, int chapter, int verse1, int verse2) {
    return versesFrom(book, chapter, verse1, verse2 - verse1);
  }

  List versesFrom(int book, int chapter, int verse, int offset) {
    List verses = List<String>(offset + 1);
    for (int i = 0; i <= offset; i++) {
      verses[i] = verse(book, chapter, verse + i);
    }
    return verses;
  }

  /// Returns 3D String array of Bible given a version
  ///
  /// @param bibleReader BufferedReader for the .txt file of the version
  /// @return nested array of Strings of the Bible
  List _readBible(BufferedReader bibleReader) {
    // Create jagged 3D array of all the lines
    var book = List<List>(numBooks);
    var numVerses = List<List>(numBooks);
    for (int i = 0; i < numBooks; i++) { // Assign correct number of chapters
      var chapterCount = bookToNumChapters[i];
      book[i] = List<List<String>>(chapterCount);
      numVerses[i] = List<int>(chapterCount);
      for (int j = 0; j < chapterCount; j++) {
        book[i][j] = List<String>(200);
      }
    }
    
    String line;
    while ((line = bibleReader.readLine()) != null) {
      Verse v = new Verse(line, getBookIndex);
      book[v.getBook()][v.getChapter() - 1][v.getVerse() - 1] = v.getText();
      numVerses[v.getBook()][v.getChapter() - 1] = v.getVerse();
    }

    for (int i = 0; i < numBooks; i++) { // Assign correct number of chapters
      for (int j = 0; j < bookToNumChapters[i]; j++) {
        book[i][j] = Arrays.copyOfRange(book[i][j], 0, numVerses[i][j]);;
      }
    }

    return book;
  }

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

  static const int numBooks = 66;
}