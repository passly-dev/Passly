import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syshack2026/core/network/dio_client.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';

class _Auth extends AuthNotifier {
  int logouts = 0;
  @override
  UserModel? build() => null;
  @override
  Future<void> logout() async {
    logouts++;
  }
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  final String message;
  _UnauthorizedAdapter(this.message);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"error":"$message"}',
      401,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final scenario in [
    ('/users/test/password', 'current password is incorrect', 0),
    ('/users/test/password', 'invalid token', 1),
    ('/users/test', 'current password is incorrect', 1),
  ]) {
    test('401 ${scenario.$1}: ${scenario.$2}', () async {
      final auth = _Auth();
      final container = ProviderContainer(
        overrides: [authNotifierProvider.overrideWith(() => auth)],
      );
      addTearDown(container.dispose);
      await container.read(authNotifierProvider.future);
      final dio = container.read(dioProvider);
      dio.httpClientAdapter = _UnauthorizedAdapter(scenario.$2);
      addTearDown(() => dio.close());
      await expectLater(
        dio.patch<dynamic>(scenario.$1),
        throwsA(isA<DioException>()),
      );
      expect(auth.logouts, scenario.$3);
    });
  }
}
