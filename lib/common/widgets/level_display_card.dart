import 'package:flutter/material.dart';

import 'package:syshack2026/common/widgets/level_badge.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';

/// Figma node 1079:875 「レベル表示カード」。
///
/// オレンジのカードに、左：すれ違い回数チップ + カウント + プログレスバー +
/// 「あと N 回で レベル M」、右：現在レベルのバッジを並べる。
///
/// [currentLevel] は右側のバッジ (level_$currentLevel.svg) と、
/// 「レベル${currentLevel + 1}」ラベルに反映される。1〜3 が有効。
class LevelDisplayCard extends StatelessWidget {
  final int count;
  final int remaining;
  final int currentLevel;
  final double progress;

  const LevelDisplayCard({
    super.key,
    required this.count,
    required this.remaining,
    required this.currentLevel,
    this.progress = 0.69,
  }) : assert(currentLevel >= 1 && currentLevel <= 4, 'currentLevel は 1〜4'),
       assert(progress >= 0 && progress <= 1);

  // Figma 原寸 (px)。内部座標はこの値を基準にスケールする。
  // 高さ 133.7 は AspectRatio 固定をやめたため参照しなくなったが、
  // Figma 原寸の記録として定義だけ残しておく (docstring 参照)。
  static const double _designW = 382;
  static const double _borderRadius = 23.152;

  // 現在レベルに応じたカード背景色。バッジ (level_$level.svg) の色と揃える。
  static const Map<int, Color> _bgByLevel = {
    1: Color(0xFF0BA601),
    2: Color(0xFF0990FF),
    3: Color(0xFFFFA406),
    4: Color(0xFF914AFF),
  };

  Color get _cardBg => _bgByLevel[currentLevel]!;

  @override
  Widget build(BuildContext context) {
    // AspectRatio で高さを 133.7 に固定すると、Noto Sans JP の Text.rich
    // ライン高がわずかに膨らむ端末 (iPhone 17 の実描画で 8.7px 程度) では
    // 底辺がオーバーフローする。内部 spacing は `* scale` のまま Figma 比率を
    // 保ちつつ、Container の高さはコンテンツの intrinsic に任せる。
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / _designW;
        return _buildCard(scale);
      },
    );
  }

  Widget _buildCard(double scale) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(_borderRadius * scale),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2.315 * scale),
            blurRadius: 34.727 * scale,
            color: const Color(0x407E857E),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 6.945 * scale,
        vertical: 2.315 * scale,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildLeft(scale)),
          Padding(
            padding: EdgeInsets.all(11.576 * scale),
            child: LevelBadge(
              level: currentLevel,
              size: 86.818 * scale,
              showLabel: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeft(double scale) {
    return Padding(
      padding: EdgeInsets.all(11.576 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CountChip(scale: scale, textColor: _cardBg),
          SizedBox(height: 10.418 * scale),
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: PasslyFont.family,
                fontWeight: PasslyFont.bold,
                color: PasslyText.onBrand,
              ),
              children: [
                TextSpan(
                  text: '$count',
                  style: TextStyle(
                    fontSize: 37.042 * scale,
                    height: 33.338 / 37.042,
                  ),
                ),
                TextSpan(
                  text: '回',
                  style: TextStyle(
                    fontSize: 18.521 * scale,
                    height: 22.225 / 18.521,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9.261 * scale),
          _ProgressBar(scale: scale, progress: progress),
          // 最大レベル (4) では「あと N 回で レベル M」の表記が成立しないため非表示。
          if (currentLevel < 4) ...[
            SizedBox(height: 9.261 * scale),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: PasslyFont.family,
                  fontSize: 13.891 * scale,
                  height: 16.669 / 13.891,
                  color: PasslyText.onBrand,
                ),
                children: [
                  TextSpan(
                    text: 'あと$remaining回で ',
                    style: const TextStyle(fontWeight: PasslyFont.regular),
                  ),
                  TextSpan(
                    text: 'レベル${currentLevel + 1}',
                    style: const TextStyle(fontWeight: PasslyFont.medium),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final double scale;
  final Color textColor;
  const _CountChip({required this.scale, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6.945 * scale,
        vertical: 2.315 * scale,
      ),
      decoration: BoxDecoration(
        color: PasslyBg.surface,
        borderRadius: BorderRadius.circular(115.758 * scale),
      ),
      child: Text(
        'すれ違い回数',
        style: TextStyle(
          fontFamily: PasslyFont.family,
          fontWeight: PasslyFont.semibold,
          fontSize: 13.891 * scale,
          height: 16.669 / 13.891,
          color: textColor,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double scale;
  final double progress;
  const _ProgressBar({required this.scale, required this.progress});

  @override
  Widget build(BuildContext context) {
    final height = 3.47273 * scale;
    final radius = BorderRadius.circular(1.73636 * scale);
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: PasslyText.secondary,
              borderRadius: radius,
            ),
          ),
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: PasslyBg.defaultBg,
                borderRadius: radius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
