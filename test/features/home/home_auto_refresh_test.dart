import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/features/auth/domain/auth_notifier.dart';
import 'package:passly/features/encounter/domain/encounter_model.dart';
import 'package:passly/features/encounter/domain/encounter_notifier.dart';
import 'package:passly/features/home/data/home_repository.dart';
import 'package:passly/features/home/domain/home_notifier.dart';
import 'package:passly/features/user/domain/user_model.dart';

class _FakeAuth extends AuthNotifier {
  @override
  FutureOr<UserModel?> build() => const UserModel(id: 'me', name: 'えいでん');
}

class _FakeEncounters extends EncounterNotifier {
  @override
  FutureOr<List<EncounterModel>> build() => const [];

  void add(String id) => state = AsyncValue.data([
    ...?state.value,
    EncounterModel(
      id: 'e_$id',
      encounteredUser: EncounteredUserInfo(id: id, name: id),
      encounteredAt: DateTime(2026, 11, 28, 14),
    ),
  ]);
}

/// 呼ばれた回数を数え，回数ぶんの人を recent_encounters に返す。
class _FakeHomeRepository implements HomeRepository {
  @override
  Future<Map<String, dynamic>?> readCachedHomeData(String userId) async => null;

  int calls = 0;

  @override
  Future<Map<String, dynamic>> fetchHomeData(String userId) async {
    calls++;
    return {
      'recent_encounters': [
        for (var i = 0; i < calls; i++)
          {'user_id': 'u$i', 'name': 'u$i', 'met_at': '2026-11-28T05:00:00Z'},
      ],
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('アプリを開いたまますれ違ったら，ホームの一覧を読み込み中にせず取り直す', () async {
    final repo = _FakeHomeRepository();
    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(_FakeAuth.new),
        encounterNotifierProvider.overrideWith(_FakeEncounters.new),
        homeRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final states = <AsyncValue<HomeState>>[];
    container.listen(homeNotifierProvider, (_, next) => states.add(next));
    await container.read(encounterNotifierProvider.future);
    await container.read(homeNotifierProvider.future);
    expect(repo.calls, 1);
    states.clear();

    (container.read(encounterNotifierProvider.notifier) as _FakeEncounters).add(
      'u9',
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(repo.calls, 2);
    expect(states.where((s) => s.isLoading && !s.hasValue), isEmpty);
    expect(
      container.read(homeNotifierProvider).value!.recentEncounters,
      hasLength(2),
    );
  });
}
