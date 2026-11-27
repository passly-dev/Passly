import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/features/home/presentation/widgets/today_event_strip.dart';

Future<void> _pump(WidgetTester tester, {int? newCount, VoidCallback? onTap}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TodayEventStrip(
            eventName: 'MEET STAGE 技術者交流会',
            todayCount: 12,
            people: const [
              (iconUrl: '', name: 'いずみ'),
              (iconUrl: '', name: 'あおい'),
              (iconUrl: '', name: 'そら'),
            ],
            newCount: newCount,
            onTap: onTap ?? () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('ふだんはイベント名と今日の人数', (tester) async {
    var tapped = 0;
    await _pump(tester, onTap: () => tapped++);
    expect(find.text('参加中'), findsOneWidget);
    expect(find.text('MEET STAGE 技術者交流会'), findsOneWidget);
    expect(find.text('12人 ›'), findsOneWidget);
    await tester.tap(find.byKey(const Key('today_event_strip')));
    expect(tapped, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('まとまった人数になると同じ形のまま表示が変わる', (tester) async {
    await _pump(tester);
    final normalSize = tester.getSize(
      find.byKey(const Key('today_event_strip')),
    );

    await _pump(tester, newCount: 5);
    await tester.pumpAndSettle();
    expect(find.text('新しく5人とすれ違いました'), findsOneWidget);
    expect(find.text('見る ›'), findsOneWidget);
    expect(find.text('MEET STAGE 技術者交流会'), findsNothing);
    // 大きさは変わらない（下の内容が押し下げられない）
    expect(
      tester.getSize(find.byKey(const Key('today_event_strip_new'))),
      normalSize,
    );
  });

  testWidgets('小さい画面でも長いイベント名ではみ出さない', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodayEventStrip(
            eventName: 'とても長いイベント名のテストのための技術者交流会と懇親会 2026',
            todayCount: 128,
            people: const [
              (iconUrl: '', name: 'いずみ'),
              (iconUrl: '', name: 'あおい'),
              (iconUrl: '', name: 'そら'),
            ],
            onTap: () {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
