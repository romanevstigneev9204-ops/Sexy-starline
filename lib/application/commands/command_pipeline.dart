import '../../data/remote/starline_api_exception.dart';
import '../../data/repositories/starline_repository.dart';
import '../../domain/entities/command.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';

enum CommandPhase { idle, confirming, pending, success, failure }

class CommandResult {
  const CommandResult({
    required this.ok,
    this.state,
    this.error,
    this.unsupported = false,
    this.rateLimited = false,
  });

  final bool ok;
  final DeviceState? state;
  final String? error;
  final bool unsupported;
  final bool rateLimited;
}

/// UI intent → capability gate → POST set_param → refresh state.
class CommandPipeline {
  CommandPipeline(this._repo);

  final StarlineRepository _repo;

  DeviceCommand? _inFlight;

  bool get isBusy => _inFlight != null;

  CommandResult gate(Device device, DeviceCommand command) {
    if (device.isShared) {
      return const CommandResult(
        ok: false,
        unsupported: true,
        error: 'Общий доступ: команды только для владельца',
      );
    }
    if (!CommandGate.allows(
      command,
      controls: device.controls,
      functions: device.functions,
    )) {
      return const CommandResult(
        ok: false,
        unsupported: true,
        error: 'Команда недоступна на этом устройстве',
      );
    }
    if (_inFlight == DeviceCommand.start &&
        (command == DeviceCommand.start || command == DeviceCommand.stop)) {
      return const CommandResult(
        ok: false,
        error: 'Команда уже выполняется',
      );
    }
    return const CommandResult(ok: true);
  }

  Future<CommandResult> execute({
    required Device device,
    required DeviceCommand command,
  }) async {
    final gated = gate(device, command);
    if (!gated.ok) return gated;

    _inFlight = command;
    try {
      await _repo.sendCommand(device.id, command);
      return CommandResult(ok: true, state: _repo.cachedState);
    } on StarlineApiException catch (e) {
      return CommandResult(
        ok: false,
        error: e.message,
        rateLimited: e.isRateLimited,
        state: _repo.cachedState,
      );
    } catch (e) {
      return CommandResult(ok: false, error: e.toString());
    } finally {
      _inFlight = null;
    }
  }
}
