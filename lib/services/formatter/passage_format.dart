import 'package:interprep/services/bible/passage.dart';

abstract class PassageFormat {
  /// Returns a formatted String based on [passage].
  String formatPassage(Passage passage1, Passage passage2);
}
