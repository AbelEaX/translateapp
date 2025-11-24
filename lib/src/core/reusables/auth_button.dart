import 'package:flutter/material.dart';

// --- Constants ---
const Color kPrimaryColor = Color(0xFF6C63FF); // Deep Purple/Blue
const Color kAccentColor = Color(0xFFFF6584);  // Pinkish accent
const Color kSecondaryAccentColor = Colors.black;
const Color kBackgroundColor = Color(0xFF2F2E41); // Dark background for Onboarding/Auth

// --- Common Widgets ---
class AuthButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AuthButton({
    super.key,
    required this.text,
    required this.isPrimary,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isPrimary
          ? ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? kPrimaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      )
          : OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor: foregroundColor ?? kPrimaryColor,
          side: BorderSide(color: backgroundColor ?? Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
