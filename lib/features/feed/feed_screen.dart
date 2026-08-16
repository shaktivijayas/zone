import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'models/post.dart';
import 'providers/feed_provider.dart';
import 'widgets/comments_sheet.dart';
import 'widgets/post_card.dart';
import 'widgets/post_composer_sheet.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Feed'), backgroundColor: AppColors.background, foregroundColor: AppColors.textPrimary),
      body: postsAsync.when(
        data: (posts) => _PostList(posts: posts, ref: ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => _ErrorState(onRetry: () => ref.read(postsProvider.notifier).refresh()),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.ctaBlack,
        onPressed: () => _openComposer(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _openComposer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardFill,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => const PostComposerSheet(),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList({required this.posts, required this.ref});

  final List<Post> posts;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(postsProvider.notifier).refresh(),
        child: ListView(
          children: const [
            SizedBox(height: 160),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'No posts yet — share the first update',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(postsProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            onTap: () => _openComments(context, post.id),
            onUpvote: () => ref.read(postsProvider.notifier).upvote(post.id),
          );
        },
      ),
    );
  }

  void _openComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardFill,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => CommentsSheet(postId: postId),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Failed to load feed', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
