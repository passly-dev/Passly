import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/core/network/dio_client.dart';

final encounterRepositoryProvider = Provider<EncounterRepository>((ref) {
  return EncounterRepository(ref.read(dioProvider));
});

/// すれ違い通信（BLE）のAPI通信を担当するリポジトリ
class EncounterRepository {
  final Dio _dio;

  EncounterRepository(this._dio);

  /// エフェメラルID（短期トークン）を取得する（GET /users/:id/ephemeral-token）
  /// プライバシー保護のため、一定時間ごとに新しいトークンを取得してアドバタイズに使用
  Future<EphemeralToken> getEphemeralToken(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/ephemeral-tokens');
      return EphemeralToken.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('エフェメラルトークンの取得に失敗: ${e.message}');
    }
  }

  /// エフェメラルIDから実際のユーザーIDを解決する（POST /encounters/resolve）
  /// すれ違い確定時に相手のエフェメラルIDから実ユーザーIDを取得
  Future<String> resolveEphemeralId(String ephemeralId) async {
    try {
      final response = await _dio.post(
        '/encounters/resolve',
        data: {"token": ephemeralId, "ephemeral_id": ephemeralId},
      );
      return response.data['user_id'] as String;
    } on DioException catch (e) {
      throw Exception('ユーザーIDの解決に失敗: ${e.message}');
    }
  }

  /// 複数のエフェメラルID（短期トークン）をプールとして取得する（GET /users/:id/ephemeral-tokens）
  /// オフライン時に備えて事前に複数個のトークンを取得
  Future<List<EphemeralToken>> getEphemeralTokens(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/ephemeral-tokens');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => EphemeralToken.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data['tokens'] is List) {
        return (data['tokens'] as List)
            .map((e) => EphemeralToken.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      // API未実装やサーバーダウン時のモック対応
      if (e.response?.statusCode == 404 || e.response == null) {
        // フォールバック: バックエンドが未実装の場合はダミーのトークンプール(5個)を返す
        debugPrint('[Mock] getEphemeralTokens fallback triggered');
        return List.generate(5, (index) {
          // ペイロード制限(31バイト)を超えないように短くする
          final validFrom = DateTime.now().add(Duration(minutes: 15 * index));
          return EphemeralToken(
            token: 'mock-$index-${DateTime.now().second}',
            validFrom: validFrom,
            expiresAt: validFrom.add(const Duration(minutes: 15)),
          );
        });
      }
      throw Exception('エフェメラルトークンプールの取得に失敗: ${e.message}');
    }
  }

  /// バックグラウンドですれ違った相手のIDを送信する（POST /encounters）
  Future<EncounterRecordResult> recordEncounter({
    required String myId,
    String? targetId,
    String? targetToken,
  }) async {
    if ((targetId == null || targetId.isEmpty) &&
        (targetToken == null || targetToken.isEmpty)) {
      throw Exception('targetId か targetToken のどちらかが必要です');
    }

    final data = <String, dynamic>{
      'my_id': myId,
      if (targetId != null && targetId.isNotEmpty) 'target_id': targetId,
      if (targetToken != null && targetToken.isNotEmpty) ...{
        'target_token': targetToken,
        // 後方互換のため従来キーも併送
        'ephemeral_id': targetToken,
        'token': targetToken,
      },
    };

    final response = await _dio.post(
      '/encounters',
      data: data,
      options: Options(contentType: 'application/json'),
    );

    final status = response.statusCode ?? 0;
    final body = response.data;
    final message = body is Map<String, dynamic>
        ? body['message']?.toString()
        : null;

    return EncounterRecordResult(created: status == 201, message: message);
  }

  /// 溜まったすれ違い記録をバッチ送信する（POST /encounters/batch）
  /// 5MBのペイロード制限を回避するため、チャンクに分割して送信する
  Future<void> recordEncountersBatch(
    List<Map<String, dynamic>> encounters,
  ) async {
    if (encounters.isEmpty) return;

    // 1チャンクあたりの最大送信件数 (5MB制限対策)
    const chunkSize = 1000;

    for (var i = 0; i < encounters.length; i += chunkSize) {
      final end = (i + chunkSize < encounters.length)
          ? i + chunkSize
          : encounters.length;

      // バックエンドの仕様に合わせてキーをスネークケースに変換
      final chunk = encounters
          .sublist(i, end)
          .map(
            (e) => {
              'target_token': e['ephemeralId'],
              'encountered_at': e['encounteredAt'],
            },
          )
          .toList();

      try {
        await _dio.post(
          '/encounters/batch',
          data: {'encounters': chunk},
          options: Options(contentType: 'application/json'),
        );
      } on DioException catch (e) {
        // バックエンドが未実装の場合はエラーを握り潰してモック的に成功扱いにする
        if (e.response?.statusCode == 404) {
          // Mock successful creation
          debugPrint(
            '[Mock] recordEncountersBatch success for ${chunk.length} items',
          );
          continue;
        }
        throw Exception('バッチ送信に失敗: ${e.message}');
      }
    }
  }

  /// すれ違い結果を確認済みにする（PUT /users/:id/encounters/confirm）
  Future<void> confirmAllEncounters(String userId) async {
    await _dio.put('/users/$userId/encounters/confirm');
  }

  /// 解除済み実績一覧を取得する（GET /users/:id/achievements）
  Future<List<UnlockedAchievement>> fetchUnlockedAchievements(
    String userId,
  ) async {
    final response = await _dio.get('/users/$userId/achievements');
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      return const [];
    }

    final achievements = (body['achievements'] as List?) ?? const [];
    return achievements
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) => e['is_unlocked'] == true)
        .map(
          (e) => UnlockedAchievement(
            id: e['id']?.toString() ?? '',
            title: e['title']?.toString() ?? '',
          ),
        )
        .where((a) => a.id.isNotEmpty)
        .toList();
  }
}

class EncounterRecordResult {
  final bool created;
  final String? message;

  const EncounterRecordResult({required this.created, this.message});
}

class UnlockedAchievement {
  final String id;
  final String title;

  const UnlockedAchievement({required this.id, required this.title});
}

/// エフェメラルトークン（短期間有効なBLEアドバタイズ用トークン）
class EphemeralToken {
  final String token;
  final DateTime validFrom;
  final DateTime expiresAt;

  EphemeralToken({
    required this.token,
    required this.validFrom,
    required this.expiresAt,
  });

  factory EphemeralToken.fromJson(Map<String, dynamic> json) {
    DateTime parseTime(String key, {required Duration fallbackOffset}) {
      final raw = json[key];
      if (raw is String && raw.isNotEmpty) {
        return DateTime.parse(raw);
      }
      return DateTime.now().add(fallbackOffset);
    }

    return EphemeralToken(
      token: json['token'] as String,
      validFrom: parseTime('valid_from', fallbackOffset: Duration.zero),
      expiresAt: parseTime(
        'expires_at',
        fallbackOffset: const Duration(hours: 1),
      ),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isFuture => DateTime.now().isBefore(validFrom);
  bool get isActive => !isExpired && !isFuture;
}
