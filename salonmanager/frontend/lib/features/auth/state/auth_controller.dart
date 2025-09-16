import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/env/env.dart';
import '../data/auth_repository.dart';
import '../models/user.dart';
import 'auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final mode = Env.usePat ? AuthMode.pat : AuthMode.spa;
  return AuthController(repo, AuthState(mode: mode));
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthController(this._repo, AuthState initial) : super(initial) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Restore PAT if any
    final sp = await SharedPreferences.getInstance();
    final savedPat = sp.getString('pat_token');
    if (Env.usePat && savedPat != null && savedPat.isNotEmpty) {
      _repo.patToken = savedPat;
      await fetchMe();
      return;
    }
    if (!Env.usePat) {
      // Try SPA session is already established (cookie in browser)
      await fetchMe();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(loading: true);
    try {
      if (state.mode == AuthMode.spa) {
        await _repo.loginSpa(email: email, password: password);
      } else {
        final token = await _repo.createPat(email: email, password: password);
        final sp = await SharedPreferences.getInstance();
        await sp.setString('pat_token', token);
      }
      await fetchMe();
    } catch (e, st) {
      debugPrint('Login error: $e\n$st');
      rethrow;
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true);
    try {
      if (state.mode == AuthMode.spa) {
        await _repo.logoutSpa();
      } else {
        // Clear PAT
        _repo.patToken = null;
        final sp = await SharedPreferences.getInstance();
        await sp.remove('pat_token');
      }
      state = const AuthState();
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> fetchMe() async {
    try {
      final User? u = await _repo.me();
      state = state.copyWith(user: u);
    } catch (_) {
      // Not logged in or tenant missing
      state = state.copyWith(user: null);
    }
  }

  bool get isAuthenticated => state.user != null;
}