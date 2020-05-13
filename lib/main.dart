import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "JBCH Interprep",
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
              onPressed: () {},
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

List<String> suggestions = [
  "창세기",
  "출애굽기",
  "레위기",
  "민수기",
  "신명기",
  "여호수아",
  "사사기",
  "룻기",
  "사무엘상",
  "사무엘하",
  "열왕기상",
  "열왕기하",
  "역대기상",
  "역대기하",
  "에스라",
  "느헤미",
  "에스더",
  "욥기",
  "시편",
  "잠언",
  "전도서",
  "아가",
  "이사야",
  "예레미야",
  "애가",
  "에스겔",
  "다니엘",
  "호세아",
  "요엘",
  "아모스",
  "오바댜",
  "요나",
  "미가",
  "나훔",
  "하박국",
  "스바냐",
  "학개",
  "스가랴",
  "말라기",
  "마태복음",
  "마가복음",
  "누가복음",
  "요한복음",
  "사도행전",
  "로마서",
  "고린도전서",
  "고린도후서",
  "갈라디아서",
  "에베소서",
  "빌립보서",
  "골로새서",
  "데살로니가전서",
  "데살로니가후서",
  "디모데전서",
  "디모데후서",
  "디도서",
  "빌레몬서",
  "히브리서",
  "야고보서",
  "베드로전서",
  "베드로후서",
  "요한일서",
  "요한이서",
  "요한삼서",
  "유다서",
  "요한계시록",
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

enum verseStatus { recited, read }
enum verseLocation { before, after }

class _CardInterfaceState extends State<CardInterface> {
  verseStatus _verseStatus = verseStatus.recited;
  verseLocation _verseLocation = verseLocation.before;
  String _currentBook = '';
  int _currentChapter = 0;
  int _currentStartVerse = 0;
  int _currentEndVerse = 0;
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  SimpleAutoCompleteTextField textField;
  TextEditingController bookName = new TextEditingController();

  //This body is for text auto-completion for book name
  _CardInterfaceState() {
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
                    width: (MediaQuery.of(context).size.width / 2.5) / 3.5,
                    height: (MediaQuery.of(context).size.height / 1.25) / 17,
                  ),
                  Flexible(
                    child: Radio(
                      value: verseStatus.recited,
                      groupValue: _verseStatus,
                      onChanged: (verseStatus value) {
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
                      value: verseStatus.read,
                      groupValue: _verseStatus,
                      onChanged: (verseStatus value) {
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
                    width: (MediaQuery.of(context).size.width / 2.5) / 3.5,
                    height: (MediaQuery.of(context).size.height / 1.25) / 17,
                  ),
                  Flexible(
                    child: Radio(
                      value: verseLocation.before,
                      groupValue: _verseLocation,
                      onChanged: (verseLocation value) {
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
                      value: verseLocation.after,
                      groupValue: _verseLocation,
                      onChanged: (verseLocation value) {
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text('Book Name :',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    alignment: Alignment.centerRight,
                    width: (MediaQuery.of(context).size.width / 2.5) / 3.5,
                    height: (MediaQuery.of(context).size.height / 1.25) / 17,
                  ),
                  Flexible(
                    child: ListTile(
                      title: textField,
                    ),
                  ),
                ],
              ),
              //fourth row - Chapter
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text('Chapter :',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    alignment: Alignment.centerRight,
                    width: (MediaQuery.of(context).size.width / 2.5) / 3.5,
                    height: (MediaQuery.of(context).size.height / 1.25) / 17,
                  ),
                  Flexible(
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
                  ),
                ],
              ),
              //fifth row - Beginning V
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text('Beginning V :',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    alignment: Alignment.centerRight,
                    width: (MediaQuery.of(context).size.width / 2.5) / 3.5,
                    height: (MediaQuery.of(context).size.height / 1.25) / 17,
                  ),
                  Flexible(
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
                  ),
                ],
              ),
              //sixth row - Ending V
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text('Ending V :',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    alignment: Alignment.centerRight,
                    width: (MediaQuery.of(context).size.width / 2.5) / 3.5,
                    height: (MediaQuery.of(context).size.height / 1.25) / 17,
                  ),
                  Expanded(
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
