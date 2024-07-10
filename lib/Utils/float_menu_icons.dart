import 'package:flutter/material.dart';

class FloatMenuIcons extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  const FloatMenuIcons({super.key, required this.onTap, required this.icon});

  @override
  State<FloatMenuIcons> createState() => _FloatMenuIconsState();
}

class _FloatMenuIconsState extends State<FloatMenuIcons> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.onTap,
      icon: Icon(
        widget.icon,
      ),
    );
  }
}
