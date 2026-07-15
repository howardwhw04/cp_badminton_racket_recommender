import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    final state = Provider.of<AppState>(context, listen: false);
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      state.login(email);
    } else {
      state.login("athlete@aerocore.com"); // Fallback mock login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1622),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Blurred Background Image
            Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/auth_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        const Color(0xFF0D1622),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Header Content
                Positioned(
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ELITE PRECISION",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Orbitron',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Experience data-driven performance with the next generation of gear.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Form Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Container(
                padding: const EdgeInsets.all(24),
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
                    const Text(
                      "Welcome back",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Orbitron',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Log in to your athlete profile",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontFamily: 'Inter',
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email Field
                    CustomInput(
                      label: "Email",
                      placeholder: "athlete@aerocore.com",
                      prefixIcon: Icons.mail_outline,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    CustomInput(
                      label: "Password",
                      placeholder: "••••••••",
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 12),

                    // Forgot Password Hyperlink
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontFamily: 'Inter',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    CustomButton(
                      text: "Sign In",
                      onPressed: _handleSignIn,
                    ),
                    const SizedBox(height: 24),

                    // OR CONTINUE WITH Separator
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.1),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "OR CONTINUE WITH",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontFamily: 'Orbitron',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.1),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social Sign In Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Google",
                            isPrimary: false,
                            onPressed: _handleSignIn,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: "Apple",
                            isPrimary: false,
                            onPressed: _handleSignIn,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "New user? ",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Inter',
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Create an account",
                      style: TextStyle(
                        color: Color(0xFF00F5D4),
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
