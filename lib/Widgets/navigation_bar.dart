import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currrentIndex = 0;

  final iconList = <IconData>[
    Icons.home,
    Icons.settings,
    Icons.verified_user,
    Icons.hourglass_empty_rounded,
  ];
  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar(
      icons: iconList,
      activeIndex: _currrentIndex,
      activeColor: Theme.of(context).colorScheme.primary,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.defaultEdge,
      iconSize: 25,
      onTap: (index) {
        setState(() {
          _currrentIndex = index;
        });
      },
    );
  }
}
