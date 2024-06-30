import 'package:expense_tracker/Widgets/app_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Expense',
      ),
      // appBar: AppBar(
      //   title: Text(
      //     "Expense Tracker",
      //     style: Theme.of(context).textTheme.labelMedium,
      //   ),
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      // ),
      body: const Column(),
    );
  }
}
