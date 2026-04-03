import 'package:flutter/material.dart';

/// App-wide constants: categories, colors, and icons
class AppConstants {
  AppConstants._();

  /// Expense categories with associated icons and colors
  static const List<String> categories = [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant_rounded,
    'Travel': Icons.flight_rounded,
    'Bills': Icons.receipt_long_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Entertainment': Icons.movie_rounded,
    'Health': Icons.medical_services_rounded,
    'Education': Icons.school_rounded,
    'Other': Icons.more_horiz_rounded,
  };

  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFFFF6B6B),
    'Travel': Color(0xFF4ECDC4),
    'Bills': Color(0xFFFFE66D),
    'Shopping': Color(0xFFA78BFA),
    'Entertainment': Color(0xFFF97316),
    'Health': Color(0xFF34D399),
    'Education': Color(0xFF60A5FA),
    'Other': Color(0xFF9CA3AF),
  };

  /// Available currencies
  static const List<String> currencies = ['₹', '\$', '€', '£', '¥'];
}
