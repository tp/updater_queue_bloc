import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';

import 'package:updater_queue_bloc/updater_queue_bloc.dart';

class CounterBloc extends UpdaterQueue<int> {
  CounterBloc() : super(0);

  Future<void> increment() async {
    await map((count) => count + 1);
  }

  Future<void> addNTimes(int n) async {
    await expand(
      (count) async* {
        for (var i = 0; i < n; i++) {
          yield count + n;
        }
      },
    );
  }
}

void main() {
  test(
    'increments using map',
    () async {
      final bloc = CounterBloc();

      unawaited(bloc.increment());
      await bloc.increment();

      expect(
        bloc.value,
        2,
      );
    },
  );

  test(
    'expands to 10',
    () async {
      final bloc = CounterBloc();

      unawaited(bloc.increment());
      await bloc.addNTimes(9);

      expect(
        bloc.value,
        10,
      );
    },
  );
}
