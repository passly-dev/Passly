import 'package:flutter_riverpod/flutter_riverpod.dart';

/// BLE すれ違い検知の動作モード。
///
/// - [normal]: 通常使用モード。画面を持って使うことを想定し、擬似フォアグラウンド
///   (WakelockPlus + アドバタイズ) を **停止** して電話中に画面が消える現象を防ぐ。
/// - [pocket]: ポケットにしまうモード。画面が消えても BLE アドバタイズ / スキャンを
///   継続するために擬似フォアグラウンドを **起動** する。
///
/// TODO(passly): 実際の擬似フォアグラウンド ON/OFF 切替は BLE 側 (いつき担当) で
/// [bleNotifierProvider] や WakelockPlus を powerModeProvider に応じて分岐させる形で
/// 統合予定。現状は UI 状態のみを保持する。
enum PowerMode { normal, pocket }

/// ホーム画面トップ右のトグルボタンで切り替える動作モード。
/// アプリ内メモリのみ (再起動でリセット)。恒久化は次回追加。
final powerModeProvider = NotifierProvider<PowerModeNotifier, PowerMode>(
  PowerModeNotifier.new,
);

class PowerModeNotifier extends Notifier<PowerMode> {
  @override
  PowerMode build() => PowerMode.normal;

  void set(PowerMode mode) {
    if (state == mode) return;
    state = mode;
  }

  void toggle() {
    state = state == PowerMode.normal ? PowerMode.pocket : PowerMode.normal;
  }
}
