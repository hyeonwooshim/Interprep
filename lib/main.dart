import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/services.dart';
import 'package:interprep/services/bible_source.dart';
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
        body: FutureBuilder(
            future: Future.wait([
              BibleSource.loadKoreanBible(context),
              BibleSource.loadNkjvBible(context)
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return CardInterface(
                      koreanBible: snapshot.data[0],
                      nkjvBible: snapshot.data[1]);
                }
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[CircularProgressIndicator()],
                ),
              );
            }),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CardInterface extends StatefulWidget {
  final KoreanBible koreanBible;
  final NkjvBible nkjvBible;

  CardInterface({Key key, @required this.koreanBible, @required this.nkjvBible})
      : super(key: key);

  @override
  _CardInterfaceState createState() =>
      new _CardInterfaceState(koreanBible: koreanBible, nkjvBible: nkjvBible);
}

List<String> suggestions = KoreanBible.fullBookNames + NkjvBible.fullBookNames;

enum VerseStatus { recited, read }
enum VerseLocation { before, after }

class _CardInterfaceState extends State<CardInterface> {
  final KoreanBible koreanBible;
  final NkjvBible nkjvBible;

  VerseStatus _verseStatus = VerseStatus.recited;
  VerseLocation _verseLocation = VerseLocation.before;
  String _currentBook = '';
  int _currentChapter = 0;
  int _currentStartVerse = 0;
  int _currentEndVerse = 0;
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  SimpleAutoCompleteTextField textField;
  TextEditingController bookName = new TextEditingController();

  //This body is for text auto-completion for book name
  _CardInterfaceState({@required this.koreanBible, @required this.nkjvBible}) {
    textField = SimpleAutoCompleteTextField(
      key: key,
      controller: bookName,
      suggestions: suggestions,
      textChanged: (text) => _currentBook = text,
      clearOnSubmit: false,
      submitOnSuggestionTap: false,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Book Name',
        isDense: true,
      ),
      textSubmitted: (text) => setState(() {
        _currentBook = text;
        bookName.text = text;
        print(_currentBook);
      }),
    );
  }

  // void copyVerse() {
  //   Clipboard.setData(ClipboardData(text: _currentBook));
  // }

  @override
  Widget build(BuildContext context) {
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
                        title: textField,
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
                            if (text != null) {
                              _currentChapter = int.tryParse(text);
                            }
                          },
                          // onSubmitted: (text) => {
                          //   print(text),
                          // },
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
                            labelText: 'Start V',
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          onChanged: (text) {
                            if (text != null) {
                              _currentStartVerse = int.tryParse(text);
                            }
                          },
                          // onSubmitted: (text) => {
                          //   print(text),
                          // },
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
                            labelText: 'End V',
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          onChanged: (text) {
                            if (text != null) {
                              _currentEndVerse = int.tryParse(text);
                            }
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
                        onPressed: () {
                          //Do COPY VERSE ACTION
                          // copyVerse();
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
