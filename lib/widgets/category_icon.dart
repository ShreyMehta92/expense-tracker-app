import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Displays the category icon inside a colored circle
class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.categoryColors[category] ?? Colors.grey;
    final icon =
        AppConstants.categoryIcons[category] ?? Icons.more_horiz_rounded;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: size * 0.55),
    );
  }
}
