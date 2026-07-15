import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/racket.dart';
import '../models/marketplace_item.dart';

class AppState extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Authentication State
  bool _isLoggedIn = false;
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  String get email => _email;

  AppState() {
    // Check initial session
    final session = _supabase.auth.currentSession;
    _isLoggedIn = session != null;
    _email = session?.user.email ?? '';

    // Listen to authentication state updates dynamically
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      _isLoggedIn = session != null;
      _email = session?.user.email ?? '';
      notifyListeners();
    });
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

  // Questionnaire / Quiz State
  int _selectedSkillLevelIndex = 1; // 0 = Beginner, 1 = Intermediate, 2 = Advanced
  int _currentQuizStep = 0; // 0, 1, 2

  int get selectedSkillLevelIndex => _selectedSkillLevelIndex;
  int get currentQuizStep => _currentQuizStep;

  void selectSkillLevel(int index) {
    _selectedSkillLevelIndex = index;
    notifyListeners();
  }

  void setQuizStep(int step) {
    _currentQuizStep = step;
    notifyListeners();
  }

  // Rackets Database
  final List<Racket> _rackets = [
    const Racket(
      brand: "YONEX PROFESSIONAL",
      name: "Astrox 99 Pro",
      series: "Astrox Series",
      weight: "4U",
      weightRange: "80-84g",
      balance: "Head Heavy",
      balanceValue: 305,
      balanceText: "Power Boost",
      flex: "Medium",
      imagePath: "assets/images/racket_astrox.png",
      matchRating: 94,
      matchExplanation: "This racket is highly recommended because your attacking playing style added 90% to the match score, and its head-heavy balance point aligns with your power metrics.",
    ),
    const Racket(
      brand: "AERO",
      name: "Pro-X1",
      series: "Precision Series",
      weight: "3U",
      weightRange: "85-89g",
      balance: "Head Heavy",
      balanceValue: 298,
      balanceText: "Head Heavy",
      flex: "STIFF",
      imagePath: "assets/images/racket_prox1.png",
      matchRating: 88,
      matchExplanation: "Suitable for offensive players looking for additional smash power, with stiff shaft flexibility for elite accuracy.",
    ),
    const Racket(
      brand: "VOLT",
      name: "Volt S3",
      series: "Speed Series",
      weight: "4U",
      weightRange: "80-84g",
      balance: "Head Heavy",
      balanceValue: 305,
      balanceText: "Power Boost",
      flex: "STIFF",
      imagePath: "assets/images/racket_volts3.png",
      matchRating: 82,
      matchExplanation: "A lightweight speed racket with head-heavy specs to give quick control and reliable netplay support.",
    ),
    const Racket(
      brand: "YONEX",
      name: "Astrox 88D Pro",
      series: "Astrox Series",
      weight: "4U",
      weightRange: "80-84g",
      balance: "Head Heavy",
      balanceValue: 301,
      balanceText: "Head Heavy",
      flex: "STIFF",
      imagePath: "assets/images/racket_astrox.png",
      matchRating: 91,
      matchExplanation: "Excellent rear court dominance model with enhanced flex for steep angle attacks.",
    ),
    const Racket(
      brand: "LI-NING",
      name: "Tectonic 7",
      series: "Tectonic Series",
      weight: "4U",
      weightRange: "80-84g",
      balance: "Even",
      balanceValue: 295,
      balanceText: "Even Balance",
      flex: "Medium",
      imagePath: "assets/images/racket_volts3.png",
      matchRating: 78,
      matchExplanation: "A flexible and forgiving racket designed to absorb frame impact and offer fast backhand recovery.",
    ),
  ];

  List<Racket> get rackets => _rackets;

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
        // Swap last
        _comparedRacketIndices.removeLast();
        _comparedRacketIndices.add(index);
      }
    }
    notifyListeners();
  }

  // Marketplace State
  final List<MarketplaceItem> _marketplaceItems = [
    const MarketplaceItem(
      title: "Yonex Astrox 88D Pro",
      price: 580.0,
      imagePath: "assets/images/racket_astrox.png",
      condition: "Used - Like New",
      usageDuration: "6 Months Used",
      location: "Kuala Lumpur",
      tag: "ELITE",
      category: "Racquets",
    ),
    const MarketplaceItem(
      title: "Victor P9200II TD",
      price: 290.0,
      imagePath: "assets/images/market_shoes.png",
      condition: "Used - Good",
      usageDuration: "6 Months Used",
      location: "Subang Jaya",
      tag: "",
      category: "Footwear",
    ),
    const MarketplaceItem(
      title: "Li-Ning Tour Bag",
      price: 150.0,
      imagePath: "assets/images/market_bag.png",
      condition: "Well Maintained",
      usageDuration: "12 Months Used",
      location: "Penang",
      tag: "",
      category: "Bags",
    ),
    const MarketplaceItem(
      title: "Li-Ning Tectonic 7",
      price: 420.0,
      imagePath: "assets/images/racket_volts3.png",
      condition: "Minor Paint Chip",
      usageDuration: "5 Months Used",
      location: "Johor Bahru",
      tag: "",
      category: "Racquets",
    ),
    const MarketplaceItem(
      title: "RSL Classic (10 tubes)",
      price: 750.0,
      imagePath: "assets/images/racket_astrox.png",
      condition: "Brand New",
      usageDuration: "Unused",
      location: "Ipoh",
      tag: "",
      category: "Accessories",
    ),
    const MarketplaceItem(
      title: "Stringing Service",
      price: 35.0,
      imagePath: "assets/images/auth_bg.png",
      condition: "Professional",
      usageDuration: "Express 1-Hour",
      location: "Cheras",
      tag: "",
      category: "Accessories",
    ),
  ];

  List<MarketplaceItem> get marketplaceItems => _marketplaceItems;

  String _selectedMarketFilter = "All Items";
  String get selectedMarketFilter => _selectedMarketFilter;

  void selectMarketFilter(String filter) {
    _selectedMarketFilter = filter;
    notifyListeners();
  }

  void addMarketplaceItem(MarketplaceItem item) {
    _marketplaceItems.insert(0, item);
    notifyListeners();
  }

  // Dynamic calibration adjustment based on Quiz response
  Racket get recommendedRacket {
    switch (_selectedSkillLevelIndex) {
      case 0: // Beginner
        return _rackets[4]; // Tectonic 7 (Even, Medium flex)
      case 2: // Advanced
        return _rackets[1]; // Pro-X1 (Head heavy, stiff)
      case 1: // Intermediate
      default:
        return _rackets[0]; // Astrox 99 Pro (Head heavy, medium)
    }
  }
}
