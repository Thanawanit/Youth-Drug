import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'widgets/main_navigation_screen.dart';
import 'constants/app_colors.dart';
import 'constants/app_text.dart';

/// Global state notifier accessible throughout the application.
/// Since we are avoiding third-party packages to guarantee zero-dependency
/// stability and offline execution, this global ValueNotifier handles state updates.
final AppStateNotifier appStateNotifier = AppStateNotifier();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YouthShieldApp());
}

class YouthShieldApp extends StatelessWidget {
  const YouthShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appStateNotifier,
      builder: (context, state, child) {
        return MaterialApp(
          title: AppText.appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Prompt',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: IconThemeData(color: AppColors.textDark),
              titleTextStyle: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Prompt',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.success,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                fontFamily: 'Prompt',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          builder: (context, widget) {
            // Apply text scaling globally based on fontScale state
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(state.fontScale),
              ),
              child: widget!,
            );
          },
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
