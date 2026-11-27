import 'package:flutter_test/flutter_test.dart';

import 'package:passly/features/memo/domain/partner_memo.dart';
import 'package:passly/features/plaza/presentation/friend_search_screen.dart';
import 'package:passly/features/user/domain/common_tags.dart';

SearchPerson _p(String id, String name, String tags) => SearchPerson(
  userId: id,
  name: name,
  iconUrl: '',
  eventName: '',
  techStack: tags,
);

void main() {
  final people = [
    _p('1', 'しすけん', 'Flutter,Dart,Go'),
    _p('2', 'さくら', 'Swift,Figma'),
    _p('3', 'Haruto', 'React,TypeScript'),
  ];
  List<String> tagsOf(SearchPerson p) => parseTechTags(p.techStack);

  test('名前の一部で見つかる（ひらがな・カタカナ，大文字小文字を区別しない）', () {
    expect(
      filterSearchPeople(people, 'すけ', tagsOf: tagsOf).map((p) => p.userId),
      ['1'],
    );
    expect(
      filterSearchPeople(people, 'サクラ', tagsOf: tagsOf).map((p) => p.userId),
      ['2'],
    );
    expect(
      filterSearchPeople(people, 'haru', tagsOf: tagsOf).map((p) => p.userId),
      ['3'],
    );
  });

  test('技術タグで見つかる．複数語は全部に当てはまる人', () {
    expect(
      filterSearchPeople(
        people,
        'flutter',
        tagsOf: tagsOf,
      ).map((p) => p.userId),
      ['1'],
    );
    expect(
      filterSearchPeople(
        people,
        'figma swift',
        tagsOf: tagsOf,
      ).map((p) => p.userId),
      ['2'],
    );
    expect(filterSearchPeople(people, 'figma go', tagsOf: tagsOf), isEmpty);
  });

  test('自分の付箋メモの言葉でも見つかる', () {
    final memo = PartnerMemo(
      title: 'メガネの面白い人',
      body: '',
      colorIndex: 0,
      updatedAt: DateTime(2026),
    );
    expect(
      filterSearchPeople(
        people,
        'めがね',
        tagsOf: tagsOf,
        memoOf: (p) => p.userId == '3' ? memo : null,
      ).map((p) => p.userId),
      ['3'],
    );
  });

  test('空なら全員', () {
    expect(filterSearchPeople(people, '  ', tagsOf: tagsOf).length, 3);
  });
}
