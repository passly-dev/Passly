import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:passly/features/event/domain/event_album_notifier.dart';

/// 今日参加しているイベント。なければ null。
///
/// イベント画面と同じデータ（[eventAlbumProvider]）を使う。
final todayEventProvider = Provider<EventSummary?>(
  (ref) => ref.watch(eventAlbumProvider).asData?.value.today,
);

/// イベント中は，この人数ずつまとめてすれ違いを知らせる。
///
/// 会場では次々にすれ違うため，1 人ずつ知らせると画面がにぎやかになりすぎる。
const int eventEncounterBatchSize = 5;

/// 未確認のすれ違いが [previous] 人から [next] 人に増えたとき，
/// イベント中のまとめた知らせを出すか（5 人，10 人…と区切りをこえたとき）。
bool crossedEncounterBatch(int previous, int next) =>
    next >= eventEncounterBatchSize &&
    next ~/ eventEncounterBatchSize > previous ~/ eventEncounterBatchSize;

/// イベント中に，未確認のすれ違いをまとめて知らせる人数に達しているか。
bool hasEncounterBatch(int pendingCount) =>
    pendingCount >= eventEncounterBatchSize;

/// イベントの詳細（その日にすれ違った人の一覧）の場所。
String eventDetailLocation(EventSummary e) => e.id != null
    ? '/events/${e.id}'
    : '/encounters/day/${eventDateParam(e.day)}';
