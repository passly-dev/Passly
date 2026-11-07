import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passly/common/router/app_router.dart';
import 'package:passly/features/auth/domain/auth_notifier.dart';
import 'package:passly/features/user/domain/user_model.dart';

class _FakeAuth extends AuthNotifier {
  @override
  FutureOr<UserModel?> build() => const UserModel(id: 'me', name: '前');

  void set(AsyncValue<UserModel?> value) => state = value;
}

void main() {
  test('同じユーザーの情報更新ではルーターに通知しない', () async {
    final container = ProviderContainer(
      overrides: [authNotifierProvider.overrideWith(_FakeAuth.new)],
    );
    addTearDown(container.dispose);
    await container.read(authNotifierProvider.future);

    final notifier = RouterNotifier(_RefHolder.of(container));
    var count = 0;
    notifier.addListener(() => count++);
    final auth = container.read(authNotifierProvider.notifier) as _FakeAuth;

    auth.set(const AsyncValue.data(UserModel(id: 'me', name: '後')));
    expect(count, 0);

    auth.set(const AsyncValue.data(null));
    expect(count, 1);
  });

  testWidgets('保存後に pop するとマイページに戻る', (tester) async {
    late GoRouter router;
    final routerProvider = Provider<GoRouter>((ref) {
      final notifier = RouterNotifier(ref);
      return GoRouter(
        initialLocation: '/mypage',
        refreshListenable: notifier,
        routes: [
          GoRoute(path: '/mypage', builder: (_, _) => const Text('マイページ')),
          GoRoute(path: '/mypage/edit', builder: (_, _) => const Text('編集')),
        ],
      );
    });
    final container = ProviderContainer(
      overrides: [authNotifierProvider.overrideWith(_FakeAuth.new)],
    );
    addTearDown(container.dispose);
    await container.read(authNotifierProvider.future);
    router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.push('/mypage/edit');
    await tester.pumpAndSettle();
    expect(find.text('編集'), findsOneWidget);

    // 編集画面の保存と同じ順番: ユーザー情報を更新してすぐ pop する．
    (container.read(authNotifierProvider.notifier) as _FakeAuth).set(
      const AsyncValue.data(UserModel(id: 'me', name: '後')),
    );
    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('マイページ'), findsOneWidget);
    expect(find.text('編集'), findsNothing);
  });
}

/// テストで RouterNotifier に Ref を渡すためのプロバイダー．
final _refProvider = Provider<Ref>((ref) => ref);

class _RefHolder {
  static Ref of(ProviderContainer c) => c.read(_refProvider);
}
