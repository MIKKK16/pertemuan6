import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final statsRandomProvider = Provider<Random>((ref) => Random());
final statsDelayProvider =
    Provider<Duration>((ref) => const Duration(seconds: 2));

const double statsFailureRate = 0.3;

class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() => _fetchStats();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchStats);
  }

  Future<List<String>> _fetchStats() async {
    await Future.delayed(ref.read(statsDelayProvider));
    if (ref.read(statsRandomProvider).nextDouble() < statsFailureRate) {
      throw Exception('Gagal mengambil statistik');
    }
    return const [
      'Total pengguna: 1.250',
      'Sesi aktif: 87',
      'Rata-rata durasi: 4m 32s',
    ];
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);
