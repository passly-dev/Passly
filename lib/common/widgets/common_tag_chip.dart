import 'package:flutter/material.dart';

import 'package:passly/core/constants/passly_tokens.dart';

/// 共通タグのチップ。
///
/// - [CommonTagChip.solid]: 緑塗り。いちばん共通点が多い人のカード / すれ違い画面
/// - [CommonTagChip.soft]: 薄緑。一覧の行
/// - [CommonTagChip.more]: 灰色の「+N」。一覧の行で 4 つ目以降をまとめる
class CommonTagChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final double fontSize;
  final EdgeInsets padding;

  const CommonTagChip.solid(this.label, {super.key})
    : background = PasslyBrand.primary,
      foreground = PasslyText.onBrand,
      fontSize = 13,
      padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 3);

  const CommonTagChip.soft(this.label, {super.key})
    : background = PasslyBrand.primarySurface,
      foreground = PasslyBrand.primaryDark,
      fontSize = 11,
      padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 2);

  /// [label] には「+2」のように残りの数を渡す。
  const CommonTagChip.more(this.label, {super.key})
    : background = PasslyBg.elevated,
      foreground = const Color(0xFF4B5563),
      fontSize = 11,
      padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(PasslyRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: PasslyFont.family,
          color: foreground,
          fontSize: fontSize,
          fontWeight: PasslyFont.bold,
          height: 1.2,
        ),
      ),
    );
  }
}

/// 共通タグを全部折り返して並べる（緑塗り）。
class CommonTagWrap extends StatelessWidget {
  final List<String> tags;

  const CommonTagWrap({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [for (final t in tags) CommonTagChip.solid(t)],
    );
  }
}

/// 一覧の行用。[maxVisible] 個まで出し、残りは「+N」にまとめる。
class CommonTagRow extends StatelessWidget {
  final List<String> tags;
  final int maxVisible;

  const CommonTagRow({super.key, required this.tags, this.maxVisible = 3});

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(maxVisible).toList();
    final rest = tags.length - visible.length;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final t in visible) CommonTagChip.soft(t),
        if (rest > 0) CommonTagChip.more('+$rest'),
      ],
    );
  }
}
