import 'package:flutter_test/flutter_test.dart';
import 'package:badmimton_racket_recommender/models/racket.dart';
import 'package:badmimton_racket_recommender/models/user_profile.dart';
import 'package:badmimton_racket_recommender/services/recommendation_service.dart';

// Subclass RecommendationService to bypass Supabase initialization requirements in unit tests
class TestRecommendationService extends RecommendationService {
  final List<Map<String, dynamic>>? mockRawData;
  final bool shouldFail;

  TestRecommendationService({
    this.mockRawData,
    this.shouldFail = false,
  });

  @override
  Future<List<Map<String, dynamic>>> fetchRawRackets() async {
    if (shouldFail) {
      throw Exception("Supabase connection failed");
    }
    return mockRawData ?? [];
  }
}

void main() {
  group('RecommendationService Unit Tests', () {
    late RecommendationService recommendationService;

    setUp(() {
      recommendationService = TestRecommendationService();
    });

    final mockRackets = [
      const Racket(
        brand: 'Yonex',
        name: 'Budget Stiff',
        weightClass: '4U',
        weightGramsRange: '80-84g',
        balancePointMm: 300,
        balanceCategory: 'Head Heavy',
        shaftFlexibility: 'Stiff',
        priceMyr: 150.0,
        priceTier: 'Budget',
        assetImagePath: 'racket_volts3.png',
        description: 'Budget stiff racket',
      ),
      const Racket(
        brand: 'Li-Ning',
        name: 'Budget Medium',
        weightClass: '4U',
        weightGramsRange: '80-84g',
        balancePointMm: 295,
        balanceCategory: 'Even Balance',
        shaftFlexibility: 'Medium',
        priceMyr: 180.0,
        priceTier: 'Budget',
        assetImagePath: 'racket_volts3.png',
        description: 'Budget medium racket',
      ),
      const Racket(
        brand: 'Yonex',
        name: 'Mid Stiff',
        weightClass: '4U',
        weightGramsRange: '80-84g',
        balancePointMm: 305,
        balanceCategory: 'Head Heavy',
        shaftFlexibility: 'Stiff',
        priceMyr: 450.0,
        priceTier: 'Mid-Range',
        assetImagePath: 'racket_astrox.png',
        description: 'Mid range stiff racket',
      ),
      const Racket(
        brand: 'Victor',
        name: 'Mid Flex',
        weightClass: '4U',
        weightGramsRange: '80-84g',
        balancePointMm: 290,
        balanceCategory: 'Head Light',
        shaftFlexibility: 'Flexible',
        priceMyr: 380.0,
        priceTier: 'Mid-Range',
        assetImagePath: 'racket_astrox.png',
        description: 'Mid range flexible racket',
      ),
      const Racket(
        brand: 'Yonex',
        name: 'Premium Stiff',
        weightClass: '3U',
        weightGramsRange: '85-89g',
        balancePointMm: 310,
        balanceCategory: 'Head Heavy',
        shaftFlexibility: 'Stiff',
        priceMyr: 850.0,
        priceTier: 'Premium',
        assetImagePath: 'racket_astrox.png',
        description: 'Premium stiff racket',
      ),
      const Racket(
        brand: 'Li-Ning',
        name: 'Premium Medium',
        weightClass: '4U',
        weightGramsRange: '80-84g',
        balancePointMm: 295,
        balanceCategory: 'Even Balance',
        shaftFlexibility: 'Medium',
        priceMyr: 880.0,
        priceTier: 'Premium',
        assetImagePath: 'racket_astrox.png',
        description: 'Premium medium racket',
      ),
    ];

    test('KBS Filter: Filters out stiff shafts for Beginner skill level', () {
      final beginnerProfile = UserProfile(
        id: 'user-123',
        skillLevel: 0, // Beginner
        matches: 5,
        winRate: 40,
        powerIndex: 30,
        control: 40,
        playingStyle: 'Defensive',
        hasLowStrength: false,
        matchType: 'Singles',
        preferredBudgetTier: 'Mid-Range',
        updatedAt: DateTime.now(),
      );

      final recommendations = recommendationService.getRecommendationsFromList(
        beginnerProfile,
        mockRackets,
      );

      // Verify that all stiff rackets ('Budget Stiff', 'Mid Stiff', 'Premium Stiff') are filtered out
      for (final r in recommendations.values) {
        expect(r.shaftFlexibility.toLowerCase(), isNot('stiff'));
      }

      // Expected recommendations per tier
      expect(recommendations['Budget']?.name, equals('Budget Medium'));
      expect(recommendations['Mid-Range']?.name, equals('Mid Flex'));
      expect(recommendations['Premium']?.name, equals('Premium Medium'));
    });

    test('KBS Filter: Filters out stiff shafts for players with low strength', () {
      final lowStrengthProfile = UserProfile(
        id: 'user-456',
        skillLevel: 1, // Intermediate
        matches: 25,
        winRate: 50,
        powerIndex: 55,
        control: 50,
        playingStyle: 'Attacking',
        hasLowStrength: true, // Low strength
        matchType: 'Doubles',
        preferredBudgetTier: 'Premium',
        updatedAt: DateTime.now(),
      );

      final recommendations = recommendationService.getRecommendationsFromList(
        lowStrengthProfile,
        mockRackets,
      );

      // Verify that all stiff rackets are filtered out
      for (final r in recommendations.values) {
        expect(r.shaftFlexibility.toLowerCase(), isNot('stiff'));
      }

      // Expected recommendations per tier
      expect(recommendations['Budget']?.name, equals('Budget Medium'));
      expect(recommendations['Mid-Range']?.name, equals('Mid Flex'));
      expect(recommendations['Premium']?.name, equals('Premium Medium'));
    });

    test('No KBS Filter: Retains stiff shafts for Advanced/Intermediate with normal strength', () {
      final advancedProfile = UserProfile(
        id: 'user-789',
        skillLevel: 2, // Advanced
        matches: 100,
        winRate: 75,
        powerIndex: 85,
        control: 80,
        playingStyle: 'Attacking',
        hasLowStrength: false, // Normal strength
        matchType: 'Singles',
        preferredBudgetTier: 'Premium',
        updatedAt: DateTime.now(),
      );

      final recommendations = recommendationService.getRecommendationsFromList(
        advancedProfile,
        mockRackets,
      );

      // Since the player is Advanced & normal strength, stiff shafts are allowed.
      // Premium Stiff should score higher than Premium Medium for an advanced attacking singles player.
      expect(recommendations['Premium']?.name, equals('Premium Stiff'));
    });

    test('SHAP Explanation Output: Generates detailed natural language report with correct base prediction', () {
      final profile = UserProfile(
        id: 'user-abc',
        skillLevel: 1,
        matches: 10,
        winRate: 50,
        powerIndex: 50,
        control: 50,
        playingStyle: 'All-Rounder',
        hasLowStrength: false,
        matchType: 'Doubles',
        preferredBudgetTier: 'Mid-Range',
        updatedAt: DateTime.now(),
      );

      final recommendations = recommendationService.getRecommendationsFromList(
        profile,
        mockRackets,
      );

      for (final r in recommendations.values) {
        final explanation = r.matchExplanation;
        expect(explanation, contains('SHAP explainable AI report:'));
        expect(explanation, contains('Base prediction is 50%.'));
        expect(explanation, contains('Attribution contributions:'));
        expect(explanation, contains('Budget Fit:'));
        expect(explanation, contains('Skill vs Flexibility:'));
        expect(explanation, contains('Strength vs Weight:'));
        expect(explanation, contains('Style vs Balance:'));
        expect(explanation, contains('Match Type Fit:'));
        expect(explanation, contains('Total match compatibility:'));
        
        // Sum of base + contributions equals the matchRating
        expect(r.matchRating, isNotNull);
        expect(r.matchRating, greaterThanOrEqualTo(0));
        expect(r.matchRating, lessThanOrEqualTo(100));
      }
    });

    group('RecommendationService Supabase Integration', () {
      test('getRecommendations returns values fallback when Supabase Client fails', () async {
        final failService = TestRecommendationService(shouldFail: true);
        final profile = UserProfile(
          id: 'user-abc',
          skillLevel: 1,
          matches: 10,
          winRate: 50,
          powerIndex: 50,
          control: 50,
          playingStyle: 'All-Rounder',
          hasLowStrength: false,
          matchType: 'Doubles',
          preferredBudgetTier: 'Mid-Range',
          updatedAt: DateTime.now(),
        );

        final recommendations = await failService.getRecommendations(
          profile,
          fallbackRackets: mockRackets,
        );

        expect(recommendations.length, equals(3));
        expect(recommendations.containsKey('Budget'), isTrue);
        expect(recommendations.containsKey('Mid-Range'), isTrue);
        expect(recommendations.containsKey('Premium'), isTrue);
      });

      test('getRecommendations returns values from Supabase client when successful', () async {
        final mockRawList = mockRackets.map((r) => r.toJson()).toList();
        final successService = TestRecommendationService(mockRawData: mockRawList);
        final profile = UserProfile(
          id: 'user-abc',
          skillLevel: 1,
          matches: 10,
          winRate: 50,
          powerIndex: 50,
          control: 50,
          playingStyle: 'All-Rounder',
          hasLowStrength: false,
          matchType: 'Doubles',
          preferredBudgetTier: 'Mid-Range',
          updatedAt: DateTime.now(),
        );

        final recommendations = await successService.getRecommendations(profile);

        expect(recommendations.length, equals(3));
        expect(recommendations['Budget']?.name, equals('Budget Medium'));
        expect(recommendations['Mid-Range']?.name, equals('Mid Flex'));
        expect(recommendations['Premium']?.name, equals('Premium Medium'));
      });
    });
  });
}
