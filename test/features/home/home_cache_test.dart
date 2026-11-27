import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:passly/features/auth/domain/auth_notifier.dart';
import 'package:passly/features/home/data/home_repository.dart';
import 'package:passly/features/home/domain/home_notifier.dart';
import 'package:passly/features/user/domain/user_model.dart';

class _SlowHomeRepository implements HomeRepository {
  final completer = Completer<Map<String, dynamic>>();
  int fetches = 0;

  @override
  Future<Map<String, dynamic>?> readCachedHomeData(String userId) async => {
    'total_encounters': 3,
  };

  @override
  Future<Map<String, dynamic>> fetchHomeData(String userId) {
    fetches++;
    return completer.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Me extends AuthNotifier {
  @override
  Future<UserModel?> build() async => const UserModel(id: 'me', name: 'me');
}

void main() {
  test('前回のデータをすぐ出し，サーバーの結果が来たら入れかえる', () async {
    final repo = _SlowHomeRepository();
    final container = ProviderContainer(
      overrides: [
        homeRepositoryProvider.overrideWithValue(repo),
        authNotifierProvider.overrideWith(_Me.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authNotifierProvider.future);

    final first = await container.read(homeNotifierProvider.future);
    expect(first.totalEncounters, 3);

    await Future<void>.delayed(Duration.zero);
    // ホームの取り直し（すれ違いの未確認の取得も同じ通信を使う）
    expect(repo.fetches, greaterThanOrEqualTo(1));

    repo.completer.complete({'total_encounters': 5});
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(homeNotifierProvider).value?.totalEncounters, 5);
  });
}
