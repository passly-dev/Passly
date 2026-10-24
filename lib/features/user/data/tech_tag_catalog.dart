/// マイページの TECH TAG 編集で提示する事前定義タグ集。
///
/// 自由入力を廃止し、この一覧から選ぶ運用にすると:
/// - 表記揺れ (Flutter / flutter / FLUTTER) が防げる
/// - 将来的に「同じタグを持つ人」検索が組みやすい
/// - ユーザーが「何を書けばいいか」で迷わない
///
/// 将来的に追加要望があればここに足す。
class TechTagCatalog {
  /// カテゴリー付き一覧。表示順はこの順。
  static const List<TechTagCategory> categories = [
    TechTagCategory('言語', [
      'Dart',
      'Go',
      'Python',
      'JavaScript',
      'TypeScript',
      'Kotlin',
      'Swift',
      'Java',
      'Ruby',
      'PHP',
      'Rust',
      'C++',
      'C#',
    ]),
    TechTagCategory('フロントエンド', [
      'React',
      'Vue',
      'Angular',
      'Next.js',
      'Nuxt',
      'Svelte',
      'Tailwind',
    ]),
    TechTagCategory('モバイル', ['Flutter', 'React Native', 'iOS', 'Android']),
    TechTagCategory('バックエンド', [
      'Node.js',
      'Express',
      'Django',
      'Rails',
      'Spring',
      'Laravel',
      'Fastify',
    ]),
    TechTagCategory('インフラ / クラウド', [
      'AWS',
      'GCP',
      'Azure',
      'Firebase',
      'Docker',
      'Kubernetes',
      'Terraform',
    ]),
    TechTagCategory('データベース', [
      'PostgreSQL',
      'MySQL',
      'MongoDB',
      'Redis',
      'SQLite',
    ]),
    TechTagCategory('デザイン', ['Figma', 'Adobe XD', 'Photoshop', 'Illustrator']),
    TechTagCategory('その他', ['Git', 'GitHub', 'GitLab', 'Linux', 'VSCode']),
  ];

  /// フラットな全タグ (ルックアップや正規化用)。
  static final List<String> allTags = [for (final c in categories) ...c.tags];

  /// 大文字小文字を無視して事前定義タグにマッチさせる。
  /// カタログ内での正式表記に正規化して返す (見つからなければそのまま返す)。
  static String normalize(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    final lower = trimmed.toLowerCase();
    for (final tag in allTags) {
      if (tag.toLowerCase() == lower) return tag;
    }
    return trimmed;
  }
}

class TechTagCategory {
  final String label;
  final List<String> tags;

  const TechTagCategory(this.label, this.tags);
}
