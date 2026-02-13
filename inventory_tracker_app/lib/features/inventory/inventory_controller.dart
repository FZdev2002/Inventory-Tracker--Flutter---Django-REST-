import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import 'inventory_models.dart';
import 'inventory_service.dart';

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  final api = ref.read(apiClientProvider).dio;
  return InventoryService(api);
});

final inventoryControllerProvider =
    StateNotifierProvider<InventoryController, AsyncValue<List<InventoryItem>>>((ref) {
  return InventoryController(ref);
});

class InventoryController extends StateNotifier<AsyncValue<List<InventoryItem>>> {
  final Ref ref;

  InventoryController(this.ref) : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final items = await ref.read(inventoryServiceProvider).listItems();
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addItem(String name, String unit, String qty) async {
    await ref.read(inventoryServiceProvider).createItem(
          name: name,
          unit: unit,
          quantity: qty,
        );
    await load();
  }

  Future<Map<String, dynamic>> preview(String name, String unit, String qty) {
    return ref.read(inventoryServiceProvider).purchasePreview(
          name: name,
          unit: unit,
          quantity: qty,
        );
  }

  Future<void> delete(int id) async {
    await ref.read(inventoryServiceProvider).deleteItem(id);
    await load();
  }

  Future<void> update(int id, String name, String unit, String qty) async {
    await ref.read(inventoryServiceProvider).updateItem(
          id: id,
          name: name,
          unit: unit,
          quantity: qty,
        );
    await load();
  }

  Future<void> confirmPurchase(String name, String unit, String qty) async {
    await ref.read(inventoryServiceProvider).purchaseConfirm(
          name: name,
          unit: unit,
          quantity: qty,
        );
    await load();
  }
}
