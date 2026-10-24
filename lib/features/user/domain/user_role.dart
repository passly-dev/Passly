/// ユーザーの技術的な役割を表す列挙型
/// サーバーとのJSON通信時には文字列として扱われる
enum UserRole {
  frontend,
  backend,
  fullstack,
  other;

  /// JSON文字列からUserRoleへ変換するファクトリ
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.other,
    );
  }
}
