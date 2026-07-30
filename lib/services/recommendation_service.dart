import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/racket.dart';

class RecommendationService {
  final SupabaseClient? _supabase;

  RecommendationService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient;

  SupabaseClient get supabaseClient => _supabase ?? Supabase.instance.client;

  /// Fetches raw racket maps from Supabase. Can be overridden for testing.
  Future<List<Map<String, dynamic>>> fetchRawRackets() async {
    final response = await supabaseClient.from('rackets').select();
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Queries the rackets table from Supabase and applies the recommendation logic.
  /// If the query fails or returns no results, it returns recommendations using the provided fallback list.
  Future<Map<String, Racket>> getRecommendations(
    UserProfile profile, {
    List<Racket>? fallbackRackets,
  }) async {
    try {
      final List<Map<String, dynamic>> response = await fetchRawRackets();
      final List<Racket> rackets = response
          .map((json) => Racket.fromJson(json))
          .toList();

      if (rackets.isEmpty && fallbackRackets != null) {
        return getRecommendationsFromList(profile, fallbackRackets);
      }
      return getRecommendationsFromList(profile, rackets);
    } catch (e) {
      if (fallbackRackets != null) {
        return getRecommendationsFromList(profile, fallbackRackets);
      }
      rethrow;
    }
  }

  /// Evaluates and filters a list of rackets to return the top recommendation for each price tier.
  Map<String, Racket> getRecommendationsFromList(
    UserProfile profile,
    List<Racket> rackets,
  ) {
    // 1. Deterministic KBS filter: filter out stiff shafts if has_low_strength or skill_level == Beginner (0) is true.
    final bool isBeginnerOrLowStrength =
        profile.hasLowStrength || profile.skillLevel == 0;

    final List<Racket> kbsFiltered = rackets.where((racket) {
      if (isBeginnerOrLowStrength) {
        final flex = racket.shaftFlexibility.toLowerCase();
        return flex != 'stiff';
      }
      return true;
    }).toList();

    // 2. Score each racket and calculate raw score to prevent clamping ties
    final List<MapEntry<Racket, double>> scoredWithRaw = kbsFiltered.map((racket) {
      final double rawScore = _calculateRawCompatibility(racket, profile);
      final finalRacket = _buildScoredRacket(racket, profile, rawScore);
      return MapEntry(finalRacket, rawScore);
    }).toList();

    // 3. Select the single highest-rated racket for each price tier (Budget, Mid-Range, Premium)
    final Map<String, Racket> topRecommendations = {};
    const List<String> targetTiers = ['Budget', 'Mid-Range', 'Premium'];

    for (final tier in targetTiers) {
      final tierEntries = scoredWithRaw
          .where((entry) => entry.key.priceTier.toLowerCase() == tier.toLowerCase())
          .toList();

      if (tierEntries.isNotEmpty) {
        // Sort descending by raw (unclamped) score
        tierEntries.sort((a, b) => b.value.compareTo(a.value));
        topRecommendations[tier] = tierEntries.first.key;
      }
    }

    return topRecommendations;
  }

  /// Evaluates and scores a single racket for a given user profile, applying KBS pruning.
  Racket scoreRacket(Racket racket, UserProfile profile) {
    final bool isBeginnerOrLowStrength =
        profile.hasLowStrength || profile.skillLevel == 0;
    if (isBeginnerOrLowStrength && racket.shaftFlexibility.toLowerCase() == 'stiff') {
      return racket.copyWith(
        matchRating: 0,
        matchExplanation: 'KBS Warning: Stiff shafts are locked for beginners or players with lower arm strength to avoid injury.',
      );
    }
    final double rawScore = _calculateRawCompatibility(racket, profile);
    return _buildScoredRacket(racket, profile, rawScore);
  }

  /// Calculates the raw compatibility score of a racket.
  double _calculateRawCompatibility(Racket racket, UserProfile profile) {
    const double baseValue = 50.0;

    double budgetContribution = 0.0;
    double skillFlexContribution = 0.0;
    double strengthWeightContribution = 0.0;
    double styleBalanceContribution = 0.0;
    double matchTypeContribution = 0.0;

    // 1. Budget Preference vs Racket Price Tier
    final String prefTier = profile.preferredBudgetTier.toLowerCase();
    final String rackTier = racket.priceTier.toLowerCase();
    if (rackTier == prefTier) {
      budgetContribution = 20.0;
    } else {
      final List<String> tiers = ['budget', 'mid-range', 'premium'];
      final int rackIdx = tiers.indexOf(rackTier);
      final int prefIdx = tiers.indexOf(prefTier);
      if (rackIdx != -1 && prefIdx != -1) {
        final int distance = (rackIdx - prefIdx).abs();
        if (distance == 1) {
          budgetContribution = 10.0;
        } else {
          budgetContribution = -10.0;
        }
      }
    }

    // 2. Skill Level vs Shaft Flexibility
    final int skill = profile.skillLevel;
    final String flex = racket.shaftFlexibility.toLowerCase();
    if (skill == 0) {
      if (flex == 'flexible') {
        skillFlexContribution = 20.0;
      } else if (flex == 'medium') {
        skillFlexContribution = 10.0;
      } else {
        skillFlexContribution = -15.0;
      }
    } else if (skill == 1) {
      if (flex == 'medium') {
        skillFlexContribution = 20.0;
      } else {
        skillFlexContribution = 10.0;
      }
    } else {
      if (flex == 'stiff') {
        skillFlexContribution = 20.0;
      } else if (flex == 'medium') {
        skillFlexContribution = 10.0;
      } else {
        skillFlexContribution = -10.0;
      }
    }

    // 3. Physical / Wrist Strength vs Weight Class
    final String weight = racket.weightClass.toUpperCase();
    if (profile.hasLowStrength) {
      if (weight == '5U') {
        strengthWeightContribution = 20.0;
      } else if (weight == '4U') {
        strengthWeightContribution = 15.0;
      } else {
        strengthWeightContribution = -20.0;
      }
    } else {
      if (weight == '3U' || weight == '4U') {
        strengthWeightContribution = 20.0;
      } else {
        strengthWeightContribution = 5.0;
      }
    }

    // 4. Playing Style vs Balance Category
    final String style = profile.playingStyle.toLowerCase();
    final String balance = racket.balanceCategory.toLowerCase();
    if (style == 'attacking') {
      if (balance == 'head heavy') {
        styleBalanceContribution = 20.0;
      } else if (balance == 'head light' || balance.contains('light')) {
        styleBalanceContribution = -10.0;
      } else {
        styleBalanceContribution = 10.0;
      }
    } else if (style == 'defensive') {
      if (balance == 'head light' || balance.contains('light')) {
        styleBalanceContribution = 20.0;
      } else if (balance == 'head heavy') {
        styleBalanceContribution = -10.0;
      } else {
        styleBalanceContribution = 15.0;
      }
    } else {
      if (balance == 'even balance' || balance == 'even') {
        styleBalanceContribution = 20.0;
      } else {
        styleBalanceContribution = 10.0;
      }
    }

    // 5. Match Format / Type
    final String match = profile.matchType.toLowerCase();
    if (match == 'doubles') {
      if (balance == 'head light' || balance == 'even balance' || balance == 'even' || balance.contains('light')) {
        matchTypeContribution = 20.0;
      } else {
        matchTypeContribution = 10.0;
      }
    } else if (match == 'singles') {
      if (balance == 'head heavy' || balance == 'even balance' || balance == 'even') {
        matchTypeContribution = 20.0;
      } else {
        matchTypeContribution = 10.0;
      }
    } else {
      matchTypeContribution = 20.0;
    }

    return baseValue +
        budgetContribution +
        skillFlexContribution +
        strengthWeightContribution +
        styleBalanceContribution +
        matchTypeContribution;
  }

  /// Builds a scored Racket instance with clamped rating and simulated SHAP explanation.
  Racket _buildScoredRacket(Racket racket, UserProfile profile, double rawScore) {
    const double baseValue = 50.0;

    double budgetContribution = 0.0;
    double skillFlexContribution = 0.0;
    double strengthWeightContribution = 0.0;
    double styleBalanceContribution = 0.0;
    double matchTypeContribution = 0.0;

    // Redo breakdown to format the reasons
    final String prefTier = profile.preferredBudgetTier.toLowerCase();
    final String rackTier = racket.priceTier.toLowerCase();
    String budgetReason = '';
    if (rackTier == prefTier) {
      budgetContribution = 20.0;
      budgetReason = 'perfect budget tier match';
    } else {
      final List<String> tiers = ['budget', 'mid-range', 'premium'];
      final int rackIdx = tiers.indexOf(rackTier);
      final int prefIdx = tiers.indexOf(prefTier);
      if (rackIdx != -1 && prefIdx != -1) {
        final int distance = (rackIdx - prefIdx).abs();
        if (distance == 1) {
          budgetContribution = 10.0;
          budgetReason = 'close budget tier match';
        } else {
          budgetContribution = -10.0;
          budgetReason = 'large budget tier difference';
        }
      } else {
        budgetReason = 'unrecognized budget tier';
      }
    }

    final int skill = profile.skillLevel;
    final String flex = racket.shaftFlexibility.toLowerCase();
    String skillReason = '';
    if (skill == 0) {
      if (flex == 'flexible') {
        skillFlexContribution = 20.0;
        skillReason = 'flexible shaft is ideal for beginners to generate power';
      } else if (flex == 'medium') {
        skillFlexContribution = 10.0;
        skillReason = 'medium flex offers a balanced feel for learning players';
      } else {
        skillFlexContribution = -15.0;
        skillReason = 'stiff shaft lacks power generation for beginners';
      }
    } else if (skill == 1) {
      if (flex == 'medium') {
        skillFlexContribution = 20.0;
        skillReason = 'medium shaft matches the balanced requirements of intermediate play';
      } else {
        skillFlexContribution = 10.0;
        skillReason = 'flexible or stiff shafts are usable but less specialized for club levels';
      }
    } else {
      if (flex == 'stiff') {
        skillFlexContribution = 20.0;
        skillReason = 'stiff shaft provides advanced players with clinical accuracy';
      } else if (flex == 'medium') {
        skillFlexContribution = 10.0;
        skillReason = 'medium stiffness is decent but may sacrifice precision';
      } else {
        skillFlexContribution = -10.0;
        skillReason = 'flexible shaft feels too unstable for high-speed advanced control';
      }
    }

    final String weight = racket.weightClass.toUpperCase();
    String strengthReason = '';
    if (profile.hasLowStrength) {
      if (weight == '5U') {
        strengthWeightContribution = 20.0;
        strengthReason = 'ultra-lightweight 5U class minimizes arm strain';
      } else if (weight == '4U') {
        strengthWeightContribution = 15.0;
        strengthReason = 'forgiving 4U weight helps maintain speed without fatigue';
      } else {
        strengthWeightContribution = -20.0;
        strengthReason = 'heavy 3U or heavier frame risks fatigue or injury';
      }
    } else {
      if (weight == '3U' || weight == '4U') {
        strengthWeightContribution = 20.0;
        strengthReason = 'standard 3U/4U weight offers stable hitting dynamics';
      } else {
        strengthWeightContribution = 5.0;
        strengthReason = 'light 5U frame lacks drive/smash stability for normal strength';
      }
    }

    final String style = profile.playingStyle.toLowerCase();
    final String balance = racket.balanceCategory.toLowerCase();
    String styleReason = '';
    if (style == 'attacking') {
      if (balance == 'head heavy') {
        styleBalanceContribution = 20.0;
        styleReason = 'head-heavy balance matches attacking style by magnifying smash power';
      } else if (balance == 'head light' || balance.contains('light')) {
        styleBalanceContribution = -10.0;
        styleReason = 'head-light balance reduces smash speed for attacking players';
      } else {
        styleBalanceContribution = 10.0;
        styleReason = 'even balance offers reasonable smash options';
      }
    } else if (style == 'defensive') {
      if (balance == 'head light' || balance.contains('light')) {
        styleBalanceContribution = 20.0;
        styleReason = 'head-light balance enables rapid net defensive recovery';
      } else if (balance == 'head heavy') {
        styleBalanceContribution = -10.0;
        styleReason = 'head-heavy balance makes defensive reactions sluggish';
      } else {
        styleBalanceContribution = 15.0;
        styleReason = 'even balance provides stable defense return profiles';
      }
    } else {
      if (balance == 'even balance' || balance == 'even') {
        styleBalanceContribution = 20.0;
        styleReason = 'even balance perfectly matches all-court play requirements';
      } else {
        styleBalanceContribution = 10.0;
        styleReason = 'polarized balance is somewhat specialized for all-court coverage';
      }
    }

    final String match = profile.matchType.toLowerCase();
    String matchReason = '';
    if (match == 'doubles') {
      if (balance == 'head light' || balance == 'even balance' || balance == 'even' || balance.contains('light')) {
        matchTypeContribution = 20.0;
        matchReason = 'quick recovery and light handle speed match doubles rallies';
      } else {
        matchTypeContribution = 10.0;
        matchReason = 'sluggish recovery is a drawback in fast doubles net play';
      }
    } else if (match == 'singles') {
      if (balance == 'head heavy' || balance == 'even balance' || balance == 'even') {
        matchTypeContribution = 20.0;
        matchReason = 'solid frame control and smash capability suit singles space coverage';
      } else {
        matchTypeContribution = 10.0;
        matchReason = 'light smash weight makes long singles court clears more tiring';
      }
    } else {
      matchTypeContribution = 20.0;
      matchReason = 'versatile specifications suit generic match formats';
    }

    final int finalRating = rawScore.clamp(0.0, 100.0).round();

    // Construct Simulated SHAP feature attribution explanation
    final List<String> attributions = [];
    void addAttr(String featureName, double contribution, String reason) {
      final String sign = contribution >= 0 ? '+' : '';
      attributions.add(
        '$featureName: $sign${contribution.toStringAsFixed(0)}% ($reason)',
      );
    }

    addAttr('Budget Fit', budgetContribution, budgetReason);
    addAttr('Skill vs Flexibility', skillFlexContribution, skillReason);
    addAttr('Strength vs Weight', strengthWeightContribution, strengthReason);
    addAttr('Style vs Balance', styleBalanceContribution, styleReason);
    addAttr('Match Type Fit', matchTypeContribution, matchReason);

    final String shapExplanation =
        'SHAP explainable AI report: Base prediction is ${baseValue.toStringAsFixed(0)}%. '
        'Attribution contributions: ${attributions.join("; ")}. '
        'Total match compatibility: $finalRating%.';

    return racket.copyWith(
      matchRating: finalRating,
      matchExplanation: shapExplanation,
    );
  }
}
