class MarketListing {
  final String? id;
  final String sellerId;
  final String title;
  final String brand;
  final double priceMyr;
  final String itemCondition;
  final String location;
  final String imageUrl;
  final DateTime? createdAt;

  const MarketListing({
    this.id,
    required this.sellerId,
    required this.title,
    required this.brand,
    required this.priceMyr,
    required this.itemCondition,
    required this.location,
    required this.imageUrl,
    this.createdAt,
  });

  // Backwards compatibility properties for existing UI (MarketplaceItem)
  double get price => priceMyr;
  String get imagePath => imageUrl;
  String get condition => itemCondition;
  String get tag => brand == 'Other' ? '' : brand.toUpperCase();
  String get category => _inferCategory(title);

  static String _inferCategory(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('shoe') || lower.contains('footwear')) return 'Footwear';
    if (lower.contains('bag') || lower.contains('backpack')) return 'Bags';
    if (lower.contains('string') || lower.contains('grip') || lower.contains('shuttle') || lower.contains('tube')) return 'Accessories';
    return 'Racquets'; // default fallback
  }

  factory MarketListing.fromJson(Map<String, dynamic> json) {
    return MarketListing(
      id: json['id'] as String?,
      sellerId: json['seller_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      brand: json['brand'] as String? ?? 'Other',
      priceMyr: (json['price_myr'] as num?)?.toDouble() ?? 0.0,
      itemCondition: json['item_condition'] as String? ?? '',
      location: json['location'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'seller_id': sellerId,
      'title': title,
      'brand': brand,
      'price_myr': priceMyr,
      'item_condition': itemCondition,
      'location': location,
      'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
