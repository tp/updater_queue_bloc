// ignore_for_file: avoid_annotating_with_dynamic
import 'dart:async';

import 'package:flutter/foundation.dart';

/// Abstract bloc implementation that runs state modifying updaters sequentially.
///
/// Use [map] inside your bloc's implementation to map to a single next state.
/// Use [expand] to emit zero, one, or many states.
///
/// If the emitted valued from either [map] or [expand] equals the current [value],
/// [value] will not be updated.
///
/// /// {@tool sample}
///
/// ```dart
/// class CounterBloc extends UpdaterQueue<int> {
///   CounterBloc() : super(0);
///
///   Future<void> increment() async {
///     await map((count) => count + 1);
///   }
///
///   Future<void> addNTimes(int n) async {
///     await expand(
///       (count) async* {
///         for (var i = 0; i < n; i++) {
///           yield count + n;
///         }
///       },
///     );
///   }
/// }
/// ```
/// {@end-tool}
abstract class UpdaterQueue<State> extends ValueNotifier<State> {
  UpdaterQueue(
    /// The initial value
    State value,
  )   : _lastTask = Future.value(value),
        super(value);

  Future<State> _lastTask;

  set value(State value) {
    throw Exception('"value" must not be set.');
  }

  /// Runs [updater] emitting after all previous scheduled updaters have completed.
  ///
  /// Use this to emit a single new [value].
  ///
  /// Any errors throw while executing [updater] will be silently ignored.
  @protected
  Future<State> map(FutureOr<State> Function(State state) updater) {
    return _lastTask =
        _lastTask.catchError((dynamic err) => value).then((_) async {
      final nextValue = await updater(value);
      if (nextValue != super.value) {
        super.value = nextValue;
      }

      return value;
    });
  }

  /// Runs [updater] emitting after all previous scheduled updaters have completed.
  ///
  /// Use this to emit 0, 1, or many [value]s.
  ///
  /// Any errors throw while executing [updater] will be silently ignored.
  @protected
  Future<State> expand(Stream<State> Function(State state) updater) {
    return _lastTask =
        _lastTask.catchError((dynamic err) => value).then((_) async {
      await for (final nextValue in updater(value)) {
        if (nextValue != super.value) {
          super.value = nextValue;
        }
      }

      return super.value;
    });
  }
}
