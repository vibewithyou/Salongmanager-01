import '../models/user.dart';

enum AuthMode { spa, pat }

class AuthState {
  final bool loading;
  final User? user;
  final AuthMode mode;

  const AuthState({this.loading = false, this.user, this.mode = AuthMode.spa});

  AuthState copyWith({bool? loading, User? user, AuthMode? mode}) =>
      AuthState(loading: loading ?? this.loading, user: user, mode: mode ?? this.mode);
}