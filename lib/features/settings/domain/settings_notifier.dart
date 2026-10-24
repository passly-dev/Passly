import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool isPocketModeEnabled;
  final bool isBleEnabled;

  const SettingsState({
    this.isPocketModeEnabled = true,
    this.isBleEnabled = true,
  });

  SettingsState copyWith({bool? isPocketModeEnabled, bool? isBleEnabled}) {
    return SettingsState(
      isPocketModeEnabled: isPocketModeEnabled ?? this.isPocketModeEnabled,
      isBleEnabled: isBleEnabled ?? this.isBleEnabled,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  static const _pocketModeKey = 'isPocketModeEnabled';
  static const _bleEnabledKey = 'isBleEnabled';

  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isPocketModeEnabled =
        prefs.getBool(_pocketModeKey) ?? true; // デフォルトはON
    final isBleEnabled = prefs.getBool(_bleEnabledKey) ?? true; // デフォルトはON
    return SettingsState(
      isPocketModeEnabled: isPocketModeEnabled,
      isBleEnabled: isBleEnabled,
    );
  }

  Future<void> setPocketModeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pocketModeKey, value);
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(isPocketModeEnabled: value));
    } else {
      state = AsyncData(SettingsState(isPocketModeEnabled: value));
    }
  }

  Future<void> setBleEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bleEnabledKey, value);
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(isBleEnabled: value));
    } else {
      state = AsyncData(SettingsState(isBleEnabled: value));
    }
  }
}

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
      SettingsNotifier.new,
    );
