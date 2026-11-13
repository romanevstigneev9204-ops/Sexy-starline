import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/starline_api_exception.dart';
import '../../data/repositories/starline_repository.dart';
import '../../domain/entities/obd_params.dart';

class ObdState {
  const ObdState({
    this.params,
    this.loading = false,
    this.error,
    this.rateLimited = false,
    this.unsupported = false,
  });

  final ObdParams? params;
  final bool loading;
  final String? error;
  final bool rateLimited;
  final bool unsupported;

  ObdState copyWith({
    ObdParams? params,
    bool clearParams = false,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? rateLimited,
    bool? unsupported,
  }) {
    return ObdState(
      params: clearParams ? null : (params ?? this.params),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      rateLimited: rateLimited ?? this.rateLimited,
      unsupported: unsupported ?? this.unsupported,
    );
  }
}

class ObdController extends StateNotifier<ObdState> {
  ObdController(this._repo) : super(const ObdState());

  final StarlineRepository _repo;

  Future<void> load(String deviceId, {bool force = false}) async {
    state = state.copyWith(
      loading: true,
      clearError: true,
      unsupported: false,
    );
    try {
      final params = await _repo.obdParams(deviceId, force: force);
      if (params == null) {
        state = state.copyWith(
          loading: false,
          unsupported: true,
          clearParams: true,
        );
        return;
      }
      state = state.copyWith(
        params: params,
        loading: false,
        rateLimited: _repo.rateLimited,
        unsupported: false,
      );
    } on StarlineApiException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.message,
        rateLimited: e.isRateLimited || _repo.rateLimited,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void acknowledgeRateLimit() {
    state = state.copyWith(rateLimited: false);
  }
}
