/// デモ動画用のイベント。
///
/// えいでんが connpass（https://connpass.com/user/akitsugu/）で参加した
/// イベントを各イベントページで調べて写したもの。
/// 日時は UTC、参加人数・定員は connpass の一覧表示に合わせている。
/// 「Matsuriba Vol.15 ※再募集」は Vol.15 と同じ会なので 1 件にまとめた。
class DemoEvent {
  final int id;
  final String name;
  final String group;
  final DateTime startAt;
  final DateTime endAt;
  final String place;
  final String address;
  final String url;
  final int accepted;
  final int limit;
  final String description;

  const DemoEvent({
    required this.id,
    required this.name,
    required this.group,
    required this.startAt,
    required this.endAt,
    required this.place,
    required this.address,
    required this.url,
    required this.accepted,
    required this.limit,
    required this.description,
  });

  /// 会場名と住所を 1 行にしたもの。
  String get location => '$place（$address）';
}

final List<DemoEvent> demoEvents = [
  DemoEvent(
    id: 374741,
    name: 'Matsuriba Vol.12',
    group: 'NxTEND',
    startAt: DateTime.utc(2025, 12, 4, 10),
    endAt: DateTime.utc(2025, 12, 4, 12, 30),
    place: '伊藤忠テクノソリューションズ 名古屋オフィス',
    address: '愛知県名古屋市中区栄4-1-1 中日ビル',
    url: 'https://nxtend.connpass.com/event/374741/',
    accepted: 41,
    limit: 80,
    description:
        '東海地方最大の学生エンジニアコミュニティ MatsuribaTech の定期交流会。'
        '加盟 11 団体と東海の学生エンジニアが集まり、LT と懇親会で交流します。',
  ),
  DemoEvent(
    id: 379505,
    name: '29Tech vol.1',
    group: 'NxTEND',
    startAt: DateTime.utc(2026, 1, 30, 10),
    endAt: DateTime.utc(2026, 1, 30, 12),
    place: '名古屋工業大学 18号館3階 NaSHシェアスペース',
    address: '愛知県名古屋市昭和区御器所町',
    url: 'https://nxtend.connpass.com/event/379505/',
    accepted: 24,
    limit: 25,
    description:
        '東海地方の 29 卒学生エンジニアがつながるコミュニティ 29Tech の第 1 回。'
        '同世代で学習や開発の話を共有する交流会です。',
  ),
  DemoEvent(
    id: 379341,
    name: '28卒,29卒学生あつまれ！『ニックトレイン』NAGOYA',
    group: 'TechTrain',
    startAt: DateTime.utc(2026, 2, 11, 7, 30),
    endAt: DateTime.utc(2026, 2, 11, 10),
    place: 'ディップ株式会社 名古屋オフィス',
    address: '愛知県名古屋市中区栄4-1-1 中日ビル 20階',
    url: 'https://techtrain.connpass.com/event/379341/',
    accepted: 29,
    limit: 34,
    description:
        '「2月から9月（ニク）」の過ごし方を考える 28・29 卒向けイベント。'
        '肉を食べながら仲間づくりとキャリアの作戦会議をします。',
  ),
  DemoEvent(
    id: 373212,
    name: 'MatsuribaMAX 2026',
    group: 'NxTEND',
    startAt: DateTime.utc(2026, 3, 8, 1),
    endAt: DateTime.utc(2026, 3, 8, 12),
    place: '名古屋市中小企業振興会館 第2ファッション展示場',
    address: '愛知県名古屋市千種区吹上2丁目6-3',
    url: 'https://nxtend.connpass.com/event/373212/',
    accepted: 113,
    limit: 182,
    description:
        '技術と想いが集う、熱量 MAX な祭り。MatsuribaTech 加盟団体が 1 年間の'
        '取り組みをセッションとブース展示で披露する、東海最大の学生エンジニア向けカンファレンス。',
  ),
  DemoEvent(
    id: 372782,
    name: 'SysHack 2026',
    group: 'システム工学研究会',
    startAt: DateTime.utc(2026, 3, 31, 1),
    endAt: DateTime.utc(2026, 3, 31, 11),
    place: '愛知工業大学 八草キャンパス',
    address: '愛知県豊田市八草町八千草1247',
    url: 'https://sysken.connpass.com/event/372782/',
    accepted: 99,
    limit: 105,
    description:
        '愛知工業大学システム工学研究会が主催する、学生エンジニアのための初心者歓迎ハッカソン。'
        '最初の一歩を踏み出す挑戦の場です。',
  ),
  DemoEvent(
    id: 390965,
    name: '【非公式】技育祭東海 後夜祭',
    group: 'C0de',
    startAt: DateTime.utc(2026, 4, 27, 9, 30),
    endAt: DateTime.utc(2026, 4, 27, 11, 30),
    place: '名古屋工業大学 5214講義室',
    address: '愛知県名古屋市昭和区御器所町',
    url: 'https://c0de.connpass.com/event/390965/',
    accepted: 30,
    limit: 50,
    description:
        '技育祭東海の翌日に開く、軽食つきの非公式な交流会。'
        '名古屋工業大学 C0de 主催、PKSHA Technology 協力。',
  ),
  DemoEvent(
    id: 391293,
    name: 'Matsuriba Vol.14',
    group: 'NxTEND',
    startAt: DateTime.utc(2026, 5, 15, 9),
    endAt: DateTime.utc(2026, 5, 15, 12),
    place: '伊藤忠テクノソリューションズ 名古屋オフィス（中日ビル 11F）',
    address: '愛知県名古屋市中区栄4-1-1',
    url: 'https://nxtend.connpass.com/event/391293/',
    accepted: 79,
    limit: 82,
    description:
        '名古屋の学生エンジニアが集結する Matsuriba の第 14 回。'
        'LT と懇親会で東海の学生エンジニア同士がつながります。',
  ),
  DemoEvent(
    id: 396090,
    name: '東海学生団体対抗運動会',
    group: '情技研',
    startAt: DateTime.utc(2026, 6, 28, 6),
    endAt: DateTime.utc(2026, 6, 28, 9, 30),
    place: '名城大学 天白キャンパス ライオンズアリーナ',
    address: '愛知県名古屋市天白区塩釜口1丁目501',
    url: 'https://jogiken.connpass.com/event/396090/',
    accepted: 14,
    limit: 50,
    description:
        '不健康なデスクの前から一旦離れてみませんか？ 学生エンジニア団体同士が'
        '技術力・チームワーク・体力を競い合う運動会です。',
  ),
  DemoEvent(
    id: 396200,
    name: 'Matsuriba Vol.15',
    group: 'NxTEND',
    startAt: DateTime.utc(2026, 7, 10, 9),
    endAt: DateTime.utc(2026, 7, 10, 11, 30),
    place: 'エイチームホールディングス',
    address: '愛知県名古屋市中村区名駅3丁目28-12 大名古屋ビルヂング 32F',
    url: 'https://nxtend.connpass.com/event/396200/',
    accepted: 18,
    limit: 65,
    description:
        '名古屋の学生エンジニアが集結する Matsuriba の第 15 回。'
        '大名古屋ビルヂングの会場で LT と懇親会を行います。',
  ),
  DemoEvent(
    id: 381453,
    name: '29Tech vol.2',
    group: 'NxTEND',
    startAt: DateTime.utc(2026, 7, 17, 10),
    endAt: DateTime.utc(2026, 7, 17, 11, 30),
    place: 'KS11名古屋会議室',
    address: '愛知県名古屋市中村区則武1丁目13-9',
    url: 'https://nxtend.connpass.com/event/381453/',
    accepted: 15,
    limit: 30,
    description:
        '29 卒の学生エンジニアがつながる 29Tech の第 2 回。'
        'エンジニアコミュニティが初めての人も気軽に参加できる交流会です。',
  ),
  DemoEvent(
    id: 397535,
    name: 'デザインシステム勉強会',
    group: 'ディップ株式会社',
    startAt: DateTime.utc(2026, 7, 31, 10),
    endAt: DateTime.utc(2026, 7, 31, 12, 45),
    place: 'dip 四谷オフィス',
    address: '東京都新宿区四谷1丁目6-1 YOTSUYA TOWER 21階',
    url: 'https://dip-dev.connpass.com/event/397535/',
    accepted: 66,
    limit: 80,
    description:
        'ディップ × MOSH によるデザインシステムの合同勉強会。'
        'ガイドラインや UI コンポーネントの運用を、エンジニアとデザイナーの視点から LT で共有します。',
  ),
  DemoEvent(
    id: 386955,
    name: 'STECH CONNECT TOKAI 2026',
    group: 'STECH',
    startAt: DateTime.utc(2026, 8, 1, 4),
    endAt: DateTime.utc(2026, 8, 1, 11),
    place: 'ディップ株式会社 名古屋オフィス',
    address: '愛知県名古屋市中区栄4-1-1 中日ビル 20階',
    url: 'https://careerselect-studygroup.connpass.com/event/386955/',
    accepted: 31,
    limit: 40,
    description:
        '学生コミュニティ STECH による東海の学生エンジニア交流イベント。'
        'ボードゲームを通して学生や企業の人と話せます。',
  ),
  DemoEvent(
    id: 399497,
    name: 'HACK STAGE|STAGE3',
    group: 'LOCAL STAGE Project',
    startAt: DateTime.utc(2026, 9, 19, 4),
    endAt: DateTime.utc(2026, 9, 27, 10),
    place: 'ウイングアーク１ｓｔ株式会社（D.E. BASE）',
    address: 'オンライン＋対面のハイブリッド開催',
    url: 'https://localstage.connpass.com/event/399497/',
    accepted: 23,
    limit: 30,
    description:
        '「地方創生 × AI」をテーマにした 9 日間のハイブリッド型ハッカソン。'
        '技術で「誰かのために」を形にするプロダクトを開発します。',
  ),
  DemoEvent(
    id: 396971,
    name: 'STECH FES 2026',
    group: 'STECH',
    startAt: DateTime.utc(2026, 10, 3, 2),
    endAt: DateTime.utc(2026, 10, 3, 9),
    place: 'TUNNEL TOKYO',
    address: '東京都品川区西品川1丁目1-1 住友不動産大崎ガーデンタワー 9階',
    url: 'https://careerselect-studygroup.connpass.com/event/396971/',
    accepted: 73,
    limit: 91,
    description:
        'テーマは「その“好き”には、仲間がいる。」。全国から集まった学生エンジニアが'
        'キャリアと技術の学びを通じて出会い、刺激し合うイベントです。',
  ),
  DemoEvent(
    id: 404056,
    name: 'Matsuriba夏祭り',
    group: 'NxTEND',
    startAt: DateTime.utc(2026, 10, 18, 6),
    endAt: DateTime.utc(2026, 10, 18, 9, 30),
    place: 'Station Ai',
    address: '愛知県名古屋市昭和区鶴舞1丁目2-32',
    url: 'https://nxtend.connpass.com/event/404056/',
    accepted: 51,
    limit: 100,
    description:
        '東海地区最大のエンジニアの夏祭り。技術への情熱を持つ学生 IT エンジニアが'
        '「祭り」という非日常の空間で交流を深めます。',
  ),
  DemoEvent(
    id: 408951,
    name: 'MEET STAGE in 名古屋 vol.1',
    group: 'LOCAL STAGE Project',
    startAt: DateTime.utc(2026, 11, 8, 4),
    endAt: DateTime.utc(2026, 11, 8, 8, 30),
    place: 'ディップ株式会社',
    address: '愛知県名古屋市中区栄4-1-1 中日ビル 20階',
    url: 'https://localstage.connpass.com/event/408951/',
    accepted: 13,
    limit: 40,
    description:
        '関西・東京で満員御礼だったエンジニアゆる交流会が名古屋で初開催。'
        '東海エリアの学生エンジニアが集まる LT ＆交流会です。',
  ),
  DemoEvent(
    id: 407711,
    name: '2026 システム工学研究会 OBOG会',
    group: 'システム工学研究会',
    startAt: DateTime.utc(2026, 11, 29, 5),
    endAt: DateTime.utc(2026, 11, 29, 10, 30),
    place: '愛知工業大学 八草キャンパス 1号館1階',
    address: '愛知県豊田市八草町八千草1247',
    url: 'https://sysken.connpass.com/event/407711/',
    accepted: 20,
    limit: 60,
    description:
        'システム工学研究会の現役部員と OBOG が集まる会。'
        'LT 会や部室での交流で、世代を超えてつながります。',
  ),
];
