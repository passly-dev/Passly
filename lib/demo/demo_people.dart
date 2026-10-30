/// デモ動画用の人物。すべて架空で、実在の参加者とは関係ない。
///
/// tech_stack は [TechTagCatalog] の表記に合わせ、自分（えいでん）と
/// Flutter / Figma / Go などが適度に重なるようにしている。
class DemoPerson {
  final String id;
  final String name;
  final String oneWord;
  final String affiliation;
  final String about;
  final String role;
  final List<String> tags;
  final String twitterUrl;
  final String githubUrl;

  const DemoPerson({
    required this.id,
    required this.name,
    required this.oneWord,
    required this.affiliation,
    required this.about,
    required this.role,
    required this.tags,
    this.twitterUrl = '',
    this.githubUrl = '',
  });

  String get techStack => tags.join(',');
}

const String demoMeId = 'demo_me';

const DemoPerson demoMe = DemoPerson(
  id: demoMeId,
  name: 'えいでん',
  oneWord: 'デザイン大好き！！',
  affiliation: 'システム工学研究会',
  about: 'Flutter でアプリを作っています。Figma でデザインを考えるのも好きです。',
  role: 'frontend',
  tags: ['Flutter', 'Dart', 'Figma', 'Go', 'Firebase', 'GitHub'],
);

const List<DemoPerson> demoPeople = [
  DemoPerson(
    id: 'demo_01',
    name: 'みなと',
    oneWord: 'Flutter と Figma で個人開発中',
    affiliation: '東海情報工科大学 アプリ開発部',
    about:
        '大学 2 年。UI の細かいアニメーションを作るのが好きです。'
        '最近は Go でバックエンドも書き始めました。',
    role: 'frontend',
    tags: ['Flutter', 'Dart', 'Figma', 'Go', 'Firebase'],
    twitterUrl: 'https://x.com/example_minato',
    githubUrl: 'https://github.com/example-minato',
  ),
  DemoPerson(
    id: 'demo_02',
    name: 'さくら',
    oneWord: 'デザインシステム沼の住人',
    affiliation: 'なごやデザインアカデミー',
    about: 'Figma でコンポーネントを作るのが趣味。エンジニアと一緒に作れる人を探しています。',
    role: 'other',
    tags: ['Figma', 'Illustrator', 'Photoshop', 'Flutter'],
    twitterUrl: 'https://x.com/example_sakura',
  ),
  DemoPerson(
    id: 'demo_03',
    name: 'はると',
    oneWord: 'Go でマイクロサービス書いてます',
    affiliation: '中部テック大学 情報研究会',
    about: 'バックエンドとインフラが好き。ハッカソンではサーバー担当になりがち。',
    role: 'backend',
    tags: ['Go', 'Docker', 'PostgreSQL', 'AWS', 'GitHub'],
    githubUrl: 'https://github.com/example-haruto',
  ),
  DemoPerson(
    id: 'demo_04',
    name: 'ゆい',
    oneWord: 'React と TypeScript が好き',
    affiliation: '尾張工業大学 Web 研究会',
    about: 'Next.js で Web アプリを作っています。最近 Flutter も触り始めました。',
    role: 'frontend',
    tags: ['React', 'TypeScript', 'Next.js', 'Tailwind', 'Flutter'],
    twitterUrl: 'https://x.com/example_yui',
    githubUrl: 'https://github.com/example-yui',
  ),
  DemoPerson(
    id: 'demo_05',
    name: 'そうた',
    oneWord: 'iOS アプリ作ってます',
    affiliation: '三河高専 情報工学科',
    about: 'Swift で SwiftUI のアプリを作っています。BLE を使った作品に興味あり。',
    role: 'frontend',
    tags: ['Swift', 'iOS', 'Firebase', 'Figma'],
    githubUrl: 'https://github.com/example-sota',
  ),
  DemoPerson(
    id: 'demo_06',
    name: 'りん',
    oneWord: '機械学習とデータ分析',
    affiliation: '東海情報工科大学 AI 研究室',
    about: 'Python で機械学習をしています。研究のかたわら Web にも挑戦中。',
    role: 'backend',
    tags: ['Python', 'Django', 'GCP', 'Docker'],
  ),
  DemoPerson(
    id: 'demo_07',
    name: 'かいと',
    oneWord: 'フルスタック目指して勉強中',
    affiliation: '名古屋みらい大学 プログラミングサークル',
    about: 'Flutter と Go で SNS アプリを作っています。ハッカソンによく出ます。',
    role: 'fullstack',
    tags: ['Flutter', 'Dart', 'Go', 'Docker', 'GitHub'],
    twitterUrl: 'https://x.com/example_kaito',
    githubUrl: 'https://github.com/example-kaito',
  ),
  DemoPerson(
    id: 'demo_08',
    name: 'あおい',
    oneWord: 'Kotlin で Android 開発',
    affiliation: '岐阜情報大学 モバイル部',
    about: 'Jetpack Compose が好きです。Flutter との違いについて語りたい。',
    role: 'frontend',
    tags: ['Kotlin', 'Android', 'Firebase', 'GitHub'],
  ),
  DemoPerson(
    id: 'demo_09',
    name: 'たくみ',
    oneWord: 'インフラと自動化が好き',
    affiliation: '中部テック大学 情報研究会',
    about: 'Terraform で何でもコード化したい人。Kubernetes を勉強中です。',
    role: 'backend',
    tags: ['AWS', 'Terraform', 'Kubernetes', 'Go', 'Linux'],
    githubUrl: 'https://github.com/example-takumi',
  ),
  DemoPerson(
    id: 'demo_10',
    name: 'ひなた',
    oneWord: 'UI/UX デザイナー志望',
    affiliation: '尾張工業大学 デザイン研究会',
    about: 'ユーザーインタビューからプロトタイプまで Figma で作ります。',
    role: 'other',
    tags: ['Figma', 'Adobe XD', 'Illustrator'],
    twitterUrl: 'https://x.com/example_hinata',
  ),
  DemoPerson(
    id: 'demo_11',
    name: 'れお',
    oneWord: 'Rust で低レイヤーを触りたい',
    affiliation: '三河高専 電子情報工学科',
    about: 'Rust と C++ が好き。競技プログラミングもやっています。',
    role: 'backend',
    tags: ['Rust', 'C++', 'Linux'],
  ),
  DemoPerson(
    id: 'demo_12',
    name: 'めい',
    oneWord: 'Vue で Web サービス運営中',
    affiliation: '名古屋みらい大学 Web 制作部',
    about: '学内向けの Web サービスを Vue と Firebase で作って運営しています。',
    role: 'frontend',
    tags: ['Vue', 'TypeScript', 'Firebase', 'Figma'],
    githubUrl: 'https://github.com/example-mei',
  ),
  DemoPerson(
    id: 'demo_13',
    name: 'しゅん',
    oneWord: 'Rails でサービス開発',
    affiliation: '岐阜情報大学 開発サークル',
    about: 'Ruby on Rails でスタートアップのインターン中。',
    role: 'backend',
    tags: ['Ruby', 'Rails', 'MySQL', 'Docker'],
  ),
  DemoPerson(
    id: 'demo_14',
    name: 'ことね',
    oneWord: 'Flutter 初心者です！',
    affiliation: '東海情報工科大学 アプリ開発部',
    about: '大学 1 年。先輩に教わりながら初めての Flutter アプリを作っています。',
    role: 'frontend',
    tags: ['Flutter', 'Dart', 'Figma'],
    twitterUrl: 'https://x.com/example_kotone',
  ),
  DemoPerson(
    id: 'demo_15',
    name: 'だいち',
    oneWord: 'ゲーム作りが好き',
    affiliation: '中部テック大学 ゲーム制作部',
    about: 'C# でゲームを作っています。Web ゲームにも挑戦中。',
    role: 'other',
    tags: ['C#', 'JavaScript', 'Git'],
  ),
  DemoPerson(
    id: 'demo_16',
    name: 'ゆうき',
    oneWord: 'Next.js と Go でサービス作り',
    affiliation: '尾張工業大学 Web 研究会',
    about: 'フロントは Next.js、バックエンドは Go。チーム開発の進め方に興味があります。',
    role: 'fullstack',
    tags: ['Next.js', 'TypeScript', 'Go', 'PostgreSQL', 'GitHub'],
    githubUrl: 'https://github.com/example-yuki',
  ),
  DemoPerson(
    id: 'demo_17',
    name: 'ななみ',
    oneWord: 'Java と Spring で勉強中',
    affiliation: '名古屋みらい大学 情報システム学科',
    about: '業務システムに興味があり、Spring Boot を勉強しています。',
    role: 'backend',
    tags: ['Java', 'Spring', 'MySQL'],
  ),
  DemoPerson(
    id: 'demo_18',
    name: 'いつき',
    oneWord: 'React Native で個人アプリ',
    affiliation: '三河高専 情報工学科',
    about: 'React Native で家計簿アプリを公開しています。Flutter と迷い中。',
    role: 'frontend',
    tags: ['React Native', 'TypeScript', 'Firebase', 'Figma'],
    twitterUrl: 'https://x.com/example_itsuki',
  ),
];

/// 最初からお気に入りにしておく人。
const List<String> demoInitialFavoriteIds = ['demo_02', 'demo_07'];

/// 各イベントですれ違った人（イベント ID → 人物 ID）。
/// 開催前のイベントはここに入れない。
const Map<int, List<String>> demoEncountersByEvent = {
  374741: ['demo_01', 'demo_03', 'demo_07', 'demo_11'],
  379505: ['demo_14', 'demo_04', 'demo_15'],
  379341: ['demo_16', 'demo_06', 'demo_13', 'demo_17', 'demo_08'],
  373212: [
    'demo_01',
    'demo_02',
    'demo_05',
    'demo_07',
    'demo_09',
    'demo_12',
    'demo_18',
    'demo_10',
  ],
  372782: ['demo_07', 'demo_03', 'demo_14', 'demo_11', 'demo_15', 'demo_06'],
  390965: ['demo_04', 'demo_16', 'demo_08'],
  391293: ['demo_12', 'demo_13', 'demo_05', 'demo_17'],
  396090: ['demo_09', 'demo_11', 'demo_15'],
  396200: ['demo_02', 'demo_18', 'demo_06', 'demo_14'],
  381453: ['demo_14', 'demo_16', 'demo_04'],
  397535: ['demo_02', 'demo_10', 'demo_12', 'demo_05', 'demo_18'],
  386955: ['demo_08', 'demo_17', 'demo_03', 'demo_07'],
  399497: ['demo_16', 'demo_09', 'demo_06', 'demo_01'],
  396971: ['demo_04', 'demo_13', 'demo_10', 'demo_11', 'demo_18'],
  404056: [
    'demo_07',
    'demo_02',
    'demo_14',
    'demo_15',
    'demo_17',
    'demo_05',
    'demo_12',
  ],
};

/// 「今日」すれ違ったことにする人と、そのイベント。
/// demo_01 は自分と共通タグが 5 つ、demo_11 と demo_17 は 0 個。
const int demoTodayEventId = 408951;
const List<String> demoTodayPeople = [
  'demo_01',
  'demo_14',
  'demo_03',
  'demo_11',
  'demo_17',
];
