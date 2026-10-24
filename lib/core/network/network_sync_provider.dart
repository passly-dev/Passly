import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:syshack2026/features/ble/ble_notifier.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';

enum NetworkConnectivityStatus { unknown, connected, disconnected }

final networkConnectivityProvider =
    NotifierProvider<NetworkConnectivityNotifier, NetworkConnectivityStatus>(
      NetworkConnectivityNotifier.new,
    );

class NetworkConnectivityNotifier extends Notifier<NetworkConnectivityStatus> {
  @override
  NetworkConnectivityStatus build() => NetworkConnectivityStatus.unknown;

  void setStatus(NetworkConnectivityStatus next) {
    state = next;
  }
}

/// ネットワーク接続状態を監視し、オンライン復帰時に自動同期処理を走らせるプロバイダー
final networkSyncProvider = Provider<void>((ref) {
  final subscription = InternetConnection().onStatusChange.listen((
    InternetStatus status,
  ) {
    ref
        .read(networkConnectivityProvider.notifier)
        .setStatus(
          status == InternetStatus.connected
              ? NetworkConnectivityStatus.connected
              : NetworkConnectivityStatus.disconnected,
        );
    if (status == InternetStatus.connected) {
      debugPrint('インターネット接続が回復しました。自動同期を開始します。');
      // 未送信のすれ違いデータを一括送信
      ref.read(bleNotifierProvider.notifier).syncUnsentTokens();
      // 最新のプロフィール情報とトークンプールを再取得
      ref.read(authNotifierProvider.notifier).refresh();
    } else {
      debugPrint('インターネット接続が切れました。オフラインモードで動作します。');
    }
  });

  ref.onDispose(() {
    subscription.cancel();
  });
});
