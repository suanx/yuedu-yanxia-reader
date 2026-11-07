import 'package:yuedu/data/models/book.dart';
import 'package:yuedu/data/models/chapter.dart';

/// 发现页 · 每日推荐（横向大卡）
final List<Book> dailyPicks = [
  Book(
    id: 'p1',
    title: '搜索的心新',
    author: 'Weekly 编辑部',
    tag: '每日推荐',
    gradientSeed: 0,
  ),
  Book(
    id: 'p2',
    title: '晚风邮局',
    author: '林知遥',
    tag: '编辑精选',
    gradientSeed: 3,
  ),
  Book(
    id: 'p3',
    title: '云边小卖部',
    author: '张嘉北',
    tag: '本周热读',
    gradientSeed: 7,
  ),
];

/// 发现页 · 新书速递（横向小卡）
final List<Book> newArrivals = [
  Book(id: 'n1', title: '时间的褶皱', author: '陆以宁', gradientSeed: 1),
  Book(id: 'n2', title: '玻璃晴朗', author: '苏迟', gradientSeed: 4),
  Book(id: 'n3', title: '未完成的夏天', author: '陈屿', gradientSeed: 5),
  Book(id: 'n4', title: '人间一格', author: '白牧', gradientSeed: 2),
  Book(id: 'n5', title: '夜航西飞', author: '柏瑞尔', gradientSeed: 8),
  Book(id: 'n6', title: '薄雾来信', author: '言桉', gradientSeed: 6),
];

/// 书架（网格）
final List<Book> bookshelf = [
  Book(id: 'b1', title: '搜索的心新', author: 'Weekly 编辑部', gradientSeed: 0, progress: 0.68, currentPage: 142, totalPages: 208),
  Book(id: 'b2', title: '时间的褶皱', author: '陆以宁', gradientSeed: 1, progress: 0.32, currentPage: 67, totalPages: 208),
  Book(id: 'b3', title: '玻璃晴朗', author: '苏迟', gradientSeed: 4, progress: 1.0, currentPage: 208, totalPages: 208),
  Book(id: 'b4', title: '未完成的夏天', author: '陈屿', gradientSeed: 5, progress: 0.05, currentPage: 10, totalPages: 196),
  Book(id: 'b5', title: '人间一格', author: '白牧', gradientSeed: 2, progress: 0.0, currentPage: 0, totalPages: 240),
  Book(id: 'b6', title: '夜航西飞', author: '柏瑞尔', gradientSeed: 8, progress: 0.21, currentPage: 52, totalPages: 248),
  Book(id: 'b7', title: '薄雾来信', author: '言桉', gradientSeed: 6, progress: 0.0, currentPage: 0, totalPages: 180),
  Book(id: 'b8', title: '晚风邮局', author: '林知遥', gradientSeed: 3, progress: 0.87, currentPage: 171, totalPages: 196),
  Book(id: 'b9', title: '云边小卖部', author: '张嘉北', gradientSeed: 7, progress: 0.0, currentPage: 0, totalPages: 224),
];

/// 当前阅读章节（占位正文，接接口时按 \n 切段填入）
/// 按 id 取书，找不到回 null。书架 → 阅读页靠它拿书名/总页数。
Book? libraryById(String id) {
  for (final b in [...bookshelf, ...dailyPicks, ...newArrivals]) {
    if (b.id == id) return b;
  }
  return null;
}

final Chapter currentChapter = Chapter(
  title: '第一章  初见',
  totalPages: 208,
  paragraphs: [
    '那年冬天来得早。巷口的梧桐还没来得及落尽最后一片叶子，风就已经带了刀锋的凉意。她把围巾又紧了紧，踩着路灯拉长的影子，一步步走进这条走了无数次的巷子。',
    '转角那家旧书店还亮着灯。暖黄的，像一块刚出炉的蛋糕，隔着玻璃都能闻到纸页和旧木头混在一起的味道。她本来只是路过，却在门口那排打折书里，看见了那本。',
    '没有腰封，没有推荐语，封面只印着一个很淡的名字。她翻到扉页，上面有一行钢笔字，字迹清瘦，像是练过很久才敢落下去的：「给在冬天里找春天的人。」',
    '她站在那儿看了很久，久到店里的老猫从柜台上跳下来，绕着她的脚踝走了两圈。',
    '后来她总说，那是她整个冬天的开始。',
    '—— 节选自《搜索的心新》',
  ],
);
