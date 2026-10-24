import 'package:syshack2026/features/event/domain/event_model.dart';
import 'package:syshack2026/features/event/data/event_repository.dart';

/// バックエンド未実装時に UI 開発を進めるためのモック実装。
///
/// eventId ごとに固定サンプルを返す。ネットワーク待ちの体感を出すため
/// わずかに遅延を入れている。
class EventRepositoryMock implements EventRepository {
  @override
  Future<EventModel> fetchEventDetail(int eventId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return EventModel(
      id: eventId,
      name: 'SysHack2026 交流会',
      startAt: DateTime.now().add(const Duration(days: 3)),
      endAt: DateTime.now().add(const Duration(days: 3, hours: 3)),
      location: '東京都渋谷区 サンプルホール',
      eventUrl: 'https://example.connpass.com/event/$eventId/',
      description:
          'エンジニア同士のカジュアルな交流イベントです。'
          'すれ違い機能を体験しながら、次のプロジェクトのきっかけを見つけましょう。',
      accepted: 42,
      waiting: 5,
      limit: 60,
      participants: [
        EventParticipant(
          userId: 'mock_user_1',
          name: 'Tanaka Ryo',
          iconUrl: '',
          oneWord: 'Flutter で個人開発してます',
          registeredAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        EventParticipant(
          userId: 'mock_user_2',
          name: 'Suzuki Ai',
          iconUrl: '',
          oneWord: 'Rust 勉強中',
          registeredAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        EventParticipant(
          userId: 'mock_user_3',
          name: 'Yamada Ken',
          iconUrl: '',
          oneWord: 'バックエンドが得意です',
          registeredAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }
}
