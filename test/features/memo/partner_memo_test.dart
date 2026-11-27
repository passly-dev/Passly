import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:passly/common/widgets/common_tag_person_card.dart';
import 'package:passly/features/memo/domain/partner_memo.dart';
import 'package:passly/features/memo/presentation/partner_memo_corner.dart';
import 'package:passly/features/memo/presentation/sticky_note.dart';

PartnerMemo _memo({String title = 'メガネの面白い人', String body = 'Flutter の神'}) =>
    PartnerMemo(
      title: title,
      body: body,
      colorIndex: 2,
      updatedAt: DateTime(2026, 3, 11),
    );

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('付箋を貼ると端末に保存され，作り直しても読める．はがすと消える', () async {
    final c1 = ProviderContainer();
    await c1.read(partnerMemosProvider.future);
    await c1.read(partnerMemosProvider.notifier).save('u1', _memo());
    expect(c1.read(partnerMemoProvider('u1'))?.title, 'メガネの面白い人');
    c1.dispose();

    final c2 = ProviderContainer();
    final loaded = await c2.read(partnerMemosProvider.future);
    expect(loaded['u1']?.body, 'Flutter の神');
    expect(loaded['u1']?.colorIndex, 2);

    await c2.read(partnerMemosProvider.notifier).remove('u1');
    expect(c2.read(partnerMemoProvider('u1')), isNull);
    c2.dispose();

    final c3 = ProviderContainer();
    expect(await c3.read(partnerMemosProvider.future), isEmpty);
    c3.dispose();
  });

  test('中身が空の付箋は貼らない', () async {
    final c = ProviderContainer();
    await c.read(partnerMemosProvider.future);
    await c
        .read(partnerMemosProvider.notifier)
        .save('u1', _memo(title: ' ', body: ''));
    expect(c.read(partnerMemoProvider('u1')), isNull);
    c.dispose();
  });

  test('一覧の付箋は見出し，なければ本文の1行目を出す', () {
    expect(_memo().headline, 'メガネの面白い人');
    expect(_memo(title: '', body: 'Swift の人\n次はiOS').headline, 'Swift の人');
  });

  testWidgets('束を押して書き，貼る → 付箋が貼られる → はがすと束に戻る', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: PartnerMemoCorner(
                userId: 'u1',
                longDateLabel: '3月11日 SysHack2026',
                shortDateLabel: '3/11',
              ),
            ),
          ),
        ),
      ),
    );
    await _settle(tester);
    expect(find.byKey(const Key('memo_blank_pad')), findsOneWidget);

    await tester.tap(find.byKey(const Key('memo_blank_pad')));
    await _settle(tester);
    expect(find.text('この付箋は自分にしか見えません'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('memo_title_field')),
      'メガネの面白い人',
    );
    await tester.tap(find.text('＋ また話したい'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('memo_color_3')));
    await tester.tap(find.byKey(const Key('memo_paste')));
    await _settle(tester);

    expect(find.byKey(const Key('memo_stuck_note')), findsOneWidget);
    expect(find.text('メガネの面白い人'), findsOneWidget);
    expect(find.text('また話したい'), findsOneWidget);
    expect(find.text('3/11'), findsOneWidget);

    await tester.tap(find.byKey(const Key('memo_stuck_note')));
    await _settle(tester);
    await tester.tap(find.byKey(const Key('memo_peel')));
    await _settle(tester);
    expect(find.byKey(const Key('memo_blank_pad')), findsOneWidget);
  });

  testWidgets('60字をこえて書けない', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: PartnerMemoCorner(
                userId: 'u1',
                longDateLabel: '',
                shortDateLabel: '',
              ),
            ),
          ),
        ),
      ),
    );
    await _settle(tester);
    await tester.tap(find.byKey(const Key('memo_blank_pad')));
    await _settle(tester);
    await tester.enterText(find.byKey(const Key('memo_title_field')), 'あ' * 20);
    await tester.enterText(find.byKey(const Key('memo_body_field')), 'い' * 80);
    await tester.pump();
    expect(find.text('60 / 60'), findsOneWidget);
  });

  testWidgets('すれ違い一覧のカードに小さい付箋が出る', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommonTagPersonCard(
            name: 'シスにゃん',
            iconUrl: '',
            commonTags: const [],
            memo: _memo(),
          ),
        ),
      ),
    );
    expect(find.byType(MiniMemoNote), findsOneWidget);
    expect(find.text('メガネの面白い人'), findsOneWidget);
  });
}
