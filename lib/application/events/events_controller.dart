import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/starline_api_exception.dart';
import '../../data/repositories/starline_repository.dart';
import '../../domain/entities/event.dart';

class EventsState {
  const EventsState({
    this.events = const [],
    this.loading = false,
    this.error,
    this.rateLimited = false,
    this.filter,
  });

  final List<VehicleEvent> events;
  final bool loading;
  final String? error;
  final bool rateLimited;
  final EventKind? filter;

  List<VehicleEvent> get visible {
    if (filter == null) return events;
    return events.where((e) => e.kind == filter).toList();
  }

  EventsState copyWith({
    List<VehicleEvent>? events,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? rateLimited,
    EventKind? filter,
    bool clearFilter = false,
  }) {
    return EventsState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      rateLimited: rateLimited ?? this.rateLimited,
      filter: clearFilter ? null : (filter ?? this.filter),
    );
  }
}

class EventsController extends StateNotifier<EventsState> {
  EventsController(this._repo) : super(const EventsState());

  final StarlineRepository _repo;

  Future<void> load(String deviceId, {bool force = false}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final list = await _repo.events(deviceId, force: force);
      state = state.copyWith(
        events: list,
        loading: false,
        rateLimited: _repo.rateLimited,
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

  void setFilter(EventKind? kind) {
    if (kind == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filter: kind);
    }
  }

  void acknowledgeRateLimit() {
    state = state.copyWith(rateLimited: false);
  }
}
