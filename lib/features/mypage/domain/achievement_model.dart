class AchievementModel {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool isUnlocked;
  final String? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🏅',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at']?.toString(),
    );
  }

  String get unlockedDateLabel {
    if (!isUnlocked || unlockedAt == null || unlockedAt!.isEmpty) {
      return '未解除';
    }

    final parts = unlockedAt!.split('-');
    if (parts.length != 3) {
      return unlockedAt!;
    }
    return '${parts[0]}/${parts[1]}/${parts[2]}';
  }
}
