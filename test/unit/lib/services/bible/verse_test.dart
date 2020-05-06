import 'package:flutter_test/flutter_test.dart';
import 'package:interprep/services/bible/verse.dart';

void main() {
  group('Constructor', () {
    test('value should start at 0', () {
      final verse = Verse('창세기', 1, 1, 1, '태초에 하나님이 천지를 창조하시니라');
      expect(verse.bookName, '창세기');
      expect(verse.book, 1);
      expect(verse.chapter, 1);
      expect(verse.verse, 1);
      expect(verse.text, '태초에 하나님이 천지를 창조하시니라');
    });
  });
}
