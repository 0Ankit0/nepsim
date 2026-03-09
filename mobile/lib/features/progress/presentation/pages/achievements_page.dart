import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/progress_provider.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(userAchievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Achievements'),
      ),
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading achievements: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(userAchievementsProvider),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
        data: (achievements) {
          if (achievements.isEmpty) {
            return const Center(child: Text('You have not unlocked any badges yet. Keep simulating!'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final userAchiev = achievements[index];
              final ach = userAchiev.achievement;
              final Color tierColor = _getTierColor(ach.tier);

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: tierColor.withValues(alpha: 0.5), width: 2),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tierColor.withValues(alpha: 0.2),
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getIconData(ach.iconName), size: 48, color: tierColor),
                      const SizedBox(height: 12),
                      Text(
                        ach.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        ach.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        'Unlocked: ${userAchiev.unlockedAt.split("T").first}',
                        style: TextStyle(fontSize: 10, color: tierColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze': return Colors.brown[400]!;
      case 'silver': return Colors.blueGrey[400]!;
      case 'gold': return Colors.amber[600]!;
      case 'platinum': return Colors.cyan[400]!;
      default: return Colors.blue;
    }
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'first_trade': return Icons.play_arrow_outlined;
      case 'profit': return Icons.attach_money;
      case 'streak_3': return Icons.local_fire_department;
      case 'sharpe_master': return Icons.insights;
      case 'diamond_hands': return Icons.diamond_outlined;
      case 'diversified': return Icons.pie_chart_outline;
      case 'quiz_perfect': return Icons.school_outlined;
      default: return Icons.military_tech;
    }
  }
}
