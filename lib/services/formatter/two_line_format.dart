import 'package:interprep/services/bible/passage.dart';
import 'package:interprep/services/formatter/passage_format.dart';

class TwoLineFormat extends PassageFormat {
  bool locationBefore;

  TwoLineFormat(locationBefore);

  String formatPassage(Passage passage1, Passage passage2) {
    return '';
  }
}
