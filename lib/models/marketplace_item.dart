class MarketplaceItem {
  final String title;
  final double price;
  final String imagePath;
  final String condition;
  final String usageDuration;
  final String location;
  final String tag; // e.g., "ELITE"
  final String category; // "Racquets", "Footwear", "Bags"

  const MarketplaceItem({
    required this.title,
    required this.price,
    required this.imagePath,
    required this.condition,
    required this.usageDuration,
    required this.location,
    required this.tag,
    required this.category,
  });
}
