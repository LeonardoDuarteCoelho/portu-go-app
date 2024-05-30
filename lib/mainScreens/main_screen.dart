import 'package:flutter/material.dart';
import 'package:portu_go_driver/constants.dart';
import 'package:portu_go_driver/tabScreens/earnings_screen.dart';
import 'package:portu_go_driver/tabScreens/home_screen.dart';
import 'package:portu_go_driver/tabScreens/profile_screen.dart';
import 'package:portu_go_driver/tabScreens/ratings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;
  int numberOfPages = 4;

  // Setting an index for each page (page one, page two and so on...)
  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  // This 'initState()' method will be automatically called whenever the user navigates to the main screen
  // ('main_screen.dart'):
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: numberOfPages, vsync: this); // Initializing bottom navigator.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
          HomeScreen(),
          EarningsScreen(),
          RatingsScreen(),
          ProfileScreen()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [

          // Home Screen:
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.homeScreenTitle,
          ),

          // Earnings Screen:
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: AppStrings.earningsScreenTitle,
          ),

          // Ratings Screen:
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: AppStrings.ratingsScreenTitle,
          ),

          // Profile Screen:
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.profileScreenTitle,
          ),

        ],

        // Navigation bar properties:
        unselectedItemColor: AppColors.gray7,
        selectedItemColor: AppColors.indigo7,
        backgroundColor: AppColors.gray0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: AppFontSizes.sm),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
