import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final recommended = state.recommendedRacket;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1622),
      appBar: AppBar(
        title: const Text(
          "ATHLETE PROFILE",
          style: TextStyle(
            color: Color(0xFF00F5D4),
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A0F18),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Meta Header Card
            Center(
              child: Column(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00F5D4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF111C28),
                      child: Icon(
                        Icons.person,
                        size: 45,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Orbitron',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.isLoggedIn ? state.email : "guest@aerocore.com",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontFamily: 'Inter',
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showEditProfileBottomSheet(context, state),
                    icon: const Icon(Icons.edit_note, size: 20, color: Color(0xFF0D1622)),
                    label: const Text(
                      "EDIT ATHLETE PROFILE",
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1622),
                        letterSpacing: 1.1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00F5D4),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Play Style Details
            const Text(
              "CALIBRATED BIOMETRICS & PREFERENCES",
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111C28),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Column(
                children: [
                  _buildProfileRow(
                    "Skill Calibration",
                    state.selectedSkillLevelIndex == 0
                        ? "Beginner"
                        : state.selectedSkillLevelIndex == 1
                            ? "Intermediate"
                            : "Advanced",
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow(
                    "Tactical Style",
                    state.playingStyle,
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow(
                    "Physical/Wrist Strength",
                    state.hasLowStrength ? "Low Strength" : "Standard Strength",
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow(
                    "Match Configuration",
                    state.matchType == "Both" ? "Both Styles" : "${state.matchType} Match",
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow(
                    "Target Budget Tier",
                    state.preferredBudgetTier,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recommended Gear Details
            const Text(
              "RECOMMENDED GEAR CALIBRATION",
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111C28),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Column(
                children: [
                  _buildProfileRow(
                    "Primary Racket",
                    recommended.name,
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow(
                    "Match Compatibility",
                    "${recommended.matchRating}% Fit",
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow(
                    "Weight Class",
                    "${recommended.weightClass} (${recommended.weightGramsRange})",
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow(
                    "Balance Point",
                    "${recommended.balanceCategory} (${recommended.balancePointMm}mm)",
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow(
                    "Shaft Stiffness",
                    recommended.shaftFlexibility,
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow(
                    "Price Tier",
                    "${recommended.priceTier} (RM ${recommended.priceMyr.toStringAsFixed(2)})",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Authentication state option details
            if (state.isLoggedIn)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    state.logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Logged out successfully."),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    "LOG OUT OF ATHLETE PROFILE",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontFamily: 'Orbitron',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontFamily: 'Inter',
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00F5D4),
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Colors.white70,
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSelectorRow<T>({
    required List<T> values,
    required List<String> displayNames,
    required T selectedValue,
    required ValueChanged<T> onChanged,
  }) {
    return Row(
      children: List.generate(values.length, (idx) {
        final isSel = values[idx] == selectedValue;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(values[idx]),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF00F5D4) : const Color(0xFF111C28),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSel ? const Color(0xFF00F5D4) : Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                displayNames[idx],
                style: TextStyle(
                  color: isSel ? const Color(0xFF0D1622) : Colors.white70,
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showEditProfileBottomSheet(BuildContext context, AppState state) {
    int selectedSkill = state.selectedSkillLevelIndex;
    String selectedStyle = state.playingStyle;
    bool selectedLowStrength = state.hasLowStrength;
    String selectedMatchType = state.matchType;
    String selectedBudget = state.preferredBudgetTier;
    final nameController = TextEditingController(text: state.isLoggedIn ? state.displayName : "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1622),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "EDIT ATHLETE PROFILE",
                          style: TextStyle(
                            color: Color(0xFF00F5D4),
                            fontFamily: 'Orbitron',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),

                    const Text(
                      "ATHLETE DETAILS",
                      style: TextStyle(
                        color: Colors.white30,
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSelectorLabel("Display Name"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      enabled: state.isLoggedIn,
                      style: TextStyle(
                        color: state.isLoggedIn ? Colors.white : Colors.white24,
                        fontFamily: 'Inter',
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF111C28),
                        hintText: state.isLoggedIn ? "Enter display name" : "Log in to edit display name",
                        hintStyle: const TextStyle(color: Colors.white30),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00F5D4)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.02)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "BIOMETRICS & CALIBRATION",
                      style: TextStyle(
                        color: Colors.white30,
                        fontFamily: 'Orbitron',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSelectorLabel("Skill Level"),
                    const SizedBox(height: 8),
                    _buildSelectorRow<int>(
                      values: [0, 1, 2],
                      displayNames: ["Beginner", "Intermediate", "Advanced"],
                      selectedValue: selectedSkill,
                      onChanged: (val) {
                        setSheetState(() {
                          selectedSkill = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildSelectorLabel("Tactical Playing Style"),
                    const SizedBox(height: 8),
                    _buildSelectorRow<String>(
                      values: ["Attacking", "Defensive", "All-Rounder"],
                      displayNames: ["Attacking", "Defensive", "All-Rounder"],
                      selectedValue: selectedStyle,
                      onChanged: (val) {
                        setSheetState(() {
                          selectedStyle = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildSelectorLabel("Wrist/Physical Strength"),
                    const SizedBox(height: 8),
                    _buildSelectorRow<bool>(
                      values: [true, false],
                      displayNames: ["Low Strength", "Standard"],
                      selectedValue: selectedLowStrength,
                      onChanged: (val) {
                        setSheetState(() {
                          selectedLowStrength = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildSelectorLabel("Preferred Match Type"),
                    const SizedBox(height: 8),
                    _buildSelectorRow<String>(
                      values: ["Singles", "Doubles", "Both"],
                      displayNames: ["Singles", "Doubles", "Both Styles"],
                      selectedValue: selectedMatchType,
                      onChanged: (val) {
                        setSheetState(() {
                          selectedMatchType = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildSelectorLabel("Preferred Budget Tier"),
                    const SizedBox(height: 8),
                    _buildSelectorRow<String>(
                      values: ["Budget", "Mid-Range", "Premium"],
                      displayNames: ["Budget", "Mid-Range", "Premium"],
                      selectedValue: selectedBudget,
                      onChanged: (val) {
                        setSheetState(() {
                          selectedBudget = val;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                     CustomButton(
                      text: "SAVE CHANGES",
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        Navigator.pop(context);
                        nameController.dispose();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF00F5D4),
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text("Updating athlete calibration..."),
                              ],
                            ),
                            backgroundColor: Color(0xFF111C28),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        try {
                          await state.updateFullProfile(
                            displayName: state.isLoggedIn ? newName : null,
                            skillLevel: selectedSkill,
                            matches: state.matches,
                            winRate: state.winRate,
                            powerIndex: state.powerIndex,
                            control: state.control,
                            playingStyle: selectedStyle,
                            hasLowStrength: selectedLowStrength,
                            matchType: selectedMatchType,
                            preferredBudgetTier: selectedBudget,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Profile and matching engine updated successfully!"),
                                backgroundColor: Color(0xFF00F5D4),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to update profile: $e"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
