import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:syshack2026/features/user/domain/last_encounter.dart';
import 'package:syshack2026/features/user/domain/user_role.dart';

part 'user_model.freezed.dart';

/// 文字列コンバーター：NULLを空文字にフォールバック
String _readString(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  if (value is String) return value;
  return value?.toString() ?? '';
}

/// ユーザー情報を表現するドメインモデル（freezedで不変データクラスを生成）
/// バックエンドのGoの構造体に合わせたJSONフィールド名を使用
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    @Default('') String email,

    /// アバター画像URL（バックエンド: icon_url）
    @Default('') String iconUrl,

    /// 一言コメント（バックエンド: one_word）
    @Default('') String oneWord,

    /// ロール（frontend / backend / fullstack / other）
    @Default(UserRole.other) UserRole role,

    /// 技術スタック（バックエンド: tech_stack）
    @Default('') String techStack,

    /// Twitter URL（バックエンド: twitter_url）
    @Default('') String twitterUrl,

    /// GitHub URL（バックエンド: github_url）
    @Default('') String githubUrl,

    /// ポートフォリオURL（バックエンド: portfolio_url）
    @Default('') String portfolioUrl,

    /// Connpassユーザー名/URL（バックエンド: connpass_username）
    @Default('') String connpassUrl,

    /// 所属（バックエンド: affiliation）
    @Default('') String affiliation,

    /// カバー画像URL（プロフィールヘッダー用、バックエンド: cover_url）
    @Default('') String coverUrl,

    /// 自己紹介文（バックエンド: about）
    @Default('') String about,

    /// この相手を「親しい友達」に登録済みか（バックエンド: is_close_friend）
    @Default(false) bool isCloseFriend,

    /// この相手と最後にすれ違った時の情報（バックエンド: last_encounter）
    LastEncounter? lastEncounter,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  /// カスタムfromJson: NULL値を空文字にフォールバックしてからパース
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // ロールのパース
    UserRole parseRole(dynamic value) {
      if (value == null) return UserRole.other;
      final str = value.toString().toLowerCase();
      switch (str) {
        case 'frontend':
          return UserRole.frontend;
        case 'backend':
          return UserRole.backend;
        case 'fullstack':
          return UserRole.fullstack;
        default:
          return UserRole.other;
      }
    }

    // DateTimeのパース
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    LastEncounter? parseLastEncounter(dynamic value) {
      if (value is! Map) return null;
      final map = Map<String, dynamic>.from(value);
      final metAt = parseDateTime(map['met_at']);
      if (metAt == null) return null;
      return LastEncounter(
        metAt: metAt,
        eventName: _readString(map, 'event_name'),
      );
    }

    return UserModel(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      email: _readString(json, 'email'),
      iconUrl: _readString(json, 'icon_url'),
      oneWord: _readString(json, 'one_word'),
      role: parseRole(json['role']),
      techStack: _readString(json, 'tech_stack'),
      twitterUrl: _readString(json, 'twitter_url'),
      githubUrl: _readString(json, 'github_url'),
      portfolioUrl: _readString(json, 'portfolio_url'),
      connpassUrl: _readString(json, 'connpass_url').isNotEmpty
          ? _readString(json, 'connpass_url')
          : _readString(json, 'connpass_username'),
      affiliation: _readString(json, 'affiliation'),
      coverUrl: _readString(json, 'cover_url'),
      about: _readString(json, 'about'),
      isCloseFriend: json['is_close_friend'] as bool? ?? false,
      lastEncounter: parseLastEncounter(json['last_encounter']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }
}
