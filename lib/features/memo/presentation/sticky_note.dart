import 'dart:math' as math;
import 'dart:typed_data';

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

  /// 右下の角からめくれている量（0〜1）。0 ならめくれていない。
  final double curl;
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
    this.curl = 0,
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
            child: _curled(
              CustomPaint(
                painter: _PaperPainter(
                  color: color,
                  radius: radius,
                  foldSize: curl > 0 ? 0 : foldSize,
                ),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Padding(padding: padding, child: child),
                ),
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

extension on StickyPaper {
  Widget _curled(Widget paper) {
    if (curl <= 0) return paper;
    final geo = _CurlGeometry(curl);
    return CustomPaint(
      foregroundPainter: _CurlPainter(geo, color, radius),
      child: ClipPath(clipper: _CurlClipper(geo, radius), child: paper),
    );
  }
}

/// 右下の角を左上へ折り返したときの形。
///
/// 角 C が C' へ動くとして，折り目は C と C' の垂直二等分線。
/// 折り目より角の側の紙を，折り目で裏返した位置に「裏側」として描く。
class _CurlGeometry {
  final double amount;
  const _CurlGeometry(this.amount);

  /// めくれていく向き（右下 → 左上，少し上より）。
  static final Offset _dir = () {
    const d = Offset(-0.75, -1);
    return d / d.distance;
  }();

  /// 折り目の中点と向き。
  ({Offset mid, Offset dir, Offset corner, Offset tip}) solve(Size size) {
    final corner = Offset(size.width, size.height);
    // 紙のいちばん遠い点（左上）までの長さ。
    final reach = -(corner.dx * _dir.dx + corner.dy * _dir.dy);
    final travel = 2 * reach * amount;
    final tip = corner + _dir * travel;
    return (mid: (corner + tip) / 2, dir: _dir, corner: corner, tip: tip);
  }

  /// 折り目より角の側（めくれて裏返る部分）の半平面。
  Path cornerSide(Size size) {
    final g = solve(size);
    final n = g.dir;
    final along = Offset(-n.dy, n.dx);
    const far = 2000.0;
    return Path()
      ..moveTo(g.mid.dx + along.dx * far, g.mid.dy + along.dy * far)
      ..lineTo(g.mid.dx - along.dx * far, g.mid.dy - along.dy * far)
      ..lineTo(
        g.mid.dx - along.dx * far - n.dx * far,
        g.mid.dy - along.dy * far - n.dy * far,
      )
      ..lineTo(
        g.mid.dx + along.dx * far - n.dx * far,
        g.mid.dy + along.dy * far - n.dy * far,
      )
      ..close();
  }

  /// 折り目で裏返す行列。
  Float64List reflect(Size size) {
    final g = solve(size);
    final n = g.dir;
    final m = g.mid;
    // p' = p - 2 ((p - m)・n) n
    final a = 1 - 2 * n.dx * n.dx;
    final b = -2 * n.dx * n.dy;
    final d = 1 - 2 * n.dy * n.dy;
    final k = 2 * (m.dx * n.dx + m.dy * n.dy);
    final tx = k * n.dx;
    final ty = k * n.dy;
    return Float64List.fromList([
      a, b, 0, 0, //
      b, d, 0, 0, //
      0, 0, 1, 0, //
      tx, ty, 0, 1,
    ]);
  }
}

Path _paperShape(Size size, double radius) => Path()
  ..addRRect(
    RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
  );

class _CurlClipper extends CustomClipper<Path> {
  final _CurlGeometry geo;
  final double radius;
  _CurlClipper(this.geo, this.radius);

  @override
  Path getClip(Size size) => Path.combine(
    PathOperation.difference,
    Path()..addRect((Offset.zero & size).inflate(20)),
    geo.cornerSide(size),
  );

  @override
  bool shouldReclip(_CurlClipper old) => old.geo.amount != geo.amount;
}

class _CurlPainter extends CustomPainter {
  final _CurlGeometry geo;
  final MemoColor color;
  final double radius;
  _CurlPainter(this.geo, this.color, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final g = geo.solve(size);
    final paper = _paperShape(size, radius);
    final removed = Path.combine(
      PathOperation.intersect,
      paper,
      geo.cornerSide(size),
    );
    final flap = removed.transform(geo.reflect(size));
    final flapOnPaper = flap;

    // 折り目のすぐ内側に落ちる影（紙が浮いて見える）。
    final shadeBand = Path.combine(
      PathOperation.intersect,
      Path.combine(PathOperation.difference, paper, geo.cornerSide(size)),
      Path()..addRect(Offset.zero & size),
    );
    canvas.save();
    canvas.clipPath(shadeBand);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.12 * (1 - geo.amount * 0.5)),
          ],
          stops: const [0.55, 1],
        ).createShader(Rect.fromPoints(g.mid + g.dir * 40, g.mid)),
    );
    canvas.restore();

    // めくれた紙の影と裏側。
    canvas.drawShadow(flapOnPaper, const Color(0xFF000000), 6, false);
    final back = Color.lerp(color.paper, Colors.white, 0.55)!;
    canvas.drawPath(
      flapOnPaper,
      Paint()
        ..shader = LinearGradient(
          colors: [Color.lerp(color.fold, back, 0.2)!, back, back],
          stops: const [0, 0.35, 1],
        ).createShader(Rect.fromPoints(g.mid, g.tip)),
    );
    // 折り目の線をうっすら。
    canvas.drawPath(
      flapOnPaper,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = color.fold.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(_CurlPainter old) =>
      old.geo.amount != geo.amount || old.color != color;
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
