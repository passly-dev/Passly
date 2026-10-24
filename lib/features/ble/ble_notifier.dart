import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/encounter/domain/encounter_notifier.dart';
import 'package:syshack2026/features/encounter/data/encounter_repository.dart';
import 'package:syshack2026/features/ble/ble_service.dart';
import 'package:syshack2026/features/encounter/data/pending_encounter_repository.dart';
import 'package:syshack2026/features/notification/notification_service.dart';

/// BLE状態を管理するプロバイダー
final bleNotifierProvider = NotifierProvider<BleNotifier, BleState>(
  BleNotifier.new,
);

/// BLEの状態
class BleState {
  final bool isScanning;
  final bool isAdvertising;
  final String? currentEphemeralId;
  final int confirmedEncounterCount;
  final List<String> newlyUnlockedAchievementTitles;
  final String? lastError;

  const BleState({
    this.isScanning = false,
    this.isAdvertising = false,
    this.currentEphemeralId,
    this.confirmedEncounterCount = 0,
    this.newlyUnlockedAchievementTitles = const [],
    this.lastError,
  });

  BleState copyWith({
    bool? isScanning,
    bool? isAdvertising,
    String? currentEphemeralId,
    int? confirmedEncounterCount,
    List<String>? newlyUnlockedAchievementTitles,
    String? lastError,
  }) {
    return BleState(
      isScanning: isScanning ?? this.isScanning,
      isAdvertising: isAdvertising ?? this.isAdvertising,
      currentEphemeralId: currentEphemeralId ?? this.currentEphemeralId,
      confirmedEncounterCount:
          confirmedEncounterCount ?? this.confirmedEncounterCount,
      newlyUnlockedAchievementTitles:
          newlyUnlockedAchievementTitles ?? this.newlyUnlockedAchievementTitles,
      lastError: lastError,
    );
  }
}

/// BLE機能を統合管理するNotifier
class BleNotifier extends Notifier<BleState> with WidgetsBindingObserver {
  late final BleService _bleService;
  EphemeralToken? _currentToken;
  String? _activeUserId;
  Set<String> _knownUnlockedAchievementIds = <String>{};

  List<EphemeralToken> _tokenPool = [];
  Timer? _rotationTimer;
  bool _isSyncing = false;
  bool _hasNotifiedInBackground = false;

  @override
  BleState build() {
    _bleService = BleService();
    WidgetsBinding.instance.addObserver(this);

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _rotationTimer?.cancel();
      _bleService.dispose();
    });

    return const BleState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _hasNotifiedInBackground = false;
      ref.read(notificationServiceProvider).cancelEncounterReminder();
      syncUnsentTokens();
    } else if (state == AppLifecycleState.paused) {
      _hasNotifiedInBackground = false;
    }
  }

  Future<void> syncUnsentTokens() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final repo = ref.read(pendingEncounterRepositoryProvider);
      await repo.removeExpiredTokens();

      final unsent = await repo.getUnsentTokens();
      if (unsent.isNotEmpty) {
        final encounterRepo = ref.read(encounterRepositoryProvider);
        await encounterRepo.recordEncountersBatch(unsent);
        await repo.clearUnsentTokens();

        await ref.read(encounterNotifierProvider.notifier).refresh();
        debugPrint('ローカル保存分のすれ違いデータを一括同期しました');
      }
    } catch (e) {
      debugPrint('未送信データの同期エラー: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void _startTokenRotation() {
    _rotationTimer?.cancel();
    if (_tokenPool.isEmpty) return;

    _tokenPool.removeWhere((t) => t.isExpired);

    if (_tokenPool.isEmpty) {
      stopAdvertising();
      ref.read(notificationServiceProvider).showTokenExhaustedNotification();
      return;
    }

    final now = DateTime.now();
    // 有効期間に入っているトークンを探す
    final activeToken = _tokenPool.where((t) => t.isActive).firstOrNull;

    if (activeToken != null) {
      if (_currentToken?.token != activeToken.token) {
        _currentToken = activeToken;
        // トークンが切り替わった場合は、一度停止してから再開する
        _bleService.stopAdvertising().then((_) {
          _bleService.startAdvertising(ephemeralId: activeToken.token);
        });
        state = state.copyWith(currentEphemeralId: activeToken.token);
      }
      // 現在のトークンが期限切れになるタイミングで再評価
      final timeToExpiry = activeToken.expiresAt.difference(now);
      _rotationTimer = Timer(timeToExpiry, _startTokenRotation);
    } else {
      // 現在有効なトークンがない場合（すべて未来のトークン）
      _currentToken = null;
      _bleService.stopAdvertising();
      state = state.copyWith(currentEphemeralId: null);

      // 一番近い未来のトークンが有効になるタイミングで再評価
      // トークンプールは基本的に時系列順に並んでいる想定
      final nextTokens = _tokenPool.where((t) => t.isFuture).toList()
        ..sort((a, b) => a.validFrom.compareTo(b.validFrom));

      if (nextTokens.isNotEmpty) {
        final timeToValid = nextTokens.first.validFrom.difference(now);
        _rotationTimer = Timer(timeToValid, _startTokenRotation);
      }
    }
  }

  Future<void> stopAdvertising() async {
    await _bleService.stopAdvertising();
    state = state.copyWith(isAdvertising: false);
  }

  /// BLEすれ違い機能を開始（スキャン + アドバタイズ）
  Future<void> start() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      state = state.copyWith(lastError: 'ログインが必要です');
      return;
    }

    // ログインユーザーが切り替わっている場合は古いBLEセッションを停止して再初期化する
    if ((_activeUserId != null && _activeUserId != user.id) ||
        state.isScanning ||
        state.isAdvertising) {
      await stop();
    }

    try {
      // 0. 事前権限チェック
      if (Platform.isAndroid) {
        final granted = await _bleService.ensurePermissions();
        if (!granted) throw Exception('Bluetooth権限がありません');
      }

      // 1. エフェメラルトークンプールを取得
      final encounterRepo = ref.read(encounterRepositoryProvider);
      _tokenPool = await encounterRepo.getEphemeralTokens(user.id);
      if (_tokenPool.isEmpty) throw Exception('トークンが取得できませんでした');
      // 起動直後の評価は _startTokenRotation に任せる
      if (_tokenPool.isNotEmpty) {
        // 全トークンのうち、一番最後に期限切れになるトークンの1つ前の期限を警告時刻とする（簡易的）
        if (_tokenPool.length >= 2) {
          final sortedTokens = List<EphemeralToken>.from(_tokenPool)
            ..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
          final warningTime = sortedTokens[sortedTokens.length - 2].expiresAt;
          await ref
              .read(notificationServiceProvider)
              .scheduleTokenWarningNotification(warningTime);
        }
      }
      _activeUserId = user.id;

      await _initializeAchievementBaseline(user.id, encounterRepo);

      // 2. スキャンを開始
      _bleService.startScanning(
        onEncounterConfirmed: _handleEncounterConfirmed,
        onError: (error) {
          debugPrint('BLEスキャンエラー: $error');
          state = state.copyWith(lastError: error.toString());
        },
      );

      state = state.copyWith(
        isScanning: true,
        isAdvertising: true, // _startTokenRotationで適宜制御される
        lastError: null,
      );

      _startTokenRotation();
      debugPrint('BLEすれ違い機能を開始しました (TokenPool: ${_tokenPool.length}個)');
    } catch (e, stackTrace) {
      debugPrint('BLE開始エラー: $e\n$stackTrace');
      state = state.copyWith(lastError: e.toString());
      rethrow;
    }
  }

  /// BLEすれ違い機能を停止
  Future<void> stop() async {
    await _bleService.stopScanning();
    await _bleService.stopAdvertising();
    _activeUserId = null;
    _knownUnlockedAchievementIds = <String>{};

    state = state.copyWith(
      isScanning: false,
      isAdvertising: false,
      currentEphemeralId: null,
      newlyUnlockedAchievementTitles: const [],
    );

    debugPrint('BLEすれ違い機能を停止しました');
  }

  /// iOSバックグラウンド移行時のアドバタイズ一時停止
  Future<void> pauseAdvertising() async {
    if (!state.isAdvertising) return;
    await _bleService.stopAdvertising();
    state = state.copyWith(isAdvertising: false);
    debugPrint('BLEアドバタイズを一時停止しました（iOSバックグラウンド）');
  }

  /// iOSフォアグラウンド復帰時のアドバタイズ再開
  Future<void> resumeAdvertising() async {
    if (state.isAdvertising || _activeUserId == null) return;
    try {
      final encounterRepo = ref.read(encounterRepositoryProvider);
      _tokenPool = await encounterRepo.getEphemeralTokens(_activeUserId!);
      if (_tokenPool.isNotEmpty) {
        _currentToken = _tokenPool.first;
        await _bleService.startAdvertising(ephemeralId: _currentToken!.token);
        state = state.copyWith(
          isAdvertising: true,
          currentEphemeralId: _currentToken!.token,
        );
        _startTokenRotation();
      }
      debugPrint('BLEアドバタイズを再開しました（iOSフォアグラウンド復帰）');
    } catch (e) {
      debugPrint('BLEアドバタイズ再開エラー: $e');
    }
  }

  // デバッグ用: すれ違いをシミュレート
  Future<void> testSimulateEncounter(String ephemeralId) async {
    await _handleEncounterConfirmed(ephemeralId);
  }

  /// すれ違い確定時の処理
  Future<void> _handleEncounterConfirmed(String ephemeralId) async {
    // TODO(Future Work): オフライン完全対応のための改修
    // 現状はすれ違った瞬間に即時バックエンドAPIを叩いて解決しているが、
    // 今後はここで PendingEncounterRepository に「ephemeralId(TOTP)」と「現在のUTCタイムスタンプ」を
    // ローカル保存（バッファリング）し、通信回復時にバックグラウンドで同期する仕組みに変更する。
    try {
      final myId = ref.read(authNotifierProvider).value?.id;
      if (myId == null) {
        debugPrint('すれ違い記録をスキップ: ログインユーザーが見つかりません');
        return;
      }

      final encounterRepo = ref.read(encounterRepositoryProvider);

      // 1. 受信したエフェメラルトークンをそのままサーバーへ渡して記録を試みる
      bool isSavedToServer = false;
      try {
        final recordResult = await encounterRepo.recordEncounter(
          myId: myId,
          targetToken: ephemeralId,
        );
        isSavedToServer = recordResult.created;
        if (!isSavedToServer) {
          debugPrint(
            'すれ違いは新規保存されませんでした: ${recordResult.message ?? 'no message'}',
          );
          await ref.read(encounterNotifierProvider.notifier).refresh();
          return;
        }
      } catch (e) {
        // オフライン等でAPI失敗時
        // APIが明示的な4xxエラー（不正なトークン等）を返した場合は保存しない
        final isNetworkError =
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException') ||
            e.toString().contains('Network') ||
            e.toString().contains('50'); // 500系のサーバーエラー

        if (isNetworkError || e.toString().contains('DioException')) {
          // DioExceptionでも、レスポンスコードが400や404なら不正トークンの可能性が高い
          // ※ここでは簡易的にすべて保存するが、isSavedToServer=falseにしておくことで
          // 誤った通知がバックグラウンドで出ないように下部で制御する。
          debugPrint('API送信失敗（オフライン・サーバーエラー）、ローカルに保存します: $e');
          final pendingRepo = ref.read(pendingEncounterRepositoryProvider);
          await pendingRepo.addUnsentToken(ephemeralId, DateTime.now().toUtc());

          // ローカル保存に成功したので、通知を出すためにフラグを立てる
          // （※ただし、完全な無効トークンは前段のHexチェックで弾かれているため、
          // ここに到達するトークンはほぼ確実に正規のトークンである）
          isSavedToServer = true;
        } else {
          debugPrint('不正なエラーのためローカル保存をスキップ: $e');
        }
      }

      if (isSavedToServer) {
        // 2. すれ違い画面遷移トリガーのみ更新
        state = state.copyWith(
          confirmedEncounterCount: state.confirmedEncounterCount + 1,
        );
        await _detectNewlyUnlockedAchievements(myId, encounterRepo);
        await ref.read(encounterNotifierProvider.notifier).refresh();
      }

      // [Phase 4] バックグラウンド動作時のローカル通知
      final isBackground =
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;
      if (isBackground && !_hasNotifiedInBackground) {
        ref.read(notificationServiceProvider).showStreetPassNotification();
        _hasNotifiedInBackground = true;
      }

      // 1日後に気づかなかった場合のリマインダーをセット
      ref.read(notificationServiceProvider).scheduleEncounterReminder();

      debugPrint('すれ違いを処理しました: token=$ephemeralId');
    } catch (e) {
      debugPrint('すれ違い記録の全体エラー: $e');
      state = state.copyWith(lastError: e.toString());
    }
  }

  /// 現在のセッションですれ違った人数をリセット
  void resetEncounterCount() {
    state = state.copyWith(
      confirmedEncounterCount: 0,
      newlyUnlockedAchievementTitles: const [],
    );
  }

  void consumeUnlockedAchievementNotifications() {
    if (state.newlyUnlockedAchievementTitles.isEmpty) return;
    state = state.copyWith(newlyUnlockedAchievementTitles: const []);
  }

  Future<void> _initializeAchievementBaseline(
    String userId,
    EncounterRepository repo,
  ) async {
    try {
      final unlocked = await repo.fetchUnlockedAchievements(userId);
      _knownUnlockedAchievementIds = unlocked.map((e) => e.id).toSet();
    } catch (e) {
      debugPrint('実績ベースライン初期化に失敗: $e');
    }
  }

  Future<void> _detectNewlyUnlockedAchievements(
    String userId,
    EncounterRepository repo,
  ) async {
    try {
      final unlocked = await repo.fetchUnlockedAchievements(userId);
      final newlyUnlocked = unlocked
          .where((a) => !_knownUnlockedAchievementIds.contains(a.id))
          .toList();

      _knownUnlockedAchievementIds = unlocked.map((e) => e.id).toSet();

      if (newlyUnlocked.isEmpty) return;

      state = state.copyWith(
        newlyUnlockedAchievementTitles: newlyUnlocked
            .map((a) => a.title)
            .toList(),
      );
    } catch (e) {
      debugPrint('新規実績の検知に失敗: $e');
    }
  }
}
