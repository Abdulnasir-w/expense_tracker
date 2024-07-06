import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:expense_tracker/Screens/fourth.dart';
import 'package:expense_tracker/Screens/home_screen.dart';
import 'package:expense_tracker/Screens/third.dart';
import 'package:expense_tracker/Screens/transiction.dart';
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
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
    const BottomNavigationBarItem(
        icon: Icon(Icons.transcribe_outlined), label: ""),
    const BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
    const BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: ""),
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
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          size: 35,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.only(top: 10),
        clipBehavior: Clip.antiAlias,
        notchMargin: 7.0,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            child: BottomNavigationBar(
              items: iconList,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.blue,
              currentIndex: _selectedIndex,
              //  iconSize: 21,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: Theme.of(context).colorScheme.surface,
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
