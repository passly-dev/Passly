// ホーム画面で使用するダミーデータ
// バックエンド連携時にはProviderから取得する形に置き換える

/// 広場の人数
const int dummyPlazaCount = 58;

/// 今日のすれ違い回数
const int dummyTodayCount = 1;

/// 1日のすれ違い上限
const int dummyDailyLimit = 5;

/// クエスト名
const String dummyQuestName = 'はじめてのすれ違い';

/// クエスト進捗（0.0〜1.0）
const double dummyQuestProgress = 1.0;

/// みんなの一言（ダミー）
final List<Map<String, String>> dummyComments = [
  {'name': 'Tanaka', 'comment': 'よろしくお願いします！'},
  {'name': 'Suzuki', 'comment': 'Flutterが好きです🎯'},
  {'name': 'Yamada', 'comment': 'ハッカソン楽しい！'},
];
