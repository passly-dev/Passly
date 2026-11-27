import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passly/demo/demo_api.dart';
import 'package:passly/demo/demo_people.dart';

Map<String, dynamic> _home() =>
    DemoApi.instance.handle(
          RequestOptions(path: '/users/$demoMeId/home', method: 'GET'),
        )
        as Map<String, dynamic>;

void main() {
  test('デモでアプリを開いたまますれ違うと，未確認と今日のすれ違いに 1 人ずつ増える', () {
    final demo = DemoApi.instance;
    // 起動時のすれ違いは確認済みにしておく
    demo.handle(
      RequestOptions(
        path: '/users/$demoMeId/encounters/confirm',
        method: 'POST',
      ),
    );
    expect(_home()['unconfirmed'], isEmpty);
    final before = (_home()['recent_encounters'] as List).length;
    final queue = demo.remainingArrivals;
    expect(queue, demoPeople.length - demoTodayPeople.length);

    for (var i = 1; i <= 5; i++) {
      expect(demo.arriveOne(), isTrue);
      expect(_home()['unconfirmed'], hasLength(i));
    }
    final recent = _home()['recent_encounters'] as List;
    expect(recent, hasLength(before + 5));
    // 新しくすれ違った人は今日のイベントで，いちばん新しい
    expect((recent.first as Map)['event_name'], 'Passly 体験会');
    final ids = {
      for (final u in _home()['unconfirmed'] as List) (u as Map)['id'],
    };
    expect(ids, hasLength(5));
    expect(ids.intersection(demoTodayPeople.toSet()), isEmpty);

    // 残りの人を使い切ったら，それ以上は増えない
    while (demo.remainingArrivals > 0) {
      demo.arriveOne();
    }
    expect(demo.arriveOne(), isFalse);
  });
}
