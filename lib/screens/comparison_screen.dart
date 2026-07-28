import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/racket.dart';
import '../widgets/custom_button.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).fetchRackets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final allRackets = state.dbRackets;
    final comparedIndices = state.comparedRacketIndices;

    // Resolve rackets being compared safely
    final List<Racket> comparedRackets = comparedIndices
        .where((idx) => idx >= 0 && idx < allRackets.length)
        .map((idx) => allRackets[idx])
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1622),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Technical Comparison",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Orbitron',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Analyze the core performance specs of your top selected gear side-by-side.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Inter',
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          if (state.isLoadingRackets) ...[
                            const SizedBox(height: 16),
                            const Center(
                              child: LinearProgressIndicator(color: Color(0xFF00F5D4)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (allRackets.isEmpty && !state.isLoadingRackets)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_off,
                                color: Colors.white24,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No Rackets Found",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Orbitron',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "The rackets list is empty. Please ensure you have created and populated the 'rackets' table in your Supabase database.",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // Racket Selection Tray (Horizontal Scroll)
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: allRackets.length,
                          itemBuilder: (context, index) {
                            final racket = allRackets[index];
                            final isCompared = comparedIndices.contains(index);

                            return GestureDetector(
                              onTap: () {
                                state.toggleComparison(index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 110,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111C28),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCompared
                                        ? const Color(0xFF00F5D4)
                                        : Colors.white.withValues(alpha: 0.06),
                                    width: isCompared ? 2 : 1,
                                  ),
                                  boxShadow: isCompared
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF00F5D4,
                                            ).withValues(alpha: 0.08),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Stack(
                                  children: [
                                    // Racket image backdrop
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          racket.imagePath,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    color: Colors.black38,
                                                  ),
                                        ),
                                      ),
                                    ),
                                    // Dark overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(alpha: 0.8),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Name tag overlay
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isCompared
                                              ? const Color(
                                                  0xFF00F5D4,
                                                ).withValues(alpha: 0.2)
                                              : Colors.black54,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          racket.name,
                                          style: TextStyle(
                                            color: isCompared
                                                ? const Color(0xFF00F5D4)
                                                : Colors.white,
                                            fontFamily: 'Orbitron',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    // Selected radio check indicator
                                    if (isCompared)
                                      const Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF00F5D4),
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Comparison Matrix Block
                      if (comparedRackets.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Text(
                              "Select rackets above to compare details.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        )
                      else ...[
                        // BRAND IDENTITY section
                        _buildSectionTitle("Brand Identity"),
                        _buildRow(
                          comparedRackets,
                          (racket) => _buildCardCell(racket.brand),
                        ),

                        // WEIGHT CLASS
                        _buildSectionTitle("Weight Class (U-Rating)"),
                        _buildRow(
                          comparedRackets,
                          (racket) => _buildDoubleLineCell(
                            racket.weight,
                            racket.weightRange,
                          ),
                        ),

                        // BALANCE POINT
                        _buildSectionTitle("Balance Point (mm)"),
                        _buildRow(
                          comparedRackets,
                          (racket) => _buildBalanceCell(racket),
                        ),

                        // SHAFT FLEXIBILITY
                        _buildSectionTitle("Shaft Flexibility"),
                        _buildRow(
                          comparedRackets,
                          (racket) => _buildFlexibilityCell(racket),
                        ),

                        // PRICE & TIER
                        _buildSectionTitle("Price & Budget Tier"),
                        _buildRow(
                          comparedRackets,
                          (racket) => _buildPriceCell(racket),
                        ),

                        // COMPATIBILITY/DESCRIPTION
                        _buildSectionTitle("Compatibility Analysis"),
                        _buildRow(
                          comparedRackets,
                          (racket) => _buildDescriptionCell(racket),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            // Large full-width sticky footer
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                text: "SELECT PRIMARY GEAR",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF111C28),
                      content: Text(
                        "Primary gear locked successfully!",
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white60,
          fontFamily: 'Orbitron',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildRow(List<Racket> rackets, Widget Function(Racket) builder) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: rackets.map((racket) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: builder(racket),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Visual cells builders
  Widget _buildCardCell(String value) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111C28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Orbitron',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDoubleLineCell(String line1, String line2) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111C28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            line1,
            style: const TextStyle(
              color: Color(0xFF00F5D4),
              fontFamily: 'Orbitron',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            line2,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontFamily: 'Inter',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCell(Racket racket) {
    // Map value (280mm to 320mm) to progress (0.0 to 1.0)
    final double value = (racket.balanceValue - 280) / 40.0;
    final progress = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: progress,
              color: const Color(0xFF00F5D4),
              backgroundColor: Colors.white10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${racket.balanceValue}mm",
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          racket.balanceText,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontFamily: 'Inter',
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildFlexibilityCell(Racket racket) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111C28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flash_on, color: Color(0xFF00F5D4), size: 16),
          const SizedBox(width: 6),
          Text(
            racket.flex.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Orbitron',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCell(Racket racket) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111C28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            "RM ${racket.priceMyr.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Color(0xFF00F5D4),
              fontFamily: 'Orbitron',
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            racket.priceTier.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCell(Racket racket) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF111C28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(
          racket.matchExplanation.isNotEmpty ? racket.matchExplanation : racket.description,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontFamily: 'Inter',
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
