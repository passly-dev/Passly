import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:passly/core/constants/passly_tokens.dart';

/// 新規登録の進み具合を表す丸いリング。真ん中に「2/3」のように出す。
///
/// 次のステップへ進むと，リングがのびるように動く。
class StepRing extends StatelessWidget {
  /// いまのステップ（1 から）。
  final int step;
  final int count;
  final double size;

  const StepRing({
    super.key,
    required this.step,
    required this.count,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ステップ $step／$count',
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: count == 0 ? 0 : step / count),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) => CustomPaint(
            painter: _RingPainter(progress: progress),
            child: child,
          ),
          child: Center(
            child: ExcludeSemantics(
              child: Text(
                '$step/$count',
                style: TextStyle(
                  fontFamily: PasslyFont.family,
                  color: PasslyText.primary,
                  fontSize: size * 0.3,
                  fontWeight: PasslyFont.bold,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width / 10;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);

    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = PasslyBorder.defaultBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      Paint()
        ..color = PasslyBrand.primary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
