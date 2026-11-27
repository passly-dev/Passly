import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/features/ble/domain/power_mode_notifier.dart';
import 'package:passly/features/home/presentation/widgets/pocket_pull_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _key = GlobalKey<PocketPullNavState>();

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  bool hint = false,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: PocketPullNav(
              key: _key,
              showFirstHint: hint,
              child: Container(height: 64, color: Colors.white),
            ),
          ),
        ),
      ),
    ),
  );
  return container;
}

Future<void> _pull(WidgetTester tester, double dy) async {
  await tester.drag(find.byKey(const Key('pocket_pull_nav')), Offset(0, dy));
  // 出している間はスマホがゆらゆら動き続けるので，時間を決めて進める
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('iPhone では最初から ON で，つまみの横に緑の点が出る', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final c = await _pump(tester);
    expect(c.read(powerModeProvider), PowerMode.pocket);
    final dot = tester.widget<AnimatedScale>(
      find.ancestor(
        of: find.byKey(const Key('pocket_on_dot')),
        matching: find.byType(AnimatedScale),
      ),
    );
    expect(dot.scale, 1);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('上に引き切るとポケットが出て，スイッチで切りかえるとしまわれる', (tester) async {
    final c = await _pump(tester);
    expect(c.read(powerModeProvider), PowerMode.normal);

    await _pull(tester, -200);
    expect(_key.currentState!.progress, closeTo(1, 0.01));

    await tester.tap(find.byKey(const Key('pocket_switch')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(c.read(powerModeProvider), PowerMode.pocket);
    expect(_key.currentState!.progress, closeTo(0, 0.01));
  });

  testWidgets('少しだけ引いてはなすと，ポケットは戻る', (tester) async {
    await _pump(tester);
    await _pull(tester, -30);
    expect(_key.currentState!.progress, closeTo(0, 0.01));
  });

  testWidgets('はじめての案内は1回だけ出る', (tester) async {
    await _pump(tester, hint: true);
    await tester.pump(const Duration(milliseconds: 900));
    final shown = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byKey(const Key('pocket_pull_hint')),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(shown.opacity, 1);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 5));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(PocketPullNav.hintShownKey), isTrue);
  });
}
