// 広場画面とプロフィール画面のダミーデータ

// 友達一覧（10人分）
final List<Map<String, dynamic>> dummyFriends = List.generate(
  10,
  (i) => {
    'id': 'user_${i + 1}',
    'name': 'User ${i + 1}',
    'comment': 'よろしくお願いします！',
    'iconUrl': '',
  },
);

// イベント一覧（7件分）- 詳細情報を含む
final List<Map<String, dynamic>> dummyEvents = [
  {
    'id': 'event_1',
    'name': 'SysHack2026',
    'date': '2026/03/03',
    'location': '東京都渋谷区 渋谷ヒカリエ',
    'count': 15,
    'participants': ['user_1', 'user_2', 'user_3', 'user_5', 'user_8'],
  },
  {
    'id': 'event_2',
    'name': 'Matsuriba MAX',
    'date': '2026/03/08',
    'location': '大阪府大阪市 グランフロント大阪',
    'count': 28,
    'participants': [
      'user_2',
      'user_4',
      'user_6',
      'user_7',
      'user_9',
      'user_10',
    ],
  },
  {
    'id': 'event_3',
    'name': 'Flutter勉強会',
    'date': '2026/03/15',
    'location': '東京都港区 六本木ヒルズ',
    'count': 12,
    'participants': ['user_1', 'user_3', 'user_5'],
  },
  {
    'id': 'event_4',
    'name': 'Matsuriba MAX',
    'date': '2026/03/22',
    'location': '福岡県福岡市 アクロス福岡',
    'count': 20,
    'participants': ['user_2', 'user_4', 'user_8', 'user_10'],
  },
  {
    'id': 'event_5',
    'name': 'React Meetup Tokyo',
    'date': '2026/03/25',
    'location': '東京都千代田区 秋葉原UDX',
    'count': 8,
    'participants': ['user_1', 'user_6'],
  },
  {
    'id': 'event_6',
    'name': 'Tech Conference 2026',
    'date': '2026/04/01',
    'location': '神奈川県横浜市 パシフィコ横浜',
    'count': 45,
    'participants': [
      'user_1',
      'user_2',
      'user_3',
      'user_4',
      'user_5',
      'user_6',
      'user_7',
    ],
  },
  {
    'id': 'event_7',
    'name': 'AI/ML Summit',
    'date': '2026/04/10',
    'location': '東京都新宿区 新宿NSビル',
    'count': 32,
    'participants': ['user_3', 'user_5', 'user_7', 'user_9'],
  },
];

// プロフィール（ダミー1人分）
final Map<String, String> dummyProfile = {
  'name': 'User name',
  'comment': 'よろしくお願いします！',
  'techStack': 'Flutter, React, Firebase',
  'twitter': '@flutter_dev_mock',
  'github': 'github.com/mockuser',
  'portfolio': 'my-portfolio.dev',
  'organization': 'Flutter Japan User Group',
};

// ランダム表示用の友達リスト（シャッフル用）
List<Map<String, dynamic>> getRandomFriends() {
  final shuffled = List<Map<String, dynamic>>.from(dummyFriends);
  shuffled.shuffle();
  return shuffled.take(7).toList();
}
