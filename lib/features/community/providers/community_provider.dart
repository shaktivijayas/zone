import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/answer.dart';
import '../models/question.dart';
import '../models/showcase_project.dart';

/// Fetches and holds the list of Ask & Answer questions, newest first.
final questionsProvider = FutureProvider<List<Question>>((ref) async {
  final client = await ref.watch(apiClientProvider.future);
  final data = await client.get('/community/questions') as List;
  return data.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList();
});

/// Fetches and holds the list of answers for a given question, oldest first.
final answersProvider = FutureProvider.family<List<Answer>, String>((ref, questionId) async {
  final client = await ref.watch(apiClientProvider.future);
  final data = await client.get('/community/questions/$questionId/answers') as List;
  return data.map((e) => Answer.fromJson(e as Map<String, dynamic>)).toList();
});

/// Fetches and holds the list of Project Showcase entries, newest first.
final showcaseProvider = FutureProvider<List<ShowcaseProject>>((ref) async {
  final client = await ref.watch(apiClientProvider.future);
  final data = await client.get('/community/showcase') as List;
  return data.map((e) => ShowcaseProject.fromJson(e as Map<String, dynamic>)).toList();
});

/// Write-side operations for the Community module. Every method hits the
/// backend then invalidates the relevant read providers so the UI refreshes.
/// [ApiException]s are intentionally left to propagate to the caller.
class CommunityActions {
  CommunityActions(this._ref);

  final Ref _ref;

  Future<void> createQuestion({required String title, required String body}) async {
    final client = await _ref.read(apiClientProvider.future);
    await client.post('/community/questions', {'title': title, 'body': body});
    _ref.invalidate(questionsProvider);
  }

  Future<void> addAnswer({required String questionId, required String text}) async {
    final client = await _ref.read(apiClientProvider.future);
    await client.post('/community/questions/$questionId/answers', {'text': text});
    _ref.invalidate(answersProvider(questionId));
    _ref.invalidate(questionsProvider);
  }

  Future<void> acceptAnswer({required String questionId, required String answerId}) async {
    final client = await _ref.read(apiClientProvider.future);
    await client.patch('/community/questions/$questionId/accept/$answerId');
    _ref.invalidate(questionsProvider);
  }

  Future<void> createShowcaseProject({
    required String title,
    required String description,
    List<String> techStack = const [],
    String? imageUrl,
  }) async {
    final client = await _ref.read(apiClientProvider.future);
    await client.post('/community/showcase', {
      'title': title,
      'description': description,
      'techStack': techStack,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    });
    _ref.invalidate(showcaseProvider);
  }

  Future<void> bookmarkProject(String projectId) async {
    final client = await _ref.read(apiClientProvider.future);
    await client.patch('/community/showcase/$projectId/bookmark');
    _ref.invalidate(showcaseProvider);
  }
}

final communityActionsProvider = Provider<CommunityActions>((ref) => CommunityActions(ref));
