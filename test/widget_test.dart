import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yuedu/data/models/chapter.dart';
import 'package:yuedu/features/reading/vertical_reader.dart';
import 'package:yuedu/features/shell/app_shell.dart';
import 'package:yuedu/features/tts/tts_engine.dart';
import 'package:yuedu/widgets/glass.dart';

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

  /// 回归测试：曾因 IndexedStack 在 Stack 里收到 loose 约束而塌缩成 0 高，
  /// 真机上表现为「整页空白、只剩底栏四个按键」。这里直接 pump 整个壳，
  /// 断言四个 tab 的内容节点都真的出现在树里并占据非零尺寸。
  testWidgets('四个 tab 页内容都真实渲染（防止整页塌缩）', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AppShell()),
      ),
    );
    await tester.pumpAndSettle();

    // 发现页：标题、搜索框、分区、玻璃卡片
    expect(find.text('发现'), findsWidgets);
    expect(find.text('搜索书籍'), findsOneWidget);
    expect(find.text('每日推荐'), findsWidgets);
    expect(find.text('新书速递'), findsOneWidget);
    expect(find.byType(GlassCard), findsWidgets);
    final box = tester.getSize(find.byType(GlassCard).first);
    expect(box.width, greaterThan(100));
    expect(box.height, greaterThan(20));

    // 底栏四个按键
    for (final label in ['发现', '书架', '看一看', '我']) {
      expect(find.text(label), findsWidgets);
    }

    // 书架页：书名 + 进度
    await tester.tap(find.byIcon(Icons.auto_stories_outlined));
    await tester.pumpAndSettle();
    expect(find.text('薄雾来信'), findsWidgets);

    // 看一看页
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(GlassCard), findsWidgets);

    // 我的页
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('听书设置'), findsOneWidget);
  });
}
