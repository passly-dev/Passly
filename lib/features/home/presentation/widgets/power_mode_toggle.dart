import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/common/widgets/press_feedback.dart';

import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/features/ble/domain/power_mode_notifier.dart';

/// ホームヘッダー右上の 2 タブセグメンテッドコントロール。
///
/// 左: ☀️ 通常使用 (アクティブ時は画面が消えないように WakelockPlus + advertise が停止)。
/// 右: 🌙 ポケット中 (画面が消えても BLE が動くように擬似フォアグラウンド起動)。
///
/// アクティブ側は `PasslyBrand.primaryLight` の背景と白アイコン、非アクティブは
/// 透明背景と `PasslyText.secondary`。極力アイコンだけで状態が分かる UX。
class PowerModeToggle extends ConsumerWidget {
  const PowerModeToggle({super.key});

  static const double _height = 32;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(powerModeProvider);
    final notifier = ref.read(powerModeProvider.notifier);

    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: PasslyBorder.divider,
        borderRadius: BorderRadius.circular(_height / 2),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            icon: Icons.wb_sunny_outlined,
            tooltip: '通常使用',
            active: mode == PowerMode.normal,
            onTap: () => notifier.set(PowerMode.normal),
          ),
          _Segment(
            icon: Icons.backpack_outlined,
            tooltip: 'ポケット中',
            active: mode == PowerMode.pocket,
            onTap: () => notifier.set(PowerMode.pocket),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  const _Segment({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  static const double _diameter = 28;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      size: 16,
      color: active ? Colors.white : AppColors.textSecondary,
    );
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: PressFeedback(
          child: Container(
            width: _diameter,
            height: _diameter,
            decoration: BoxDecoration(
              color: active ? PasslyBrand.primaryLight : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
        ),
      ),
    );
  }
}
