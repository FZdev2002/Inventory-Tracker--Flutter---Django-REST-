import 'package:dio/dio.dart';
import 'inventory_models.dart';

class InventoryService {
  final Dio dio;
  InventoryService(this.dio);

  Future<List<InventoryItem>> listItems() async {
    final res = await dio.get("/api/inventory/items/");
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map(InventoryItem.fromJson).toList();
  }

  Future<void> deleteItem(int id) async {
  await dio.delete("/api/inventory/items/$id/");
}

Future<void> updateItem({
  required int id,
  required String name,
  required String unit,
  required String quantity,
}) async {
  await dio.patch("/api/inventory/items/$id/", data: {
    "name": name,
    "unit": unit,
    "quantity": quantity,
  });
}

  Future<void> createItem({
    required String name,
    required String unit,
    required String quantity,
  }) async {
    await dio.post("/api/inventory/items/", data: {
      "name": name,
      "unit": unit,
      "quantity": quantity,
    });
  }

  Future<Map<String, dynamic>> purchasePreview({
    required String name,
    required String unit,
    required String quantity,
  }) async {
    final res = await dio.post("/api/inventory/items/purchase-preview/", data: {
      "name": name,
      "unit": unit,
      "quantity": quantity,
    });
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> purchaseConfirm({
  required String name,
  required String unit,
  required String quantity,
}) async {
  final res = await dio.post("/api/inventory/items/purchase-confirm/", data: {
    "name": name,
    "unit": unit,
    "quantity": quantity,
  });
  return (res.data as Map).cast<String, dynamic>();
}

}
