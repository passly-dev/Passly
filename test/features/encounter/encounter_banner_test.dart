import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/features/encounter/presentation/widgets/encounter_banner.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool visible,
  VoidCallback? onOpen,
  VoidCallback? onDismiss,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 60,
              left: 15,
              right: 15,
              child: EncounterBanner(
                visible: visible,
                title: '新しく2人とすれ違いました',
                body: 'いずみさんと共通のタグ: Flutter・Go',
                people: const [
                  (iconUrl: '', name: 'いずみ'),
                  (iconUrl: '', name: 'あおい'),
                ],
                onOpen: onOpen ?? () {},
                onDismiss: onDismiss ?? () {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('出すときは画面の上から下りてくる', (tester) async {
    await _pump(tester, visible: false);
    final banner = find.byKey(const Key('encounter_banner'));
    // 隠れているときは画面の外（上）にいる
    expect(tester.getBottomLeft(banner).dy, lessThan(0));

    await _pump(tester, visible: true);
    await tester.pump(const Duration(milliseconds: 120));
    final midTop = tester.getTopLeft(banner).dy;
    expect(midTop, lessThan(60));

    await tester.pumpAndSettle();
    expect(tester.getTopLeft(banner).dy, 60);
    expect(find.text('新しく2人とすれ違いました'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('押すと結果画面を開き，上にスワイプすると閉じる', (tester) async {
    var opened = 0;
    var dismissed = 0;
    await _pump(
      tester,
      visible: true,
      onOpen: () => opened++,
      onDismiss: () => dismissed++,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('見る'));
    expect(opened, 1);

    await tester.fling(
      find.byKey(const Key('encounter_banner')),
      const Offset(0, -80),
      800,
    );
    await tester.pumpAndSettle();
    expect(dismissed, 1);
  });

  testWidgets('隠れているときは押せない', (tester) async {
    var opened = 0;
    await _pump(tester, visible: false, onOpen: () => opened++);
    await tester.pumpAndSettle();
    await tester.tap(find.text('見る'), warnIfMissed: false);
    expect(opened, 0);
  });
}
