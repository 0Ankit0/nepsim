import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/learn_provider.dart';
import '../models/learn_models.dart';
import '../data/repositories/learn_repository.dart';

class QuizPage extends ConsumerStatefulWidget {
  final int lessonId;

  const QuizPage({super.key, required this.lessonId});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  final Map<int, int> _answers = {};
  bool _submitting = false;
  QuizResult? _result;

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonDetailProvider(widget.lessonId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: lessonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (lesson) {
          final quiz = lesson.quiz;
          if (quiz == null) {
            return const Center(child: Text('No quiz available for this lesson.'));
          }

          if (_result != null) {
            return _QuizResultView(result: _result!);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quiz.questions.length,
                  itemBuilder: (context, index) {
                    final question = quiz.questions[index];
                    return _QuestionWidget(
                      question: question,
                      selectedIndex: _answers[question.id],
                      onSelected: (optionIndex) {
                        setState(() {
                          _answers[question.id] = optionIndex;
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _answers.length < quiz.questions.length || _submitting
                        ? null
                        : _submitQuiz,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Submit Quiz'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitQuiz() async {
    final lesson = ref.read(lessonDetailProvider(widget.lessonId)).value;
    if (lesson?.quiz == null) return;

    setState(() => _submitting = true);
    try {
      final repository = ref.read(learnRepositoryProvider);
      final submission = QuizSubmission(answers: _answers);
      final result = await repository.submitQuiz(lesson!.quiz!.id, submission);
      setState(() {
        _result = result;
      });
      // Invalidate progress to refresh curriculum view
      ref.invalidate(quizProgressProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }
}

class _QuestionWidget extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedIndex;
  final Function(int) onSelected;

  const _QuestionWidget({
    required this.question,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.questionText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...List.generate(question.options.length, (index) {
              final option = question.options[index];
              final isSelected = selectedIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: isSelected ? Theme.of(context).colorScheme.primary : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(option)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  final QuizResult result;

  const _QuizResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            result.passed ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
            size: 80,
            color: result.passed ? Colors.amber : Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            result.passed ? 'Congratulations!' : 'Try Again',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            result.passed
                ? 'You passed the quiz with ${result.score}% score.'
                : 'You need ${result.passingScore}% to pass. You got ${result.score}%.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          _ResultItem(label: 'Correct Answers', value: '${result.correctCount}/${result.totalQuestions}'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Back to Academy'),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final String value;

  const _ResultItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
