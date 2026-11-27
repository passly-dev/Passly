import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/common/widgets/passly_refresh.dart';
import 'package:passly/common/widgets/tag_sticker.dart';

Future<(int, int)> _pull(
  WidgetTester tester,
  double distance, {
  List<String> tags = const ['Flutter', 'Dart', 'Figma'],
}) async {
  var refreshed = 0;
  var done = 0;
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: PasslyRefresh(
            stickerTags: tags,
            onRefresh: () async => refreshed++,
            onDone: () => done++,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [for (var i = 0; i < 30; i++) Text('行$i')],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.drag(find.text('行0'), Offset(0, distance));
  await tester.pump();
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
  return (refreshed, done);
}

void main() {
  testWidgets('引っぱり切ってはなすと更新し，終わったら知らせる', (tester) async {
    expect(await _pull(tester, 400), (1, 1));
  });

  testWidgets('少しだけ引っぱったときは更新しない', (tester) async {
    expect(await _pull(tester, 60), (0, 0));
  });

  testWidgets('引っぱり切ると3枚のステッカーと「はなすと更新」が出る', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: PasslyRefresh(
              stickerTags: const ['Swift'],
              onRefresh: () async {},
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [Text('行0')],
              ),
            ),
          ),
        ),
      ),
    );
    final g = await tester.startGesture(tester.getCenter(find.text('行0')));
    for (var i = 0; i < 30; i++) {
      await g.moveBy(const Offset(0, 12));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('はなすと更新'), findsOneWidget);
    // タグが1つの人は，残りを決まったタグで補う
    expect(find.byType(TagSticker), findsNWidgets(3));
    await g.up();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  });
}
