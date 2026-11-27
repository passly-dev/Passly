import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:passly/features/memo/domain/partner_memo.dart';
import 'package:passly/features/memo/presentation/sticky_note.dart';

/// 付箋を書く画面（②）の結果。
sealed class MemoEditResult {
  const MemoEditResult();
}

/// 「貼る」を押した。
class MemoPasted extends MemoEditResult {
  final PartnerMemo memo;
  const MemoPasted(this.memo);
}

/// 「はがす」を押した。
class MemoPeeled extends MemoEditResult {
  const MemoPeeled();
}

/// 付箋を書く画面を開く。
///
/// [from] は付箋の束（または貼ってある付箋）の画面上の位置。そこから 1 枚はがれて
/// 画面の真ん中で大きくなり，まっすぐになる（0.3 秒，easeOutCubic）。
/// うしろの画面の外を押したときは何も変えずに閉じる（null）。
Future<MemoEditResult?> showMemoEditor(
  BuildContext context, {
  PartnerMemo? initial,
  required String dateLabel,
  Rect? from,
}) {
  return showGeneralDialog<MemoEditResult>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '閉じる',
    barrierColor: const Color(0xFF111827).withValues(alpha: 0.72),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, _) =>
        MemoEditor(initial: initial, dateLabel: dateLabel),
    transitionBuilder: (context, animation, _, child) {
      final t = Curves.easeOutCubic.transform(animation.value);
      final screen = MediaQuery.of(context).size;
      final center = screen.center(Offset.zero);
      final origin = from?.center ?? center;
      final startScale = from == null
          ? 0.6
          : (from.width / MemoEditor.noteWidth).clamp(0.1, 1.0);
      final offset = Offset.lerp(origin - center, Offset.zero, t)!;
      final scale = startScale + (1 - startScale) * t;
      final angle = (1 - t) * -5 * math.pi / 180;
      // うしろの画面をぼかして，ボタンや文字と重ならないようにする。
      final blur = 10 * animation.value;
      return Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Opacity(
            opacity: animation.value < 0.15 ? animation.value / 0.15 : 1,
            child: Transform.translate(
              offset: offset,
              child: Transform.rotate(
                angle: angle,
                child: Transform.scale(scale: scale, child: child),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class MemoEditor extends StatefulWidget {
  final PartnerMemo? initial;
  final String dateLabel;

  const MemoEditor({super.key, this.initial, required this.dateLabel});

  static const double noteWidth = 240;

  /// よく使うことば。押すと付箋に足される。
  static const List<String> phrases = [
    '話した',
    'また話したい',
    '〇〇に詳しい',
    'LTしてた',
    '同じ学校',
  ];

  @override
  State<MemoEditor> createState() => _MemoEditorState();
}

class _MemoEditorState extends State<MemoEditor>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _title = TextEditingController(
    text: widget.initial?.title ?? '',
  );
  late final TextEditingController _body = TextEditingController(
    text: widget.initial?.body ?? '',
  );
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _bodyFocus = FocusNode();
  late int _color = widget.initial?.colorIndex ?? 0;

  /// はがす動き（1 秒）。
  /// 0〜0.62: 右下の角からめくれ上がる。
  /// 0.62: テープから紙が離れる（振動）。
  /// 0.62〜1: 紙がふわっと持ち上がって消え，テープはその場に残ってうすれる。
  late final AnimationController _peeling = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  bool _tornFelt = false;

  int get _length => _title.text.length + _body.text.length;
  int get _bodyLimit => math.max(0, PartnerMemo.maxLength - _title.text.length);
  int get _titleLimit => math.max(0, PartnerMemo.maxLength - _body.text.length);

  @override
  void initState() {
    super.initState();
    _title.addListener(_changed);
    _body.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _titleFocus.dispose();
    _bodyFocus.dispose();
    _peeling.dispose();
    super.dispose();
  }

  /// よく使うことばを足す。見出しが空なら見出しへ，そうでなければ本文の次の行へ。
  /// 「〇〇」は選んだ状態にして，すぐ書きかえられるようにする。
  void _addPhrase(String phrase) {
    HapticFeedback.selectionClick();
    final toTitle = _title.text.trim().isEmpty;
    final controller = toTitle ? _title : _body;
    final focus = toTitle ? _titleFocus : _bodyFocus;
    final current = controller.text;
    final sep = current.isEmpty || toTitle ? '' : '\n';
    var addition = '$sep$phrase';
    final room = PartnerMemo.maxLength - _length;
    if (room <= 0) return;
    if (addition.length > room) addition = addition.substring(0, room);
    final next = current + addition;
    final mark = next.lastIndexOf('〇〇');
    controller.value = TextEditingValue(
      text: next,
      selection: mark >= current.length
          ? TextSelection(baseOffset: mark, extentOffset: mark + 2)
          : TextSelection.collapsed(offset: next.length),
    );
    focus.requestFocus();
  }

  void _paste() {
    HapticFeedback.lightImpact();
    final memo = PartnerMemo(
      title: _title.text.trim(),
      body: _body.text.trim(),
      colorIndex: _color,
      updatedAt: DateTime.now(),
    );
    Navigator.of(
      context,
    ).pop(memo.isEmpty ? const MemoPeeled() : MemoPasted(memo));
  }

  Future<void> _peel() async {
    if (_peeling.isAnimating) return;
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    await _peeling.forward();
    if (!mounted) return;
    Navigator.of(context).pop(const MemoPeeled());
  }

  @override
  Widget build(BuildContext context) {
    final color = MemoColor.of(_color);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ColorDots(
                    selected: _color,
                    onSelect: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _color = i);
                    },
                  ),
                  const SizedBox(height: 18),
                  AnimatedBuilder(
                    animation: _peeling,
                    builder: (context, _) => _peelingNote(color),
                  ),
                  // 「自分にしか見えない」と文字数は付箋のすぐ下に置き，
                  // キーボードが出ても隠れないようにする。
                  SizedBox(
                    width: MemoEditor.noteWidth + 40,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Text(
                              'この付箋は自分にしか見えません',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '$_length / ${PartnerMemo.maxLength}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in MemoEditor.phrases)
                        _PhraseChip(label: p, onTap: () => _addPhrase(p)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          key: const Key('memo_peel'),
                          label: 'はがす',
                          filled: false,
                          onTap: _peel,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          key: const Key('memo_paste'),
                          label: '貼る',
                          filled: true,
                          onTap: _paste,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// はがす動きをつけた付箋。
  Widget _peelingNote(MemoColor color) {
    final t = _peeling.value;
    if (t == 0) return _note(color);
    return _peelCurl(color, t);
  }

  void _feelOnce(double t, double at, void Function() haptic) {
    if (t >= at && !_tornFelt) {
      _tornFelt = true;
      haptic();
    }
  }

  double _phase(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);

  /// テープだけがその場に残って，うすれていく。
  Widget _wallTape(MemoColor color, double opacity) => Positioned(
    top: 0,
    child: Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.rotate(
        angle: -4 * math.pi / 180,
        child: MaskingTape(color: color, size: _tapeSize),
      ),
    ),
  );

  /// 右下の角からくるっとめくれて裏が見え（影つき），テープから離れたところで
  /// ふわっと持ち上がって消える。テープはその場に残ってうすれる。
  Widget _peelCurl(MemoColor color, double t) {
    const tear = 0.62;
    _feelOnce(t, tear, HapticFeedback.mediumImpact);
    final curl = Curves.easeInOutCubic.transform(_phase(t, 0, tear)) * 0.6;
    final lift = Curves.easeInCubic.transform(_phase(t, tear, 1));
    final torn = t >= tear;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Opacity(
          opacity: 1 - lift,
          child: Transform.translate(
            offset: Offset(18 * lift, -70 * lift),
            child: Transform.rotate(
              angle: -0.12 * lift,
              child: Transform.scale(
                scale: 1 + 0.06 * lift,
                child: _note(color, tape: !torn, curl: curl),
              ),
            ),
          ),
        ),
        if (torn) _wallTape(color, 1 - _phase(t, tear, 0.9)),
      ],
    );
  }

  static const Size _tapeSize = Size(56, 18);

  Widget _note(
    MemoColor color, {
    double fold = 14,
    bool tape = true,
    double curl = 0,
  }) {
    const inputDeco = InputDecoration(
      isDense: true,
      border: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      counterText: '',
    );
    return StickyPaper(
      color: color,
      width: MemoEditor.noteWidth,
      height: MediaQuery.of(context).viewInsets.bottom > 0 ? 160 : 190,
      tapeSize: _tapeSize,
      tapeOpacity: tape ? 1 : 0,
      foldSize: fold,
      curl: curl,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('memo_title_field'),
            controller: _title,
            focusNode: _titleFocus,
            autofocus: widget.initial == null,
            maxLength: _titleLimit,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _bodyFocus.requestFocus(),
            cursorColor: MemoFont.ink,
            style: const TextStyle(
              fontFamily: MemoFont.title,
              fontWeight: MemoFont.titleWeight,
              fontSize: 16,
              height: 1.4,
              color: MemoFont.ink,
            ),
            decoration: inputDeco.copyWith(
              hintText: 'どんな人？',
              hintStyle: const TextStyle(
                fontFamily: MemoFont.title,
                fontWeight: MemoFont.titleWeight,
                fontSize: 16,
                color: MemoFont.inkLight,
              ),
            ),
          ),
          const SizedBox(height: 4),
          DottedRule(color: color.fold),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              key: const Key('memo_body_field'),
              controller: _body,
              focusNode: _bodyFocus,
              maxLength: _bodyLimit,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLines: null,
              expands: true,
              cursorColor: MemoFont.ink,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontFamily: MemoFont.body,
                fontSize: 12.5,
                height: 1.5,
                color: MemoFont.ink,
              ),
              decoration: inputDeco.copyWith(
                hintText: '話したこと，次に聞きたいこと',
                hintStyle: const TextStyle(
                  fontFamily: MemoFont.body,
                  fontSize: 12.5,
                  color: MemoFont.inkLight,
                ),
              ),
            ),
          ),
          Text(
            widget.dateLabel,
            style: const TextStyle(
              fontFamily: MemoFont.body,
              fontSize: 9,
              color: MemoFont.inkLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorDots extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _ColorDots({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < MemoColor.all.length; i++)
          GestureDetector(
            key: Key('memo_color_$i'),
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: i == selected ? 32 : 26,
              height: i == selected ? 32 : 26,
              decoration: BoxDecoration(
                color: MemoColor.all[i].paper,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: i == selected ? 3 : 0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PhraseChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PhraseChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            '＋ $label',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    super.key,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? Colors.white : Colors.transparent,
      shape: StadiumBorder(
        side: filled
            ? BorderSide.none
            : const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: filled ? const Color(0xFF111827) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
