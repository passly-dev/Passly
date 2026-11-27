import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:passly/features/memo/domain/partner_memo.dart';
import 'package:passly/features/memo/presentation/memo_editor.dart';
import 'package:passly/features/memo/presentation/sticky_note.dart';

/// 相手プロフィールのカバー右下に置く付箋メモ。
///
/// まだ貼っていなければ白紙の付箋の束（①），押すと書く画面（②）。
/// 「貼る」で付箋が小さくなりながら右下へ飛び，-5° に傾いて「ペタッ」と貼られる
/// （0.35 秒，easeOutBack，貼った瞬間に lightImpact）。テープは 0.1 秒遅れて乗る（③）。
class PartnerMemoCorner extends ConsumerStatefulWidget {
  final String userId;

  /// 書く画面の下に出す日付（例: 3月11日 SysHack2026）。
  final String longDateLabel;

  /// 貼った付箋の下に出す日付（例: 3/11）。
  final String shortDateLabel;

  const PartnerMemoCorner({
    super.key,
    required this.userId,
    required this.longDateLabel,
    required this.shortDateLabel,
  });

  @override
  ConsumerState<PartnerMemoCorner> createState() => _PartnerMemoCornerState();
}

class _PartnerMemoCornerState extends ConsumerState<PartnerMemoCorner>
    with SingleTickerProviderStateMixin {
  /// 貼る動き。最初から貼ってあるときは終わった状態（1）から始める。
  late final AnimationController _stick = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    value: 1,
  );
  final GlobalKey _anchor = GlobalKey();

  /// 貼った瞬間（飛び終わり）に 1 回だけ振動させる。
  bool _pendingThud = false;

  @override
  void initState() {
    super.initState();
    _stick.addListener(() {
      if (_pendingThud && _stick.value >= 0.78) {
        _pendingThud = false;
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _stick.dispose();
    super.dispose();
  }

  Rect? _anchorRect() {
    final box = _anchor.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _open(PartnerMemo? current) async {
    HapticFeedback.selectionClick();
    final result = await showMemoEditor(
      context,
      initial: current,
      dateLabel: widget.longDateLabel,
      from: _anchorRect(),
    );
    if (!mounted || result == null) return;
    final notifier = ref.read(partnerMemosProvider.notifier);
    switch (result) {
      case MemoPasted(:final memo):
        await notifier.save(widget.userId, memo);
        if (!mounted) return;
        _stick.value = 0;
        _pendingThud = true;
        _stick.forward();
      case MemoPeeled():
        await notifier.remove(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final memo = ref.watch(partnerMemoProvider(widget.userId));

    if (memo == null) {
      // 束はカバーのふちにかかる高さに置く。
      return Padding(
        padding: const EdgeInsets.only(top: 40, right: 6),
        child: KeyedSubtree(
          key: _anchor,
          child: BlankMemoPad(onTap: () => _open(null)),
        ),
      );
    }

    return GestureDetector(
      key: const Key('memo_stuck_note'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(memo),
      child: AnimatedBuilder(
        animation: _stick,
        builder: (context, child) {
          // 0〜0.78（0.35 秒）: 飛んで貼られる／0.78〜1（0.1 秒）: テープが乗る。
          final fly = Curves.easeOutBack.transform(
            (_stick.value / 0.78).clamp(0.0, 1.0),
          );
          final tape = ((_stick.value - 0.78) / 0.22).clamp(0.0, 1.0);
          final scale = 1.9 - 0.9 * fly;
          final angle = -5 * fly * math.pi / 180;
          final offset = Offset(-90 * (1 - fly), 120 * (1 - fly));
          return Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: angle,
              child: Transform.scale(
                scale: scale,
                child: StuckMemoNote(
                  key: _anchor,
                  memo: memo,
                  dateLabel: widget.shortDateLabel,
                  tapeOpacity: tape,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
