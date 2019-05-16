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
