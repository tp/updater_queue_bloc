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
