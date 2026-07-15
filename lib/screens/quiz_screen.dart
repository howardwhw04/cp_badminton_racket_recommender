import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_button.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Card options list
    final List<Map<String, dynamic>> options = [
      {
        "title": "Beginner",
        "subtitle": "Learning fundamentals",
        "icon": Icons.fitness_center,
      },
      {
        "title": "Intermediate",
        "subtitle": "Club player / Consistent rallies",
        "icon": Icons.sports_tennis,
      },
      {
        "title": "Advanced",
        "subtitle": "Tournament level performance",
        "icon": Icons.bolt,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1622),
      appBar: AppBar(
        title: const Text(
          "AEROCORE",
          style: TextStyle(
            color: Color(0xFF00F5D4),
            fontFamily: 'Orbitron',
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1622),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isActive = index == state.currentQuizStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8,
                    width: isActive ? 32 : 8,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF00F5D4) : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Category Subtitle & Title
              const Text(
                "ONBOARDING",
                style: TextStyle(
                  color: Color(0xFF00F5D4),
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "What is your current Skill Level?",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Orbitron',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Help us calibrate our algorithm for your playstyle.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontFamily: 'Inter',
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),

              // Selectable List Cards
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = state.selectedSkillLevelIndex == index;

                    return GestureDetector(
                      onTap: () {
                        state.selectSkillLevel(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111C28),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00F5D4)
                                : Colors.white.withOpacity(0.06),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00F5D4).withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Leading Icon Container
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00F5D4).withOpacity(0.1)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                option["icon"] as IconData,
                                color: isSelected ? const Color(0xFF00F5D4) : Colors.white60,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Text block
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option["title"] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Orbitron',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option["subtitle"] as String,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Trailing radio / checked indicator
                            Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isSelected ? const Color(0xFF00F5D4) : Colors.white24,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Navigation Tray
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    TextButton(
                      onPressed: () {
                        if (state.currentQuizStep > 0) {
                          state.setQuizStep(state.currentQuizStep - 1);
                        }
                      },
                      child: Text(
                        "Back",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Next Step Button
                    CustomButton(
                      text: "Next Step",
                      width: 180,
                      onPressed: () {
                        // In a real flow, this moves to step 1/2. We can show a dialog or transition to compare/recommendation tab directly.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF111C28),
                            content: Text(
                              "Calibration successful! Recalibrating matching engine...",
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
