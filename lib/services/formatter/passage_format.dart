import 'package:interprep/services/bible/passage.dart';

abstract class PassageFormat {
  /// Returns a formatted String based on [passage1] and [passage2].
  String formatPassagePair(Passage passage1, Passage passage2);
}
