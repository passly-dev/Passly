import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// リキッドグラス質感の丸ボタン背景 (QR 画面 / マイページヘッダーで共有)。
///
/// - iOS: [LiquidGlass] (`liquid_glass_renderer`) で本物の屈折 + specular を描画
/// - Android / Web / その他: SkSL シェーダーが動かない環境向けに、
///   `BackdropFilter` + `CustomPainter` で描いた擬似ガラスにフォールバック
///   (Android の Impeller / GLES では liquid_glass_renderer のシェーダーが
///   コンパイルできず、ボタン下のレイヤーが反転して表示されてしまうため)。
class PasslyGlassCircle extends StatelessWidget {
  final double diameter;
  final Widget child;

  const PasslyGlassCircle({super.key, this.diameter = 40, required this.child});

  bool get _supportsLiquidGlass {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    if (_supportsLiquidGlass) {
      return LiquidGlassLayer(
        settings: const LiquidGlassSettings(
          thickness: 12,
          blur: 8,
          glassColor: Color(0x1AFFFFFF),
        ),
        child: LiquidGlass(
          shape: const LiquidOval(),
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Center(child: child),
          ),
        ),
      );
    }
    return _FallbackGlassCircle(diameter: diameter, child: child);
  }
}

/// Android 向けの擬似ガラス実装。
///
/// 3 層構成:
/// 1. [BackdropFilter] で背景をブラーしたベース (半透明白 8%)
/// 2. 上部 (10:30 方向) の強い光沢アーク + 下部 (4:30 方向) の弱い映り込み +
///    外周の細いリングを [CustomPainter] で描画
/// 3. 中央に [child]
class _FallbackGlassCircle extends StatelessWidget {
  final double diameter;
  final Widget child;

  const _FallbackGlassCircle({required this.diameter, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          CustomPaint(
            size: Size(diameter, diameter),
            painter: const _GlassShinePainter(),
          ),
          child,
        ],
      ),
    );
  }
}

/// ガラス玉の specular highlight を描くペインター (fallback 用)。
///
/// Figma の質感に合わせて左上→右下の斜めに光が当たっている表現。
class _GlassShinePainter extends CustomPainter {
  const _GlassShinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius - 1.2);

    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawCircle(center, radius - 0.8, edgePaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7);
    canvas.drawArc(rect, 5 * math.pi / 4 - 1.13, 2.27, false, highlightPaint);

    final bottomShinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6);
    canvas.drawArc(rect, math.pi / 4 - 0.96, 1.92, false, bottomShinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
