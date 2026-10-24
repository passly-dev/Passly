class AppTime {
  // アプリ全体の基準タイムゾーン（JST固定）
  static const timeZoneOffset = Duration(hours: 9);

  /// UI表示やカレンダー用の時間（常に日本時間）
  static DateTime nowLocal() {
    return DateTime.now().toUtc().add(timeZoneOffset);
  }

  /// サーバー通信等で使う絶対的な時間（システム用）
  static DateTime nowUtc() {
    return DateTime.now().toUtc();
  }

  /// サーバーから来たUTC時間をUI用（日本時間）に変換
  static DateTime toAppLocal(DateTime utcTime) {
    return utcTime.toUtc().add(timeZoneOffset);
  }

  /// 時:分 (HH:mm) 形式にフォーマットする
  static String formatHHMM(DateTime time) {
    final local = toAppLocal(time);
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
