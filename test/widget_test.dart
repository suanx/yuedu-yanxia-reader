import 'package:flutter_test/flutter_test.dart';
import 'package:yuedu/data/models/chapter.dart';
import 'package:yuedu/features/reading/vertical_reader.dart';
import 'package:yuedu/features/tts/tts_engine.dart';

void main() {
  test('章节纯文本按段落拼接', () {
    const c = Chapter(title: 'T', paragraphs: <String>['甲', '乙']);
    expect(c.plainText, '甲\n乙');
  });

  test('按句切分并保留字符区间', () {
    final s = splitSentences('你好。世界！');
    expect(s.length, 2);
    expect(s.first.$1, '你好');
    expect(s.first.$2, 0);
    expect(s.first.$3, 2);
  });

  test('中文数字规一化', () {
    expect(normalizeForSpeech('2026年'), '二零二六年');
    expect(normalizeForSpeech('50%'), '五零百分之');
  });

  test('竖排分页返回非空版面', () {
    const layout = VerticalLayout(
      charHeight: 30,
      charWidth: 20,
      columnGap: 20,
      lineLeading: 5,
      contentTop: 10,
      contentBottom: 600,
      contentRight: 380,
      contentLeft: 20,
    );
    final pages = paginateVertical(
      text: '那年冬天来得早。巷口的梧桐还没落尽最后一片叶子。',
      layout: layout,
    );
    expect(pages, isNotEmpty);
    expect(emptyVerticalPage(layout).columns.length, 1);
  });
}
