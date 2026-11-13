import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/starline_api_exception.dart';
import '../../data/repositories/starline_repository.dart';
import '../../domain/entities/command.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';
import '../../domain/polling/poll_policy.dart';
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
    this.budgetNearLimit = false,
    this.pollInterval = PollPolicy.defaultInterval,
  });

  final Device? device;
  final DeviceState? state;
  final bool loading;
  final bool commandBusy;
  final String? error;
  final bool rateLimited;
  final bool forceOfflinePreview;
  final bool budgetNearLimit;
  final Duration pollInterval;

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
    bool? budgetNearLimit,
    Duration? pollInterval,
  }) {
    return HomeState(
      device: device ?? this.device,
      state: state ?? this.state,
      loading: loading ?? this.loading,
      commandBusy: commandBusy ?? this.commandBusy,
      error: clearError ? null : (error ?? this.error),
      rateLimited: rateLimited ?? this.rateLimited,
      forceOfflinePreview: forceOfflinePreview ?? this.forceOfflinePreview,
      budgetNearLimit: budgetNearLimit ?? this.budgetNearLimit,
      pollInterval: pollInterval ?? this.pollInterval,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  HomeController(this._repo) : super(const HomeState()) {
    _pipeline = CommandPipeline(_repo);
  }

  final StarlineRepository _repo;
  late final CommandPipeline _pipeline;

  Timer? _pollTimer;
  DateTime? _lastSuccessAt;
  bool _foreground = true;
  void Function()? onBudgetChanged;

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
      _lastSuccessAt = DateTime.now();
      final budget = await _repo.budget();
      state = state.copyWith(
        device: device,
        state: ds,
        loading: false,
        rateLimited: _repo.rateLimited,
        budgetNearLimit: budget.isNearLimit || budget.isExceeded,
        pollInterval: PollPolicy.intervalFor(budget),
      );
      _restartPollTimer();
      onBudgetChanged?.call();
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

  /// Call when Home tab is visible / app resumed.
  void setForeground(bool value) {
    _foreground = value;
    if (value) {
      unawaited(_maybeAutoRefresh(reason: 'resume'));
      _restartPollTimer();
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
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

    final budget = await _repo.budget();
    if (!force && budget.isExceeded) {
      state = state.copyWith(
        rateLimited: true,
        budgetNearLimit: true,
        error: 'Дневной лимит API исчерпан — показываем кэш',
      );
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      final ds = await _repo.refreshState(device.id, force: force);
      _lastSuccessAt = DateTime.now();
      final nextBudget = await _repo.budget();
      state = state.copyWith(
        state: ds,
        loading: false,
        rateLimited: _repo.rateLimited,
        forceOfflinePreview: false,
        budgetNearLimit: nextBudget.isNearLimit || nextBudget.isExceeded,
        pollInterval: PollPolicy.intervalFor(nextBudget),
      );
      _restartPollTimer();
      onBudgetChanged?.call();
    } on StarlineApiException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.message,
        rateLimited: e.isRateLimited || _repo.rateLimited,
        budgetNearLimit: budget.isNearLimit || e.isRateLimited,
      );
    }
  }

  Future<void> _maybeAutoRefresh({required String reason}) async {
    if (!_foreground || state.commandBusy) return;
    final device = state.device;
    if (device == null) return;

    final budget = await _repo.budget();
    final since = _lastSuccessAt == null
        ? const Duration(days: 1)
        : DateTime.now().difference(_lastSuccessAt!);
    final allow = PollPolicy.shouldAutoRefresh(
      budget: budget,
      sinceLastSuccess: since,
      force: false,
    );
    if (!allow) {
      state = state.copyWith(
        budgetNearLimit: budget.isNearLimit || budget.isExceeded,
        pollInterval: PollPolicy.intervalFor(budget),
      );
      return;
    }
    await refresh(force: false);
  }

  void _restartPollTimer() {
    _pollTimer?.cancel();
    if (!_foreground) return;
    final interval = PollPolicy.clampInterval(state.pollInterval);
    _pollTimer = Timer.periodic(interval, (_) {
      unawaited(_maybeAutoRefresh(reason: 'timer'));
    });
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
    if (result.ok) {
      _lastSuccessAt = DateTime.now();
    }
    final budget = await _repo.budget();
    state = state.copyWith(
      state: result.state ?? state.state,
      commandBusy: false,
      error: result.error,
      rateLimited: result.rateLimited || _repo.rateLimited,
      budgetNearLimit: budget.isNearLimit || budget.isExceeded,
      pollInterval: PollPolicy.intervalFor(budget),
    );
    onBudgetChanged?.call();
    return result.ok;
  }

  void acknowledgeRateLimit() {
    state = state.copyWith(rateLimited: false);
  }

  void previewOffline(bool value) {
    state = state.copyWith(forceOfflinePreview: value);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
