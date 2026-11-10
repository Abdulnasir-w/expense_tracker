import 'package:flutter/material.dart';

/// Predefined icon map ensuring no dynamic icon code points break tree-shaking.
class AppCategoryIcons {
  AppCategoryIcons._();

  static const Map<String, IconData> icons = {
    // Expense
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'fastfood': Icons.fastfood,
    'shopping_bag': Icons.shopping_bag,
    'shopping_cart': Icons.shopping_cart,
    'directions_car': Icons.directions_car,
    'directions_bus': Icons.directions_bus,
    'flight': Icons.flight,
    'local_gas_station': Icons.local_gas_station,
    'home': Icons.home,
    'receipt_long': Icons.receipt_long,
    'power': Icons.power,
    'wifi': Icons.wifi,
    'medical_services': Icons.medical_services,
    'fitness_center': Icons.fitness_center,
    'sports_esports': Icons.sports_esports,
    'movie': Icons.movie,
    'school': Icons.school,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'redeem': Icons.redeem,

    // Income
    'work': Icons.work,
    'payments': Icons.payments,
    'account_balance_wallet': Icons.account_balance_wallet,
    'trending_up': Icons.trending_up,
    'savings': Icons.savings,
    'card_giftcard': Icons.card_giftcard,

    // Accounts
    'account_balance': Icons.account_balance,
    'credit_card': Icons.credit_card,
    'wallet': Icons.wallet,
    'attach_money': Icons.attach_money,

    // Fallback
    'category': Icons.category,
    'more_horiz': Icons.more_horiz,
  };

  static IconData getIcon(String key) {
    return icons[key] ?? Icons.category;
  }
}

