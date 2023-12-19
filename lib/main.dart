import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prakriti/screens/dashboard.dart';
import 'package:prakriti/screens/home_screen.dart';
import 'package:prakriti/screens/login_screen.dart';
import 'package:prakriti/screens/profile_form_screen.dart';
import 'package:prakriti/screens/profile_screen.dart';
import 'package:prakriti/screens/signup_screen.dart';
import 'package:prakriti/screens/survey_screen.dart';
import 'package:prakriti/screens/welcome.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  return isLoggedIn;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  // Initialize Firebase with the default options.
  await Firebase.initializeApp(options: firebaseOptions);
  final isLoggedIn = await isUserLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({required this.isLoggedIn, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Ubuntu',
          ),
        ),
      ),
      initialRoute: isLoggedIn ? ProfileHomeScreen.id : SignUpScreen.id,
      routes: {
        ProfileHomeScreen.id: (context) => Builder(
              builder: (context) {
                // You need to obtain a User object here.
                final user = FirebaseAuth.instance.currentUser;

                // Now, you can create an instance of ProfileHomeScreen with the user.
                return ProfileHomeScreen(user: user);
              },
            ),
        HomeScreen.id: (context) => HomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        SignUpScreen.id: (context) => SignUpScreen(),
        SignUpProfileScreen.id: (context) => SignUpProfileScreen(),
        // Removed the 'user' parameter here.
        SurveyScreen.id: (context) => SurveyScreen(),
        DashboardScreen.id: (context) => DashboardScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
      },
    );
  }
}
