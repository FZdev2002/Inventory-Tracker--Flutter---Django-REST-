import 'package:dio/dio.dart';
import 'purchase_model.dart';

class PurchaseService {
  final Dio dio;
  PurchaseService(this.dio);

  Future<List<Purchase>> listPurchases() async {
    final res = await dio.get("/api/inventory/purchases/");
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map(Purchase.fromJson).toList();
  }
}
