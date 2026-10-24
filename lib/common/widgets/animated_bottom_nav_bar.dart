import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syshack2026/core/constants/app_colors.dart';

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });

  IconData get floatingIcon => activeIcon ?? icon;
}

class AnimatedBottomNavBar extends StatefulWidget {
  // 高さ計算のために外部から参照可能な定数
  static const double circleR = 28.0;
  static const double barH = 64.0;
  static const double protrude = 18.0;

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  final Color activeColor;
  final Color inactiveColor;
  final Color barColor;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.textDisabled,
    this.barColor = Colors.white,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _posAnim;

  static const double _circleR = AnimatedBottomNavBar.circleR;
  static const double _barH = AnimatedBottomNavBar.barH;
  static const double _protrude = AnimatedBottomNavBar.protrude;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _posAnim = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedBottomNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _posAnim =
          Tween<double>(
            begin: _posAnim.value,
            end: widget.currentIndex.toDouble(),
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: _protrude + _barH + bp,
      child: AnimatedBuilder(
        animation: _posAnim,
        builder: (ctx, _) => LayoutBuilder(
          builder: (ctx, constraints) {
            final totalW = constraints.maxWidth;
            final itemW = totalW / widget.items.length;
            final notchX = (_posAnim.value + 0.5) * itemW;

            return Stack(
              children: [
                // ノッチ付きバー背景
                Positioned(
                  top: _protrude,
                  left: 0,
                  right: 0,
                  height: _barH + bp,
                  child: CustomPaint(
                    painter: _NotchedBarPainter(
                      notchX: notchX,
                      circleR: _circleR,
                      protrude: _protrude,
                      color: widget.barColor,
                    ),
                  ),
                ),

                // タブアイテム（非アクティブ）
                Positioned(
                  top: _protrude,
                  left: 0,
                  right: 0,
                  height: _barH,
                  child: Row(
                    children: List.generate(widget.items.length, (i) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onTap(i),
                          behavior: HitTestBehavior.opaque,
                          child: i == widget.currentIndex
                              ? _ActiveSlot(
                                  label: widget.items[i].label,
                                  color: widget.activeColor,
                                  circleR: _circleR,
                                  protrude: _protrude,
                                  barH: _barH,
                                )
                              : _InactiveSlot(
                                  item: widget.items[i],
                                  color: widget.inactiveColor,
                                ),
                        ),
                      );
                    }),
                  ),
                ),

                // 浮かぶ円（アクティブタブ）
                Positioned(
                  top: 0,
                  left: notchX - _circleR,
                  child: GestureDetector(
                    onTap: () => widget.onTap(widget.currentIndex),
                    child: Container(
                      width: _circleR * 2,
                      height: _circleR * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.activeColor,
                        boxShadow: [
                          BoxShadow(
                            color: widget.activeColor.withValues(alpha: 0.4),
                            blurRadius: 14,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.items[widget.currentIndex].floatingIcon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// アクティブタブ：ノッチ部分は空白にしてラベルだけ下部に表示
class _ActiveSlot extends StatelessWidget {
  final String label;
  final Color color;
  final double circleR;
  final double protrude;
  final double barH;

  const _ActiveSlot({
    required this.label,
    required this.color,
    required this.circleR,
    required this.protrude,
    required this.barH,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: barH,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// 非アクティブタブ：アイコン＋ラベル
class _InactiveSlot extends StatelessWidget {
  final BottomNavItem item;
  final Color color;

  const _InactiveSlot({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon, color: color, size: 22),
        const SizedBox(height: 3),
        Text(item.label, style: TextStyle(color: color, fontSize: 10)),
      ],
    );
  }
}

/// ノッチ付きバーをCustomPainterで描画
class _NotchedBarPainter extends CustomPainter {
  final double notchX;
  final double circleR;
  final double protrude;
  final Color color;

  _NotchedBarPainter({
    required this.notchX,
    required this.circleR,
    required this.protrude,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ノッチのサイズと深さ
    final notchR = circleR + 8.0; // 円より少し大きめのノッチ
    final depth = circleR * 2 - protrude + 8.0; // バー上端からのノッチの深さ
    final entryX = notchX - notchR;
    final exitX = notchX + notchR;

    final path = Path();
    path.moveTo(0, 0);

    // 左端からノッチ入り口まで
    if (entryX > 0) path.lineTo(entryX, 0);

    // 左側の曲線（なめらかにノッチへ入る）
    path.quadraticBezierTo(
      notchX - notchR * 0.55,
      0,
      notchX - notchR * 0.2,
      depth * 0.6,
    );

    // ノッチの底部
    path.quadraticBezierTo(
      notchX,
      depth + 4,
      notchX + notchR * 0.2,
      depth * 0.6,
    );

    // 右側の曲線（ノッチから出る）
    path.quadraticBezierTo(
      notchX + notchR * 0.55,
      0,
      math.min(size.width, exitX),
      0,
    );

    // 右端まで
    if (exitX < size.width) path.lineTo(size.width, 0);

    // バーの下辺
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // バー上部に広がるシャドウ
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // バー本体（シャドウの上に重ねる）
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_NotchedBarPainter old) => old.notchX != notchX;
}
