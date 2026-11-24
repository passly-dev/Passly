import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passly/features/auth/domain/auth_notifier.dart';
import 'package:passly/features/home/presentation/home_screen.dart';
import 'package:passly/features/mypage/presentation/profile_edit_screen.dart';
import 'package:passly/features/user/domain/user_model.dart';

class _FakeAuth extends AuthNotifier {
  final String iconUrl;
  _FakeAuth(this.iconUrl);

  @override
  FutureOr<UserModel?> build() =>
      UserModel(id: 'me', name: 'えいでん', iconUrl: iconUrl);
}

const _tip = '顔が分かる写真をアイコンにすると，すれ違った人が会場であなたを見つけやすくなります';
const _nameHelp = 'イベントの名札やconnpassで使っている名前にすると，会場で見つけてもらいやすくなります';

Future<void> _pumpEdit(WidgetTester tester, String iconUrl) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authNotifierProvider.overrideWith(() => _FakeAuth(iconUrl))],
      child: const MaterialApp(home: ProfileEditScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('アイコンがないときは，顔が分かる写真をすすめる', (tester) async {
    await _pumpEdit(tester, '');
    expect(tester.takeException(), isNull);
    expect(find.text(_tip), findsOneWidget);
    expect(find.text(_nameHelp), findsOneWidget);
  });

  testWidgets('アイコンがあるときは，写真のすすめを出さない', (tester) async {
    await _pumpEdit(tester, 'https://example.com/me.png');
    expect(find.text(_tip), findsNothing);
    expect(find.text(_nameHelp), findsOneWidget);
  });

  testWidgets('ホームの写真のすすめを押すとプロフィール編集を開く', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: IconPhotoBanner()),
        ),
        GoRoute(
          path: '/mypage/edit',
          builder: (_, _) => const Text('プロフィール編集'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('アイコンを顔写真にしよう'));
    await tester.pumpAndSettle();
    expect(find.text('プロフィール編集'), findsOneWidget);
  });
}
