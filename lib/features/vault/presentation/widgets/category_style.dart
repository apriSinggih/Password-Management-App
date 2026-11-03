import 'package:flutter/material.dart';

import '../../../../core/constants/categories.dart';

class CategoryStyle {
  static IconData iconFor(String category) {
    switch (category) {
      case VaultCategories.social:
        return Icons.groups_outlined;
      case VaultCategories.banking:
        return Icons.account_balance_outlined;
      case VaultCategories.work:
        return Icons.work_outline;
      case VaultCategories.entertainment:
        return Icons.movie_outlined;
      case VaultCategories.shopping:
        return Icons.shopping_bag_outlined;
      case VaultCategories.email:
        return Icons.alternate_email;
      default:
        return Icons.vpn_key_outlined;
    }
  }

  static Color colorFor(String category) {
    switch (category) {
      case VaultCategories.social:
        return const Color(0xFF3B82F6);
      case VaultCategories.banking:
        return const Color(0xFF10B981);
      case VaultCategories.work:
        return const Color(0xFFF59E0B);
      case VaultCategories.entertainment:
        return const Color(0xFFEC4899);
      case VaultCategories.shopping:
        return const Color(0xFF8B5CF6);
      case VaultCategories.email:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }
}
