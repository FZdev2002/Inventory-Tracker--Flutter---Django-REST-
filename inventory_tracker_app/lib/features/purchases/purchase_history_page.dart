import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'purchase_controller.dart';

class PurchaseHistoryPage extends ConsumerWidget {
  const PurchaseHistoryPage({super.key});

  String _fmt(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, "0");
    return "${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchaseControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de compras"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(purchaseControllerProvider.notifier).load(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text("Aún no hay compras registradas."));
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = items[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text("${_fmt(p.createdAt)} • ${p.quantity} ${p.unit}"),
                leading: const Icon(Icons.receipt_long),
              );
            },
          );
        },
      ),
    );
  }
}
