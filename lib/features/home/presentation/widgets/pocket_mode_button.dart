import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:passly/common/widgets/press_feedback.dart';
import 'package:passly/core/constants/passly_tokens.dart';
import 'package:passly/features/ble/domain/power_mode_notifier.dart';

/// ナビゲーションバーの右上に浮かぶポケットモードの切り替えボタン
/// （Figma node 1950:1787「ポケットモード A案」）。
///
/// 直径 52 の白い丸にリュックのアイコン。ON は緑のアイコン + 右上の緑の点、
/// OFF は灰色のアイコンで点なし。タップで ON / OFF を切り替え、
/// 切り替えた直後だけボタンの上に「ポケットモード ON / OFF」を約 2 秒出す。
class PocketModeButton extends ConsumerStatefulWidget {
  const PocketModeButton({super.key});

  @override
  ConsumerState<PocketModeButton> createState() => _PocketModeButtonState();
}

class _PocketModeButtonState extends ConsumerState<PocketModeButton> {
  static const double _diameter = 52;

  bool _showLabel = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _toggle() {
    ref.read(powerModeProvider.notifier).toggle();
    _hideTimer?.cancel();
    setState(() => _showLabel = true);
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showLabel = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOn = ref.watch(powerModeProvider) == PowerMode.pocket;

    // Scaffold の外（画面全体の Stack）に置くので、Material がないと
    // 文字に黄色の二重下線（デバッグ用の警告表示）が付く。透明な Material で包む。
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showLabel ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: PasslyText.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  isOn ? 'ポケットモード ON' : 'ポケットモード OFF',
                  style: const TextStyle(
                    fontFamily: PasslyFont.family,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PasslyText.onBrand,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: PressFeedback(
              child: SizedBox(
                width: _diameter,
                height: _diameter,
                child: Stack(
                  children: [
                    Container(
                      width: _diameter,
                      height: _diameter,
                      decoration: BoxDecoration(
                        color: PasslyBg.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF858E85,
                            ).withValues(alpha: 0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.backpack_outlined,
                        size: 22,
                        color: isOn
                            ? PasslyBrand.primary
                            : PasslyText.secondary,
                      ),
                    ),
                    if (isOn)
                      Positioned(
                        left: 36,
                        top: 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: PasslyBrand.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: PasslyBg.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
