import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/feed_provider.dart';
import '../utils/relative_time.dart';

/// Bottom sheet showing a post's comments with an inline add-comment field.
class CommentsSheet extends ConsumerStatefulWidget {
  const CommentsSheet({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final _textController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      await ref.read(commentsProvider(widget.postId).notifier).addComment(text);
      _textController.clear();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.postId));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              Expanded(
                child: commentsAsync.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return const Center(
                        child: Text('No comments yet', style: TextStyle(color: AppColors.textSecondary)),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment.text, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text(
                                relativeTime(comment.createdAtTime),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, st) => const Center(
                    child: Text('Failed to load comments', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sending ? null : _send,
                      icon: const Icon(Icons.send, color: AppColors.ctaBlack),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
