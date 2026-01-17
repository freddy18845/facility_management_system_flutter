import 'package:flutter/material.dart';
import 'package:fms_app/screens/login_screen.dart';


// Step 1: Create a ValueNotifier to control theme
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

// Step 2: MyApp uses ValueListenableBuilder to listen to theme changes
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Dark Mode Demo',

          // Light theme
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor:Colors.grey.shade50,
            secondaryHeaderColor: Colors.grey.shade200,
            cardColor:  Colors.white,
            dialogBackgroundColor:Colors.grey.shade50,
            focusColor: Colors.blue.shade50,
          ),

          // Dark theme
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            cardColor: Colors.grey[850],
            dialogBackgroundColor: Colors.grey[850],
            secondaryHeaderColor: Colors.black,
            focusColor: Colors.amber.withValues(alpha: 0.1)
          ),

          // ThemeMode controlled by ValueNotifier
          themeMode: currentMode,

          home: const LoginScreen(),
        );
      },
    );
  }
}
