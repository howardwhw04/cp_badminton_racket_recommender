import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentStep = 0;
  bool _isSaving = false;

  // Local state for quiz answers
  int _skillLevel = 1;
  String _playingStyle = 'All-Rounder';
  bool _hasLowStrength = false;
  String _matchType = 'Singles';
  String _preferredBudgetTier = 'Mid-Range';

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = Provider.of<AppState>(context, listen: false);
      _skillLevel = state.selectedSkillLevelIndex;
      _playingStyle = state.playingStyle;
      _hasLowStrength = state.hasLowStrength;
      _matchType = state.matchType;
      _preferredBudgetTier = state.preferredBudgetTier;
      _initialized = true;
    }
  }

  void _nextStep(AppState state) async {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Submit responses
      setState(() {
        _isSaving = true;
      });

      try {
        await state.submitQuizResponse(
          skillLevel: _skillLevel,
          playingStyle: _playingStyle,
          hasLowStrength: _hasLowStrength,
          matchType: _matchType,
          preferredBudgetTier: _preferredBudgetTier,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF111C28),
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF00F5D4)),
                  SizedBox(width: 12),
                  Text(
                    "Calibration successful! Recalibrating matching engine...",
                    style: TextStyle(
                      color: Color(0xFF00F5D4),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF111C28),
              content: Text(
                "Error saving calibration: $e",
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
            _currentStep = 0;
          });
        }
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Get metadata for current step
    final stepInfo = _getStepInfo();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1622),
      appBar: AppBar(
        title: const Text(
          "RACKETBASE CALIBRATION",
          style: TextStyle(
            color: Color(0xFF00F5D4),
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1622),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isSaving
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF00F5D4)),
                    SizedBox(height: 20),
                    Text(
                      "SAVING PREFERENCES...",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Progress Indicators (5 steps)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final isActive = index == _currentStep;
                        final isCompleted = index < _currentStep;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 8,
                          width: isActive ? 32 : 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF00F5D4)
                                : isCompleted
                                    ? const Color(0xFF00F5D4).withValues(alpha: 0.5)
                                    : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Step Category & Subtitle
                    Text(
                      "STEP ${_currentStep + 1} OF 5: ${stepInfo.category}",
                      style: const TextStyle(
                        color: Color(0xFF00F5D4),
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stepInfo.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Orbitron',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      stepInfo.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontFamily: 'Inter',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Options List
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: stepInfo.options.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final option = stepInfo.options[index];
                          final isSelected = _isOptionSelected(index);

                          return GestureDetector(
                            onTap: () {
                              _selectOption(index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111C28),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00F5D4)
                                      : Colors.white.withValues(alpha: 0.06),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF00F5D4)
                                              .withValues(alpha: 0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF00F5D4)
                                              .withValues(alpha: 0.1)
                                          : Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      option.icon,
                                      color: isSelected
                                          ? const Color(0xFF00F5D4)
                                          : Colors.white60,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Orbitron',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          option.description,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? const Color(0xFF00F5D4)
                                        : Colors.white24,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Navigation tray
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _currentStep > 0 ? _prevStep : null,
                            child: Text(
                              "Back",
                              style: TextStyle(
                                color: _currentStep > 0
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : Colors.white24,
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          CustomButton(
                            text: _currentStep == 4 ? "Complete Calibration" : "Next Step",
                            width: 200,
                            onPressed: () => _nextStep(state),
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

  // Helpers for checking option selection
  bool _isOptionSelected(int index) {
    switch (_currentStep) {
      case 0:
        return _skillLevel == index;
      case 1:
        if (index == 0) return _playingStyle == 'Attacking';
        if (index == 1) return _playingStyle == 'Defensive';
        return _playingStyle == 'All-Rounder';
      case 2:
        return _hasLowStrength == (index == 0);
      case 3:
        if (index == 0) return _matchType == 'Singles';
        if (index == 1) return _matchType == 'Doubles';
        return _matchType == 'Both';
      case 4:
        if (index == 0) return _preferredBudgetTier == 'Budget';
        if (index == 1) return _preferredBudgetTier == 'Mid-Range';
        return _preferredBudgetTier == 'Premium';
      default:
        return false;
    }
  }

  // Helpers for updating local states
  void _selectOption(int index) {
    setState(() {
      switch (_currentStep) {
        case 0:
          _skillLevel = index;
          break;
        case 1:
          _playingStyle = index == 0
              ? 'Attacking'
              : index == 1
                  ? 'Defensive'
                  : 'All-Rounder';
          break;
        case 2:
          _hasLowStrength = index == 0;
          break;
        case 3:
          _matchType = index == 0
              ? 'Singles'
              : index == 1
                  ? 'Doubles'
                  : 'Both';
          break;
        case 4:
          _preferredBudgetTier = index == 0
              ? 'Budget'
              : index == 1
                  ? 'Mid-Range'
                  : 'Premium';
          break;
      }
    });
  }

  // Struct definitions for wizard questions
  _StepData _getStepInfo() {
    switch (_currentStep) {
      case 0:
        return _StepData(
          category: "SKILL PROFILE",
          title: "What is your current Skill Level?",
          subtitle: "Allows us to calibrate frame elasticity and shaft flex limits.",
          options: [
            _OptionData(
              title: "Beginner",
              description: "Learning correct grip styles and base court clearances.",
              icon: Icons.fitness_center,
            ),
            _OptionData(
              title: "Intermediate",
              description: "Consistent basic rallies, starting to execute tactical drops/smashes.",
              icon: Icons.sports_tennis,
            ),
            _OptionData(
              title: "Advanced",
              description: "High speed defensive block control and rapid counter-attacks.",
              icon: Icons.bolt,
            ),
          ],
        );
      case 1:
        return _StepData(
          category: "TACTICAL STYLE",
          title: "Select your primary Playing Style",
          subtitle: "Used to calibrate head-heaviness weight allocation.",
          options: [
            _OptionData(
              title: "Attacking",
              description: "Slamming hard smashes from rear court, offensive aggression.",
              icon: Icons.flash_on,
            ),
            _OptionData(
              title: "Defensive",
              description: "Fast front-court net kills, steady backhand recoveries.",
              icon: Icons.shield,
            ),
            _OptionData(
              title: "All-Rounder",
              description: "Adapting tactical drives, drops, and clears based on play flow.",
              icon: Icons.all_inclusive,
            ),
          ],
        );
      case 2:
        return _StepData(
          category: "ERGONOMIC CALIBRATION",
          title: "Do you experience low wrist/physical strength?",
          subtitle: "If true, we'll recommend lighter classes to minimize strain.",
          options: [
            _OptionData(
              title: "Yes, low strength",
              description: "Prefer ultra-light rackets (5U/4U) to reduce muscle fatigue.",
              icon: Icons.accessibility_new,
            ),
            _OptionData(
              title: "No, standard strength",
              description: "Comfortable wielding heavier frames (3U) for higher power stability.",
              icon: Icons.sports_gymnastics,
            ),
          ],
        );
      case 3:
        return _StepData(
          category: "SPEED MATRICES",
          title: "Which Match Type do you play?",
          subtitle: "Calibrates quick frame aerodynamics vs solid sweet spot ratios.",
          options: [
            _OptionData(
              title: "Singles Match",
              description: "Focus on single-shot precision, court coverage, and deep clears.",
              icon: Icons.person,
            ),
            _OptionData(
              title: "Doubles Match",
              description: "Focus on rapid driving, flat push rallies, and netplay speed.",
              icon: Icons.people,
            ),
            _OptionData(
              title: "Both Styles",
              description: "All-around adaptability for both singles and doubles configurations.",
              icon: Icons.group_add,
            ),
          ],
        );
      case 4:
      default:
        return _StepData(
          category: "VALUATION INDEX",
          title: "What is your target Budget Tier?",
          subtitle: "Filters rackets according to your spending capabilities.",
          options: [
            _OptionData(
              title: "Budget",
              description: "Affordable entry-level models offering solid durability.",
              icon: Icons.savings,
            ),
            _OptionData(
              title: "Mid-Range",
              description: "Balanced features and construction specs for active players.",
              icon: Icons.payments,
            ),
            _OptionData(
              title: "Premium",
              description: "High-end flagship materials and advanced professional design.",
              icon: Icons.diamond,
            ),
          ],
        );
    }
  }
}

class _StepData {
  final String category;
  final String title;
  final String subtitle;
  final List<_OptionData> options;

  _StepData({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.options,
  });
}

class _OptionData {
  final String title;
  final String description;
  final IconData icon;

  _OptionData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

