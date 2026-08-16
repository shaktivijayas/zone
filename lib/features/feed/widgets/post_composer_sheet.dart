import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/feed_provider.dart';
import '../utils/flair.dart';

/// Bottom sheet content for composing a new feed post.
class PostComposerSheet extends ConsumerStatefulWidget {
  const PostComposerSheet({super.key});

  @override
  ConsumerState<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends ConsumerState<PostComposerSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _selectedFlair;
  bool _submitting = false;
  String? _validationError;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      setState(() => _validationError = 'Title and body are required');
      return;
    }

    setState(() {
      _submitting = true;
      _validationError = null;
    });

    try {
      await ref.read(postsProvider.notifier).createPost(title: title, body: body, flair: _selectedFlair);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'New Post',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: "What's happening?", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: flairOptions.entries.map((entry) {
              final selected = _selectedFlair == entry.key;
              return ChoiceChip(
                label: Text('${entry.value.emoji} ${entry.key}'),
                selected: selected,
                onSelected: (val) => setState(() => _selectedFlair = val ? entry.key : null),
                selectedColor: entry.value.color.withValues(alpha: 0.15),
                backgroundColor: AppColors.background,
                side: BorderSide(color: selected ? entry.value.color : AppColors.cardBorder),
                labelStyle: TextStyle(color: selected ? entry.value.color : AppColors.textSecondary),
              );
            }).toList(),
          ),
          if (_validationError != null) ...[
            const SizedBox(height: 8),
            Text(_validationError!, style: const TextStyle(color: AppColors.semanticAlert, fontSize: 12)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ctaBlack,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Post'),
          ),
        ],
      ),
    );
  }
}
