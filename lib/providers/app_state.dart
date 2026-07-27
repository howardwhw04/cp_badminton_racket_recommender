import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/racket.dart';
import '../models/market_listing.dart';

class AppState extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Authentication State
  bool _isLoggedIn = false;
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  String get email => _email;

  String get displayName {
    if (!_isLoggedIn) return 'Anonymous Player';
    final user = _supabase.auth.currentUser;
    final metadata = user?.userMetadata;
    return metadata?['display_name'] as String? ?? metadata?['full_name'] as String? ?? 'Elite Athlete';
  }

  // User Profile Statistics (database backed)
  int _matches = 0;
  int _winRate = 0;
  int _powerIndex = 50;
  int _control = 50;

  int get matches => _matches;
  int get winRate => _winRate;
  int get powerIndex => _powerIndex;
  int get control => _control;

  // User Profile Attributes (Quiz responses)
  int _selectedSkillLevelIndex = 1; // 0 = Beginner, 1 = Intermediate, 2 = Advanced
  String _playingStyle = 'All-Rounder';
  bool _hasLowStrength = false;
  String _matchType = 'Singles';
  String _preferredBudgetTier = 'Mid-Range';
  int _currentQuizStep = 0;

  int get selectedSkillLevelIndex => _selectedSkillLevelIndex;
  String get playingStyle => _playingStyle;
  bool get hasLowStrength => _hasLowStrength;
  String get matchType => _matchType;
  String get preferredBudgetTier => _preferredBudgetTier;
  int get currentQuizStep => _currentQuizStep;

  AppState() {
    // Check initial session
    final session = _supabase.auth.currentSession;
    _isLoggedIn = session != null;
    _email = session?.user.email ?? '';
    if (_isLoggedIn) {
      fetchUserProfile();
      fetchRackets();
      fetchMarketListings();
    }

    // Listen to authentication state updates dynamically
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      _isLoggedIn = session != null;
      _email = session?.user.email ?? '';
      if (_isLoggedIn) {
        fetchUserProfile();
        fetchRackets();
        fetchMarketListings();
      } else {
        _resetProfile();
      }
      notifyListeners();
    });
  }

  Future<void> fetchUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        _selectedSkillLevelIndex = data['skill_level'] as int? ?? 1;
        _matches = data['matches'] as int? ?? 0;
        _winRate = data['win_rate'] as int? ?? 0;
        _powerIndex = data['power_index'] as int? ?? 50;
        _control = data['control'] as int? ?? 50;
        _playingStyle = data['playing_style'] as String? ?? 'All-Rounder';
        _hasLowStrength = data['has_low_strength'] as bool? ?? false;
        _matchType = data['match_type'] as String? ?? 'Singles';
        _preferredBudgetTier = data['preferred_budget_tier'] as String? ?? 'Mid-Range';
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
  }

  Future<void> updateUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'skill_level': _selectedSkillLevelIndex,
        'matches': _matches,
        'win_rate': _winRate,
        'power_index': _powerIndex,
        'control': _control,
        'playing_style': _playingStyle,
        'has_low_strength': _hasLowStrength,
        'match_type': _matchType,
        'preferred_budget_tier': _preferredBudgetTier,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Error updating user profile: $e");
    }
  }

  Future<void> submitQuizResponse({
    required int skillLevel,
    required String playingStyle,
    required bool hasLowStrength,
    required String matchType,
    required String preferredBudgetTier,
  }) async {
    _selectedSkillLevelIndex = skillLevel;
    _playingStyle = playingStyle;
    _hasLowStrength = hasLowStrength;
    _matchType = matchType;
    _preferredBudgetTier = preferredBudgetTier;
    notifyListeners();
    await updateUserProfile();
  }

  Future<void> updateFullProfile({
    String? displayName,
    required int skillLevel,
    required int matches,
    required int winRate,
    required int powerIndex,
    required int control,
    required String playingStyle,
    required bool hasLowStrength,
    required String matchType,
    required String preferredBudgetTier,
  }) async {
    _selectedSkillLevelIndex = skillLevel;
    _matches = matches;
    _winRate = winRate;
    _powerIndex = powerIndex;
    _control = control;
    _playingStyle = playingStyle;
    _hasLowStrength = hasLowStrength;
    _matchType = matchType;
    _preferredBudgetTier = preferredBudgetTier;

    if (displayName != null && _isLoggedIn) {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'display_name': displayName,
          },
        ),
      );
    }

    notifyListeners();
    await updateUserProfile();
  }

  void _resetProfile() {
    _selectedSkillLevelIndex = 1;
    _matches = 0;
    _winRate = 0;
    _powerIndex = 50;
    _control = 50;
    _playingStyle = 'All-Rounder';
    _hasLowStrength = false;
    _matchType = 'Singles';
    _preferredBudgetTier = 'Mid-Range';
    _currentQuizStep = 0;
    _dbRackets.clear();
    _marketListings.clear();
  }

  Future<void> login(String email, String password) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Questionnaire / Quiz Steps Control
  void selectSkillLevel(int index) {
    _selectedSkillLevelIndex = index;
    notifyListeners();
    updateUserProfile();
  }

  void setQuizStep(int step) {
    _currentQuizStep = step;
    notifyListeners();
  }

  // Rackets Database
  List<Racket> _dbRackets = [];
  bool _isLoadingRackets = false;
  bool get isLoadingRackets => _isLoadingRackets;

  final List<Racket> _rackets = [
    const Racket(
      brand: "YONEX PROFESSIONAL",
      name: "Astrox 99 Pro",
      weightClass: "4U",
      weightGramsRange: "80-84g",
      balancePointMm: 305,
      balanceCategory: "Head Heavy",
      shaftFlexibility: "Medium",
      priceMyr: 850.00,
      priceTier: "Premium",
      assetImagePath: "assets/images/racket_astrox.png",
      description: "Unleash devastating power and steep smash angles with Astrox 99 Pro, designed for high-performance players.",
    ),
    const Racket(
      brand: "AERO",
      name: "Pro-X1",
      weightClass: "3U",
      weightGramsRange: "85-89g",
      balancePointMm: 298,
      balanceCategory: "Head Heavy",
      shaftFlexibility: "Stiff",
      priceMyr: 450.00,
      priceTier: "Mid-Range",
      assetImagePath: "assets/images/racket_prox1.png",
      description: "Stiff shaft and head-heavy framework optimized for clinical accuracy and hard hitters.",
    ),
    const Racket(
      brand: "VOLT",
      name: "Volt S3",
      weightClass: "4U",
      weightGramsRange: "80-84g",
      balancePointMm: 305,
      balanceCategory: "Head Heavy",
      shaftFlexibility: "Stiff",
      priceMyr: 280.00,
      priceTier: "Budget",
      assetImagePath: "assets/images/racket_volts3.png",
      description: "High tension support and quick recoil capabilities make this budget head-heavy model ideal for fast offensive play.",
    ),
    const Racket(
      brand: "Yonex",
      name: "Astrox 88D Pro",
      weightClass: "4U",
      weightGramsRange: "80-84g",
      balancePointMm: 301,
      balanceCategory: "Head Heavy",
      shaftFlexibility: "Stiff",
      priceMyr: 820.00,
      priceTier: "Premium",
      assetImagePath: "assets/images/racket_astrox.png",
      description: "Front/rear-court dominance weapon featuring a concentrated sweet spot and robust flex.",
    ),
    const Racket(
      brand: "Li-Ning",
      name: "Tectonic 7",
      weightClass: "4U",
      weightGramsRange: "80-84g",
      balancePointMm: 295,
      balanceCategory: "Even Balance",
      shaftFlexibility: "Medium",
      priceMyr: 580.00,
      priceTier: "Premium",
      assetImagePath: "assets/images/racket_volts3.png",
      description: "Forgiving frame structure offers elastic recovery rate and outstanding defense absorption.",
    ),
  ];

  Future<void> fetchRackets() async {
    _isLoadingRackets = true;
    notifyListeners();
    try {
      final List<dynamic> data = await _supabase.from('rackets').select();
      if (data.isNotEmpty) {
        _dbRackets = data.map((json) => Racket.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching rackets from Supabase: $e");
    } finally {
      _isLoadingRackets = false;
      notifyListeners();
    }
  }

  // Calculate compatibility dynamically (0 - 100)
  Racket _calculateCompatibility(Racket racket) {
    int score = 0;
    List<String> matchingFactors = [];

    // 1. Budget Tier Match (20 points)
    if (racket.priceTier.toLowerCase() == _preferredBudgetTier.toLowerCase()) {
      score += 20;
      matchingFactors.add("fits your $_preferredBudgetTier budget tier");
    } else {
      final tiers = ['budget', 'mid-range', 'premium'];
      final racketIdx = tiers.indexOf(racket.priceTier.toLowerCase());
      final prefIdx = tiers.indexOf(_preferredBudgetTier.toLowerCase());
      if (racketIdx != -1 && prefIdx != -1 && (racketIdx - prefIdx).abs() == 1) {
        score += 10;
      }
    }

    // 2. Skill Level vs Shaft Flexibility (20 points)
    final skill = _selectedSkillLevelIndex;
    final flex = racket.shaftFlexibility.toLowerCase();
    if (skill == 0) { // Beginner
      if (flex == 'flexible') {
        score += 20;
        matchingFactors.add("flexible shaft matches beginner requirements");
      } else if (flex == 'medium') {
        score += 15;
      } else {
        score += 5;
      }
    } else if (skill == 1) { // Intermediate
      if (flex == 'medium') {
        score += 20;
        matchingFactors.add("medium shaft stiffness is ideal for club play");
      } else if (flex == 'flexible' || flex == 'stiff') {
        score += 15;
      }
    } else { // Advanced
      if (flex == 'stiff') {
        score += 20;
        matchingFactors.add("stiff shaft offers clinical accuracy for advanced control");
      } else if (flex == 'medium') {
        score += 10;
      }
    }

    // 3. Wrist/Physical Strength vs Weight (20 points)
    final weight = racket.weightClass;
    if (_hasLowStrength) {
      if (weight == '5U') {
        score += 20;
        matchingFactors.add("ultra-lightweight class protects wrist strength");
      } else if (weight == '4U') {
        score += 15;
        matchingFactors.add("forgiving 4U weight helps with lower arm strength");
      } else {
        score += 0;
      }
    } else {
      if (weight == '3U' || weight == '4U') {
        score += 20;
        matchingFactors.add("optimal weight distribution for solid stability");
      } else {
        score += 10;
      }
    }

    // 4. Playing Style vs Balance Category (20 points)
    final style = _playingStyle.toLowerCase();
    final balance = racket.balanceCategory.toLowerCase();
    if (style == 'attacking') {
      if (balance == 'head heavy') {
        score += 20;
        matchingFactors.add("head-heavy balance boosts smash power");
      } else if (balance == 'even balance' || balance == 'even') {
        score += 10;
      }
    } else if (style == 'defensive') {
      if (balance == 'head light' || balance.contains('light')) {
        score += 20;
        matchingFactors.add("head-light setup provides swift defensive recovery");
      } else if (balance == 'even balance' || balance == 'even') {
        score += 15;
      }
    } else { // All-Rounder
      if (balance == 'even balance' || balance == 'even') {
        score += 20;
        matchingFactors.add("even balance suits all-court gameplay");
      } else {
        score += 12;
      }
    }

    // 5. Match Type / Speed (20 points)
    final match = _matchType.toLowerCase();
    if (match == 'doubles') {
      if (balance == 'head light' || balance == 'even balance' || balance == 'even' || balance.contains('light')) {
        score += 20;
        matchingFactors.add("quick maneuverability is excellent for fast-paced doubles rallies");
      } else {
        score += 10;
      }
    } else if (match == 'singles') {
      if (balance == 'head heavy' || balance == 'even balance' || balance == 'even') {
        score += 20;
        matchingFactors.add("solid frame control gives dominance in singles court coverage");
      } else {
        score += 10;
      }
    } else { // Both
      score += 20;
      matchingFactors.add("versatile framework adapts well to both singles and doubles");
    }

    // Generate dynamic explanation
    String explanation = "This racket is rated at $score% compatibility. ";
    if (matchingFactors.isNotEmpty) {
      explanation += "Key factors: It ${matchingFactors.join(", and it ")}.";
    } else {
      explanation += racket.description.isNotEmpty ? racket.description : "Fits general recreation/club play styles.";
    }

    return racket.copyWith(
      matchRating: score,
      matchExplanation: explanation,
    );
  }

  List<Racket> get rackets {
    final list = _dbRackets.isNotEmpty ? _dbRackets : _rackets;
    return list.map((racket) => _calculateCompatibility(racket)).toList();
  }

  // Comparison State
  final List<int> _comparedRacketIndices = [1, 2]; // Default: Pro-X1, Volt S3
  List<int> get comparedRacketIndices => _comparedRacketIndices;

  void toggleComparison(int index) {
    if (_comparedRacketIndices.contains(index)) {
      if (_comparedRacketIndices.length > 1) {
        _comparedRacketIndices.remove(index);
      }
    } else {
      if (_comparedRacketIndices.length < 3) {
        _comparedRacketIndices.add(index);
      } else {
        _comparedRacketIndices.removeLast();
        _comparedRacketIndices.add(index);
      }
    }
    notifyListeners();
  }

  // Marketplace State
  List<MarketListing> _marketListings = [];
  bool _isLoadingMarket = false;

  List<MarketListing> get marketplaceItems => _marketListings.isNotEmpty ? _marketListings : _fallbackMarketListings;
  bool get isLoadingMarket => _isLoadingMarket;

  final List<MarketListing> _fallbackMarketListings = [
    const MarketListing(
      sellerId: '00000000-0000-0000-0000-000000000000',
      title: "Yonex Astrox 88D Pro",
      brand: "Yonex",
      priceMyr: 580.0,
      imageUrl: "assets/images/racket_astrox.png",
      itemCondition: "Used - Like New",
      location: "Kuala Lumpur",
    ),
    const MarketListing(
      sellerId: '00000000-0000-0000-0000-000000000000',
      title: "Victor P9200II TD",
      brand: "Victor",
      priceMyr: 290.0,
      imageUrl: "assets/images/market_shoes.png",
      itemCondition: "Used - Good",
      location: "Subang Jaya",
    ),
    const MarketListing(
      sellerId: '00000000-0000-0000-0000-000000000000',
      title: "Li-Ning Tour Bag",
      brand: "Li-Ning",
      priceMyr: 150.0,
      imageUrl: "assets/images/market_bag.png",
      itemCondition: "Well Maintained",
      location: "Penang",
    ),
    const MarketListing(
      sellerId: '00000000-0000-0000-0000-000000000000',
      title: "Li-Ning Tectonic 7",
      brand: "Li-Ning",
      priceMyr: 420.0,
      imageUrl: "assets/images/racket_volts3.png",
      itemCondition: "Minor Paint Chip",
      location: "Johor Bahru",
    ),
    const MarketListing(
      sellerId: '00000000-0000-0000-0000-000000000000',
      title: "RSL Classic (10 tubes)",
      brand: "Other",
      priceMyr: 750.0,
      imageUrl: "assets/images/racket_astrox.png",
      itemCondition: "Brand New",
      location: "Ipoh",
    ),
    const MarketListing(
      sellerId: '00000000-0000-0000-0000-000000000000',
      title: "Stringing Service",
      brand: "Other",
      priceMyr: 35.0,
      imageUrl: "assets/images/auth_bg.png",
      itemCondition: "Professional",
      location: "Cheras",
    ),
  ];

  Future<void> fetchMarketListings() async {
    _isLoadingMarket = true;
    notifyListeners();
    try {
      final List<dynamic> data = await _supabase
          .from('market_listings')
          .select()
          .order('created_at', ascending: false);
      _marketListings = data.map((json) => MarketListing.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("Error fetching market listings: $e");
    } finally {
      _isLoadingMarket = false;
      notifyListeners();
    }
  }

  Future<void> addMarketListing(MarketListing listing) async {
    try {
      final json = listing.toJson();
      final response = await _supabase.from('market_listings').insert(json).select().single();
      final created = MarketListing.fromJson(response);
      _marketListings.insert(0, created);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding market listing: $e");
      rethrow;
    }
  }

  String _selectedMarketFilter = "All Items";
  String get selectedMarketFilter => _selectedMarketFilter;

  void selectMarketFilter(String filter) {
    _selectedMarketFilter = filter;
    notifyListeners();
  }

  Racket get recommendedRacket {
    final list = rackets;
    if (list.isEmpty) return _rackets[0];
    Racket best = list[0];
    for (var r in list) {
      if (r.matchRating > best.matchRating) {
        best = r;
      }
    }
    return best;
  }
}

