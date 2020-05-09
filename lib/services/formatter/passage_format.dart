import 'package:interprep/services/bible/passage.dart';

abstract class PassageFormat {
  /// Takes two lists of verses [verses1] and [verses2] and returns a formatted String.
  String formatPassage(Passage passage);
}
