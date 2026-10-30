/// その人が次に参加するイベント（バックエンド: next_event）。
///
/// 相手プロフィールの「NEXT EVENT」に出す。サーバーはまだ返さないので、
/// 今はデモモードのダミーデータだけで埋まる。
class NextEvent {
  final String title;
  final DateTime startedAt;
  final String place;
  final String url;
  final String imageUrl;

  const NextEvent({
    required this.title,
    required this.startedAt,
    this.place = '',
    this.url = '',
    this.imageUrl = '',
  });

  /// [json] が Map でない、またはタイトルか日時がなければ null。
  static NextEvent? tryParse(Object? json) {
    if (json is! Map) return null;
    final title = json['title']?.toString() ?? '';
    final startedAt = DateTime.tryParse(json['started_at']?.toString() ?? '');
    if (title.isEmpty || startedAt == null) return null;
    return NextEvent(
      title: title,
      startedAt: startedAt,
      place: json['place']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NextEvent &&
      other.title == title &&
      other.startedAt == startedAt &&
      other.place == place &&
      other.url == url &&
      other.imageUrl == imageUrl;

  @override
  int get hashCode => Object.hash(title, startedAt, place, url, imageUrl);
}
