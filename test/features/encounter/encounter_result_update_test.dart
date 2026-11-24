import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/common/widgets/encounter_loading_skeleton.dart';
import 'package:passly/features/auth/domain/auth_notifier.dart';
import 'package:passly/features/encounter/domain/encounter_model.dart';
import 'package:passly/features/encounter/domain/encounter_notifier.dart';
import 'package:passly/features/encounter/presentation/encounter_result_screen.dart';
import 'package:passly/features/user/domain/user_model.dart';

class _FakeAuth extends AuthNotifier {
  @override
  FutureOr<UserModel?> build() =>
      const UserModel(id: 'me', name: 'えいでん', techStack: 'Flutter');
}

EncounterModel _person(String id, String name) => EncounterModel(
  id: 'e_$id',
  encounteredUser: EncounteredUserInfo(id: id, name: name, techStack: 'Go'),
  eventName: 'SysHack2026',
  encounteredAt: DateTime(2026, 11, 8, 14),
);

/// 見ている間に新しくすれ違ったときの一覧の更新をまねる。
class _FakeEncounters extends EncounterNotifier {
  @override
  FutureOr<List<EncounterModel>> build() => [
    _person('u1', 'あおい'),
    _person('u2', 'いずみ'),
  ];

  void replace(List<EncounterModel> list) => state = AsyncValue.data(list);
}

void main() {
  testWidgets('新しくすれ違っても見ている人のまま表示を続ける', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(_FakeAuth.new),
        encounterNotifierProvider.overrideWith(_FakeEncounters.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: EncounterResultScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('あおい'), findsWidgets);
    await tester.tap(find.textContaining('次の人へ'));
    await tester.pumpAndSettle();
    expect(find.textContaining('いずみ'), findsWidgets);

    // サーバーが新しい人を先頭にして返しても，見ている人は変わらない
    (container.read(encounterNotifierProvider.notifier) as _FakeEncounters)
        .replace([
          _person('u3', 'うみ'),
          _person('u1', 'あおい'),
          _person('u2', 'いずみ'),
        ]);
    await tester.pump();

    expect(find.byType(EncounterLoadingSkeleton), findsNothing);
    expect(find.textContaining('いずみ'), findsWidgets);
    expect(find.textContaining('うみ'), findsNothing);

    // 新しい人は後ろに足されて，次に見られる
    expect(find.textContaining('次の人へ　3 / 3'), findsOneWidget);
    await tester.tap(find.textContaining('次の人へ'));
    await tester.pumpAndSettle();
    expect(find.textContaining('うみ'), findsWidgets);
  });
}
