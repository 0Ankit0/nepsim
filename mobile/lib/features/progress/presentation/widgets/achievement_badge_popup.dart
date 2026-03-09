import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/progress.dart';

class AchievementBadgePopup extends StatelessWidget {
  final Achievement achievement;

  const AchievementBadgePopup({super.key, required this.achievement});

  static Future<void> show(BuildContext context, Achievement achievement) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => AchievementBadgePopup(achievement: achievement),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color tierColor = _getTierColor(achievement.tier);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background burst effect
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: tierColor.withValues(alpha: 0.5),
                  blurRadius: 100,
                  spreadRadius: 20,
                )
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.5, 0.5)),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: tierColor, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ACHIEVEMENT UNLOCKED!',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.5),
                const SizedBox(height: 24),
                
                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(achievement.iconName),
                    size: 80,
                    color: tierColor,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1.seconds, curve: Curves.easeInOut)
                .animate() // initial entrance
                .fadeIn(delay: 300.ms)
                .scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 12),
                
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.5),
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tierColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ).animate().fadeIn(delay: 1000.ms),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
        ],
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
