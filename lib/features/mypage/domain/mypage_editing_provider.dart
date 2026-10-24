import 'package:flutter_riverpod/flutter_riverpod.dart';

/// マイページが編集モードに入っているかを外部から参照するためのフラグ。
///
/// マイページ画面 (`_MyPageScreenState`) が編集モード遷移時に `.set(true)`
/// / 終了時に `.set(false)` を書き込み、[MainScreen] がこれを watch して
/// ボトムナビの表示を制御する。
class MyPageEditingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final myPageEditingProvider = NotifierProvider<MyPageEditingNotifier, bool>(
  MyPageEditingNotifier.new,
);
