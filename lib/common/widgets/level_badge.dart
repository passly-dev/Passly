import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';

/// Figma node 1077:751 の「レベル別バッチ」。
///
/// Figma からエクスポートした SVG をそのまま描画する。多角形の辺数と色は
/// SVG に埋め込まれているため、Flutter 側では level に対応するアセットを
/// 切り替えるだけで済む。
///
/// - Lv.1: 五角形 / 緑
/// - Lv.2: 六角形 / 青
/// - Lv.3: 七角形 / オレンジ
/// - Lv.4: 八角形 / 紫
///
/// [size] は SVG の幅。原寸は 100x122 (縦横比 1.22) なので、実描画高さは
/// `size * 1.22` になる。ラベルはさらに下に表示される。
class LevelBadge extends StatelessWidget {
  final int level;
  final double size;
  final bool showLabel;

  const LevelBadge({
    super.key,
    required this.level,
    this.size = 80,
    this.showLabel = true,
  }) : assert(level >= 1 && level <= 4, 'level は 1〜4 の範囲');

  static const double _aspectRatio = 122 / 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/level_badges/level_$level.svg',
          width: size,
          height: size * _aspectRatio,
        ),
        if (showLabel) ...[
          const SizedBox(height: PasslySpace.s8),
          Text(
            'レベル$level',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: PasslyFont.bold,
            ),
          ),
        ],
      ],
    );
  }
}
