import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

class FakeRandom implements Random {
  FakeRandom(this.value);
  double value;

  @override
  double nextDouble() => value;

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  int nextInt(int max) => throw UnimplementedError();
}

ProviderContainer makeContainer(FakeRandom random) {
  final container = ProviderContainer(
    retry: (retryCount, error) => null,
    overrides: [
      statsRandomProvider.overrideWithValue(random),
      statsDelayProvider.overrideWithValue(Duration.zero),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('sukses: mengembalikan 3 item saat random >= 0.3', () async {
    final container = makeContainer(FakeRandom(0.9));

    final items = await container.read(statsProvider.future);

    expect(items, hasLength(3));
  });

  test('error: melempar Exception saat random < 0.3', () async {
    final container = makeContainer(FakeRandom(0.1));

    await expectLater(
      container.read(statsProvider.future),
      throwsA(isA<Exception>()),
    );
    expect(container.read(statsProvider).hasError, isTrue);
  });

  test('batas: nilai tepat 0.3 dianggap sukses', () async {
    final container = makeContainer(FakeRandom(0.3));

    final items = await container.read(statsProvider.future);

    expect(items, isNotEmpty);
  });

  test('reload: pulih dari error menjadi success', () async {
    final random = FakeRandom(0.1);
    final container = makeContainer(random);

    await expectLater(
      container.read(statsProvider.future),
      throwsA(isA<Exception>()),
    );

    random.value = 0.9;
    await container.read(statsProvider.notifier).reload();

    final state = container.read(statsProvider);
    expect(state.hasValue, isTrue);
    expect(state.requireValue, hasLength(3));
  });

  test('reload: state sempat AsyncLoading sebelum selesai', () async {
    final container = makeContainer(FakeRandom(0.9));
    await container.read(statsProvider.future);

    final future = container.read(statsProvider.notifier).reload();
    expect(container.read(statsProvider).isLoading, isTrue);

    await future;
    expect(container.read(statsProvider).hasValue, isTrue);
  });
}
