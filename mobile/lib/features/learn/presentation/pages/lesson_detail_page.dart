import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/learn_provider.dart';
import 'package:go_router/go_router.dart';

class LessonDetailPage extends ConsumerWidget {
  final int lessonId;

  const LessonDetailPage({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonDetailProvider(lessonId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson'),
      ),
      body: lessonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading lesson: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(lessonDetailProvider(lessonId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (lesson) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _DifficultyBadge(level: lesson.difficultyLevel),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${lesson.readTimeMinutes} min read',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const Divider(height: 32),
                HtmlWidget(
                  lesson.contentHtml,
                  textStyle: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 32),
                if (lesson.quiz != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('${AppConstants.quizRoute}?id=${lesson.id}');
                      },
                      icon: const Icon(Icons.quiz_outlined),
                      label: const Text('Take Quiz'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String level;
  const _DifficultyBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (level.toLowerCase()) {
      case 'beginner': color = Colors.green; break;
      case 'intermediate': color = Colors.orange; break;
      case 'advanced': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
