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
import 'services/about_source.dart';

import 'dart:js' as js;

void main() => runApp(Interprep());

class Interprep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Interprep",
      home: MainRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Interprep"),
        centerTitle: true,
        backgroundColor: Colors.brown[300],
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutInterface()));
            },
          ),
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
    );
  }
}

class AboutInterface extends StatelessWidget {
  final List<Widget> aboutInfoText = AboutInfo.aboutInfo
      .map((str) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: (str[0] == '@')
                ? new Text(str, style: TextStyle(fontWeight: FontWeight.bold))
                : new Text(str),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
        centerTitle: true,
        backgroundColor: Colors.brown[300],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 1000,
          ),
          child: Card(
            margin: EdgeInsets.all(15),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: aboutInfoText,
              ),
            ),
          ),
        ),
      ),
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
  bool _showVerseNumbers = false;
  String _currentBook = '';
  int _currentChapter;
  int _currentStartVerse;
  int _currentEndVerse;

  FocusNode _keyboardListenerFocusNode;
  Function _keyboardFocusChangedListener;

  FocusNode _bookNameFocusNode;
  FocusNode _chapterFocusNode;
  FocusNode _startVerseFocusNode;
  FocusNode _endVerseFocusNode;

  TextEditingController _bookNameEditController;
  TextEditingController _chapterEditController;
  TextEditingController _startVerseEditController;
  TextEditingController _endVerseEditController;

  void initState() {
    super.initState();
    bibleFetch = Future.wait([
      BibleSource.loadKoreanBible(context),
      BibleSource.loadNkjvBible(context),
    ]);

    _keyboardListenerFocusNode = FocusNode();
    // Adding this listener ensures that the RawKeyboardListener
    // constantly listens for keyboard inputs. Probably will need
    // to change this if we start putting in more inputs.
    _keyboardFocusChangedListener = () {
      if (!_keyboardListenerFocusNode.hasFocus) {
        _keyboardListenerFocusNode.requestFocus();
      }
    };
    _keyboardListenerFocusNode.addListener(_keyboardFocusChangedListener);

    _bookNameFocusNode = FocusNode();
    _chapterFocusNode = FocusNode();
    _startVerseFocusNode = FocusNode();
    _endVerseFocusNode = FocusNode();

    _bookNameEditController = TextEditingController();
    _chapterEditController = TextEditingController();
    _startVerseEditController = TextEditingController();
    _endVerseEditController = TextEditingController();

    _bookNameEditController.addListener(() {
      setState(() => _currentBook = _bookNameEditController.text);
    });

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

  void copyVerse() {
    final str = fetchVersesToCopy();
    if (str == null) return;

    if (_verseStatus == VerseStatus.read) {
      js.context.callMethod('copyToClip', [str]);
    } else {
      Clipboard.setData(ClipboardData(text: str));
    }

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Passage copied!'),
      duration: Duration(seconds: 1),
    ));
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
      str = TwoLineFormat().formatPassagePair(
        korean,
        nkjv,
        locationFirst: locationFirst,
        showVerseNums: _showVerseNumbers,
        useAbbreviation1: true,
      );
    } else {
      str = TwoColumnFormat().formatPassagePair(
        korean,
        nkjv,
        useAbbreviation1: true,
      );
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

  String searchBookMatch() {
    if (_currentBook.isEmpty) return null;
    int book = koreanBible.getBookIndex(_currentBook);
    if (book != -1) return koreanBible.bookNames[book];
    book = nkjvBible.getBookIndex(_currentBook);
    if (book != -1) return nkjvBible.bookNames[book];
    return null;
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
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: _keyboardListenerFocusNode,
        child: Card(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: inputCardContent(),
          ),
        ),
        onKey: (event) {
          if (event.runtimeType != RawKeyDownEvent) return;
          if (event.logicalKey != LogicalKeyboardKey.enter &&
              event.logicalKey != LogicalKeyboardKey.backquote) return;
          copyVerse();
        },
      ),
    );
  }

  Widget inputCardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        recitedOrReadSetting(),
        beforeOrAfterSetting(),
        showVerseNumbersSetting(),
        // Book name
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: bookNameField(),
        ),
        // Verse location input
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
        //  Submit button
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

  Widget recitedOrReadSetting() {
    ValueChanged<bool> onChanged = (v) {
      setState(() {
        _verseStatus = v ? VerseStatus.read : VerseStatus.recited;
      });
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text("Recited"),
        Switch(
          value: _verseStatus == VerseStatus.read,
          onChanged: onChanged,
          inactiveTrackColor: Colors.grey[500],
          activeColor: Colors.white,
          activeTrackColor: Colors.grey[500],
        ),
        Text("Read"),
      ],
    );
  }

  Widget beforeOrAfterSetting() {
    ValueChanged<bool> onChanged;
    if (_verseStatus != VerseStatus.read) {
      onChanged = (v) {
        setState(() {
          _verseLocation = v ? VerseLocation.after : VerseLocation.before;
        });
      };
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Before",
          style: TextStyle(
            color: _verseStatus != VerseStatus.read
                ? Colors.black
                : Colors.black.withOpacity(0.3),
          ),
        ),
        Switch(
          value: _verseLocation == VerseLocation.after,
          onChanged: onChanged,
          inactiveThumbColor:
              _verseStatus != VerseStatus.read ? Colors.white : null,
          inactiveTrackColor:
              _verseStatus != VerseStatus.read ? Colors.grey[500] : null,
          activeColor: Colors.white,
          activeTrackColor: Colors.grey[500],
        ),
        Text(
          "After",
          style: TextStyle(
            color: _verseStatus != VerseStatus.read
                ? Colors.black
                : Colors.black.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget showVerseNumbersSetting() {
    ValueChanged<bool> onChanged;
    if (_verseStatus != VerseStatus.read) {
      onChanged = (v) {
        setState(() => _showVerseNumbers = v);
      };
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          margin: EdgeInsets.only(right: 15.0, left: 20.0),
          child: Text(
            "Verse Numbers",
            style: TextStyle(
              color: _verseStatus != VerseStatus.read
                  ? Colors.black
                  : Colors.black.withOpacity(0.3),
            ),
          ),
        ),
        Switch(
          value: _showVerseNumbers,
          onChanged: onChanged,
          inactiveThumbColor:
              _verseStatus != VerseStatus.read ? Colors.white : null,
          inactiveTrackColor:
              _verseStatus != VerseStatus.read ? Colors.grey[500] : null,
          activeColor: Colors.white,
          activeTrackColor: Colors.grey[500],
        ),
        Text(
          "No Verse Numbers",
          style: TextStyle(
            color: _verseStatus != VerseStatus.read
                ? Colors.black
                : Colors.black.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget bookNameField() {
    final useSuggestions = false;
    if (useSuggestions) {
      return autocompleteBookNameField();
    } else {
      return previewBookNameField();
    }
  }

  Widget previewBookNameField() {
    final matchedName = searchBookMatch();
    final displayText = matchedName ?? 'Book Name';
    return TextField(
      focusNode: _bookNameFocusNode,
      controller: _bookNameEditController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: displayText,
        isDense: true,
      ),
    );
  }

  Widget autocompleteBookNameField() {
    return TypeAheadField<String>(
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
      // Disables animation.
      transitionBuilder: (_, suggestionsBox, __) => suggestionsBox,
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
    _keyboardListenerFocusNode.removeListener(_keyboardFocusChangedListener);
    _keyboardListenerFocusNode.dispose();

    _bookNameFocusNode.dispose();
    _chapterFocusNode.dispose();
    _startVerseFocusNode.dispose();
    _endVerseFocusNode.dispose();

    _bookNameEditController.dispose();
    _chapterEditController.dispose();
    _startVerseEditController.dispose();
    _endVerseEditController.dispose();

    super.dispose();
  }
}
