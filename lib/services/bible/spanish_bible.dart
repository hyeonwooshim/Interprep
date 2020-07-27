import 'package:interprep/services/bible/bible.dart';

class SpanishBible extends Bible {
  SpanishBible();

  SpanishBible.fromLines(dynamic lines) : super.fromLines(lines);

  @override
  String get language => 'Spanish';

  @override
  List<String> get bookNames => fullBookNames;

  @override
  List<String> get shortenedBookNames => shortBookNames;

  @override
  int getBookIndex(String book) {
    if (book.isEmpty) return -1;

    // First check through the abbreviations.
    var shortNames = shortenedBookNames;
    for (int i = 0; i < shortNames.length; i++) {
      if (shortNames[i].toLowerCase() == book.toLowerCase()) return i;
    }
    return super.getBookIndex(book);
  }

  static const shortBookNames = [
    'Génesis',
    'Éxodo',
    'Levítico',
    'Números',
    'Deuteronomio',
    'Josué',
    'Jueces',
    'Rut',
    '1Samuel',
    '2Samuel',
    '1Reyes',
    '2Reyes',
    '1Crónicas',
    '2Crónicas',
    'Esdras',
    'Nehemías',
    'Ester',
    'Job',
    'Salmos',
    'Proverbios',
    'Eclesiastés',
    'CantardelosCantares',
    'Isaías',
    'Jeremías',
    'Lamentaciones',
    'Ezequiel',
    'Daniel',
    'Oseas',
    'Joel',
    'Amós',
    'Abdías',
    'Jonás',
    'Miqueas',
    'Nahum',
    'Habacuc',
    'Sofonías',
    'Hageo',
    'Zacarías',
    'Malaquías',
    'Mateo',
    'Marcos',
    'Lucas',
    'Juan',
    'Hechos',
    'Romanos',
    '1Corintios',
    '2Corintios',
    'Gálatas',
    'Efesios',
    'Filipenses',
    'Colosenses',
    '1Tesalonicenses',
    '2Tesalonicenses',
    '1Timoteo',
    '2Timoteo',
    'Tito',
    'Filemón',
    'Hebreos',
    'Santiago',
    '1Pedro',
    '2Pedro',
    '1Juan',
    '2Juan',
    '3Juan',
    'Judas',
    'Apocalipsis'
  ];

  static const fullBookNames = [
    'Génesis',
    'Éxodo',
    'Levítico',
    'Números',
    'Deuteronomio',
    'Josué',
    'Jueces',
    'Rut',
    '1 Samuel',
    '2 Samuel',
    '1 Reyes',
    '2 Reyes',
    '1 Crónicas',
    '2 Crónicas',
    'Esdras',
    'Nehemías',
    'Ester',
    'Job',
    'Salmos',
    'Proverbios',
    'Eclesiastés',
    'Cantar de los Cantares',
    'Isaías',
    'Jeremías',
    'Lamentaciones',
    'Ezequiel',
    'Daniel',
    'Oseas',
    'Joel',
    'Amós',
    'Abdías',
    'Jonás',
    'Miqueas',
    'Nahum',
    'Habacuc',
    'Sofonías',
    'Hageo',
    'Zacarías',
    'Malaquías',
    'Mateo',
    'Marcos',
    'Lucas',
    'Juan',
    'Hechos',
    'Romanos',
    '1 Corintios',
    '2 Corintios',
    'Gálatas',
    'Efesios',
    'Filipenses',
    'Colosenses',
    '1 Tesalonicenses',
    '2 Tesalonicenses',
    '1 Timoteo',
    '2 Timoteo',
    'Tito',
    'Filemón',
    'Hebreos',
    'Santiago',
    '1 Pedro',
    '2 Pedro',
    '1 Juan',
    '2 Juan',
    '3 Juan',
    'Judas',
    'Apocalipsis'
  ];
}
