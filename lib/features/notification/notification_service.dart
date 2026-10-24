import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // タイムゾーンの初期化
    tz.initializeTimeZones();
    final String timeZoneName =
        (await FlutterTimezone.getLocalTimezone()).identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android初期化設定
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS初期化設定
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _plugin.initialize(settings: initializationSettings);

    // 権限リクエスト
    if (Platform.isAndroid) {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final iosImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _initialized = true;
  }

  NotificationDetails _getDetails() {
    const androidDetails = AndroidNotificationDetails(
      'syshack_passly_channel', // チャンネルID
      'すれ違い通信', // チャンネル名
      channelDescription: 'バックグラウンドでのすれ違い検知や警告を通知します',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );
    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// バックグラウンドでの初回すれ違い検知時に呼ばれる（即時発火）
  Future<void> showStreetPassNotification() async {
    await initialize();
    debugPrint('[NotificationService] 🔔 すれ違いを検知しました！（バックグラウンド即時通知）');
    await _plugin.show(
      id: 0,
      title: 'すれ違いを検知しました！',
      body: '新しいすれ違いデータがあります。アプリを開いて確認してください。',
      notificationDetails: _getDetails(),
    );
  }

  /// オフライン用トークンがラスト1個になる日時に合わせて発火するスケジュール通知
  Future<void> scheduleTokenWarningNotification(DateTime warningTime) async {
    await initialize();
    debugPrint('[NotificationService] ⏰ トークン枯渇予告をスケジュールしました: $warningTime');
    await _plugin.zonedSchedule(
      id: 1, // ID=1 (上書き可能)
      title: 'オフラインすれ違いの停止予告',
      body: 'オフライン用の通信トークンが残り1回分です。次回利用分がないため、アプリを開いて補充してください。',
      scheduledDate: tz.TZDateTime.from(warningTime, tz.local),
      notificationDetails: _getDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// すれ違いがある状態で1日アプリを開かなかった場合に発火するスケジュール通知
  Future<void> scheduleEncounterReminder() async {
    await initialize();
    final scheduledTime = tz.TZDateTime.now(tz.local)
        .add(const Duration(days: 1));
    debugPrint(
      '[NotificationService] ⏰ 1日後のすれ違いリマインダーをスケジュールしました: $scheduledTime',
    );
    await _plugin.zonedSchedule(
      id: 2, // ID=2
      title: 'すれ違いデータがあります',
      body: '未確認のすれ違い通信があります！アプリを開いて結果を確認してみましょう。',
      scheduledDate: scheduledTime,
      notificationDetails: _getDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// リマインダー通知をキャンセルする（アプリを開いた時などに呼ぶ）
  Future<void> cancelEncounterReminder() async {
    debugPrint('[NotificationService] 🚫 リマインダー通知をキャンセルしました');
    await _plugin.cancel(id: 2);
  }

  /// デバッグ用 (以前の互換性維持)
  Future<void> showTokenExhaustedNotification() async {
    await scheduleTokenWarningNotification(
      DateTime.now().add(const Duration(seconds: 5)),
    );
  }
}
