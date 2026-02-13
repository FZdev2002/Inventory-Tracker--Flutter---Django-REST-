import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import '../auth/login_page.dart';
import 'inventory_controller.dart';
import 'buy_page.dart';
import '../purchases/purchase_history_page.dart';

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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BuyPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PurchaseHistoryPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("Agregar"),
      ),

      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),

        data: (items) {

          if (items.isEmpty) {
            return const Center(
              child: Text(
                "No tienes productos aún.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,

            itemBuilder: (_, i) {

              final it = items[i];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                child: ListTile(

                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2_outlined),
                  ),

                  title: Text(
                    it.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text("${it.quantity} ${it.unit}"),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
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
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(
                          context,
                          ref,
                          it.id,
                          it.name,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

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
