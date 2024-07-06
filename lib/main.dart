import 'package:expense_tracker/Theme/app_theme.dart';
import 'package:expense_tracker/Widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const CustomBottomNavigationBar(),
    );
  }
}
