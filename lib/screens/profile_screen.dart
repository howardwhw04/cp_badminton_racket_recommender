import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

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
                      border: Border.all(color: const Color(0xFF00F5D4), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F5D4).withOpacity(0.15),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF111C28),
                      child: Icon(Icons.person, size: 45, color: Colors.white60),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.isLoggedIn ? "Elite Athlete" : "Anonymous Player",
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
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Inter',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Performance Statistics Section
            const Text(
              "PERFORMANCE STATISTICS",
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Orbitron',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard("Matches", "42", Icons.emoji_events),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard("Win Rate", "68%", Icons.trending_up),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard("Power Index", "92", Icons.flash_on),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard("Control", "85", Icons.gps_fixed),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Play Style Details
            const Text(
              "CALIBRATED PLAYSTYLE",
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
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Column(
                children: [
                  _buildProfileRow("Skill Calibration", state.selectedSkillLevelIndex == 0 ? "Beginner" : state.selectedSkillLevelIndex == 1 ? "Intermediate" : "Advanced"),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow("Primary Racket", state.recommendedRacket.name),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow("Weight Preferred", state.recommendedRacket.weight),
                  const Divider(color: Colors.white10, height: 24),
                  _buildProfileRow("Shaft Stiffness", state.recommendedRacket.flex),
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111C28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00F5D4), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Orbitron',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white30,
              fontFamily: 'Inter',
              fontSize: 11,
            ),
          ),
        ],
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
}
