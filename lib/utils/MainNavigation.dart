import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/catalogo_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/widgets/BottomNavBar.dart';
import 'package:flutter_application_1/utils/snackbar_utils.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    Placeholder(), 
    CatalogoScreen(),
    ProfileScreen(),
  ];

  void _onBottomNavSelected(int index) {
    if (index == 1) {
      showWarningSnackbar(context, 'Ups!', 'Pronto podrás ver tus platillos favoritos.');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavSelected,
      ),
    );
  }
}
