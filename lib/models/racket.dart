class Racket {
  final String brand;
  final String name;
  final String series;
  final String weight;
  final String weightRange;
  final String balance;
  final int balanceValue; // in mm
  final String balanceText; // e.g., "Head Heavy", "Power Boost"
  final String flex;
  final String imagePath;
  final int matchRating;
  final String matchExplanation;

  const Racket({
    required this.brand,
    required this.name,
    required this.series,
    required this.weight,
    required this.weightRange,
    required this.balance,
    required this.balanceValue,
    required this.balanceText,
    required this.flex,
    required this.imagePath,
    required this.matchRating,
    required this.matchExplanation,
  });
}
