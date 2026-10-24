import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

/// Passlyアプリ専用のBLEサービスUUID（16-bit圧縮対応のBase UUID）
const String streetPassServiceUuid = '0000fff0-0000-1000-8000-00805f9b34fb';

/// すれ違い確定の条件
const int _requiredDetectionCount = 1; // 1回検知で確定（端末差による取りこぼし対策）

class DetectedDevice {
  final String ephemeralId;
  final List<DateTime> detectionTimes;
  bool isConfirmed;

  DetectedDevice({required this.ephemeralId, required DateTime firstDetection})
    : detectionTimes = [firstDetection],
      isConfirmed = false;

  void addDetection(DateTime time) {
    detectionTimes.add(time);
  }

  bool meetsEncounterCriteria(DateTime now) {
    if (isConfirmed) return false;
    return detectionTimes.length >= _requiredDetectionCount;
  }
}

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  static const MethodChannel _channel = MethodChannel('syshack/ble');
  static const EventChannel _eventChannel = EventChannel(
    'syshack/ble/scan_results',
  );

  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();

  bool _isScanning = false;
  bool _isAdvertising = false;
  String? _currentEphemeralId;
  StreamSubscription<dynamic>? _scanSubscription;

  final Map<String, DetectedDevice> _detectionBuffer = {};
  Timer? _cleanupTimer;
  Timer? _tokenRefreshTimer;
  static const Duration _cleanupInterval = Duration(seconds: 15);

  void Function(String)? _onEncounterConfirmed;

  bool get isScanning => _isScanning;
  bool get isAdvertising => _isAdvertising;
  String? get currentEphemeralId => _currentEphemeralId;

  // ═══════════════════════════════════════════════════════
  //  スキャン（受信）処理
  // ═══════════════════════════════════════════════════════

  Future<bool> ensurePermissions() async {
    if (Platform.isAndroid) {
      final hasPermissions =
          await _channel.invokeMethod<bool>('hasRequiredPermissions') ?? false;
      if (!hasPermissions) {
        final granted =
            await _channel.invokeMethod<bool>('requestPermissions') ?? false;
        if (!granted) {
          debugPrint('Bluetooth権限が許可されませんでした');
          return false;
        }
      }
      final isEnabled =
          await _channel.invokeMethod<bool>('isBluetoothEnabled') ?? false;
      if (!isEnabled) {
        debugPrint('Bluetoothが無効です');
        return false;
      }
    }
    return true;
  }

  void startScanning({
    required void Function(String ephemeralId) onEncounterConfirmed,
    required void Function(Object error) onError,
  }) {
    if (_isScanning) return;
    _isScanning = true;
    _onEncounterConfirmed = onEncounterConfirmed;

    if (Platform.isIOS && FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.stopScan();
    }

    _startCleanupTimer();

    if (Platform.isAndroid) {
      ensurePermissions().then((granted) {
        if (!granted) {
          onError('Bluetooth権限がありません');
          return;
        }
        _channel
            .invokeMethod('startScanning', {
              'serviceUuid': streetPassServiceUuid,
            })
            .catchError((Object error) {
              debugPrint('BLEスキャン開始エラー(Android): $error');
              onError(error);
            });
      });

      _scanSubscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is! Map) return;
          final ephemeralId = event['ephemeralId'] as String?;
          if (ephemeralId == null) return;
          _processDetection(ephemeralId, DateTime.now());
        },
        onError: (Object error) {
          debugPrint('BLEスキャンエラー(Android): $error');
          onError(error);
        },
      );
    } else {
      // iOS用実装
      FlutterBluePlus.startScan(
        withServices: [], // iOSのバグ回避のため全スキャン
        timeout: const Duration(hours: 24),
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          final now = DateTime.now();
          for (final result in results) {
            final ephemeralId = _extractEphemeralId(result);
            if (ephemeralId != null) {
              _processDetection(ephemeralId, now);
            }
          }
        },
        onError: (error) {
          debugPrint('BLEスキャンエラー(iOS): $error');
          onError(error);
        },
      );
    }

    debugPrint('BLEスキャンを開始しました');
  }

  void _processDetection(String ephemeralId, DateTime now) {
    if (ephemeralId == _currentEphemeralId) return;

    if (_detectionBuffer.containsKey(ephemeralId)) {
      final device = _detectionBuffer[ephemeralId]!;
      device.addDetection(now);

      if (device.meetsEncounterCriteria(now)) {
        device.isConfirmed = true;
        debugPrint('すれ違い確定: $ephemeralId');
        _onEncounterConfirmed?.call(ephemeralId);
      }
    } else {
      final device = DetectedDevice(
        ephemeralId: ephemeralId,
        firstDetection: now,
      );
      _detectionBuffer[ephemeralId] = device;
      debugPrint('新規デバイス検知: $ephemeralId');

      if (device.meetsEncounterCriteria(now)) {
        device.isConfirmed = true;
        debugPrint('すれ違い確定: $ephemeralId');
        _onEncounterConfirmed?.call(ephemeralId);
      }
    }
  }

  /// iOS専用: ScanResultからエフェメラルIDを抽出
  bool _isValidToken(String token) {
    if (token.length != 8 && token.length != 16) return false;
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(token);
  }

  /// iOS専用: ScanResultからエフェメラルIDを抽出
  String? _extractEphemeralId(ScanResult result) {
    // 1. Service Data から抽出 (Androidからの発信)
    final serviceDataBytes =
        result.advertisementData.serviceData[Guid(streetPassServiceUuid)];
    if (serviceDataBytes != null && serviceDataBytes.isNotEmpty) {
      var token = String.fromCharCodes(serviceDataBytes).trim();
      // Androidが万が一プレフィックスを付けて送ってきた場合は剥がす
      if (token.startsWith('SP_')) {
        token = token.substring(3);
      }
      if (_isValidToken(token)) return token;
    }

    // 2. Local Name から抽出 (iOSからの発信)
    // iOSは31バイト制限回避のため、プレフィックス等を一切つけずトークンをそのまま格納している
    var advertisedName = result.advertisementData.advName.trim();
    if (advertisedName.startsWith('SP_')) {
      advertisedName = advertisedName.substring(3);
    }
    if (_isValidToken(advertisedName)) return advertisedName;

    var platformName = result.device.platformName.trim();
    if (platformName.startsWith('SP_')) {
      platformName = platformName.substring(3);
    }
    if (_isValidToken(platformName)) return platformName;

    return null;
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      final now = DateTime.now();
      _detectionBuffer.removeWhere((id, device) {
        if (device.isConfirmed) return true;
        if (device.detectionTimes.isEmpty) return true;
        final lastDetection = device.detectionTimes.last;
        return now.difference(lastDetection) > const Duration(seconds: 30);
      });
    });
  }

  Future<void> stopScanning() async {
    _isScanning = false;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    await _scanSubscription?.cancel();
    _scanSubscription = null;

    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('stopScanning');
      } catch (e) {
        debugPrint('BLEスキャン停止エラー(Android): $e');
      }
    } else {
      await FlutterBluePlus.stopScan();
    }

    _detectionBuffer.clear();
    debugPrint('BLEスキャンを停止しました');
  }

  // ═══════════════════════════════════════════════════════
  //  アドバタイズ（発信）処理
  // ═══════════════════════════════════════════════════════

  Future<void> startAdvertising({
    required String ephemeralId,
    Future<String> Function()? refreshCallback,
    Duration refreshInterval = const Duration(minutes: 5),
  }) async {
    if (_isAdvertising) {
      debugPrint('既にアドバタイズ中です');
      return;
    }

    try {
      if (Platform.isAndroid) {
        final granted = await ensurePermissions();
        if (!granted) {
          debugPrint('Bluetooth権限がないため、アドバタイズを開始できません');
          throw Exception('Bluetooth権限がありません');
        }
      } else {
        final isSupported = await _blePeripheral.isSupported;
        if (!isSupported) {
          debugPrint('このデバイスはBLEアドバタイズをサポートしていません');
          return;
        }
      }

      _currentEphemeralId = ephemeralId;
      await _startAdvertisingWithId(ephemeralId);
      _isAdvertising = true;

      if (refreshCallback != null) {
        _tokenRefreshTimer?.cancel();
        _tokenRefreshTimer = Timer.periodic(refreshInterval, (_) async {
          try {
            final newToken = await refreshCallback();
            await _updateAdvertisingId(newToken);
          } catch (e) {
            debugPrint('トークン更新エラー: $e');
          }
        });
      }

      debugPrint('BLEアドバタイズを開始しました: ephemeralId=$ephemeralId');
    } catch (e) {
      debugPrint('BLEアドバタイズ開始エラー: $e');
      _isAdvertising = false;
    }
  }

  Future<void> _startAdvertisingWithId(String ephemeralId) async {
    if (Platform.isAndroid) {
      // Android用ネイティブ実装 (ネイティブ内で "SP_" を付与する)
      await _channel.invokeMethod('startAdvertising', {
        'token': ephemeralId,
        'serviceUuid': streetPassServiceUuid,
      });
    } else {
      // iOS用実装 (Plan C: トークンをそのままLocal Nameに乗せる)
      final localName = ephemeralId;

      final advertiseData = AdvertiseData(
        serviceUuids: [streetPassServiceUuid],
        localName: localName,
        includePowerLevel: false,
      );
      final advertiseSettings = AdvertiseSettings(
        advertiseMode: AdvertiseMode.advertiseModeBalanced,
        txPowerLevel: AdvertiseTxPower.advertiseTxPowerMedium,
        connectable: false,
        timeout: 0,
      );
      await _blePeripheral.start(
        advertiseData: advertiseData,
        advertiseSettings: advertiseSettings,
      );
    }
  }

  Future<void> _updateAdvertisingId(String newEphemeralId) async {
    if (!_isAdvertising) return;

    if (Platform.isAndroid) {
      await _channel.invokeMethod('stopAdvertising');
    } else {
      await _blePeripheral.stop();
    }

    _currentEphemeralId = newEphemeralId;
    await _startAdvertisingWithId(newEphemeralId);
    debugPrint('アドバタイズIDを更新しました: $newEphemeralId');
  }

  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;

    try {
      _tokenRefreshTimer?.cancel();
      _tokenRefreshTimer = null;

      if (Platform.isAndroid) {
        await _channel.invokeMethod('stopAdvertising');
      } else {
        await _blePeripheral.stop();
      }

      _isAdvertising = false;
      _currentEphemeralId = null;
      debugPrint('BLEアドバタイズを停止しました');
    } catch (e) {
      debugPrint('BLEアドバタイズ停止エラー: $e');
    }
  }

  Future<void> dispose() async {
    await stopScanning();
    await stopAdvertising();
  }
}
