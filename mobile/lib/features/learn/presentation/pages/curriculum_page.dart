import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/learn_provider.dart';
import '../models/learn_models.dart';
import 'package:go_router/go_router.dart';

class CurriculumPage extends ConsumerWidget {
  const CurriculumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curriculumAsync = ref.watch(curriculumProvider);
    final progressAsync = ref.watch(quizProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NEPSIM Academy'),
      ),
      body: curriculumAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading curriculum: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(curriculumProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (sections) => progressAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading progress: $err'),
          data: (completedIds) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return _SectionWidget(section: section, completedIds: completedIds);
            },
          ),
        ),
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final CurriculumSection section;
  final List<int> completedIds;

  const _SectionWidget({required this.section, required this.completedIds});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            section.section.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...section.lessons.map((lesson) => _LessonCard(
              lesson: lesson,
              isCompleted: completedIds.contains(lesson.id),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonSummary lesson;
  final bool isCompleted;

  const _LessonCard({required this.lesson, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.menu_book,
            color: isCompleted ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
               _DifficultyBadge(level: lesson.difficultyLevel),
               const SizedBox(width: 8),
               Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
               const SizedBox(width: 4),
               Text('${lesson.readTimeMinutes} min', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
               if (lesson.hasQuiz) ...[
                 const SizedBox(width: 8),
                 Icon(Icons.quiz_outlined, size: 14, color: Colors.grey[600]),
                 const SizedBox(width: 4),
                 Text('Quiz', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
               ]
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push('${AppConstants.lessonDetailRoute}?id=${lesson.id}');
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        level,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
