import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double padding;

  const NeonCard({
    Key? key,
    required this.child,
    this.borderColor = AppColors.borderCyan,
    this.padding = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}