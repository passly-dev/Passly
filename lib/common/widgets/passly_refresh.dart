import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passly/common/widgets/sized_network_image.dart';
import 'package:passly/common/widgets/tag_sticker.dart';
import 'package:passly/core/constants/passly_tokens.dart';

/// 引っぱって更新の見せ方。
enum PasslyRefreshStyle {
  /// A: 2人のアイコンが近づき，読み込み中は入れかわる（すれ違う）。
  encounter,

  /// C: タグのステッカーが1枚ずつ貼られ，読み込み中はくるっと裏返る。
  sticker,
}

/// アプリ全体で使う見せ方（案を見比べるあいだだけ切りかえられるようにしておく）。
final passlyRefreshStyleProvider = Provider<PasslyRefreshStyle>(
  (ref) => PasslyRefreshStyle.encounter,
);

/// 引っぱって更新に出す人（アイコンがなければ頭文字の丸）。
typedef RefreshPerson = ({String iconUrl, String name});

/// アプリ共通の「引っぱって更新」。
///
/// [RefreshIndicator] の代わりに使う。一覧ごと下にずらし，空いた上の場所に
/// [style] の動きを出す。終わったら一覧を戻してから [onDone] を呼ぶので，
/// すれ違いの通知（上から下りてくるバナー）はそこで出す。
class PasslyRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final VoidCallback? onDone;
  final PasslyRefreshStyle style;

  /// A で近づく2人（自分と，最近すれ違った人）。
  final RefreshPerson? me;
  final RefreshPerson? other;

  /// C で貼るステッカー（自分のタグから3つ）。
  final List<String> stickerTags;

  const PasslyRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.onDone,
    this.style = PasslyRefreshStyle.encounter,
    this.me,
    this.other,
    this.stickerTags = const [],
  });

  /// ここまで引っぱると，はなしたときに更新する。
  static const double trigger = 84;

  /// 読み込み中に空けておく高さ。
  static const double hold = 84;

  /// 一覧をこれ以上は下げない。
  static const double maxPull = 132;

  /// 読み込みが速くても，動きが一回りは見えるようにする。
  static const Duration minLoading = Duration(milliseconds: 1200);

  @override
  State<PasslyRefresh> createState() => _PasslyRefreshState();
}

enum _Phase { idle, pulling, armed, loading, done }

class _PasslyRefreshState extends State<PasslyRefresh>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.idle;
  double _pull = 0;

  /// はなしたあとの一覧の位置（読み込み位置へ／元へ戻す）。
  late final AnimationController _settle = AnimationController.unbounded(
    vsync: this,
  )..addListener(() => setState(() => _pull = _settleTween.evaluate(_settle)));
  Tween<double> _settleTween = Tween(begin: 0, end: 0);

  /// 読み込み中のくり返し（0→1 を回す）。
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: widget.style == PasslyRefreshStyle.encounter
        ? const Duration(milliseconds: 900)
        : const Duration(milliseconds: 1100),
  );

  /// 終わったときに消えていく動き。
  late final AnimationController _out = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void dispose() {
    _settle.dispose();
    _loop.dispose();
    _out.dispose();
    super.dispose();
  }

  double get _progress => (_pull / PasslyRefresh.trigger).clamp(0.0, 1.0);

  bool get _busy => _phase == _Phase.loading || _phase == _Phase.done;

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || _busy) return false;

    if (n is OverscrollNotification &&
        n.dragDetails != null &&
        n.overscroll < 0 &&
        n.metrics.extentBefore == 0) {
      // 上の端で下に引っぱっている。指より少し重く動かす
      _settle.stop();
      final resist = 1 - (_pull / PasslyRefresh.maxPull) * 0.6;
      _setPull(_pull - n.overscroll * 0.55 * resist);
    } else if (n is ScrollUpdateNotification &&
        n.dragDetails != null &&
        _pull > 0 &&
        (n.scrollDelta ?? 0) > 0) {
      // 引っぱったまま指を戻した
      _setPull(_pull - n.scrollDelta!);
    } else if (n is ScrollEndNotification && _pull > 0) {
      _release();
    }
    return false;
  }

  void _setPull(double v) {
    final next = v.clamp(0.0, PasslyRefresh.maxPull);
    final armed = next >= PasslyRefresh.trigger;
    final phase = next == 0
        ? _Phase.idle
        : armed
        ? _Phase.armed
        : _Phase.pulling;
    if (phase == _Phase.armed && _phase != _Phase.armed) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _pull = next;
      _phase = phase;
    });
  }

  Future<void> _animatePull(double to, Duration d, Curve curve) {
    _settleTween = Tween(begin: _pull, end: to);
    _settle.duration = d;
    return _settle
        .animateWith(_CurvedSim(curve, d))
        .orCancel
        .catchError((_) {});
  }

  Future<void> _release() async {
    if (_phase != _Phase.armed) {
      await _animatePull(
        0,
        const Duration(milliseconds: 260),
        Curves.easeOutCubic,
      );
      if (mounted && !_busy) setState(() => _phase = _Phase.idle);
      return;
    }
    setState(() => _phase = _Phase.loading);
    _loop.repeat();
    final started = DateTime.now();
    await Future.wait([
      _animatePull(
        PasslyRefresh.hold,
        const Duration(milliseconds: 300),
        Curves.easeOutBack,
      ),
      widget.onRefresh().catchError((_) {}),
    ]);
    final waited = DateTime.now().difference(started);
    if (waited < PasslyRefresh.minLoading) {
      await Future<void>.delayed(PasslyRefresh.minLoading - waited);
    }
    if (!mounted) return;

    // 動きを止めて上へ消し，一覧を戻してから通知を出す
    setState(() => _phase = _Phase.done);
    _loop.stop();
    await _out.forward(from: 0).orCancel.catchError((_) {});
    await _animatePull(
      0,
      const Duration(milliseconds: 280),
      Curves.easeOutCubic,
    );
    if (!mounted) return;
    setState(() => _phase = _Phase.idle);
    _out.value = 0;
    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(context).copyWith(
      // どの端末でも同じ動きにするため，はね返りと端の光は使わない
      physics: const ClampingScrollPhysics(),
      overscroll: false,
    );
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: math.max(_pull, 0),
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.bottomCenter,
              minHeight: PasslyRefresh.hold,
              maxHeight: PasslyRefresh.hold,
              child: _phase == _Phase.idle
                  ? const SizedBox.shrink()
                  : AnimatedBuilder(
                      animation: Listenable.merge([_loop, _out]),
                      builder: (context, _) => _indicator(),
                    ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, _pull),
          child: ScrollConfiguration(
            behavior: behavior,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }

  String get _label => switch (_phase) {
    _Phase.armed => 'はなすと更新',
    _Phase.loading || _Phase.done =>
      widget.style == PasslyRefreshStyle.encounter ? 'すれ違い中…' : '更新中…',
    _ => '引っぱって更新',
  };

  Widget _indicator() {
    final out = Curves.easeInCubic.transform(_out.value);
    return Opacity(
      opacity: 1 - out,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 52,
            child: switch (widget.style) {
              PasslyRefreshStyle.encounter => _EncounterIndicator(
                me: widget.me,
                other: widget.other,
                progress: _progress,
                armed: _phase == _Phase.armed,
                loading: _phase == _Phase.loading,
                loop: _loop.value,
                out: out,
              ),
              PasslyRefreshStyle.sticker => _StickerIndicator(
                tags: widget.stickerTags,
                progress: _progress,
                armed: _phase == _Phase.armed,
                loading: _phase == _Phase.loading,
                loop: _loop.value,
                out: out,
              ),
            },
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Text(
              _label,
              key: ValueKey(_label),
              style: TextStyle(
                fontFamily: PasslyFont.family,
                fontSize: 11,
                fontWeight: PasslyFont.bold,
                color: _phase == _Phase.idle || _phase == _Phase.pulling
                    ? const Color(0xFF8A9099)
                    : PasslyBrand.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 曲線つきで 0→1 に進めるシミュレーション（[AnimationController.animateWith] 用）。
class _CurvedSim extends Simulation {
  _CurvedSim(this.curve, Duration d) : _secs = d.inMicroseconds / 1e6;
  final Curve curve;
  final double _secs;

  @override
  double x(double t) => curve.transform((t / _secs).clamp(0.0, 1.0));

  @override
  double dx(double t) => 0;

  @override
  bool isDone(double t) => t >= _secs;
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

// ---------------------------------------------------------------- A

class _EncounterIndicator extends StatelessWidget {
  const _EncounterIndicator({
    required this.me,
    required this.other,
    required this.progress,
    required this.armed,
    required this.loading,
    required this.loop,
    required this.out,
  });

  final RefreshPerson? me;
  final RefreshPerson? other;
  final double progress;
  final bool armed;
  final bool loading;
  final double loop;
  final double out;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    // 引っぱる間は左右から近づく。読み込み中は左右を入れかえ続ける
    double dx;
    double dy = 0;
    if (loading || out > 0) {
      // 行って戻る（0→0.5 で入れかわり，0.5→1 で戻る）
      final half = loop < 0.5 ? loop * 2 : (1 - loop) * 2;
      final e = Curves.easeInOut.transform(half);
      dx = _lerp(22, -22, e);
      dy = math.sin(e * math.pi) * 7;
    } else {
      dx = _lerp(118, 22, Curves.easeOut.transform(progress));
    }
    final opacity = loading || out > 0 ? 1.0 : _lerp(0.4, 1, progress);
    final scale = _lerp(1, 0.55, out);
    final lift = -26 * out;

    // すれ違う瞬間（入れかわりの真ん中）に火花を出す
    final crossing = loading ? (loop < 0.5 ? loop * 2 : (1 - loop) * 2) : 0.0;
    final spark = (1 - (crossing - 0.5).abs() / 0.25).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // 引っぱり切ったら後ろに緑のうすい光
        AnimatedOpacity(
          opacity: armed || loading ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 120,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(999),
              gradient: RadialGradient(
                colors: [
                  PasslyBrand.primary.withValues(alpha: 0.22),
                  PasslyBrand.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        if (spark > 0)
          for (var i = 0; i < 6; i++)
            Transform.translate(
              offset: Offset.fromDirection(
                i * math.pi / 3 + math.pi / 6,
                8 + 18 * (1 - spark),
              ),
              child: Opacity(
                opacity: spark,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: PasslyBrand.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        Transform.translate(
          offset: Offset(-dx, -dy + lift),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: _Avatar(person: me, size: _size),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(dx, dy + lift),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: _Avatar(person: other, size: _size),
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.person, required this.size});
  final RefreshPerson? person;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = person;
    final initial = Center(
      child: Text(
        p == null || p.name.trim().isEmpty
            ? '?'
            : p.name.trim().characters.first,
        style: const TextStyle(
          fontFamily: PasslyFont.family,
          color: PasslyBrand.primaryDark,
          fontSize: 15,
          fontWeight: PasslyFont.bold,
        ),
      ),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PasslyBrand.primarySurface,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: p == null || p.iconUrl.isEmpty
          ? initial
          : SizedNetworkImage(
              url: p.iconUrl,
              fit: BoxFit.cover,
              fallback: (_) => initial,
            ),
    );
  }
}

// ---------------------------------------------------------------- C

class _StickerIndicator extends StatelessWidget {
  const _StickerIndicator({
    required this.tags,
    required this.progress,
    required this.armed,
    required this.loading,
    required this.loop,
    required this.out,
  });

  final List<String> tags;
  final double progress;
  final bool armed;
  final bool loading;
  final double loop;
  final double out;

  static const double _size = 38;
  static const List<double> _angles = [-8, 0, 8];

  @override
  Widget build(BuildContext context) {
    final shown = tags.take(3).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          _slot(i, i < shown.length ? shown[i] : null),
        ],
      ],
    );
  }

  Widget _slot(int i, String? tag) {
    // 引っぱる量 1/3 ごとに1枚ずつ貼る
    final placed = loading || out > 0 || progress >= (i + 1) / 3 - 0.001;
    // 1枚ずつ 0.15 秒ずらして裏返す（1 周 1.1 秒のうち 0.5 秒）
    var flip = 0.0;
    if (loading) {
      final local = (loop * 1.1 - i * 0.15) / 0.5;
      if (local > 0 && local < 1) {
        flip = Curves.easeInOut.transform(local) * 2 * math.pi;
      }
    }
    // 終わったら上（通知が下りてくる方）へ吸いこまれる
    final o = Curves.easeIn.transform((out * 1.4 - i * 0.15).clamp(0.0, 1.0));

    return SizedBox(
      width: _size + 8,
      height: _size + 8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!placed) const _DashedSlot(size: _size),
          AnimatedScale(
            scale: placed ? 1 : 0.3,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: placed ? 1 : 0,
              duration: const Duration(milliseconds: 140),
              child: TweenAnimationBuilder<double>(
                // 3枚そろったら少し跳ねる
                key: ValueKey(armed),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 360),
                builder: (context, t, child) {
                  final hop = armed ? math.sin(t * math.pi) * -6 : 0.0;
                  return Transform.translate(
                    offset: Offset(0, hop - 34 * o),
                    child: Transform.scale(scale: 1 - 0.5 * o, child: child),
                  );
                },
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateZ(_angles[i] * math.pi / 180)
                    ..rotateY(flip),
                  child: tag == null
                      ? const SizedBox.shrink()
                      : TagSticker(tag: tag, size: _size, tilt: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedSlot extends StatelessWidget {
  const _DashedSlot({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _DashPainter());
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC5CAD1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      );
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
