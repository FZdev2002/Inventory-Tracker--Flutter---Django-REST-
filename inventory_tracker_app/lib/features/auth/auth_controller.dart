import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../core/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(tokenStorageProvider);
  return ApiClient(storage);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AuthController(this.ref) : super(const AsyncData(null));

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    try {
      final api = ref.read(apiClientProvider).dio;

      final res = await api.post("/api/auth/login/", data: {
        "username": username,
        "password": password,
      });

      final access = res.data["access"] as String?;
      final refresh = res.data["refresh"] as String?;
      if (access == null || refresh == null) {
        throw Exception("Respuesta inválida del login (sin tokens).");
      }

      await ref.read(tokenStorageProvider).saveTokens(access: access, refresh: refresh);
      state = const AsyncData(null);
    } on DioException catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
  }
}
