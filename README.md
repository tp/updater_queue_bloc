# updater_queue_bloc

A simple BLoC base class that runs `async` updater functions sequentially.

This simplifies state management by ensuring that only a single updater function is running at any time.

Updaters can emit multiple new state values, for example a data loading BLoC can emit a `LoadingState` initially,
then `await` the completion of an HTTP request, and finally emit a `LoadedState` with the received data.

## Example usage

```dart
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
```

## State Type

The state type is not always a simple primitive like `int` in the example above.

Let's image we have a BLoC backing a news article widget, which handles navigating to other articles by invoking a `openArticle` method.

For this case a shared abstract base state class (`ArticleState` below) is used so that the BLoC can have a single emitted type,
without introduction optional or nullable fields for the individual sub-states.

```dart
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:updater_queue_bloc/updater_queue_bloc.dart';

@immutable
abstract class ArticlePageState {}

class ArticlePageLoading extends ArticlePageState {
  ArticlePageLoading(this.articleId) : assert(articleId != null);

  final int articleId;
}

class ArticlePageLoaded extends ArticlePageState {
  ArticlePageLoaded(this.articleId, this.text)
      : assert(articleId != null),
        assert(text != null);

  final int articleId;
  final String text;
}

class ArticlePageBloc extends UpdaterQueue<ArticlePageState> {
  ArticlePageBloc(int initialArticleId)
      : super(ArticlePageLoading(initialArticleId)) {
    // trigger initial loading (this way we don't need an "idle" state)
    loadArticle(initialArticleId);
  }

  Future<void> loadArticle(int articleId) async {
    await expand(
      (value) async* {
        if (value is ArticlePageLoaded && value.articleId == articleId) {
          // Article already current & loaded
          // not doing anythig and emitting no new state.
          return;
        }

        // Emit loading state, UI might show progress indicator now
        yield ArticlePageLoading(articleId);

        // Fetching the Article Text
        final text = (await (await HttpClient()
                    .getUrl(Uri.parse('http://news.example.com/$articleId')))
                .close())
            .transform(Utf8Decoder())
            .join();

        yield ArticlePageLoaded(articleId, text);
      },
    );
  }
}
```
