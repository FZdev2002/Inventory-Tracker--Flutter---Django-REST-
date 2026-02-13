import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import '../auth/login_page.dart';
import 'inventory_controller.dart';
import 'buy_page.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  static const List<String> units = [
    "unidad",
    "kg",
    "g",
    "lb",
    "lt",
    "ml",
    "docena",
    "caja",
    "paquete",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Inventario"),
        actions: [
          // ✅ Botón para ir a Comprar (BuyPage)
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BuyPage()),
              );
            },
          ),

          // Logout
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text("No tienes productos aún."));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final it = items[i];
              return ListTile(
                title: Text(it.name),
                subtitle: Text("${it.quantity} ${it.unit}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openEditDialog(
                        context,
                        ref,
                        it.id,
                        it.name,
                        it.unit,
                        it.quantity,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, ref, it.id, it.name),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ FIX: Dropdown ahora funciona (StatefulBuilder)
  Future<void> _openAddDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: "1");
    String unit = "unidad";

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text("Agregar producto"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Nombre (ej. Cebolla)"),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: "Cantidad"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: unit,
                        items: InventoryPage.units
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setLocalState(() => unit = v);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final qty = qtyCtrl.text.trim();
                    if (name.isEmpty || qty.isEmpty) return;

                    await ref.read(inventoryControllerProvider.notifier).addItem(name, unit, qty);

                    if (context.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    qtyCtrl.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, int id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar"),
        content: Text("¿Eliminar '$name' del inventario?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(inventoryControllerProvider.notifier).delete(id);
    }
  }

  // ✅ FIX: Dropdown ahora funciona (StatefulBuilder)
  Future<void> _openEditDialog(
    BuildContext context,
    WidgetRef ref,
    int id,
    String currentName,
    String currentUnit,
    String currentQty,
  ) async {
    final nameCtrl = TextEditingController(text: currentName);
    final qtyCtrl = TextEditingController(text: currentQty);
    String unit = currentUnit;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text("Editar producto"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: "Cantidad"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: unit,
                        items: InventoryPage.units
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setLocalState(() => unit = v);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final qty = qtyCtrl.text.trim();
                    if (name.isEmpty || qty.isEmpty) return;

                    await ref.read(inventoryControllerProvider.notifier).update(id, name, unit, qty);

                    if (context.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text("Guardar cambios"),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    qtyCtrl.dispose();
  }
}
