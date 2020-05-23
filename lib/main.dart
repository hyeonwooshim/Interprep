import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:interprep/services/bible/passage.dart';
import 'package:interprep/services/bible/verse.dart';
import 'package:interprep/services/bible_source.dart';
import 'package:interprep/services/formatter/two_column_format.dart';
import 'package:interprep/services/formatter/two_line_format.dart';
import 'services/bible/korean_bible.dart';
import 'services/bible/nkjv_bible.dart';

void main() => runApp(Interprep());

class Interprep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Interprep",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Interprep"),
          centerTitle: true,
          backgroundColor: Colors.brown[300],
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.book,
                color: Colors.white,
              ),
              onPressed: null,
            ),
          ],
        ),
        body: CardInterface(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CardInterface extends StatefulWidget {
  @override
  _CardInterfaceState createState() => new _CardInterfaceState();
}

List<String> suggestions = KoreanBible.fullBookNames + NkjvBible.fullBookNames;

enum VerseStatus { recited, read }
enum VerseLocation { before, after }

class _CardInterfaceState extends State<CardInterface> {
  Future<List<dynamic>> bibleFetch;
  KoreanBible koreanBible;
  NkjvBible nkjvBible;

  VerseStatus _verseStatus = VerseStatus.recited;
  VerseLocation _verseLocation = VerseLocation.before;
  String _currentBook = '';
  int _currentChapter;
  int _currentStartVerse;
  int _currentEndVerse;

  TypeAheadField<String> bookNameField;
  final TextEditingController _bookNameFieldController =
      TextEditingController();

  void initState() {
    super.initState();
    bibleFetch = Future.wait([
      BibleSource.loadKoreanBible(context),
      BibleSource.loadNkjvBible(context)
    ]);

    _bookNameFieldController.addListener(() {
      setState(() => _currentBook = _bookNameFieldController.text);
    });
    bookNameField = TypeAheadField<String>(
        textFieldConfiguration: TextFieldConfiguration(
            controller: _bookNameFieldController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Book Name',
              isDense: true,
            )),
        suggestionsCallback: (pattern) async {
          final whitespace = new RegExp(r"\s+\b|\b\s|\s|\b");
          pattern = pattern.replaceAll(whitespace, "");
          if (pattern.isEmpty) return [];

          final candidates = suggestions.where((b) {
            b = b.replaceAll(whitespace, "");
            return b.toLowerCase().startsWith(pattern.toLowerCase());
          });
          if (candidates.isNotEmpty) return candidates;
          return suggestions.where((b) {
            b = b.replaceAll(whitespace, "");
            return b.toLowerCase().contains(pattern.toLowerCase());
          });
        },
        itemBuilder: (context, suggestion) {
          return Listener(
            child: ListTile(title: Text(suggestion)),
            onPointerUp: (_) {
              _bookNameFieldController.text = suggestion;
            },
          );
        },
        onSuggestionSelected: (_) {},
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: true);
  }

  void copyVerse() {
    final verseArr = initVerses();
    if (verseArr == null) return;
    final v1 = verseArr[0];
    final v2 = verseArr[1];

    if (Passage.validatePassage(koreanBible, v1, v2) != null) return null;

    final korean = Passage(koreanBible, v1, v2);
    final nkjv = Passage(nkjvBible, v1, v2);

    String str;
    if (_verseStatus == VerseStatus.recited) {
      final locationFirst = _verseLocation == VerseLocation.before;
      str = TwoLineFormat().formatPassagePair(korean, nkjv,
          locationFirst: locationFirst, useAbbreviation1: true);
    } else {
      str = TwoColumnFormat()
          .formatPassagePair(korean, nkjv, useAbbreviation1: true);
    }
    Clipboard.setData(ClipboardData(text: str));
  }

  List<Verse> initVerses() {
    int book = koreanBible.getBookIndex(_currentBook);
    if (book == -1) book = nkjvBible.getBookIndex(_currentBook);
    if (book == -1) return null;

    if (_currentChapter == null ||
        _currentStartVerse == null ||
        _currentEndVerse == null) return null;

    final v1 = Verse(null, book, _currentChapter, _currentStartVerse, null);
    final v2 = Verse(null, book, _currentChapter, _currentEndVerse, null);
    return [v1, v2];
  }

  VoidCallback copyButtonOnPressed() {
    final verseArr = initVerses();
    if (verseArr == null) return null;
    final v1 = verseArr[0];
    final v2 = verseArr[1];

    if (Passage.validatePassage(koreanBible, v1, v2) != null) return null;

    return () => copyVerse();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: bibleFetch,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              koreanBible ??= snapshot.data[0];
              nkjvBible ??= snapshot.data[1];
              return mainWidget(context);
            }
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Text('Loading the Bible...'),
              ],
            ),
          );
        });
  }

  Widget mainWidget(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2.5,
        height: MediaQuery.of(context).size.height / 1.25,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //first row - Recited/Read
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text('Recited/Read :',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    alignment: Alignment.centerRight,
                    width: (MediaQuery.of(context).size.width / 2.5) / 2.4,
                    height: (MediaQuery.of(context).size.height / 1.25) / 17,
                  ),
                  Flexible(
                    child: Radio(
                      value: VerseStatus.recited,
                      groupValue: _verseStatus,
                      onChanged: (VerseStatus value) {
                        setState(() {
                          _verseStatus = value;
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Recited',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Flexible(
                    child: Radio(
                      value: VerseStatus.read,
                      groupValue: _verseStatus,
                      onChanged: (VerseStatus value) {
                        setState(() {
                          _verseStatus = value;
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Read',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              //second row - Before/After
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text('Before/After :',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    alignment: Alignment.centerRight,
                    width: (MediaQuery.of(context).size.width / 2.5) / 2.4,
                    height: (MediaQuery.of(context).size.height / 1.25) / 17,
                  ),
                  Flexible(
                    child: Radio(
                      value: VerseLocation.before,
                      groupValue: _verseLocation,
                      onChanged: (VerseLocation value) {
                        setState(() {
                          _verseLocation = value;
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Before',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Flexible(
                    child: Radio(
                      value: VerseLocation.after,
                      groupValue: _verseLocation,
                      onChanged: (VerseLocation value) {
                        setState(() {
                          _verseLocation = value;
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'After',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              //third row - Book name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      child: ListTile(
                        title: bookNameField,
                      ),
                      width: (MediaQuery.of(context).size.width / 2.5) / 1.7,
                    ),
                  ),
                ],
              ),
              //fourth row - Chapter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      child: ListTile(
                        title: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Chapter',
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          onChanged: (text) {
                            setState(() {
                              if (text != null) {
                                _currentChapter = int.tryParse(text);
                              }
                            });
                          },
                        ),
                      ),
                      width: (MediaQuery.of(context).size.width / 2.5) / 1.7,
                    ),
                  ),
                ],
              ),
              //fifth row - Beginning V
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      child: ListTile(
                        title: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Start Verse',
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          onChanged: (text) {
                            setState(() {
                              if (text != null) {
                                _currentStartVerse = int.tryParse(text);
                              }
                            });
                          },
                        ),
                      ),
                      width: (MediaQuery.of(context).size.width / 2.5) / 1.7,
                    ),
                  ),
                ],
              ),
              //sixth row - Ending V
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      child: ListTile(
                        title: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'End Verse',
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          onChanged: (text) {
                            setState(() {
                              if (text != null) {
                                _currentEndVerse = int.tryParse(text);
                              }
                            });
                          },
                        ),
                      ),
                      width: (MediaQuery.of(context).size.width / 2.5) / 1.7,
                    ),
                  ),
                ],
              ),
              //seventh row - submit
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: FlatButton(
                        child: Text(
                          'Copy Verse',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        color: Colors.blue,
                        textColor: Colors.white,
                        disabledColor: Colors.black12,
                        onPressed: copyButtonOnPressed()),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _bookNameFieldController.dispose();
    super.dispose();
  }
}
