import 'dart:async';
import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:passly/features/auth/domain/auth_notifier.dart';

/// 付箋の色。紙とマスキングテープ（しま模様の2色）をセットで持つ。
class MemoColor {
  final Color paper;
  final Color fold;
  final Color tape;
  final Color tapeStripe;

  const MemoColor({
    required this.paper,
    required this.fold,
    required this.tape,
    required this.tapeStripe,
  });

  /// 黄・緑・ピンク・水色の4色。テープは付箋と別の色にする。
  static const List<MemoColor> all = [
    MemoColor(
      paper: Color(0xFFFFF0A6),
      fold: Color(0xFFF2DC72),
      tape: Color(0xFFFFC9D8),
      tapeStripe: Color(0xFFFFE3EB),
    ),
    MemoColor(
      paper: Color(0xFFDDF5D3),
      fold: Color(0xFFBFE6B0),
      tape: Color(0xFFFFE07A),
      tapeStripe: Color(0xFFFFF0B8),
    ),
    MemoColor(
      paper: Color(0xFFFFDCE6),
      fold: Color(0xFFF5BFCF),
      tape: Color(0xFFB9DCFA),
      tapeStripe: Color(0xFFDCEEFD),
    ),
    MemoColor(
      paper: Color(0xFFD9EEFF),
      fold: Color(0xFFB7DAF5),
      tape: Color(0xFFFFE07A),
      tapeStripe: Color(0xFFFFF0B8),
    ),
  ];

  static MemoColor of(int index) => all[index.clamp(0, all.length - 1)];
}

/// 相手のプロフィールに貼る，自分にだけ見える付箋メモ。
///
/// 1行目の [title]（例: メガネの面白い人）と本文 [body]。合わせて [maxLength] 字まで。
/// サーバーには送らず，この端末にだけ保存する（アプリを入れ直すと消える）。
class PartnerMemo {
  static const int maxLength = 60;

  final String title;
  final String body;
  final int colorIndex;
  final DateTime updatedAt;

  const PartnerMemo({
    required this.title,
    required this.body,
    required this.colorIndex,
    required this.updatedAt,
  });

  MemoColor get color => MemoColor.of(colorIndex);

  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty;

  /// 一覧の小さい付箋に出す頭の部分。
  String get headline {
    final t = title.trim();
    if (t.isNotEmpty) return t;
    return body.trim().split('\n').first;
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'color': colorIndex,
    'updated_at': updatedAt.toIso8601String(),
  };

  factory PartnerMemo.fromJson(Map<String, dynamic> json) => PartnerMemo(
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    colorIndex: json['color'] as int? ?? 0,
    updatedAt:
        DateTime.tryParse(json['updated_at'] as String? ?? '') ??
        DateTime.now(),
  );
}

/// 自分が貼った付箋メモ（相手の userId → メモ）。
///
/// ログイン中ユーザーごとに SharedPreferences の別のキーへ保存する。
final partnerMemosProvider =
    AsyncNotifierProvider<PartnerMemosNotifier, Map<String, PartnerMemo>>(
      PartnerMemosNotifier.new,
    );

/// 1人分の付箋メモ。貼っていなければ null。
final partnerMemoProvider = Provider.family<PartnerMemo?, String>(
  (ref, userId) => ref.watch(partnerMemosProvider).value?[userId],
);

class PartnerMemosNotifier extends AsyncNotifier<Map<String, PartnerMemo>> {
  static const _keyPrefix = 'partner_memos_';

  String get _key =>
      '$_keyPrefix${ref.read(authNotifierProvider).value?.id ?? 'guest'}';

  @override
  FutureOr<Map<String, PartnerMemo>> build() async {
    ref.watch(authNotifierProvider.select((s) => s.value?.id));
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return const {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in decoded.entries)
          e.key: PartnerMemo.fromJson(e.value as Map<String, dynamic>),
      };
    } catch (_) {
      return const {};
    }
  }

  /// 付箋を貼る（書き直しも同じ）。中身が空なら [remove] と同じ。
  Future<void> save(String userId, PartnerMemo memo) async {
    if (memo.isEmpty) return remove(userId);
    final next = {...?state.value, userId: memo};
    state = AsyncData(next);
    await _persist(next);
  }

  /// 付箋をはがす。
  Future<void> remove(String userId) async {
    final next = {...?state.value}..remove(userId);
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> _persist(Map<String, PartnerMemo> memos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({for (final e in memos.entries) e.key: e.value.toJson()}),
      );
    } catch (_) {
      // 保存に失敗しても画面の状態はそのまま使う。
    }
  }
}
