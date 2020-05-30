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

  final _bookNameFocusNode = FocusNode();
  final _chapterFocusNode = FocusNode();
  final _startVerseFocusNode = FocusNode();
  final _endVerseFocusNode = FocusNode();

  final _bookNameEditController = TextEditingController();
  final _chapterEditController = TextEditingController();
  final _startVerseEditController = TextEditingController();
  final _endVerseEditController = TextEditingController();

  void initState() {
    super.initState();
    bibleFetch = Future.wait([
      BibleSource.loadKoreanBible(context),
      BibleSource.loadNkjvBible(context),
    ]);

    _bookNameEditController.addListener(() {
      setState(() => _currentBook = _bookNameEditController.text);
    });
    bookNameField = TypeAheadField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        focusNode: _bookNameFocusNode,
        controller: _bookNameEditController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Book Name',
          isDense: true,
        ),
      ),
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
            _bookNameEditController.text = suggestion;
          },
        );
      },
      onSuggestionSelected: (_) {},
      hideOnEmpty: true,
      hideOnError: true,
      hideOnLoading: true,
    );

    listenToSelectAllOnFocus(_bookNameFocusNode, _bookNameEditController);
    listenToSelectAllOnFocus(_chapterFocusNode, _chapterEditController);
    listenToSelectAllOnFocus(_startVerseFocusNode, _startVerseEditController);
    listenToSelectAllOnFocus(_endVerseFocusNode, _endVerseEditController);
  }

  void listenToSelectAllOnFocus(
    FocusNode focusNode,
    TextEditingController textController,
  ) {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: textController.text.length,
        );
      }
    });
  }

  ValueChanged<VerseLocation> beforeOrAfterOnChanged() {
    if (_verseStatus == VerseStatus.recited) {
      return (VerseLocation value) {
        setState(() {
          _verseLocation = value;
        });
      };
    }
    return null;
  }

  void copyVerse() {
    final str = fetchVersesToCopy();
    if (str == null) return;
    Clipboard.setData(ClipboardData(text: str));
  }

  String fetchVersesToCopy() {
    final verseArr = initVerses();
    if (verseArr == null) return null;
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
    return str;
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
            return smartMainWidget();
          }
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Container(
                margin: EdgeInsets.all(10),
                child: Text(
                  'Loading the Bible...',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget smartMainWidget() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        if (constraints.maxWidth < 1000) {
          return oneColumnLayout();
        } else {
          return twoColumnLayout();
        }
      },
    );
  }

  Widget oneColumnLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          inputWidget(maxWidth: double.infinity),
        ],
      ),
    );
  }

  Widget twoColumnLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          inputWidget(),
        ],
      ),
    );
  }

  Widget inputWidget({double maxWidth = 500}) {
    return Container(
      alignment: Alignment.topCenter,
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: Card(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: inputCardContent(),
        ),
      ),
    );
  }

  Widget inputCardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row - Recited/Read
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerRight,
              constraints: BoxConstraints(minWidth: 120),
              child: Text(
                'Recited/Read:',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: RadioListTile<VerseStatus>(
                title: Text('Recited'),
                dense: true,
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
              flex: 2,
              child: RadioListTile<VerseStatus>(
                title: Text('Read'),
                dense: true,
                value: VerseStatus.read,
                groupValue: _verseStatus,
                onChanged: (VerseStatus value) {
                  setState(() {
                    _verseStatus = value;
                  });
                },
              ),
            ),
          ],
        ),
        // Second row - Before/After
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              constraints: BoxConstraints(minWidth: 120),
              child: Text(
                'Before/After:',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: RadioListTile<VerseLocation>(
                title: Text('Before'),
                dense: true,
                value: VerseLocation.before,
                groupValue: _verseLocation,
                onChanged: beforeOrAfterOnChanged(),
              ),
            ),
            Flexible(
              flex: 2,
              child: RadioListTile<VerseLocation>(
                title: Text('After'),
                dense: true,
                value: VerseLocation.after,
                groupValue: _verseLocation,
                onChanged: beforeOrAfterOnChanged(),
              ),
            ),
          ],
        ),
        // Third row - Book name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: bookNameField,
              ),
            ),
          ],
        ),
        // Fourth row - verse location
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: chapterTextField(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  ':',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Flexible(
                child: startVerseTextField(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  '~',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Flexible(
                child: endVerseTextField(),
              ),
            ],
          ),
        ),
        // Fifth row - submit
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
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
              onPressed: copyButtonOnPressed(),
            ),
          ],
        ),
      ],
    );
  }

  Widget chapterTextField() {
    return TextField(
      focusNode: _chapterFocusNode,
      controller: _chapterEditController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Chapter',
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
      onChanged: (text) {
        setState(() {
          if (text != null) {
            _currentChapter = int.tryParse(text);
          }
        });
      },
    );
  }

  Widget startVerseTextField() {
    return TextField(
      focusNode: _startVerseFocusNode,
      controller: _startVerseEditController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Start Verse',
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
      onChanged: (text) {
        setState(() {
          if (text != null) {
            _currentStartVerse = int.tryParse(text);
          }
        });
      },
    );
  }

  Widget endVerseTextField() {
    return TextField(
      focusNode: _endVerseFocusNode,
      controller: _endVerseEditController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'End Verse',
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
      onChanged: (text) {
        setState(() {
          if (text != null) {
            _currentEndVerse = int.tryParse(text);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _bookNameEditController.dispose();
    _chapterEditController.dispose();
    _startVerseEditController.dispose();
    _endVerseEditController.dispose();

    _bookNameFocusNode.dispose();
    _chapterFocusNode.dispose();
    _startVerseFocusNode.dispose();
    _endVerseFocusNode.dispose();

    super.dispose();
  }
}
