import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/core/network/dio_client.dart';
import 'package:syshack2026/features/mypage/domain/achievement_model.dart';

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository(ref.read(dioProvider));
});

class AchievementResponse {
  final int unlockedCount;
  final int totalCount;
  final List<AchievementModel> achievements;

  const AchievementResponse({
    required this.unlockedCount,
    required this.totalCount,
    required this.achievements,
  });

  factory AchievementResponse.fromJson(Map<String, dynamic> json) {
    final rawList = (json['achievements'] as List?) ?? const [];
    final achievements = rawList
        .whereType<Map>()
        .map((e) => AchievementModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return AchievementResponse(
      unlockedCount: json['unlocked_count'] as int? ?? 0,
      totalCount: json['total_count'] as int? ?? achievements.length,
      achievements: achievements,
    );
  }
}

class AchievementRepository {
  final Dio _dio;

  AchievementRepository(this._dio);

  Future<AchievementResponse> fetchAchievements(String userId) async {
    final response = await _dio.get('/users/$userId/achievements');
    return AchievementResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
