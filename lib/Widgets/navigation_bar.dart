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

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  late int _selectedIndex = 0;
  bool isOpen = false;
  late AnimationController _animationController;
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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
  }

  void _toggleMenu() {
    setState(() {
      isOpen = !isOpen;
      if (isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Stack(
        // mainAxisSize: MainAxisSize.min,
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          if (isOpen) ...[
            Positioned(
              bottom: 70,
              child: _buildFabMenuItem(FluentIcons.send_24_regular, () {}),
            ),
            Positioned(
              bottom: 130,
              child: _buildFabMenuItem(FluentIcons.drop_24_regular, () {}),
            ),
            Positioned(
              bottom: 190,
              child: _buildFabMenuItem(
                FluentIcons.delete_24_regular,
                () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Fourth()));
                },
              ),
            ),
          ],
          FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38)),
              onPressed: _toggleMenu,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _animationController)),
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

  Widget _buildFabMenuItem(IconData icon, final VoidCallback onTap) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
      child: FloatingActionButton(
        onPressed: onTap,
        mini: true,
        child: Icon(icon),
      ),
    );
  }
}
