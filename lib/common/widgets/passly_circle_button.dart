import 'package:flutter/material.dart';

import 'package:passly/common/widgets/passly_icon.dart';
import 'package:passly/common/widgets/press_feedback.dart';
import 'package:passly/core/constants/passly_tokens.dart';

/// ヘッダーの丸ボタン（Figma node 1931:5439「新コンポーネント」）。
///
/// 不透明の白い円（直径 30・影 / ブラー / 枠線なし）の中央に SVG アイコンを置く。
/// 戻る・閉じる・QR・編集・設定・友だち追加で共通に使う。
/// 見た目は 30 のまま、指で押しやすいようタップ領域は 40x40 にしている。
class PasslyCircleButton extends StatelessWidget {
  final String asset;
  final double iconSize;
  final Color color;
  final VoidCallback? onTap;

  const PasslyCircleButton({
    super.key,
    required this.asset,
    required this.iconSize,
    this.color = PasslyText.primary,
    this.onTap,
  });

  static const double diameter = 30;
  static const double _tapSize = 40;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: PressFeedback(
        child: SizedBox(
          width: _tapSize,
          height: _tapSize,
          child: Center(
            child: Container(
              width: diameter,
              height: diameter,
              decoration: const BoxDecoration(
                color: PasslyBg.surface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: PasslyIcon(asset: asset, size: iconSize, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
