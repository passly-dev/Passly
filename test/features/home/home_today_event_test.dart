import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/features/auth/domain/auth_notifier.dart';
import 'package:passly/features/encounter/domain/encounter_model.dart';
import 'package:passly/features/encounter/domain/encounter_notifier.dart';
import 'package:passly/features/event/domain/event_album_notifier.dart';
import 'package:passly/features/event/domain/today_event.dart';
import 'package:passly/features/home/data/home_repository.dart';
import 'package:passly/features/home/presentation/home_screen.dart';
import 'package:passly/features/user/domain/user_model.dart';

class _FakeAuth extends AuthNotifier {
  @override
  FutureOr<UserModel?> build() =>
      const UserModel(id: 'me', name: 'えいでん', iconUrl: 'https://x/me.png');
}

class _FakeEncounters extends EncounterNotifier {
  _FakeEncounters(this.count);
  final int count;

  @override
  FutureOr<List<EncounterModel>> build() => [
    for (var i = 0; i < count; i++)
      EncounterModel(
        id: 'e$i',
        encounteredUser: EncounteredUserInfo(id: 'u$i', name: 'u$i'),
        encounteredAt: DateTime(2026, 11, 28, 14, i),
      ),
  ];
}

class _EmptyHomeRepository implements HomeRepository {
  @override
  Future<Map<String, dynamic>> fetchHomeData(String userId) async => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _event = EventSummary(
  id: 1,
  name: 'MEET STAGE 技術者交流会',
  startAt: DateTime(2026, 11, 28, 12),
  location: '',
  imageUrl: '',
);

Future<void> _pump(
  WidgetTester tester, {
  required EventSummary? event,
  required int pending,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(_FakeAuth.new),
        encounterNotifierProvider.overrideWith(() => _FakeEncounters(pending)),
        homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
        todayEventProvider.overrideWithValue(event),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('イベントがない日は帯を出さない', (tester) async {
    await _pump(tester, event: null, pending: 0);
    expect(find.byKey(const Key('today_event_strip')), findsNothing);
  });

  testWidgets('イベント中，1〜4 人のうちは帯の表示を変えない', (tester) async {
    await _pump(tester, event: _event, pending: 4);
    expect(find.byKey(const Key('today_event_strip')), findsOneWidget);
    expect(find.text('MEET STAGE 技術者交流会'), findsOneWidget);
    expect(find.textContaining('新しく'), findsNothing);
  });

  testWidgets('イベント中，5 人たまったら帯が「新しく5人」に変わる', (tester) async {
    await _pump(tester, event: _event, pending: 5);
    expect(find.byKey(const Key('today_event_strip_new')), findsOneWidget);
    expect(find.text('新しく5人とすれ違いました'), findsOneWidget);
  });
}
