import 'package:flutter/material.dart';

import 'package:passly/core/constants/passly_tokens.dart';

/// 「共通点のある人 3 / すべて 4」の切り替え。
///
/// 灰色のトラックの中を、白いピルが選ばれている側へすべって移動する。
/// 各セグメントの色をフェードさせると白→透明の途中で灰色に点滅して見えるため、
/// ピルは 1 枚だけにして位置だけを動かす。
class PasslySegmentedSwitch extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const PasslySegmentedSwitch({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final count = labels.length;
    final x = count > 1 ? -1 + 2 * selectedIndex / (count - 1) : 0.0;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: PasslyBorder.defaultBorder,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment(x, 0),
            child: FractionallySizedBox(
              widthFactor: 1 / count,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: PasslyBg.surface,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (int i = 0; i < count; i++)
                Expanded(
                  child: _Segment(
                    label: labels[i],
                    selected: i == selectedIndex,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: PasslyFont.family,
            color: selected ? PasslyText.primary : const Color(0xFF4B5563),
            fontSize: 14,
            fontWeight: selected ? PasslyFont.bold : PasslyFont.regular,
          ),
        ),
      ),
    );
  }
}
