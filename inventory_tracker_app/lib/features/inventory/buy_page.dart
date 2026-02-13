import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_controller.dart';
import 'inventory_page.dart';

class BuyPage extends ConsumerStatefulWidget {
  const BuyPage({super.key});

  @override
  ConsumerState<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends ConsumerState<BuyPage> {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: "1");
  String unit = "unidad";
  String? error;
  bool loading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _buy() async {
    setState(() {
      error = null;
      loading = true;
    });

    final name = nameCtrl.text.trim();
    final qty = qtyCtrl.text.trim();

    if (name.isEmpty || qty.isEmpty) {
      setState(() {
        error = "Completa nombre y cantidad.";
        loading = false;
      });
      return;
    }

    try {
      final preview = await ref
          .read(inventoryControllerProvider.notifier)
          .preview(name, unit, qty);

      final exists = preview["exists"] == true;

      if (exists) {
        final msg = preview["message"]?.toString() ??
            "⚠️ Ya tienes este producto. ¿Seguro que quieres agregar más?";

        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Producto duplicado"),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Agregar igual"),
              ),
            ],
          ),
        );

        if (ok != true) {
          setState(() => loading = false);
          return;
        }
      }

      await ref
          .read(inventoryControllerProvider.notifier)
          .confirmPurchase(name, unit, qty);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Agregado al inventario")),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const InventoryPage()),
      );
    } catch (e) {
      setState(() => error = "Error al comprar: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comprar / Agregar")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (error != null) ...[
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Producto (ej. Cebolla)"),
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
                          onChanged: (v) => setState(() => unit = v ?? "unidad"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : _buy,
                        child: loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Confirmar"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
