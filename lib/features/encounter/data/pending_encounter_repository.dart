import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syshack2026/core/network/dio_client.dart';
import 'package:syshack2026/features/encounter/domain/encounter_model.dart';

/// ローカル保存用リポジトリのプロバイダー
final pendingEncounterRepositoryProvider = Provider<PendingEncounterRepository>(
  (ref) {
    return PendingEncounterRepository(ref.read(secureStorageProvider));
  },
);

/// 未確認すれ違いデータのローカル保存を担当するリポジトリ
/// flutter_secure_storageを使ってJSON形式で保存する
class PendingEncounterRepository {
  final FlutterSecureStorage _storage;
  static const _key = 'pending_encounters';
  static const _lastShutdownIdsKey = 'last_shutdown_encounter_user_ids';

  PendingEncounterRepository(this._storage);

  /// 未確認のすれ違いデータをローカルから取得する
  Future<List<EncounterModel>> getPending() async {
    final jsonStr = await _storage.read(key: _key);
    if (jsonStr == null) return [];

    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => EncounterModel.fromJson(e)).toList();
  }

  /// すれ違いデータを1件追加してローカルに保存する
  Future<void> add(EncounterModel encounter) async {
    final current = await getPending();
    current.add(encounter);
    await _save(current);
  }

  /// ローカルの未確認データをすべてクリアする
  Future<void> clearAll() async {
    await _storage.delete(key: _key);
  }

  /// 前回終了時点の未確認ユーザーID一覧を保存する
  Future<void> saveLastShutdownEncounterUserIds(List<String> userIds) async {
    final unique = userIds.toSet().toList();
    await _storage.write(key: _lastShutdownIdsKey, value: jsonEncode(unique));
  }

  /// 前回終了時点の未確認ユーザーID一覧を取得する
  Future<Set<String>> getLastShutdownEncounterUserIds() async {
    final jsonStr = await _storage.read(key: _lastShutdownIdsKey);
    if (jsonStr == null || jsonStr.isEmpty) return <String>{};

    final list = (jsonDecode(jsonStr) as List).map((e) => e.toString());
    return list.toSet();
  }

  /// リストをJSON文字列としてセキュアストレージに書き込む
  Future<void> _save(List<EncounterModel> encounters) async {
    final jsonStr = jsonEncode(encounters.map((e) => e.toJson()).toList());
    await _storage.write(key: _key, value: jsonStr);
  }

  // --- オフライン保存用 (未送信トークン) ---
  static const _unsentTokensKey = 'unsent_ephemeral_tokens';

  /// 未送信のトークンと遭遇時刻をローカルに保存
  Future<void> addUnsentToken(
    String ephemeralId,
    DateTime encounteredAt,
  ) async {
    final tokens = await getUnsentTokens();
    tokens.add({
      'ephemeralId': ephemeralId,
      'encounteredAt': encounteredAt.toUtc().toIso8601String(),
    });
    await _storage.write(key: _unsentTokensKey, value: jsonEncode(tokens));
  }

  /// 未送信のトークン一覧を取得
  Future<List<Map<String, dynamic>>> getUnsentTokens() async {
    final data = await _storage.read(key: _unsentTokensKey);
    if (data == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// 未送信のトークン一覧を全消去
  Future<void> clearUnsentTokens() async {
    await _storage.delete(key: _unsentTokensKey);
  }

  /// 遭遇から48時間以上経過した古いトークンを削除
  Future<void> removeExpiredTokens() async {
    final tokens = await getUnsentTokens();
    if (tokens.isEmpty) return;

    final now = DateTime.now().toUtc();
    final validTokens = tokens.where((token) {
      final encounteredAtStr = token['encounteredAt'] as String?;
      if (encounteredAtStr == null) return false;

      try {
        final encounteredAt = DateTime.parse(encounteredAtStr).toUtc();
        final difference = now.difference(encounteredAt);
        // 48時間以内のデータのみ残す
        return difference.inHours < 48;
      } catch (e) {
        return false;
      }
    }).toList();

    // 削除された要素があれば更新する
    if (validTokens.length != tokens.length) {
      await _storage.write(
        key: _unsentTokensKey,
        value: jsonEncode(validTokens),
      );
    }
  }
}
