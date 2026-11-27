import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/core/config/feature_flags.dart';
import 'package:passly/common/widgets/passly_header.dart';
import 'package:passly/demo/demo_api.dart';
import 'package:passly/demo/demo_people.dart';
import 'package:passly/features/home/presentation/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// デモモードのときだけ動く（flutter test --dart-define=DEMO_MODE=true）。
void main() {
  testWidgets('デモでヘッダーを長押しすると，1人ずつすれ違って5人で帯が変わる', (tester) async {
    if (!FeatureFlags.demoMode) return;
    FlutterSecureStorage.setMockInitialValues({});
    DemoApi.instance.handle(
      RequestOptions(
        path: '/users/$demoMeId/encounters/confirm',
        method: 'POST',
      ),
    );
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('today_event_strip')), findsOneWidget);
    await tester.longPress(find.byType(PasslyHeader));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('today_event_strip_new')), findsNothing);
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('新しく5人とすれ違いました'), findsOneWidget);
  });
}
