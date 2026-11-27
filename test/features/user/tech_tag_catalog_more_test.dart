import 'package:flutter_test/flutter_test.dart';
import 'package:passly/features/user/data/tech_tag_catalog.dart';

void main() {
  test('モバイルは iOS・Android ではなく Swift・Kotlin', () {
    final mobile = TechTagCatalog.categories.firstWhere(
      (c) => c.label == 'モバイル',
    );
    expect(mobile.tags, containsAll(['Swift', 'Kotlin']));
    expect(TechTagCatalog.allTags, isNot(contains('iOS')));
    expect(TechTagCatalog.allTags, isNot(contains('Android')));
  });

  test('前に付けた iOS・Android は Swift・Kotlin として読む', () {
    expect(TechTagCatalog.parse('Flutter, iOS, Android'), [
      'Flutter',
      'Swift',
      'Kotlin',
    ]);
    // すでに Swift もあるときは 1 つにまとめる
    expect(TechTagCatalog.parse('Swift, iOS'), ['Swift']);
  });

  test('同じタグが 2 つのカテゴリに入っていない', () {
    final all = TechTagCatalog.allTags;
    expect(all.toSet().length, all.length);
  });

  test('/ を含む shadcn/ui は分けずに 1 つのタグにする', () {
    expect(TechTagCatalog.parse('Next.js, shadcn/ui, Tailwind'), [
      'Next.js',
      'shadcn/ui',
      'Tailwind',
    ]);
    expect(TechTagCatalog.parse('Go/Docker'), ['Go', 'Docker']);
    expect(
      TechTagCatalog.parse(
        TechTagCatalog.join(['shadcn/ui', 'Unreal Engine', 'GitHub Actions']),
      ),
      ['shadcn/ui', 'Unreal Engine', 'GitHub Actions'],
    );
  });

  test('追加したタグを検索できる', () {
    expect(TechTagCatalog.search('jet'), ['Jetpack Compose']);
    expect(TechTagCatalog.search('torch'), ['PyTorch']);
    expect(TechTagCatalog.categoryOf('Unity'), 'ゲーム / 3D');
  });
}
