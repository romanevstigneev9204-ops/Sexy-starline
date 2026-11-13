import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/starline_api_client.dart';
import '../../data/remote/starline_api_exception.dart';
import '../../data/repositories/starline_repository.dart';
import '../../domain/entities/session.dart';

enum AuthStatus { unknown, unauthenticated, needsExtra, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.error,
    this.needsCaptcha = false,
    this.needsSms = false,
    this.captchaSid,
    this.busy = false,
  });

  final AuthStatus status;
  final Session? session;
  final String? error;
  final bool needsCaptcha;
  final bool needsSms;
  final String? captchaSid;
  final bool busy;

  AuthState copyWith({
    AuthStatus? status,
    Session? session,
    String? error,
    bool clearError = false,
    bool? needsCaptcha,
    bool? needsSms,
    String? captchaSid,
    bool? busy,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      error: clearError ? null : (error ?? this.error),
      needsCaptcha: needsCaptcha ?? this.needsCaptcha,
      needsSms: needsSms ?? this.needsSms,
      captchaSid: captchaSid ?? this.captchaSid,
      busy: busy ?? this.busy,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState());

  final StarlineRepository _repo;
  String? _pendingLogin;
  String? _pendingPassword;

  Future<void> bootstrap() async {
    final session = await _repo.restoreSession();
    if (session != null) {
      state = AuthState(status: AuthStatus.authenticated, session: session);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<LoginResult?> login(String login, String password) async {
    state = state.copyWith(busy: true, clearError: true);
    _pendingLogin = login;
    _pendingPassword = password;
    try {
      final result = await _repo.login(login: login, password: password);
      if (result.isOk && result.session != null) {
        await _repo.persistSession(result.session!);
        state = AuthState(
          status: AuthStatus.authenticated,
          session: result.session,
        );
      } else if (result.needsExtra) {
        state = AuthState(
          status: AuthStatus.needsExtra,
          needsCaptcha: result.needsCaptcha,
          needsSms: result.needsSms,
          captchaSid: result.captchaSid,
        );
      }
      return result;
    } on StarlineApiException catch (e) {
      state = state.copyWith(
        busy: false,
        status: AuthStatus.unauthenticated,
        error: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        busy: false,
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return null;
    } finally {
      if (state.status != AuthStatus.authenticated) {
        state = state.copyWith(busy: false);
      }
    }
  }

  Future<void> submitExtra(String code) async {
    final login = _pendingLogin;
    final password = _pendingPassword;
    if (login == null || password == null) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      final result = await _repo.login(
        login: login,
        password: password,
        captchaOrSms: code,
        captchaSid: state.captchaSid,
      );
      if (result.isOk && result.session != null) {
        await _repo.persistSession(result.session!);
        state = AuthState(
          status: AuthStatus.authenticated,
          session: result.session,
        );
      } else if (result.needsExtra) {
        state = state.copyWith(
          busy: false,
          needsCaptcha: result.needsCaptcha,
          needsSms: result.needsSms,
          captchaSid: result.captchaSid,
          error: 'Нужен повторный код',
        );
      } else {
        state = state.copyWith(
          busy: false,
          error: 'Не удалось подтвердить код',
        );
      }
    } on StarlineApiException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
    }
  }

  Future<void> enterDemo() async {
    state = state.copyWith(busy: true, clearError: true);
    final result = await _repo.login(login: 'demo', password: 'demo');
    if (result.session != null) {
      await _repo.persistSession(result.session!);
      state = AuthState(
        status: AuthStatus.authenticated,
        session: result.session,
      );
    } else {
      state = state.copyWith(busy: false, error: 'Демо недоступно');
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
