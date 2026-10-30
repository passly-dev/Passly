import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/features/ble/domain/power_mode_notifier.dart';
import 'package:passly/features/home/presentation/widgets/pocket_mode_button.dart';

void main() {
  testWidgets('tapping toggles pocket mode and shows the state briefly', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: PocketModeButton())),
        ),
      ),
    );

    // テスト環境は Android 扱いなので最初は OFF
    expect(container.read(powerModeProvider), PowerMode.normal);

    await tester.tap(find.byIcon(Icons.backpack_outlined));
    await tester.pump();
    expect(container.read(powerModeProvider), PowerMode.pocket);
    expect(find.text('ポケットモード ON'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.backpack_outlined));
    await tester.pump();
    expect(container.read(powerModeProvider), PowerMode.normal);
    expect(find.text('ポケットモード OFF'), findsOneWidget);

    // 表示は 2 秒ほどで消える（タイマーを流しきる）
    await tester.pump(const Duration(seconds: 3));
  });
}
