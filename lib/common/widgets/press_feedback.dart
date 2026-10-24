import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';

class PressFeedback extends StatefulWidget {
  final Widget child;

  const PressFeedback({super.key, required this.child});

  @override
  State<PressFeedback> createState() => _PressFeedbackState();
}

class _PressFeedbackState extends State<PressFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _press() {
    _controller.forward(from: 0);
  }

  void _release() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.hasBoundedWidth
                  ? constraints.maxWidth
                  : 0.0;
              final height = constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 0.0;
              final diameter =
                  math.min(width, height) * 0.5 * _controller.value;

              return Stack(
                fit: StackFit.passthrough,
                clipBehavior: Clip.hardEdge,
                children: [
                  widget.child,
                  if (diameter > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: diameter,
                            height: diameter,
                            decoration: BoxDecoration(
                              color: PasslyText.secondary.withValues(
                                alpha: 0.28,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
