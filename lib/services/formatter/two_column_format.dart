import 'package:interprep/services/bible/passage.dart';
import 'package:interprep/services/formatter/passage_format.dart';

class TwoColumnFormat extends PassageFormat {
  String formatPassagePair(Passage passage1, Passage passage2,
      {useAbbreviation1 = false, useAbbreviation2 = false}) {
    final loc1 = passage1.locationString(useAbbreviation: useAbbreviation1);
    final loc2 = passage2.locationString(useAbbreviation: useAbbreviation2);

    final formatted1 = _formatIndividualPassage(passage1);
    final formatted2 = _formatIndividualPassage(passage2);

    return '<pre><b>"$loc1"&#9;"$loc2"</b></pre><br>'
        '<table style="border:1px solid black; border-collapse:collapse;'
        'padding-left:0.08in; padding-right:0.08in; padding-top:0in; padding-bottom:0in;">'
        '<tr>'
        '<td style="vertical-align:top; border:1px solid black;">$formatted1</td>'
        '<td style="vertical-align:top; border:1px solid black;">$formatted2</td>'
        '</tr>'
        '</table>';
  }

  String _formatIndividualPassage(passage) {
    return passage.verses.map((v) => '${v.verse}. ${v.text}').join('<br><br>');
  }
}
