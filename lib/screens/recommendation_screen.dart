import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_button.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int _selectedRacketIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final recommendedList = state.recommendedRackets;

    if (recommendedList.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1622),
        body: Center(
          child: Text(
            "No recommendations found.",
            style: TextStyle(color: Colors.white60, fontFamily: 'Inter'),
          ),
        ),
      );
    }

    if (_selectedRacketIndex >= recommendedList.length) {
      _selectedRacketIndex = 0;
    }

    final recommended = recommendedList[_selectedRacketIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1622),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Segmented selection bar for top 3
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF111C28),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                child: Row(
                  children: List.generate(recommendedList.length, (index) {
                    final isSelected = _selectedRacketIndex == index;
                    final racket = recommendedList[index];
                    final label = "${index + 1}. ${racket.priceTier.toUpperCase()}";

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRacketIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00F5D4)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF0D1622)
                                    : Colors.white70,
                                fontFamily: 'Orbitron',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // Product Showcase Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF111C28),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section with Image and Ribbon Badge
                    Stack(
                      children: [
                        // Racket Product Image Block on dark background
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            color: const Color(0xFF0A0F18),
                            child: Image.asset(
                              recommended.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.black45,
                                    child: const Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.white24,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        // Badge label
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F5D4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedRacketIndex == 0 ? "TOP RANKED" : "MATCH OPTION ${_selectedRacketIndex + 1}",
                              style: const TextStyle(
                                color: Color(0xFF0D1622),
                                fontFamily: 'Orbitron',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        // Match score badge
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111C28),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00F5D4),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              "${recommended.matchRating}% MATCH",
                              style: const TextStyle(
                                color: Color(0xFF00F5D4),
                                fontFamily: 'Orbitron',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Racket Detail Texts
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommended.brand,
                            style: const TextStyle(
                              color: Color(0xFF00F5D4),
                              fontFamily: 'Orbitron',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recommended.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Orbitron',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Spec Grid (3 columns)
                          Row(
                            children: [
                              Expanded(
                                child: _buildSpecCell(
                                  "Weight",
                                  recommended.weight,
                                ),
                              ),
                              Container(
                                height: 32,
                                width: 1,
                                color: Colors.white10,
                              ),
                              Expanded(
                                child: _buildSpecCell(
                                  "Balance",
                                  recommended.balance,
                                ),
                              ),
                              Container(
                                height: 32,
                                width: 1,
                                color: Colors.white10,
                              ),
                              Expanded(
                                child: _buildSpecCell("Flex", recommended.flex),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Explainable AI (ERS) Callout
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0F18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border(
                                left: BorderSide(
                                  color: const Color(0xFF00F5D4),
                                  width: 4,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF00F5D4),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    recommended.matchExplanation.replaceAll('; ', '\n• '),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full specs bottom action trigger button
              CustomButton(
                text: "VIEW FULL SPECS",
                trailingIcon: Icons.arrow_forward,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF111C28),
                      content: Text(
                        "Navigating to detailed structural engineering analysis for ${recommended.name}...",
                        style: const TextStyle(
                          color: Color(0xFF00F5D4),
                          fontFamily: 'Inter',
                        ),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontFamily: 'Inter',
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00F5D4),
            fontFamily: 'Orbitron',
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
