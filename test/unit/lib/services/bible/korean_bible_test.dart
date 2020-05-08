import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:interprep/services/bible/bible.dart';
import 'package:interprep/services/bible/korean_bible.dart';
import 'package:interprep/services/bible/verse.dart';

void main() {
  group('Constructor fromLines', () {
    test('produces correctly indexed Bible', () {
      final lines = File('assets/KoreanVer.txt').readAsLinesSync();
      final bible = KoreanBible.fromLines(lines);

      expect(bible.indexedBible.length, Bible.numBooks);
      expect(
          bible.indexedBible
              .map((b) => b.map((c) => c.length).reduce((j, k) => j + k))
              .reduce((j, k) => j + k),
          Bible.numVerses);
      expect(bible.indexedBible.map((b) => b.length), Bible.bookToNumChapters);

      bible.indexedBible.asMap().forEach((i, b) {
        b.asMap().forEach((j, c) {
          c.asMap().forEach((k, v) {
            expect(v.book, i);
            expect(v.chapter, j + 1);
            expect(v.verse, k + 1);
          });
        });
      });
    });
  });

  test('language is Korean', () {
    expect(KoreanBible().language, 'Korean');
  });

  group('hasChapter()', () {
    test('returns false if book is negative', () {
      expect(KoreanBible().hasChapter(-1, 0), false);
    });

    test('returns false if book is out of range', () {
      expect(KoreanBible().hasChapter(66, 0), false);
    });

    test('returns false if chapter is nonpositive', () {
      expect(KoreanBible().hasChapter(0, 0), false);
    });

    test('returns false if chapter is out of range', () {
      expect(KoreanBible().hasChapter(0, 51), false);
    });

    test('returns true if book and chapter are in range', () {
      expect(KoreanBible().hasChapter(0, 50), true);
    });
  });

  group('getBookIndex()', () {
    test('returns -1 if book is empty', () {
      expect(KoreanBible().getBookIndex(''), -1);
    });

    test('searches shortened names first', () {
      // Without that search, this will result in getting 요나 instead 요한복음
      expect(KoreanBible().getBookIndex('요'), 42);
    });

    test('returns first index that contains string', () {
      expect(KoreanBible().getBookIndex('굽'), 1);
    });

    test('works with full book name', () {
      expect(KoreanBible().getBookIndex('사무엘상'), 8);
    });
  });

  group('defaultParseLine()', () {
    test('successfully parses usual line', () {
      final line = '창1:1 태초에 하나님이 천지를 창조하시니라';
      expect(KoreanBible().defaultParseLine(line),
          Verse('창세기', 0, 1, 1, '태초에 하나님이 천지를 창조하시니라'));
    });

    test('throws ArgumentError with weird line', () {
      final line = '창1창1:1 태초에 하나님이 천지를 창조하시니라';
      expect(
          () => KoreanBible().defaultParseLine(line),
          throwsA(allOf(
              isArgumentError,
              predicate((e) =>
                  e.message == 'line does not fit the standard format'))));
    });
  });
  group('constant', () {
    test('shortenedBookNames is correct', () {
      expect(KoreanBible().shortenedBookNames, [
        "창",
        "출",
        "레",
        "민",
        "신",
        "수",
        "삿",
        "룻",
        "삼상",
        "삼하",
        "왕상",
        "왕하",
        "대상",
        "대하",
        "스",
        "느",
        "에",
        "욥",
        "시",
        "잠",
        "전",
        "아",
        "사",
        "렘",
        "애",
        "겔",
        "단",
        "호",
        "욜",
        "암",
        "옵",
        "욘",
        "미",
        "나",
        "합",
        "습",
        "학",
        "슥",
        "말",
        "마",
        "막",
        "눅",
        "요",
        "행",
        "롬",
        "고전",
        "고후",
        "갈",
        "엡",
        "빌",
        "골",
        "살전",
        "살후",
        "딤전",
        "딤후",
        "딛",
        "몬",
        "히",
        "약",
        "벧전",
        "벧후",
        "요일",
        "요이",
        "요삼",
        "유",
        "계",
      ]);
      expect(KoreanBible().shortenedBookNames.length, 66);
    });

    test('bookNames is correct', () {
      expect(KoreanBible().bookNames, [
        "창세기",
        "출애굽기",
        "레위기",
        "민수기",
        "신명기",
        "여호수아",
        "사사기",
        "룻기",
        "사무엘상",
        "사무엘하",
        "열왕기상",
        "열왕기하",
        "역대기상",
        "역대기하",
        "에스라",
        "느헤미",
        "에스더",
        "욥기",
        "시편",
        "잠언",
        "전도서",
        "아가",
        "이사야",
        "예레미야",
        "애가",
        "에스겔",
        "다니엘",
        "호세아",
        "요엘",
        "아모스",
        "오바댜",
        "요나",
        "미가",
        "나훔",
        "하박국",
        "스바냐",
        "학개",
        "스가랴",
        "말라기",
        "마태복음",
        "마가복음",
        "누가복음",
        "요한복음",
        "사도행전",
        "로마서",
        "고린도전서",
        "고린도후서",
        "갈라디아서",
        "에베소서",
        "빌립보서",
        "골로새서",
        "데살로니가전서",
        "데살로니가후서",
        "디모데전서",
        "디모데후서",
        "디도서",
        "빌레몬서",
        "히브리서",
        "야고보서",
        "베드로전서",
        "베드로후서",
        "요한일서",
        "요한이서",
        "요한삼서",
        "유다서",
        "요한계시록",
      ]);
      expect(KoreanBible().bookNames.length, 66);
    });
  });
}
