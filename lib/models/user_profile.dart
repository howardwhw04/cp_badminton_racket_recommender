class UserProfile {
  final String id;
  final int skillLevel;
  final int matches;
  final int winRate;
  final int powerIndex;
  final int control;
  final String playingStyle;
  final bool hasLowStrength;
  final String matchType;
  final String preferredBudgetTier;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.skillLevel,
    required this.matches,
    required this.winRate,
    required this.powerIndex,
    required this.control,
    required this.playingStyle,
    required this.hasLowStrength,
    required this.matchType,
    required this.preferredBudgetTier,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      skillLevel: json['skill_level'] as int? ?? 1,
      matches: json['matches'] as int? ?? 0,
      winRate: json['win_rate'] as int? ?? 0,
      powerIndex: json['power_index'] as int? ?? 50,
      control: json['control'] as int? ?? 50,
      playingStyle: json['playing_style'] as String? ?? 'All-Rounder',
      hasLowStrength: json['has_low_strength'] as bool? ?? false,
      matchType: json['match_type'] as String? ?? 'Singles',
      preferredBudgetTier:
          json['preferred_budget_tier'] as String? ?? 'Mid-Range',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill_level': skillLevel,
      'matches': matches,
      'win_rate': winRate,
      'power_index': powerIndex,
      'control': control,
      'playing_style': playingStyle,
      'has_low_strength': hasLowStrength,
      'match_type': matchType,
      'preferred_budget_tier': preferredBudgetTier,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
