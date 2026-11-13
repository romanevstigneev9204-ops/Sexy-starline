import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/starline_api_exception.dart';
import '../../data/repositories/starline_repository.dart';
import '../../domain/entities/command.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';
import '../commands/command_pipeline.dart';

class HomeState {
  const HomeState({
    this.device,
    this.state,
    this.loading = false,
    this.commandBusy = false,
    this.error,
    this.rateLimited = false,
    this.forceOfflinePreview = false,
  });

  final Device? device;
  final DeviceState? state;
  final bool loading;
  final bool commandBusy;
  final String? error;
  final bool rateLimited;
  final bool forceOfflinePreview;

  bool get showOffline =>
      forceOfflinePreview || (state != null && !state!.online);

  bool get hasData => device != null && state != null;

  HomeState copyWith({
    Device? device,
    DeviceState? state,
    bool? loading,
    bool? commandBusy,
    String? error,
    bool clearError = false,
    bool? rateLimited,
    bool? forceOfflinePreview,
  }) {
    return HomeState(
      device: device ?? this.device,
      state: state ?? this.state,
      loading: loading ?? this.loading,
      commandBusy: commandBusy ?? this.commandBusy,
      error: clearError ? null : (error ?? this.error),
      rateLimited: rateLimited ?? this.rateLimited,
      forceOfflinePreview: forceOfflinePreview ?? this.forceOfflinePreview,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  HomeController(this._repo) : super(const HomeState()) {
    _pipeline = CommandPipeline(_repo);
  }

  final StarlineRepository _repo;
  late final CommandPipeline _pipeline;

  Future<void> bootstrap() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final devices = await _repo.devices();
      if (devices.isEmpty) {
        state = state.copyWith(loading: false, error: 'Нет устройств');
        return;
      }
      final primaryId = await _repo.primaryDeviceId();
      final device = devices.firstWhere(
        (d) => d.id == primaryId,
        orElse: () => devices.firstWhere(
          (d) => d.isPrimary,
          orElse: () => devices.first,
        ),
      );
      final ds = await _repo.refreshState(device.id);
      state = state.copyWith(
        device: device,
        state: ds,
        loading: false,
        rateLimited: _repo.rateLimited,
      );
    } on StarlineApiException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.message,
        rateLimited: e.isRateLimited || _repo.rateLimited,
        state: _repo.cachedState,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> selectDevice(Device device) async {
    await _repo.setPrimaryDevice(device.id);
    state = state.copyWith(device: device.copyWith(isPrimary: true));
    await refresh(force: true);
  }

  Future<void> refresh({bool force = false}) async {
    final device = state.device;
    if (device == null) {
      await bootstrap();
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final ds = await _repo.refreshState(device.id, force: force);
      state = state.copyWith(
        state: ds,
        loading: false,
        rateLimited: _repo.rateLimited,
        forceOfflinePreview: false,
      );
    } on StarlineApiException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.message,
        rateLimited: e.isRateLimited || _repo.rateLimited,
      );
    }
  }

  bool canSend(DeviceCommand command) {
    final device = state.device;
    if (device == null) return false;
    return _pipeline.gate(device, command).ok;
  }

  Future<bool> sendCommand(DeviceCommand command) async {
    final device = state.device;
    if (device == null) return false;

    state = state.copyWith(commandBusy: true, clearError: true);
    final result = await _pipeline.execute(device: device, command: command);
    state = state.copyWith(
      state: result.state ?? state.state,
      commandBusy: false,
      error: result.error,
      rateLimited: result.rateLimited || _repo.rateLimited,
    );
    return result.ok;
  }

  void acknowledgeRateLimit() {
    state = state.copyWith(rateLimited: false);
  }

  void previewOffline(bool value) {
    state = state.copyWith(forceOfflinePreview: value);
  }
}
