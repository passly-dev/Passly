import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/common/router/app_router.dart';
import 'package:syshack2026/common/widgets/network_activity_indicator.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/core/network/network_sync_provider.dart';

void main() {
  // Riverpodの状態管理スコープでアプリ全体をラップ
  runApp(const ProviderScope(child: PasslyApp()));
}

/// アプリのルートWidget
class PasslyApp extends ConsumerWidget {
  const PasslyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GoRouterのインスタンスをProviderから取得
    final router = ref.watch(appRouterProvider);

    // ネットワーク状態の監視を開始（常駐）
    ref.watch(networkSyncProvider);

    return MaterialApp.router(
      title: 'Passly',
      debugShowCheckedModeBanner: false,
      // 日本語ロケール設定
      locale: const Locale('ja', 'JP'),
      supportedLocales: const [Locale('ja', 'JP')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // ダークテーマの設定
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        highlightColor: Colors.transparent,
        splashColor: PasslyText.secondary.withValues(alpha: 0.28),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(overlayColor: _pressedOverlayColor),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(overlayColor: _pressedOverlayColor),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(overlayColor: _pressedOverlayColor),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(overlayColor: _pressedOverlayColor),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(overlayColor: _pressedOverlayColor),
        ),
        // 日本語フォント設定
        fontFamily: 'Hiragino Sans',
        fontFamilyFallback: const [
          'Hiragino Kaku Gothic ProN',
          'Noto Sans JP',
          'sans-serif',
        ],
      ),
      // GoRouterをMaterialAppに接続する
      routerConfig: router,
      builder: (context, child) =>
          NetworkActivityIndicator(child: child ?? const SizedBox.shrink()),
    );
  }
}

final _pressedOverlayColor = WidgetStateProperty.resolveWith<Color?>((states) {
  if (states.contains(WidgetState.pressed)) {
    return Colors.transparent;
  }
  return null;
});
