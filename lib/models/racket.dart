class Racket {
  final int? id;
  final String brand;
  final String name;
  final String weightClass;
  final String weightGramsRange;
  final int balancePointMm;
  final String balanceCategory;
  final String shaftFlexibility;
  final double priceMyr;
  final String priceTier;
  final String assetImagePath;
  final String description;

  // Dynamic compatibility attributes calculated at runtime
  final int matchRating;
  final String matchExplanation;

  const Racket({
    this.id,
    required this.brand,
    required this.name,
    required this.weightClass,
    required this.weightGramsRange,
    required this.balancePointMm,
    required this.balanceCategory,
    required this.shaftFlexibility,
    required this.priceMyr,
    required this.priceTier,
    required this.assetImagePath,
    required this.description,
    this.matchRating = 80,
    this.matchExplanation = '',
  });

  // Backward compatibility getters
  String get series => "$brand Series";
  String get weight => weightClass;
  String get weightRange => weightGramsRange;
  String get balance => balanceCategory;
  int get balanceValue => balancePointMm;
  String get balanceText => balanceCategory;
  String get flex => shaftFlexibility;
  String get imagePath {
    if (assetImagePath.startsWith('http://') || assetImagePath.startsWith('https://')) {
      return assetImagePath;
    }
    if (assetImagePath.startsWith('assets/images/')) {
      return assetImagePath;
    }
    return 'assets/images/$assetImagePath';
  }

  factory Racket.fromJson(Map<String, dynamic> json) {
    return Racket(
      id: json['id'] as int?,
      brand: json['brand'] as String? ?? 'Yonex',
      name: json['name'] as String? ?? '',
      weightClass: json['weight_class'] as String? ?? '4U',
      weightGramsRange: json['weight_grams_range'] as String? ?? '80-84g',
      balancePointMm: json['balance_point_mm'] as int? ?? 295,
      balanceCategory: json['balance_category'] as String? ?? 'Even Balance',
      shaftFlexibility: json['shaft_flexibility'] as String? ?? 'Medium',
      priceMyr: (json['price_myr'] as num?)?.toDouble() ?? 0.0,
      priceTier: json['price_tier'] as String? ?? 'Mid-Range',
      assetImagePath: json['asset_image_path'] as String? ?? 'assets/images/racket_volts3.png',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'brand': brand,
      'name': name,
      'weight_class': weightClass,
      'weight_grams_range': weightGramsRange,
      'balance_point_mm': balancePointMm,
      'balance_category': balanceCategory,
      'shaft_flexibility': shaftFlexibility,
      'price_myr': priceMyr,
      'price_tier': priceTier,
      'asset_image_path': assetImagePath,
      'description': description,
    };
  }

  Racket copyWith({
    int? id,
    String? brand,
    String? name,
    String? weightClass,
    String? weightGramsRange,
    int? balancePointMm,
    String? balanceCategory,
    String? shaftFlexibility,
    double? priceMyr,
    String? priceTier,
    String? assetImagePath,
    String? description,
    int? matchRating,
    String? matchExplanation,
  }) {
    return Racket(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      weightClass: weightClass ?? this.weightClass,
      weightGramsRange: weightGramsRange ?? this.weightGramsRange,
      balancePointMm: balancePointMm ?? this.balancePointMm,
      balanceCategory: balanceCategory ?? this.balanceCategory,
      shaftFlexibility: shaftFlexibility ?? this.shaftFlexibility,
      priceMyr: priceMyr ?? this.priceMyr,
      priceTier: priceTier ?? this.priceTier,
      assetImagePath: assetImagePath ?? this.assetImagePath,
      description: description ?? this.description,
      matchRating: matchRating ?? this.matchRating,
      matchExplanation: matchExplanation ?? this.matchExplanation,
    );
  }
}

