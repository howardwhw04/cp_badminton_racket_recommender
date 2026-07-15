import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_button.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final recommended = state.recommendedRacket;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1622),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Circular Match Score Ring
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow behind the ring
                    Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F5D4).withOpacity(0.12),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Outer track circle
                    SizedBox(
                      height: 170,
                      width: 170,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                    // Active value progress indicator
                    SizedBox(
                      height: 170,
                      width: 170,
                      child: CircularProgressIndicator(
                        value: recommended.matchRating / 100.0,
                        strokeWidth: 8,
                        color: const Color(0xFF00F5D4),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Center Content Text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${recommended.matchRating}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Orbitron',
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              "%",
                              style: TextStyle(
                                color: Color(0xFF00F5D4),
                                fontFamily: 'Orbitron',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "MATCH RATING",
                          style: TextStyle(
                            color: const Color(0xFF00F5D4),
                            fontFamily: 'Orbitron',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF00F5D4).withOpacity(0.5),
                                blurRadius: 8,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Product Showcase Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF111C28),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
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
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.black45,
                                child: const Icon(Icons.image, size: 50, color: Colors.white24),
                              ),
                            ),
                          ),
                        ),
                        // Badge label
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F5D4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "TOP RANKED",
                              style: TextStyle(
                                color: Color(0xFF0D1622),
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
                                child: _buildSpecCell("Weight", recommended.weight),
                              ),
                              Container(
                                height: 32,
                                width: 1,
                                color: Colors.white10,
                              ),
                              Expanded(
                                child: _buildSpecCell("Balance", recommended.balance),
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
                                    recommended.matchExplanation,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
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
                        "Navigating to detailed structural engineering analysis...",
                        style: TextStyle(
                          color: const Color(0xFF00F5D4),
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
            color: Colors.white.withOpacity(0.4),
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
