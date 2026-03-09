class Achievement {
  final int id;
  final String slug;
  final String title;
  final String description;
  final String iconName;
  final String tier;
  final bool isActive;

  const Achievement({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.iconName,
    required this.tier,
    required this.isActive,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as int,
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['icon_name'] as String,
      tier: json['tier'] as String,
      isActive: json['is_active'] as bool,
    );
  }
}

class UserAchievement {
  final Achievement achievement;
  final String unlockedAt;
  final int? simulationId;

  const UserAchievement({
    required this.achievement,
    required this.unlockedAt,
    this.simulationId,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      achievement: Achievement.fromJson(json['achievement'] as Map<String, dynamic>),
      unlockedAt: json['unlocked_at'] as String,
      simulationId: json['simulation_id'] as int?,
    );
  }
}

class UserProgress {
  final int userId;
  final int totalSimulations;
  final int totalTrades;
  final double averagePnlPct;
  final double bestPnlPct;
  final double worstPnlPct;
  final double overallWinRate;
  final int bestStreak;
  
  final double timingScore;
  final double selectionScore;
  final double riskScore;
  final double patienceScore;
  
  final int lessonsCompleted;
  final int quizzesPassed;
  final String updatedAt;

  const UserProgress({
    required this.userId,
    required this.totalSimulations,
    required this.totalTrades,
    required this.averagePnlPct,
    required this.bestPnlPct,
    required this.worstPnlPct,
    required this.overallWinRate,
    required this.bestStreak,
    required this.timingScore,
    required this.selectionScore,
    required this.riskScore,
    required this.patienceScore,
    required this.lessonsCompleted,
    required this.quizzesPassed,
    required this.updatedAt,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['user_id'] as int,
      totalSimulations: json['total_simulations'] as int,
      totalTrades: json['total_trades'] as int,
      averagePnlPct: (json['average_pnl_pct'] as num).toDouble(),
      bestPnlPct: (json['best_pnl_pct'] as num).toDouble(),
      worstPnlPct: (json['worst_pnl_pct'] as num).toDouble(),
      overallWinRate: (json['overall_win_rate'] as num).toDouble(),
      bestStreak: json['best_streak'] as int,
      timingScore: (json['timing_score'] as num).toDouble(),
      selectionScore: (json['selection_score'] as num).toDouble(),
      riskScore: (json['risk_score'] as num).toDouble(),
      patienceScore: (json['patience_score'] as num).toDouble(),
      lessonsCompleted: json['lessons_completed'] as int,
      quizzesPassed: json['quizzes_passed'] as int,
      updatedAt: json['updated_at'] as String,
    );
  }
}
