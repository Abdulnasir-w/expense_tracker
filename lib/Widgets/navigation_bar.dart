import 'package:circular_menu/circular_menu.dart';
import 'package:expense_tracker/Screens/expense.dart';
import 'package:expense_tracker/Screens/fourth.dart';
import 'package:expense_tracker/Screens/home_screen.dart';
import 'package:expense_tracker/Screens/income.dart';
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

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with SingleTickerProviderStateMixin {
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

  CircularMenuItem _circularMenuItem({
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return CircularMenuItem(
      iconSize: 24,
      icon: icon,
      color: color,
      iconColor: Colors.white,
      onTap: () {
        _navigateToScreen(context, screen);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          HomeScreen(),
          Transiction(),
          Third(),
          Fourth(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CircularMenu(
        toggleButtonColor: Theme.of(context).colorScheme.primary,
        toggleButtonMargin: 45,
        toggleButtonSize: 24,
        toggleButtonPadding: 13,
        startingAngleInRadian: 4.2,
        endingAngleInRadian: 5.3,
        items: [
          _circularMenuItem(
              icon: FluentIcons.arrow_down_24_regular,
              color: Colors.green,
              screen: const IncomeScreen()),
          _circularMenuItem(
              icon: FluentIcons.arrow_up_24_regular,
              color: Colors.red,
              screen: const ExpenseScreen()),
        ],
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
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
