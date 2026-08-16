import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/comment.dart';
import '../models/post.dart';

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final client = await ref.watch(apiClientProvider.future);
    final data = await client.get('/posts') as List;
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Re-fetches the post list, used for pull-to-refresh and after mutations.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  /// Creates a new post. Propagates [ApiException] to the caller on failure
  /// (e.g. 422 moderation rejection, 400 missing fields).
  Future<void> createPost({required String title, required String body, String? flair}) async {
    final client = await ref.read(apiClientProvider.future);
    await client.post('/posts', {'title': title, 'body': body, 'flair': ?flair});
    await refresh();
  }

  /// Upvotes a post by id. Propagates [ApiException] to the caller on failure.
  Future<void> upvote(String postId) async {
    final client = await ref.read(apiClientProvider.future);
    await client.patch('/posts/$postId/upvote');
    await refresh();
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  CommentsNotifier(this.postId);

  final String postId;

  @override
  Future<List<Comment>> build() async {
    final client = await ref.watch(apiClientProvider.future);
    final data = await client.get('/posts/$postId/comments') as List;
    return data.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Re-fetches this post's comment list.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  /// Adds a comment to this post, refreshes the comment list, and refreshes
  /// the post list so the post's commentCount stays in sync. Propagates
  /// [ApiException] to the caller on failure.
  Future<void> addComment(String text) async {
    final client = await ref.read(apiClientProvider.future);
    await client.post('/posts/$postId/comments', {'text': text});
    await refresh();
    await ref.read(postsProvider.notifier).refresh();
  }
}

final commentsProvider = AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, String>(
  CommentsNotifier.new,
);
