/// すれ違い回数からレベル / 次レベルまでの残り / 進捗を算出する簡易ロジック。
///
/// 現状はクライアント計算のモック。バックエンドが `level` / `next_level_at`
/// 相当のフィールドを返すようになったら、そちらの値に置き換える。
class LevelInfo {
  final int level;
  final int remaining;
  final double progress;

  const LevelInfo({
    required this.level,
    required this.remaining,
    required this.progress,
  });

  /// 各レベルの開始点: L1=0, L2=5, L3=10, L4=15。
  /// Figma のサンプル値 (count=12 → L3 / 残り3 / レベル4 に到達) と整合する。
  static const List<int> _thresholds = [0, 5, 10, 15];

  static LevelInfo compute(int count) {
    int level = 1;
    for (int i = _thresholds.length - 1; i >= 0; i--) {
      if (count >= _thresholds[i]) {
        level = i + 1;
        break;
      }
    }
    if (level >= 4) {
      return const LevelInfo(level: 4, remaining: 0, progress: 1);
    }
    final start = _thresholds[level - 1];
    final next = _thresholds[level];
    final remaining = next - count;
    final progress = (count - start) / (next - start);
    return LevelInfo(
      level: level,
      remaining: remaining,
      progress: progress.clamp(0.0, 1.0),
    );
  }
}
