import 'package:expense_tracker/Screens/fourth.dart';
import 'package:expense_tracker/Screens/home_screen.dart';
import 'package:expense_tracker/Screens/third.dart';
import 'package:expense_tracker/Screens/transiction.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final PageController _pageController = PageController(initialPage: 0);
  late int _selectedIndex = 0;
  final iconList = [
    const BottomNavigationBarItem(
        icon: Icon(FluentIcons.home_24_regular), label: ""),
    const BottomNavigationBarItem(
        icon: Icon(FluentIcons.call_transfer_24_regular), label: ""),
    const BottomNavigationBarItem(
        icon: Icon(FluentIcons.settings_24_regular), label: ""),
    const BottomNavigationBarItem(
        icon: Icon(FluentIcons.production_24_filled), label: ""),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: const [
          HomeScreen(),
          Transiction(),
          Third(),
          Fourth(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.padded,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          FluentIcons.add_24_regular,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.only(top: 10),
        clipBehavior: Clip.antiAlias,
        notchMargin: 10.0,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            child: BottomNavigationBar(
              items: iconList,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              iconSize: 27,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  _pageController.jumpToPage(index);
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
