// ignore_for_file: avoid_annotating_with_dynamic
import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class UpdaterQueue<State> extends ValueNotifier<State> {
  UpdaterQueue(State value)
      : _lastTask = Future.value(value),
        super(value);

  Future<State> _lastTask;

  set value(State value) {
    throw Exception('"value" must not be set.');
  }

  @protected
  Future<State> map(FutureOr<State> Function(State state) f) {
    return _lastTask =
        _lastTask.catchError((dynamic err) => value).then((_) async {
      super.value = await f(value);

      return value;
    });
  }

  @protected
  Future<State> expand(Stream<State> Function(State state) f) {
    return _lastTask =
        _lastTask.catchError((dynamic err) => value).then((_) async {
      await for (final state in f(value)) {
        super.value = state;
      }

      return super.value;
    });
  }
}
