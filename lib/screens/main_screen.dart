import 'package:flutter/material.dart';
import 'package:flutter_application_1/buttons/my_drawer_widget.dart';
import 'package:flutter_application_1/screens/display_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/product_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> pages = [HomeScreen(), ProductScreen(), DisplayScreen()];
  int currentIndex = 0;
  void changeTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      drawer: MyWiget(),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: currentIndex,
      //   onTap: changeTap,
      //   selectedLabelStyle: TextStyle(color: Colors.blue),
      //   unselectedLabelStyle: TextStyle(color: Colors.grey),
      //   selectedItemColor: Colors.red,
      //   showSelectedLabels: true,
      //   unselectedItemColor: Colors.grey,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.home_max), label: 'home'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.branding_watermark),
      //       label: 'product',
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'product'),
      //   ],
      // ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "home"),
          NavigationDestination(icon: Icon(Icons.propane), label: "product"),
          NavigationDestination(icon: Icon(Icons.person), label: "person"),
        ],
      ),
      body: pages[currentIndex],
    );
  }
}
