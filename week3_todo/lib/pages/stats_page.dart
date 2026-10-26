import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat: $err'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(statsProvider.notifier).reload(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.insights),
            title: Text(items[index]),
          ),
        ),
      ),
    );
  }
}
