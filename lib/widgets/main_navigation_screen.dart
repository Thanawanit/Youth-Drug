import 'package:flutter/material.dart';
import '../main.dart';
import '../state/app_state.dart';
import '../constants/app_colors.dart';
import '../pages/home_tab.dart';
import '../pages/explore_tab.dart';
import '../pages/quiz_page.dart';
import '../pages/law_page.dart';
import 'app_background.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToTab(int index) {
    if (_currentIndex == index) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, child) {
        final isDark = state.isDarkMode;
        final activeColor = isDark ? AppColors.success : AppColors.primary;
        final inactiveColor = isDark ? Colors.white70 : AppColors.textGrey;

        final List<Widget> tabs = [
          HomeTab(onNavigateToTab: _navigateToTab),
          const ExploreTab(),
          const LawPage(),
          const QuizPage(),
        ];

        return Scaffold(
          body: BackgroundWrapper(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: tabs,
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black38 : Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _navigateToTab,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              indicatorColor: activeColor.withOpacity(0.15),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: inactiveColor),
                  selectedIcon: Icon(Icons.home_rounded, color: activeColor),
                  label: 'หน้าหลัก',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined, color: inactiveColor),
                  selectedIcon: Icon(Icons.explore_rounded, color: activeColor),
                  label: 'สำรวจความรู้',
                ),
                NavigationDestination(
                  icon: Icon(Icons.gavel_outlined, color: inactiveColor),
                  selectedIcon: Icon(Icons.gavel_rounded, color: activeColor),
                  label: 'กฎหมายน่ารู้',
                ),
                NavigationDestination(
                  icon: Icon(Icons.quiz_outlined, color: inactiveColor),
                  selectedIcon: Icon(Icons.quiz_rounded, color: activeColor),
                  label: 'แบบทดสอบ',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
