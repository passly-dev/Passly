import 'package:flutter_test/flutter_test.dart';
import 'package:passly/features/event/domain/event_album_notifier.dart';
import 'package:passly/features/event/domain/today_event.dart';

void main() {
  group('イベント中は 5 人ずつまとめて知らせる', () {
    test('1〜4 人のうちは知らせない', () {
      expect(crossedEncounterBatch(0, 1), isFalse);
      expect(crossedEncounterBatch(1, 2), isFalse);
      expect(crossedEncounterBatch(3, 4), isFalse);
      expect(hasEncounterBatch(4), isFalse);
    });

    test('5 人になったら知らせる', () {
      expect(crossedEncounterBatch(4, 5), isTrue);
      expect(crossedEncounterBatch(2, 6), isTrue);
      expect(hasEncounterBatch(5), isTrue);
    });

    test('5 人をこえてからは次の 10 人まで知らせない', () {
      expect(crossedEncounterBatch(5, 6), isFalse);
      expect(crossedEncounterBatch(8, 9), isFalse);
      expect(crossedEncounterBatch(9, 10), isTrue);
    });

    test('減ったとき（確認したとき）は知らせない', () {
      expect(crossedEncounterBatch(6, 0), isFalse);
    });
  });

  test('イベント詳細の場所は id があれば /events/:id，なければ日付', () {
    final withId = EventSummary(
      id: 42,
      name: 'MEET STAGE',
      startAt: DateTime(2026, 11, 28, 12),
      location: '',
      imageUrl: '',
    );
    final noId = EventSummary(
      id: null,
      name: 'MEET STAGE',
      startAt: DateTime(2026, 11, 28, 12),
      location: '',
      imageUrl: '',
    );
    expect(eventDetailLocation(withId), '/events/42');
    expect(eventDetailLocation(noId), '/encounters/day/2026-11-28');
  });
}
