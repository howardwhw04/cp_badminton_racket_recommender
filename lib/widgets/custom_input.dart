import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final String label;
  final String placeholder;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const CustomInput({
    super.key,
    required this.label,
    required this.placeholder,
    required this.prefixIcon,
    this.isPassword = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Section
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF00F5D4),
            fontFamily: 'Orbitron',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        // Input Container
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111C28),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 16,
            ),
            cursorColor: const Color(0xFF00F5D4),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontFamily: 'Inter',
                fontSize: 16,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white.withOpacity(0.5),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
