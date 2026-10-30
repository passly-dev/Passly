import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:passly/common/widgets/press_feedback.dart';
import 'package:passly/core/constants/passly_tokens.dart';
import 'package:passly/features/ble/domain/power_mode_notifier.dart';

/// ナビゲーションバーの右上に浮かぶポケットモードの切り替えボタン
/// （Figma node 1945:1380「ポケットモード 確定案B」）。
///
/// ON: リュックと状態を緑で「ON・すれ違い中」。OFF: 灰色で「OFF」。
/// タップで ON / OFF を切り替える。
class PocketModeButton extends ConsumerWidget {
  const PocketModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOn = ref.watch(powerModeProvider) == PowerMode.pocket;
    final accent = isOn ? PasslyBrand.primary : PasslyText.secondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(powerModeProvider.notifier).toggle(),
      child: PressFeedback(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
          decoration: BoxDecoration(
            color: PasslyBg.surface,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF858E85).withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.backpack_outlined, size: 22, color: accent),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ポケットモード',
                    style: TextStyle(
                      fontFamily: PasslyFont.family,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: PasslyText.primary,
                    ),
                  ),
                  Text(
                    isOn ? 'ON・すれ違い中' : 'OFF',
                    style: TextStyle(
                      fontFamily: PasslyFont.family,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
