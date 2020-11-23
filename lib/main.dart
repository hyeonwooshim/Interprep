import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interprep/services/bible/passage.dart';
import 'package:interprep/services/bible/verse.dart';
import 'package:interprep/services/bible_source.dart';
import 'package:interprep/services/formatter/two_column_format.dart';
import 'package:interprep/services/formatter/two_line_format.dart';
import 'services/bible/korean_bible.dart';
import 'services/bible/nkjv_bible.dart';
import 'services/bible/spanish_bible.dart';
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

List<String> suggestions = KoreanBible.fullBookNames +
    NkjvBible.fullBookNames +
    SpanishBible.fullBookNames;

enum VerseStatus { recited, read }
enum VerseLocation { before, after }
enum LanguageStatus { korEng, korSpan, engSpan }

class _CardInterfaceState extends State<CardInterface> {
  Future<List<dynamic>> bibleFetch;
  KoreanBible koreanBible;
  NkjvBible nkjvBible;
  SpanishBible spanishBible;

  VerseStatus _verseStatus = VerseStatus.recited;
  VerseLocation _verseLocation = VerseLocation.before;
  LanguageStatus _languageStatus = LanguageStatus.korEng;

  bool _showVerseNumbers = false;
  String _currentBook = '';
  int _currentChapter;
  int _currentStartVerse;
  int _currentEndVerse;

  FocusNode _keyboardListenerFocusNode;
  Function _keyboardFocusChangedListener;

  FocusNode _bookNameFocusNode;
  FocusNode _smartFocusNode;

  TextEditingController _bookNameEditController;
  TextEditingController _smartEditController;

  Map<String, dynamic> smartInputCache = {'input': null, 'result': null};

  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    bibleFetch = Future.wait([
      BibleSource.loadKoreanBible(context),
      BibleSource.loadNkjvBible(context),
      BibleSource.loadSpanBible(context),
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
    _smartFocusNode = FocusNode();

    _bookNameEditController = TextEditingController();
    _smartEditController = TextEditingController();

    _bookNameEditController.addListener(() {
      setState(() => _currentBook = _bookNameEditController.text);
    });

    listenToSelectAllOnFocus(_bookNameFocusNode, _bookNameEditController);
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

    Passage lang1;
    Passage lang2;

    if (_languageStatus == LanguageStatus.korEng) {
      lang1 = Passage(koreanBible, v1, v2);
      lang2 = Passage(nkjvBible, v1, v2);
    } else if (_languageStatus == LanguageStatus.engSpan) {
      lang1 = Passage(nkjvBible, v1, v2);
      lang2 = Passage(spanishBible, v1, v2);
    } else {
      lang1 = Passage(koreanBible, v1, v2);
      lang2 = Passage(spanishBible, v1, v2);
    }

    String str;
    if (_verseStatus == VerseStatus.recited) {
      final locationFirst = _verseLocation == VerseLocation.before;
      str = TwoLineFormat().formatPassagePair(
        lang1,
        lang2,
        locationFirst: locationFirst,
        showVerseNums: _showVerseNumbers,
        useAbbreviation1: true,
      );
    } else {
      str = TwoColumnFormat().formatPassagePair(
        lang1,
        lang2,
        useAbbreviation1: true,
      );
    }
    return str;
  }

  List<Verse> initVerses() {
    int book = koreanBible.getBookIndex(_currentBook);
    if (book == -1) book = nkjvBible.getBookIndex(_currentBook);
    if (book == -1) book = spanishBible.getBookIndex(_currentBook);
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
    book = spanishBible.getBookIndex(_currentBook);
    if (book != -1) return spanishBible.bookNames[book];
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
            spanishBible ??= snapshot.data[2];
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          languageSetting(),
          SizedBox(
            height: 30,
          ),
          recitedOrReadSetting(),
          beforeOrAfterSetting(),
          showVerseNumbersSetting(),
          // Book name
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: previewBookNameField(),
          ),
          // Verse location input
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: smartTextField(),
                ),
              ],
            ),
          ),
          //  Submit button
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
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
          ),
        ],
      ),
    );
  }

  bool inReadMode() {
    return _verseStatus == VerseStatus.read;
  }

  Widget languageText(LanguageStatus status) {
    if (status == LanguageStatus.korEng) {
      return Text("Korean / English");
    } else if (status == LanguageStatus.korSpan) {
      return Text("Korean / Spanish");
    } else {
      return Text("English / Spanish");
    }
  }

  Widget languageSetting() {
    return DropdownButton<LanguageStatus>(
      value: _languageStatus,
      icon: Icon(
        Icons.language,
      ),
      isDense: true,
      iconSize: 25,
      onChanged: (LanguageStatus newStatus) {
        setState(() {
          _languageStatus = newStatus;
        });
      },
      items: <LanguageStatus>[
        LanguageStatus.korEng,
        LanguageStatus.korSpan,
        LanguageStatus.engSpan,
      ].map<DropdownMenuItem<LanguageStatus>>((LanguageStatus status) {
        return DropdownMenuItem<LanguageStatus>(
          value: status,
          child: languageText(status),
        );
      }).toList(),
    );
  }

  Widget recitedOrReadSetting() {
    ValueChanged<bool> onChanged = (v) {
      setState(() {
        _verseStatus = v ? VerseStatus.read : VerseStatus.recited;
      });
    };
    return Row(
      children: [
        Expanded(
          child: Text(
            "Recited",
            textAlign: TextAlign.center,
          ),
        ),
        Switch(
          value: _verseStatus == VerseStatus.read,
          onChanged: onChanged,
          inactiveTrackColor: Colors.grey[500],
          activeColor: Colors.white,
          activeTrackColor: Colors.grey[500],
        ),
        Expanded(
          child: Text(
            "Read",
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget beforeOrAfterSetting() {
    ValueChanged<bool> onChanged;
    if (!inReadMode()) {
      onChanged = (v) {
        setState(() {
          _verseLocation = v ? VerseLocation.after : VerseLocation.before;
        });
      };
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            "Before",
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  !inReadMode() ? Colors.black : Colors.black.withOpacity(0.3),
            ),
          ),
        ),
        Switch(
          value: _verseLocation == VerseLocation.after,
          onChanged: onChanged,
          inactiveThumbColor: !inReadMode() ? Colors.white : null,
          inactiveTrackColor: !inReadMode() ? Colors.grey[500] : null,
          activeColor: Colors.white,
          activeTrackColor: Colors.grey[500],
        ),
        Expanded(
          child: Text(
            "After",
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  !inReadMode() ? Colors.black : Colors.black.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget showVerseNumbersSetting() {
    ValueChanged<bool> onChanged;
    if (!inReadMode()) {
      onChanged = (v) {
        setState(() => _showVerseNumbers = v);
      };
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            "No Verse #",
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  !inReadMode() ? Colors.black : Colors.black.withOpacity(0.3),
            ),
          ),
        ),
        Switch(
          value: _showVerseNumbers,
          onChanged: onChanged,
          inactiveThumbColor: !inReadMode() ? Colors.white : null,
          inactiveTrackColor: !inReadMode() ? Colors.grey[500] : null,
          activeColor: Colors.white,
          activeTrackColor: Colors.grey[500],
        ),
        Expanded(
          child: Text(
            "Show Verse #",
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  !inReadMode() ? Colors.black : Colors.black.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget previewBookNameField() {
    final matchedName = searchBookMatch();
    final displayText = matchedName ?? 'Book Name';
    return TextFormField(
      focusNode: _bookNameFocusNode,
      controller: _bookNameEditController,
      decoration: InputDecoration(
        labelText: displayText,
        isDense: true,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget smartTextField() {
    return TextFormField(
      focusNode: _smartFocusNode,
      controller: _smartEditController,
      decoration: InputDecoration(
        labelText: 'Smart',
        isDense: false,
      ),
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.always,
      onChanged: (text) {
        setState(() {
          final parsed = parsePassageInput(text);
          if (parsed['locations'].isEmpty) return;
          final loc = parsed['locations'][0];
          final valid = parsed['problemStart'] == null;
          _currentChapter = valid ? loc['ch'] : null;
          _currentStartVerse = valid ? loc['v1'] : null;
          _currentEndVerse = valid ? loc['v2'] ?? loc['v1'] : null;
        });
      },
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9,:;-]'))],
      validator: (value) {
        final result = parsePassageInput(value);
        if (result['problemStart'] == null) return null;
        final start = result['problemStart'];
        final substr = value.substring(start, start + result['problemLength']);
        return 'Problem at $start with \'$substr\'';
      },
    );
  }

  Map<String, dynamic> parsePassageInput(input) {
    final result = {'locations': []};
    if (input.isEmpty) return result;

    if (smartInputCache['input'] == input) return smartInputCache['result'];

    int pos = 0;
    final problemResult = (start, length) {
      final res = {
        'problemStart': start,
        'problemLength': length,
        'locations': result['locations'],
      };
      smartInputCache['input'] = input;
      smartInputCache['result'] = res;
      return res;
    };

    final locs = input.split(';');
    if (locs.isEmpty) return problemResult(pos, input.length);

    // TODO(ericshim): remove this logic to enable referencing multiple verses
    if (locs.length != 1) return problemResult(pos, input.length);

    for (String loc in locs) {
      final chapterVerseSplit = loc.split(':');
      if (chapterVerseSplit.length != 2) return problemResult(pos, loc.length);

      final chapter = int.tryParse(chapterVerseSplit[0]);
      if (chapter == null)
        return problemResult(pos, chapterVerseSplit[0].length);

      pos += chapterVerseSplit[0].length + 1;

      if (chapterVerseSplit[1].isEmpty) return problemResult(pos, 0);

      final verseLocs = chapterVerseSplit[1].split(',');
      if (verseLocs.isEmpty)
        return problemResult(pos, chapterVerseSplit[1].length);

      for (String verseLoc in verseLocs) {
        if (verseLoc.isEmpty) return problemResult(pos, 0);

        final verseNumMatches =
            RegExp('^([0-9]+)(?:-([0-9]+))?\$').allMatches(verseLoc);
        if (verseNumMatches.isEmpty) return problemResult(pos, verseLoc.length);

        final v1Str = verseNumMatches.elementAt(0).group(1);
        final v1 = int.tryParse(v1Str);
        if (v1 == null) return problemResult(pos, v1Str.length);

        pos += v1Str.length + 1;

        final verseRef = {'ch': chapter, 'v1': v1};
        final v2Str = verseNumMatches.elementAt(0)?.group(2);
        if (v2Str != null) {
          final v2 = int.tryParse(v2Str);
          if (v2 == null) return problemResult(pos, v2Str.length);
          verseRef['v2'] = v2;

          pos += v2Str.length + 1;
        }
        result['locations'].add(verseRef);
      }
    }

    return result;
  }

  @override
  void dispose() {
    _keyboardListenerFocusNode.removeListener(_keyboardFocusChangedListener);
    _keyboardListenerFocusNode.dispose();

    _bookNameFocusNode.dispose();

    _bookNameEditController.dispose();

    super.dispose();
  }
}
