import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;
  const CustomAppBar(
      {super.key, required this.title, this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        "Expense Tracker",
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
