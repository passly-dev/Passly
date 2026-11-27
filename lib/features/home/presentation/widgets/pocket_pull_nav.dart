import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passly/core/constants/passly_tokens.dart';
import 'package:passly/features/ble/domain/power_mode_notifier.dart';

/// ナビを上に引くと，ナビのうしろから緑の「ポケット」が出てくる（Figma ポケットB）。
///
/// [child] にナビを渡す。ナビの上の小さなつまみが目印で，ON のときは
/// つまみの横に緑の点が付く。スイッチを入れるとスマホの絵がポケットに落ち，
/// 少したってポケットがナビのうしろへしまわれる。
///
/// [onProgress] にポケットの出ぐあい（0〜1）を渡すので，うしろを暗くするときに使う。
class PocketPullNav extends ConsumerStatefulWidget {
  final Widget child;
  final ValueChanged<double>? onProgress;

  /// はじめて出したときだけ，ポケットが2回顔を出して引き方を教えるか。
  final bool showFirstHint;

  const PocketPullNav({
    super.key,
    required this.child,
    this.onProgress,
    this.showFirstHint = true,
  });

  /// 案内を出したことを覚えておくキー。
  static const String hintShownKey = 'pocket_pull_hint_shown';

  static const double navHeight = 64;
  static const double pocketWidth = 300;
  static const double pocketHeight = 150;

  /// 出し切ったとき，ナビより上に見えるポケットの高さ。
  static const double reveal = 118;

  @override
  ConsumerState<PocketPullNav> createState() => PocketPullNavState();
}

class PocketPullNavState extends ConsumerState<PocketPullNav>
    with TickerProviderStateMixin {
  /// ポケットの出ぐあい（0＝しまっている，1＝出し切った）。
  late final AnimationController _open = AnimationController.unbounded(
    vsync: this,
  )..addListener(_changed);

  /// スマホがポケットに落ちる動き（0＝上で待つ，1＝中に入った）。
  late final AnimationController _drop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  /// 落ちたときにポケットが少しつぶれる動き。
  late final AnimationController _squash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  /// スマホが上でゆらゆら待つ動き。
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  bool _dragging = false;

  /// はじめての案内（吹き出し）を出しているか。
  bool _hint = false;

  double get progress => _open.value;

  void _changed() {
    widget.onProgress?.call(_open.value.clamp(0.0, 1.0));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (ref.read(powerModeProvider) == PowerMode.pocket) _drop.value = 1;
    if (widget.showFirstHint) _maybeShowHint();
  }

  /// はじめてのときだけ，ポケットのふちを2回のぞかせて吹き出しで教える。
  Future<void> _maybeShowHint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(PocketPullNav.hintShownKey) ?? false) return;
      await prefs.setBool(PocketPullNav.hintShownKey, true);
    } catch (_) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted || _open.value > 0) return;
    setState(() => _hint = true);
    for (var i = 0; i < 2; i++) {
      if (!mounted || _dragging) break;
      await _animateTo(0.14, const Duration(milliseconds: 220), Curves.easeOut);
      await _animateTo(0, const Duration(milliseconds: 220), Curves.easeIn);
    }
    await Future<void>.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => _hint = false);
  }

  @override
  void dispose() {
    _open.dispose();
    _drop.dispose();
    _squash.dispose();
    _bob.dispose();
    super.dispose();
  }

  Future<void> _animateTo(double to, Duration d, Curve curve) {
    return _open
        .animateTo(to, duration: d, curve: curve)
        .orCancel
        .catchError((_) {});
  }

  /// ポケットを出し切る。
  Future<void> open() async {
    _bob.repeat();
    await _animateTo(1, const Duration(milliseconds: 420), Curves.easeOutBack);
  }

  /// ポケットをナビのうしろへしまう。
  Future<void> close() async {
    await _animateTo(0, const Duration(milliseconds: 320), Curves.easeInBack);
    _bob.stop();
  }

  void _onDragStart(DragStartDetails _) {
    _dragging = true;
    if (_hint) setState(() => _hint = false);
    _open.stop();
    _bob.repeat();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    // ナビより上へはゴムのように少し重くする
    final v = _open.value - d.delta.dy / PocketPullNav.reveal;
    _open.value = v > 1 ? 1 + (v - 1) * 0.3 : math.max(0, v);
  }

  void _onDragEnd(DragEndDetails d) {
    _dragging = false;
    final velocity = d.primaryVelocity ?? 0;
    if (velocity < -300 || (velocity <= 300 && _open.value > 0.5)) {
      HapticFeedback.selectionClick();
      open();
    } else {
      close();
    }
  }

  Future<void> _toggle() async {
    final notifier = ref.read(powerModeProvider.notifier);
    final turningOn = ref.read(powerModeProvider) == PowerMode.normal;
    notifier.set(turningOn ? PowerMode.pocket : PowerMode.normal);
    if (turningOn) {
      await _drop
          .animateTo(1, curve: Curves.easeIn)
          .orCancel
          .catchError((_) {});
      HapticFeedback.mediumImpact();
      await _squash.forward(from: 0).orCancel.catchError((_) {});
    } else {
      HapticFeedback.lightImpact();
      await _drop
          .animateBack(0, curve: Curves.easeOutBack)
          .orCancel
          .catchError((_) {});
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted && !_dragging) await close();
  }

  @override
  Widget build(BuildContext context) {
    final isOn = ref.watch(powerModeProvider) == PowerMode.pocket;
    final t = _open.value;
    const navH = PocketPullNav.navHeight;
    const regionH = PocketPullNav.pocketHeight + 80;

    // 画面全体の Stack に置くので，Material がないと文字に黄色の二重下線
    // （デバッグ用の警告）が付く。透明な Material で包む。
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: navH + regionH - navH / 2,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ポケット（ナビの真ん中より上だけ見せる）
            Positioned(
              left: 0,
              right: 0,
              bottom: navH / 2,
              height: regionH,
              child: IgnorePointer(
                ignoring: t <= 0.01,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        (1 - t) * (PocketPullNav.pocketHeight + 40),
                      ),
                      child: GestureDetector(
                        onVerticalDragStart: _onDragStart,
                        onVerticalDragUpdate: _onDragUpdate,
                        onVerticalDragEnd: _onDragEnd,
                        child: _Pocket(
                          isOn: isOn,
                          drop: _drop,
                          squash: _squash,
                          bob: _bob,
                          onToggle: _toggle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ナビ（上に引くとポケットが出る）
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: navH,
              child: GestureDetector(
                key: const Key('pocket_pull_nav'),
                behavior: HitTestBehavior.translucent,
                onVerticalDragStart: _onDragStart,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: widget.child,
              ),
            ),
            // はじめての案内
            Positioned(
              left: 0,
              right: 0,
              bottom: navH + 14,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _hint ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Center(
                    child: Container(
                      key: const Key('pocket_pull_hint'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: PasslyText.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '↑ ',
                              style: TextStyle(color: Color(0xFF4ADE80)),
                            ),
                            TextSpan(text: 'ナビを上に引くと，ポケットモード'),
                          ],
                        ),
                        style: TextStyle(
                          fontFamily: PasslyFont.family,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // つまみ（ON なら横に緑の点）
            Positioned(
              top: regionH - navH / 2 + 5,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 13),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC5CAD1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 5),
                    AnimatedScale(
                      scale: isOn ? 1 : 0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutBack,
                      child: Container(
                        key: const Key('pocket_on_dot'),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: PasslyBrand.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pocket extends StatelessWidget {
  const _Pocket({
    required this.isOn,
    required this.drop,
    required this.squash,
    required this.bob,
    required this.onToggle,
  });

  final bool isOn;
  final Animation<double> drop;
  final Animation<double> squash;
  final Animation<double> bob;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([drop, squash, bob]),
      builder: (context, _) {
        final d = drop.value;
        final s = 1 - math.sin(squash.value * math.pi) * 0.04;
        final float = d == 0 ? math.sin(bob.value * 2 * math.pi) * 3 : 0.0;
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.diagonal3Values(1 / s, s, 1),
            child: SizedBox(
              width: PocketPullNav.pocketWidth,
              height: PocketPullNav.pocketHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: PasslyBrand.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                          bottom: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: CustomPaint(painter: _StitchPainter()),
                    ),
                  ),
                  // スマホ：上で傾いて待ち，ON で中へ落ちる
                  Positioned(
                    left: 26,
                    top: -24 + 46 * d + float,
                    child: Transform.rotate(
                      angle: (-8 * (1 - d)) * math.pi / 180,
                      child: const _Phone(),
                    ),
                  ),
                  Positioned(
                    left: 84,
                    top: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ポケットモード',
                          style: TextStyle(
                            fontFamily: PasslyFont.family,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '画面を消しても\nすれ違いを続けます',
                          style: TextStyle(
                            fontFamily: PasslyFont.family,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 30,
                    child: GestureDetector(
                      key: const Key('pocket_switch'),
                      onTap: onToggle,
                      child: _Switch(on: isOn),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 96,
                    child: Opacity(
                      opacity: 0.85,
                      child: Text(
                        isOn ? 'ポケットに入れたら，画面が真っ黒になります' : 'スイッチを入れて，そのままポケットへ',
                        style: const TextStyle(
                          fontFamily: PasslyFont.family,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Phone extends StatelessWidget {
  const _Phone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 64,
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: on ? Colors.white : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(13),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: on ? PasslyBrand.primary : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Offset.zero & size,
          topLeft: const Radius.circular(22),
          topRight: const Radius.circular(22),
          bottomLeft: const Radius.circular(6),
          bottomRight: const Radius.circular(6),
        ),
      );
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 11) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
