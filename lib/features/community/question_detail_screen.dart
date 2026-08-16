import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/device/device_service.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import 'models/question.dart';
import 'providers/community_provider.dart';
import 'widgets/answer_tile.dart';

class QuestionDetailScreen extends ConsumerStatefulWidget {
  const QuestionDetailScreen({super.key, required this.question});

  final Question question;

  @override
  ConsumerState<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  final _answerController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await ref.read(communityActionsProvider).addAnswer(questionId: widget.question.id, text: text);
      _answerController.clear();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _acceptAnswer(String answerId) async {
    try {
      await ref.read(communityActionsProvider).acceptAnswer(questionId: widget.question.id, answerId: answerId);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    final question = questionsAsync.maybeWhen(
      data: (qs) => qs.firstWhere((q) => q.id == widget.question.id, orElse: () => widget.question),
      orElse: () => widget.question,
    );

    final hashedDeviceIdAsync = ref.watch(hashedDeviceIdProvider);
    final isQuestionAuthor = hashedDeviceIdAsync.maybeWhen(
      data: (hash) => hash == question.authorHash,
      orElse: () => false,
    );

    final answersAsync = ref.watch(answersProvider(question.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('Question'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(answersProvider(question.id).future),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      question.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.body,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Answers',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    answersAsync.when(
                      data: (answers) {
                        if (answers.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('No answers yet.', style: TextStyle(color: AppColors.textSecondary)),
                          );
                        }
                        return Column(
                          children: [
                            for (final answer in answers) ...[
                              AnswerTile(
                                answer: answer,
                                isAccepted: question.acceptedAnswerId == answer.id,
                                canAccept: isQuestionAuthor && question.acceptedAnswerId == null,
                                onAccept: () => _acceptAnswer(answer.id),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, st) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('Failed to load answers.', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.cardFill,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _answerController,
                        decoration: const InputDecoration(hintText: 'Write an answer...', border: InputBorder.none),
                      ),
                    ),
                    IconButton(
                      onPressed: _submitting ? null : _submitAnswer,
                      icon: _submitting
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send, color: AppColors.ctaBlack),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
