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
      body: const Column(
        children: [
          Center(
            child: Text("HOme"),
          )
        ],
      ),
    );
  }
}
