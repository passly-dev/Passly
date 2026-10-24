import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/features/ble/ble_service.dart';

/// BLEサービスのプロバイダー（アプリ全体で1つのインスタンスを共有）
final bleServiceProvider = Provider<BleService>((ref) {
  final service = BleService();
  // プロバイダー破棄時にリソースを解放する
  ref.onDispose(() => service.dispose());
  return service;
});

/// BLEのスキャン状態を管理するプロバイダー
final isScanningProvider = Provider<bool>((ref) => false);
