import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class GlowingButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color glowColor;
  final IconData? icon;

  const GlowingButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.glowColor = AppColors.primaryNeonBlue,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.35),
            blurRadius: 16.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          highlightColor: glowColor.withOpacity(0.2),
          splashColor: glowColor.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: glowColor, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: glowColor, size: 20.0),
                  const SizedBox(width: 10.0),
                ],
                Text(
                  text.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 14.0,
                    shadows: [
                      Shadow(
                        color: glowColor,
                        blurRadius: 10.0,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}