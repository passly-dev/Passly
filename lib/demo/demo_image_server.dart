import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// デモ用の画像（人物のアイコンとイベント画像）を返す端末内サーバー。
///
/// アイコンは assets/demo/avatars/<人物 ID>.png を返し、なければ
/// 名前の頭文字 + 淡い背景色の画像を作って返す。
/// イベント画像は assets/demo/events/<イベント ID>.jpg を返す。
/// アプリの各画面は画像 URL を Image.network で読むので、
/// 127.0.0.1 で画像を返せば本番の表示コードを変えずに画像を出せる。
/// 外部への通信はしない。
class DemoImageServer {
  DemoImageServer._();

  static HttpServer? _server;
  static final Map<String, List<int>> _cache = {};

  /// 背景色（淡い色）と文字色の組。人ごとに順番に割り当てる。
  static const List<(Color, Color)> _palette = [
    (Color(0xFFDDF3DA), Color(0xFF2E7D32)),
    (Color(0xFFDCEBFB), Color(0xFF1E5AA8)),
    (Color(0xFFFDE4D2), Color(0xFFB4541A)),
    (Color(0xFFEDE2FA), Color(0xFF6A3FB0)),
    (Color(0xFFFBE0E8), Color(0xFFB0305A)),
    (Color(0xFFFFF2C7), Color(0xFF8A6A00)),
    (Color(0xFFD7F2F0), Color(0xFF1F7A72)),
    (Color(0xFFE6E9EE), Color(0xFF4B5563)),
  ];

  static Future<void> start() async {
    if (_server != null) return;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    server.listen((request) async {
      final params = request.uri.queryParameters;
      if (request.uri.path == '/event.jpg') {
        final bytes = await _load(
          'assets/demo/events/${params['id'] ?? ''}.jpg',
        );
        request.response.statusCode = bytes == null ? 404 : 200;
        request.response.headers.contentType = ContentType('image', 'jpeg');
        if (bytes != null) request.response.add(bytes);
        await request.response.close();
        return;
      }
      final bytes =
          await _loadAsset(params['id'] ?? '') ??
          await _render(
            initial: params['c'] ?? '',
            colorIndex: int.tryParse(params['i'] ?? '') ?? 0,
          );
      request.response
        ..headers.contentType = ContentType('image', 'png')
        ..add(bytes);
      await request.response.close();
    });
  }

  /// [id] の人のアイコンの URL。イラストがなければ [name] の頭文字と
  /// [colorIndex] 番目の色で作る。
  /// サーバーが動いていなければ空文字（アプリ標準の人型アイコンになる）。
  static String urlFor(String id, String name, int colorIndex) {
    final server = _server;
    if (server == null || name.isEmpty) return '';
    final initial = String.fromCharCode(name.runes.first);
    return Uri(
      scheme: 'http',
      host: '127.0.0.1',
      port: server.port,
      path: '/avatar.png',
      queryParameters: {'id': id, 'c': initial, 'i': '$colorIndex'},
    ).toString();
  }

  /// [eventId] のイベント画像の URL。サーバーが動いていなければ空文字。
  static String eventImageUrlFor(int eventId) {
    final server = _server;
    if (server == null) return '';
    return Uri(
      scheme: 'http',
      host: '127.0.0.1',
      port: server.port,
      path: '/event.jpg',
      queryParameters: {'id': '$eventId'},
    ).toString();
  }

  static Future<List<int>?> _loadAsset(String id) async {
    if (id.isEmpty) return null;
    return _load('assets/demo/avatars/$id.png');
  }

  static Future<List<int>?> _load(String path) async {
    try {
      final data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  static Future<List<int>> _render({
    required String initial,
    required int colorIndex,
  }) async {
    final key = '$initial/$colorIndex';
    final cached = _cache[key];
    if (cached != null) return cached;

    const size = 256.0;
    final (background, foreground) = _palette[colorIndex % _palette.length];
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      Paint()..color = background,
    );
    final text = TextPainter(
      text: TextSpan(
        text: initial,
        style: TextStyle(
          color: foreground,
          fontSize: size * 0.46,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      Offset((size - text.width) / 2, (size - text.height) / 2),
    );
    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = data!.buffer.asUint8List();
    _cache[key] = bytes;
    return bytes;
  }
}
