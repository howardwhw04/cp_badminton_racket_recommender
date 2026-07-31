import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/racket.dart';
import '../models/market_listing.dart';
import '../models/user_profile.dart';
import '../services/recommendation_service.dart';

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
    return metadata?['display_name'] as String? ??
        metadata?['full_name'] as String? ??
        'Elite Athlete';
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
  int _selectedSkillLevelIndex =
      1; // 0 = Beginner, 1 = Intermediate, 2 = Advanced
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
    // Always load static rackets from Supabase on startup
    fetchRackets();
    _initializeFallbackRackets();

    // Check initial session
    final session = _supabase.auth.currentSession;
    _isLoggedIn = session != null;
    _email = session?.user.email ?? '';
    if (_isLoggedIn) {
      fetchUserProfile();
      fetchMarketListings();
    }

    // Listen to authentication state updates dynamically
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      _isLoggedIn = session != null;
      _email = session?.user.email ?? '';
      if (_isLoggedIn) {
        fetchUserProfile();
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
        _preferredBudgetTier =
            data['preferred_budget_tier'] as String? ?? 'Mid-Range';
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
        UserAttributes(data: {'display_name': displayName}),
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
    _marketListings.clear();
  }

  Future<void> login(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);
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
    // YONEX MODELS
    const Racket(
      brand: 'Yonex',
      name: 'Astrox 99 Pro',
      weightClass: '4U',
      weightGramsRange: '80-84g',
      balancePointMm: 305,
      balanceCategory: 'Head Heavy',
      shaftFlexibility: 'Stiff',
      priceMyr: 689.00,
      priceTier: 'Premium',
      assetImagePath: 'assets/images/astrox_99_pro.png',
      description:
          'Engineered for explosive rear-court power. Features the 2G-Namd Flex Force graphite and Rotational Generator System for heavy, steep smashes and continuous attacking play.',
    ),
    const Racket(
      brand: 'Yonex',
      name: 'Astrox 100ZZ',
      weightClass: '3U',
      weightGramsRange: '85-89g',
      balancePointMm: 308,
      balanceCategory: 'Head Heavy',
      shaftFlexibility: 'Stiff',
      priceMyr: 729.00,
      priceTier: 'Premium',
      assetImagePath: 'assets/images/astrox_100zz.png',
      description:
          'The flagship attacking racket built with a Hyper Slim Shaft and Namd graphite. Designed for advanced players seeking maximum smash velocity and hyper-fast shot recovery.',
    ),
    const Racket(
      brand: 'Yonex',
      name: 'Nanoflare 800 Game',
      weightClass: '4U',
      weightGramsRange: '80-84g',
      balancePointMm: 288,
      balanceCategory: 'Head Light',
      shaftFlexibility: 'Medium',
      priceMyr: 380.00,
      priceTier: 'Mid-Range',
      assetImagePath: 'assets/images/nanoflare_800_game.png',
      description:
          'A speed-oriented racket engineered with a Sonic Flare System. Offers lightning-fast swing speeds, ideal for rapid drive exchanges and quick defensive counter-attacks.',
    ),
    const Racket(
      brand: 'Yonex',
      name: 'Arcsaber 11 Play',
      weightClass: '4U',
      weightGramsRange: '80-84g',
      balancePointMm: 293,
      balanceCategory: 'Even Balance',
      shaftFlexibility: 'Flexible',
      priceMyr: 189.00,
      priceTier: 'Budget',
      assetImagePath: 'assets/images/arcsaber_11_play.png',
      description:
          'An all-around control racket designed to hold the shuttlecock longer on the string bed. Perfect for club players seeking high accuracy, stability, and comfortable power generation.',
    ),
    const Racket(
      brand: 'Yonex',
      name: 'Nanoflare 170 Light',
      weightClass: '5U',
      weightGramsRange: '75-79g',
      balancePointMm: 285,
      balanceCategory: 'Head Light',
      shaftFlexibility: 'Flexible',
      priceMyr: 169.00,
      priceTier: 'Budget',
      assetImagePath: 'assets/images/nanoflare_170.png',
      description:
          'An ultra-lightweight, head-light racket designed for effortless maneuvering and swift reactions at the net. Highly recommended for developing players and junior athletes.',
    ),

    // LI-NING MODELS
    const Racket(
      brand: 'Li-Ning',
      name: 'Axforce 90 Max',
      weightClass: '3U',
      weightGramsRange: '85-89g',
      balancePointMm: 305,
      balanceCategory: 'Head Heavy',
      shaftFlexibility: 'Stiff',
      priceMyr: 750.00,
      priceTier: 'Premium',
      assetImagePath: 'assets/images/axforce_90.png',
      description:
          'Built with TB Nano carbon fiber and a slim 6.2mm hard flexible shaft. Delivers concentrated power transmission for dominant single players and backcourt smashers.',
    ),
    const Racket(
      brand: 'Li-Ning',
      name: 'Axforce 70',
      weightClass: '4U',
      weightGramsRange: '80-84g',
      balancePointMm: 300,
      balanceCategory: 'Head Heavy',
      shaftFlexibility: 'Medium',
      priceMyr: 480.00,
      priceTier: 'Mid-Range',
      assetImagePath: 'assets/images/axforce_70.png',
      description:
          'Features a box wing frame layout to maximize hitting power while maintaining smooth maneuverability. Great for aggressive intermediate players looking for accessible head-heavy power.',
    ),
    const Racket(
      brand: 'Li-Ning',
      name: 'Halbertec 6000',
      weightClass: '4U',
      weightGramsRange: '80-84g',
      balancePointMm: 295,
      balanceCategory: 'Even Balance',
      shaftFlexibility: 'Medium',
      priceMyr: 420.00,
      priceTier: 'Mid-Range',
      assetImagePath: 'assets/images/halbertec_6000.png',
      description:
          'Designed with a frame system that balances elasticity and control. Excellent for tactical players who rely on precise shuttle placement, drop shots, and consistent rallies.',
    ),
    const Racket(
      brand: 'Li-Ning',
      name: 'BladeX 200',
      weightClass: '4U',
      weightGramsRange: '80-84g',
      balancePointMm: 288,
      balanceCategory: 'Head Light',
      shaftFlexibility: 'Flexible',
      priceMyr: 199.00,
      priceTier: 'Budget',
      assetImagePath: 'assets/images/bladex_200.png',
      description:
          'Focuses on rapid swing speeds and defensive agility. The flexible shaft assists developing players in generating court clearing depth with minimal arm strain.',
    ),
    const Racket(
      brand: 'Li-Ning',
      name: 'Windstorm 72',
      weightClass: '7U/8U',
      weightGramsRange: 'Below 70g',
      balancePointMm: 312,
      balanceCategory: 'Head Heavy',
      shaftFlexibility: 'Flexible',
      priceMyr: 289.00,
      priceTier: 'Mid-Range',
      assetImagePath: 'assets/images/windstorm_72.png',
      description:
          'Super lightweight yet head-heavy. Designed specifically for fast doubles play, offering incredible reaction speed without forfeiting overhead smash power.',
    ),

    // VICTOR MODELS
    const Racket(
      brand: 'Victor',
      name: 'Thruster Ryuga II',
      weightClass: '3U',
      weightGramsRange: '85-89g',
      balancePointMm: 307,
      balanceCategory: 'Head Heavy',
      shaftFlexibility: 'Stiff',
      priceMyr: 650.00,
      priceTier: 'Premium',
      assetImagePath: 'assets/images/ryuga_2.png',
      description:
          'Equipped with WES 2.0 technology and a Free Core synthetic handle. Engineered for aggressive offensive play, delivering whipping smash angles and solid feel at impact.',
    ),
    const Racket(
      brand: 'Victor',
      name: 'Auraspeed 90K II',
      weightClass: '4U',
      weightGramsRange: '80-84g',
      balancePointMm: 292,
      balanceCategory: 'Head Light',
      shaftFlexibility: 'Stiff',
      priceMyr: 590.00,
      priceTier: 'Premium',
      assetImagePath: 'assets/images/auraspeed_90k.png',
      description:
          'Designed for high-speed flat drives and push attacks. Incorporates a Compound-Sword frame to reduce air resistance and deliver immediate rebound velocity.',
    ),
    const Racket(
      brand: 'Victor',
      name: 'DriveX 9X',
      weightClass: '4U',
      weightGramsRange: '80-84g',
      balancePointMm: 295,
      balanceCategory: 'Even Balance',
      shaftFlexibility: 'Medium',
      priceMyr: 520.00,
      priceTier: 'Mid-Range',
      assetImagePath: 'assets/images/drivex_9x.png',
      description:
          'A versatile all-around racket utilizing the Dynamic-Sword frame structure. Delivers smooth handling, excellent stability on touch shots, and balanced attacking power.',
    ),
    const Racket(
      brand: 'Victor',
      name: 'Thruster Hammer (TK-HMR)',
      weightClass: '4U',
      weightGramsRange: '80-84g',
      balancePointMm: 300,
      balanceCategory: 'Head Heavy',
      shaftFlexibility: 'Flexible',
      priceMyr: 169.00,
      priceTier: 'Budget',
      assetImagePath: 'assets/images/tk_hmr.png',
      description:
          'An entry-level power racket built with Power Box technology. Features a flexible shaft to help beginners produce high clears and smashes with less effort.',
    ),
    const Racket(
      brand: 'Victor',
      name: 'Auraspeed 30H',
      weightClass: '4U',
      weightGramsRange: '80-84g',
      balancePointMm: 290,
      balanceCategory: 'Head Light',
      shaftFlexibility: 'Medium',
      priceMyr: 210.00,
      priceTier: 'Mid-Range',
      assetImagePath: 'assets/images/auraspeed_30h.png',
      description:
          'High-tension durable speed racket capable of supporting up to 31 lbs. Great for fast-paced doubles defense and rapid net interceptions.',
    ),
  ];

  List<Racket> _filteredFallbackRackets = [];

  Future<void> _initializeFallbackRackets() async {
    _filteredFallbackRackets = await _filterRacketsWithExistingAssets(_rackets);
    notifyListeners();
  }

  Future<List<Racket>> _filterRacketsWithExistingAssets(
    List<Racket> inputList,
  ) async {
    final List<Racket> result = [];
    for (final racket in inputList) {
      final path = racket.imagePath;
      final exists = await _checkAssetExists(path);
      if (exists) {
        final actualPath = await _resolveActualAssetPath(path);
        result.add(racket.copyWith(assetImagePath: actualPath));
      }
    }
    return result;
  }

  Future<bool> _checkAssetExists(String assetPath) async {
    if (assetPath.startsWith('http://') || assetPath.startsWith('https://')) {
      return true;
    }
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      if (assetPath.endsWith('.png')) {
        try {
          final fallback = assetPath.replaceAll('.png', '.jpg');
          await rootBundle.load(fallback);
          return true;
        } catch (_) {}
      } else if (assetPath.endsWith('.jpg')) {
        try {
          final fallback = assetPath.replaceAll('.jpg', '.png');
          await rootBundle.load(fallback);
          return true;
        } catch (_) {}
      }
      return false;
    }
  }

  Future<String> _resolveActualAssetPath(String assetPath) async {
    if (assetPath.startsWith('http://') || assetPath.startsWith('https://')) {
      return assetPath;
    }
    try {
      await rootBundle.load(assetPath);
      return assetPath;
    } catch (_) {
      if (assetPath.endsWith('.png')) {
        final fallback = assetPath.replaceAll('.png', '.jpg');
        try {
          await rootBundle.load(fallback);
          return fallback;
        } catch (_) {}
      } else if (assetPath.endsWith('.jpg')) {
        final fallback = assetPath.replaceAll('.jpg', '.png');
        try {
          await rootBundle.load(fallback);
          return fallback;
        } catch (_) {}
      }
      return assetPath;
    }
  }

  Future<void> fetchRackets() async {
    _isLoadingRackets = true;
    notifyListeners();
    try {
      final List<dynamic> data = await _supabase.from('rackets').select();
      List<Racket> fetchedRackets = [];
      if (data.isNotEmpty) {
        fetchedRackets = data
            .map((json) => Racket.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint(
          "Supabase rackets table is empty. Seeding fallback rackets...",
        );
        final racketsJson = _rackets.map((r) => r.toJson()).toList();
        await _supabase.from('rackets').insert(racketsJson);
        final List<dynamic> refetched = await _supabase
            .from('rackets')
            .select();
        fetchedRackets = refetched
            .map((json) => Racket.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      _dbRackets = await _filterRacketsWithExistingAssets(fetchedRackets);
    } catch (e) {
      debugPrint("Error fetching rackets from Supabase: $e");
    } finally {
      _isLoadingRackets = false;
      notifyListeners();
    }
  }

  UserProfile get userProfile => UserProfile(
    id: _supabase.auth.currentUser?.id ?? '',
    skillLevel: _selectedSkillLevelIndex,
    matches: _matches,
    winRate: _winRate,
    powerIndex: _powerIndex,
    control: _control,
    playingStyle: _playingStyle,
    hasLowStrength: _hasLowStrength,
    matchType: _matchType,
    preferredBudgetTier: _preferredBudgetTier,
    updatedAt: DateTime.now(),
  );

  List<Racket> get rackets {
    final list = _dbRackets.isNotEmpty
        ? _dbRackets
        : (_filteredFallbackRackets.isNotEmpty
              ? _filteredFallbackRackets
              : _rackets);
    final service = RecommendationService();
    return list
        .map((racket) => service.scoreRacket(racket, userProfile))
        .toList();
  }

  List<Racket> get dbRackets {
    final list = _dbRackets.isNotEmpty
        ? _dbRackets
        : (_filteredFallbackRackets.isNotEmpty
              ? _filteredFallbackRackets
              : _rackets);
    final service = RecommendationService();
    return list
        .map((racket) => service.scoreRacket(racket, userProfile))
        .toList();
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

  void setComparisonFromRecommended() {
    final allList = _dbRackets.isNotEmpty
        ? _dbRackets
        : (_filteredFallbackRackets.isNotEmpty
              ? _filteredFallbackRackets
              : _rackets);
    final recommended = recommendedRackets;

    _comparedRacketIndices.clear();
    for (final rec in recommended) {
      final idx = allList.indexWhere((r) => r.name == rec.name);
      if (idx != -1) {
        _comparedRacketIndices.add(idx);
      }
    }
    // Limit to max 3 compared rackets for the side-by-side comparison layout
    if (_comparedRacketIndices.length > 3) {
      _comparedRacketIndices.removeRange(3, _comparedRacketIndices.length);
    }
    // Safety fallback
    if (_comparedRacketIndices.isEmpty && allList.isNotEmpty) {
      _comparedRacketIndices.add(0);
    }
    notifyListeners();
  }

  // Marketplace State
  List<MarketListing> _marketListings = [];
  bool _isLoadingMarket = false;

  List<MarketListing> get marketplaceItems =>
      _marketListings.isNotEmpty ? _marketListings : _fallbackMarketListings;
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
      _marketListings = data
          .map((json) => MarketListing.fromJson(json as Map<String, dynamic>))
          .toList();
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
      final response = await _supabase
          .from('market_listings')
          .insert(json)
          .select()
          .single();
      final created = MarketListing.fromJson(response);
      _marketListings.insert(0, created);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding market listing: $e");
      rethrow;
    }
  }

  Future<void> updateMarketListing(MarketListing listing) async {
    debugPrint(
      "updateMarketListing - listing.id: ${listing.id}, listing.sellerId: ${listing.sellerId}, currentUser: ${Supabase.instance.client.auth.currentUser?.id}",
    );
    try {
      final json = {
        'seller_id': listing.sellerId,
        'title': listing.title,
        'brand': listing.brand,
        'price_myr': listing.priceMyr,
        'item_condition': listing.itemCondition,
        'location': listing.location,
        'image_url': listing.imageUrl,
      };
      final response = await _supabase
          .from('market_listings')
          .update(json)
          .eq('id', listing.id!)
          .select()
          .single();
      final updated = MarketListing.fromJson(response);
      final index = _marketListings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _marketListings[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating market listing: $e");
      rethrow;
    }
  }

  Future<void> deleteMarketListing(String id) async {
    try {
      await _supabase.from('market_listings').delete().eq('id', id);
      _marketListings.removeWhere((l) => l.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting market listing: $e");
      rethrow;
    }
  }

  String _selectedMarketFilter = "All Items";
  String get selectedMarketFilter => _selectedMarketFilter;

  void selectMarketFilter(String filter) {
    _selectedMarketFilter = filter;
    notifyListeners();
  }

  List<Racket> get recommendedRackets {
    final service = RecommendationService();
    final list = _dbRackets.isNotEmpty
        ? _dbRackets
        : (_filteredFallbackRackets.isNotEmpty
              ? _filteredFallbackRackets
              : _rackets);
    final recommendationsMap = service.getRecommendationsFromList(
      userProfile,
      list,
    );
    if (recommendationsMap.isEmpty) {
      final scoredList = list
          .map((racket) => service.scoreRacket(racket, userProfile))
          .toList();
      scoredList.sort((a, b) => b.matchRating.compareTo(a.matchRating));
      return scoredList.take(3).toList();
    }
    final recommendations = recommendationsMap.values.toList();
    recommendations.sort((a, b) => b.matchRating.compareTo(a.matchRating));
    return recommendations;
  }

  Racket get recommendedRacket {
    final list = recommendedRackets;
    if (list.isEmpty) {
      final listRaw = _dbRackets.isNotEmpty
          ? _dbRackets
          : (_filteredFallbackRackets.isNotEmpty
                ? _filteredFallbackRackets
                : _rackets);
      final service = RecommendationService();
      return service.scoreRacket(listRaw[0], userProfile);
    }
    return list.first;
  }
}
