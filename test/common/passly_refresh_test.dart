import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/common/widgets/passly_refresh.dart';

Future<(int, int)> _pull(
  WidgetTester tester,
  PasslyRefreshStyle style,
  double distance,
) async {
  var refreshed = 0;
  var done = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PasslyRefresh(
          style: style,
          me: (iconUrl: '', name: 'えいでん'),
          other: (iconUrl: '', name: 'ゆい'),
          stickerTags: const ['Flutter', 'Dart', 'Figma'],
          onRefresh: () async => refreshed++,
          onDone: () => done++,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [for (var i = 0; i < 30; i++) Text('行$i')],
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
  for (final style in PasslyRefreshStyle.values) {
    testWidgets('$style: 引っぱり切ってはなすと更新し，終わったら知らせる', (tester) async {
      expect(await _pull(tester, style, 400), (1, 1));
    });

    testWidgets('$style: 少しだけ引っぱったときは更新しない', (tester) async {
      expect(await _pull(tester, style, 60), (0, 0));
    });
  }
}
