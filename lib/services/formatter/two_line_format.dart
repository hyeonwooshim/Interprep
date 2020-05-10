import 'package:interprep/services/bible/passage.dart';
import 'package:interprep/services/formatter/passage_format.dart';

class TwoLineFormat extends PassageFormat {
  String formatPassagePair(Passage passage1, Passage passage2,
      {locationFirst = true,
      showVerseNums = false,
      useAbbreviation1 = false,
      useAbbreviation2 = false}) {
    final formatted1 = _formatIndividualPassage(
        passage1, locationFirst, useAbbreviation1, showVerseNums);
    final formatted2 = _formatIndividualPassage(
        passage2, locationFirst, useAbbreviation2, showVerseNums);

    return '$formatted1\n$formatted2';
  }

  String _formatIndividualPassage(
      passage, locationFirst, useAbbreviation, showVerseNums) {
    var versesStr;
    if (showVerseNums) {
      versesStr = passage.verses.map((v) => '${v.verse}. ${v.text}').join(' ');
    } else {
      versesStr = passage.verses.map((v) => '${v.text}').join(' ');
    }

    final loc = passage.locationString(useAbbreviation: useAbbreviation);
    if (locationFirst) {
      return '($loc) $versesStr';
    } else {
      return '$versesStr ($loc)';
    }
  }
}
