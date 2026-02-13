import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import 'purchase_model.dart';
import 'purchase_service.dart';

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final dio = ref.read(apiClientProvider).dio;
  return PurchaseService(dio);
});

final purchaseControllerProvider =
    StateNotifierProvider<PurchaseController, AsyncValue<List<Purchase>>>((ref) {
  return PurchaseController(ref);
});

class PurchaseController extends StateNotifier<AsyncValue<List<Purchase>>> {
  final Ref ref;
  PurchaseController(this.ref) : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final items = await ref.read(purchaseServiceProvider).listPurchases();
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
