import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkActivityProvider = NotifierProvider<NetworkActivityNotifier, int>(
  NetworkActivityNotifier.new,
);

final networkActivityVisibilityProvider =
    NotifierProvider<NetworkActivityVisibilityNotifier, bool>(
      NetworkActivityVisibilityNotifier.new,
    );

class NetworkActivityNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void start() {
    state++;
  }

  void finish() {
    if (state > 0) state--;
  }
}

void startNetworkActivity(Ref ref) {
  Future.microtask(() {
    ref.read(networkActivityProvider.notifier).start();
  });
}

void finishNetworkActivity(Ref ref) {
  Future.microtask(() {
    ref.read(networkActivityProvider.notifier).finish();
  });
}

class NetworkActivityVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enable() {
    state = true;
  }
}

void enableNetworkActivity(WidgetRef ref) {
  Future.microtask(() {
    ref.read(networkActivityVisibilityProvider.notifier).enable();
  });
}
