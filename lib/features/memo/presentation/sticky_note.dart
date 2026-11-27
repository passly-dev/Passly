import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:passly/core/constants/passly_tokens.dart';
import 'package:passly/features/memo/domain/partner_memo.dart';

/// 付箋で使う文字。見出しも本文もアプリの文字にそろえ，見出しは太字にする。
abstract final class MemoFont {
  static const String title = PasslyFont.family;
  static const FontWeight titleWeight = PasslyFont.bold;
  static const String body = PasslyFont.family;
  static const Color ink = Color(0xFF5B4A3A);
  static const Color inkLight = Color(0xFF9A8A78);
}

/// 付箋の紙。角丸・右下のめくれ・影・上辺のマスキングテープを描く。
class StickyPaper extends StatelessWidget {
  final MemoColor color;
  final double width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double foldSize;

  /// テープの大きさ。0 ならテープを貼らない。
  final Size tapeSize;

  /// テープの見え方（0〜1）。貼った直後に遅れて乗せるのに使う。
  final double tapeOpacity;
  final Widget child;

  const StickyPaper({
    super.key,
    required this.color,
    required this.width,
    this.height,
    this.padding = const EdgeInsets.fromLTRB(12, 14, 12, 10),
    this.radius = 10,
    this.foldSize = 14,
    this.tapeSize = const Size(40, 14),
    this.tapeOpacity = 1,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final hasTape = tapeSize.width > 0;
    final tapeTop = tapeSize.height / 2;
    return SizedBox(
      width: width,
      height: height == null ? null : height! + tapeTop,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(top: tapeTop),
            child: CustomPaint(
              painter: _PaperPainter(
                color: color,
                radius: radius,
                foldSize: foldSize,
              ),
              child: SizedBox(
                width: width,
                height: height,
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
          if (hasTape)
            Positioned(
              top: 0,
              left: (width - tapeSize.width) / 2,
              child: Opacity(
                opacity: tapeOpacity.clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: -4 * math.pi / 180,
                  child: MaskingTape(color: color, size: tapeSize),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  final MemoColor color;
  final double radius;
  final double foldSize;

  _PaperPainter({
    required this.color,
    required this.radius,
    required this.foldSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final f = foldSize;
    final r = radius;

    // 右下を斜めに切った紙の形。
    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, h - f)
      ..lineTo(w - f, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();

    canvas.drawShadow(path, const Color(0x66000000), 3, false);
    canvas.drawPath(path, Paint()..color = color.paper);

    // めくれ（三角）。
    final fold = Path()
      ..moveTo(w, h - f)
      ..lineTo(w - f, h - f)
      ..quadraticBezierTo(w - f, h - f / 2, w - f, h)
      ..close();
    canvas.drawPath(fold, Paint()..color = color.fold);
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      old.color != color || old.radius != radius || old.foldSize != foldSize;
}

/// しま模様のマスキングテープ。少し透けさせる。
class MaskingTape extends StatelessWidget {
  final MemoColor color;
  final Size size;

  const MaskingTape({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: size, painter: _TapePainter(color));
  }
}

class _TapePainter extends CustomPainter {
  final MemoColor color;
  _TapePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRect(rect);
    canvas.drawRect(rect, Paint()..color = color.tape.withValues(alpha: 0.9));
    final stripe = Paint()
      ..color = color.tapeStripe.withValues(alpha: 0.9)
      ..strokeWidth = size.height / 4;
    final step = size.height / 1.6;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripe,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TapePainter old) => old.color != color;
}

/// 見出しの下の点線。
class DottedRule extends StatelessWidget {
  final Color color;
  const DottedRule({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: CustomPaint(painter: _DotsPainter(color)),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;
  _DotsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (double x = 1; x < size.width; x += 5) {
      canvas.drawCircle(Offset(x, size.height / 2), 0.8, p);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.color != color;
}

/// プロフィールに貼られた付箋（③）。見出し・本文の頭・日付を出す。
class StuckMemoNote extends StatelessWidget {
  final PartnerMemo memo;
  final String dateLabel;
  final double tapeOpacity;

  const StuckMemoNote({
    super.key,
    required this.memo,
    required this.dateLabel,
    this.tapeOpacity = 1,
  });

  static const double width = 118;

  @override
  Widget build(BuildContext context) {
    final title = memo.title.trim();
    final body = memo.body.trim();
    return StickyPaper(
      color: memo.color,
      width: width,
      height: 84,
      radius: 8,
      foldSize: 10,
      tapeSize: const Size(36, 12),
      tapeOpacity: tapeOpacity,
      padding: const EdgeInsets.fromLTRB(9, 9, 9, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: MemoFont.title,
                fontWeight: MemoFont.titleWeight,
                fontSize: 11,
                height: 1.3,
                color: MemoFont.ink,
              ),
            ),
            const SizedBox(height: 2),
            DottedRule(color: memo.color.fold),
            const SizedBox(height: 3),
          ],
          Expanded(
            child: Text(
              body,
              maxLines: title.isEmpty ? 4 : 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: MemoFont.body,
                fontSize: 8,
                height: 1.35,
                color: MemoFont.ink,
              ),
            ),
          ),
          Text(
            dateLabel,
            style: const TextStyle(
              fontFamily: MemoFont.body,
              fontSize: 7,
              color: MemoFont.inkLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// すれ違い一覧の行の右に出す小さい付箋（④）。
class MiniMemoNote extends StatelessWidget {
  final PartnerMemo memo;
  const MiniMemoNote({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -5 * math.pi / 180,
      child: StickyPaper(
        color: memo.color,
        width: 58,
        height: 30,
        radius: 4,
        foldSize: 6,
        tapeSize: const Size(24, 8),
        padding: const EdgeInsets.fromLTRB(5, 6, 5, 3),
        child: Center(
          child: Text(
            memo.headline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: MemoFont.title,
              fontWeight: MemoFont.titleWeight,
              fontSize: 8,
              height: 1.2,
              color: MemoFont.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// まだ貼っていないときの白紙の付箋の束（①）。
///
/// 開いて 0.6 秒後に一番上の 1 枚が ±4° で 1 回揺れて気づかせる。
class BlankMemoPad extends StatefulWidget {
  final VoidCallback onTap;
  const BlankMemoPad({super.key, required this.onTap});

  static const double size = 40;

  @override
  State<BlankMemoPad> createState() => _BlankMemoPadState();
}

class _BlankMemoPadState extends State<BlankMemoPad>
    with SingleTickerProviderStateMixin {
  /// 0〜0.6 秒は待つだけ，0.6〜1.0 秒で揺れる（タイマーを使わない）。
  late final AnimationController _wiggle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  static const _sheet = MemoColor(
    paper: Color(0xFFFFF0A6),
    fold: Color(0xFFF2DC72),
    tape: Color(0xFFFFC9D8),
    tapeStripe: Color(0xFFFFE3EB),
  );

  @override
  Widget build(BuildContext context) {
    const s = BlankMemoPad.size;
    Widget sheet(Color c) => Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      label: '付箋メモを貼る',
      child: GestureDetector(
        key: const Key('memo_blank_pad'),
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: s + 8,
          height: s + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 6,
                top: 6,
                child: Transform.rotate(
                  angle: 8 * math.pi / 180,
                  child: sheet(const Color(0xFFFFDCE6)),
                ),
              ),
              Positioned(
                left: 3,
                top: 3,
                child: Transform.rotate(
                  angle: 3 * math.pi / 180,
                  child: sheet(const Color(0xFFD9EEFF)),
                ),
              ),
              AnimatedBuilder(
                animation: _wiggle,
                builder: (context, child) {
                  final t = ((_wiggle.value - 0.6) / 0.4).clamp(0.0, 1.0);
                  final angle = math.sin(t * math.pi * 3) * (1 - t) * 4;
                  return Transform.rotate(
                    angle: (angle - 4) * math.pi / 180,
                    alignment: Alignment.topCenter,
                    child: child,
                  );
                },
                child: StickyPaper(
                  color: _sheet,
                  width: s,
                  height: s,
                  radius: 6,
                  foldSize: 7,
                  tapeSize: Size.zero,
                  padding: const EdgeInsets.only(top: 3),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '＋',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: MemoFont.ink,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'メモ',
                        style: TextStyle(
                          fontFamily: MemoFont.title,
                          fontWeight: MemoFont.titleWeight,
                          fontSize: 8,
                          height: 1.1,
                          color: MemoFont.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
