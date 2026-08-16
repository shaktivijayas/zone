import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'providers/community_provider.dart';
import 'question_detail_screen.dart';
import 'widgets/question_card.dart';
import 'widgets/question_composer_sheet.dart';
import 'widgets/showcase_card.dart';
import 'widgets/showcase_composer_sheet.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          title: const Text('Community'),
          bottom: const TabBar(
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.ctaBlack,
            tabs: [Tab(text: 'Ask & Answer'), Tab(text: 'Showcase')],
          ),
        ),
        body: const TabBarView(
          children: [_AskAnswerTab(), _ShowcaseTab()],
        ),
      ),
    );
  }
}

class _AskAnswerTab extends ConsumerWidget {
  const _AskAnswerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(questionsProvider.future),
        child: questionsAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'No questions yet — ask the first one',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final question = questions[index];
                return QuestionCard(
                  question: question,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => QuestionDetailScreen(question: question)),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(
                child: Text('Failed to load questions.', style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => QuestionComposerSheet.show(context),
        backgroundColor: AppColors.ctaBlack,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ShowcaseTab extends ConsumerWidget {
  const _ShowcaseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showcaseAsync = ref.watch(showcaseProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(showcaseProvider.future),
        child: showcaseAsync.when(
          data: (projects) {
            if (projects.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'No projects yet — show off your work',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final project = projects[index];
                return ShowcaseCard(
                  project: project,
                  onBookmark: () => ref.read(communityActionsProvider).bookmarkProject(project.id),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => ListView(
            children: [
              const SizedBox(height: 120),
              Center(
                child: Text('Failed to load projects.', style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ShowcaseComposerSheet.show(context),
        backgroundColor: AppColors.ctaBlack,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
