import 'package:flutter/material.dart';
import 'package:prakriti/components/components.dart';
import 'package:prakriti/constants.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:prakriti/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prakriti/screens/login_screen.dart';
import 'package:prakriti/screens/profile_form_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static String id = 'signup_screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  late String _email;
  late String _password;
  late String _confirmPass;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, HomeScreen.id);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoadingOverlay(
          isLoading: _saving,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TopScreenImage(screenImageName: 'signup.png'),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ScreenTitle(title: 'Sign Up'),
                          CustomTextField(
                            textField: TextField(
                              onChanged: (value) {
                                _email = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Email',
                              ),
                            ),
                          ),
                          CustomTextField(
                            textField: TextField(
                              obscureText: true,
                              onChanged: (value) {
                                _password = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Password',
                              ),
                            ),
                          ),
                          CustomTextField(
                            textField: TextField(
                              obscureText: true,
                              onChanged: (value) {
                                _confirmPass = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Confirm Password',
                              ),
                            ),
                          ),
                          CustomBottomScreen(
                            textButton: 'Sign Up',
                            heroTag: 'signup_btn',
                            question: 'Have an account?',
                            buttonPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                _saving = true;
                              });
                              if (_confirmPass == _password) {
                                try {
                                  await _auth.createUserWithEmailAndPassword(
                                      email: _email, password: _password);

                                  await signIn(_email, _password);

                                  if (context.mounted) {
                                    setState(() {
                                      _saving = false;
                                      _password =
                                          ''; // Clear the password field
                                      _confirmPass =
                                          ''; // Clear the confirm password field
                                    });
                                    showRegistrationSuccessAlert(context);
                                  }
                                } catch (e) {
                                  print(e.toString());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Something went wrong. Please try again later.',
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    _saving = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  _password = ''; // Clear the password field
                                  _confirmPass =
                                      ''; // Clear the confirm password field
                                  _saving = false; // Stop the loading overlay
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Passwords do not match. Please try again.',
                                    ),
                                  ),
                                );
                              }
                            },
                            questionPressed: () async {
                              Navigator.pushNamed(context, LoginScreen.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    // ...
  }

  // Show registration success alert
  void showRegistrationSuccessAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations, account created!'),
          content:
              Text('Submit your profile details to complete registration.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(SignUpProfileScreen.id);
              },
              child: Text('Complete Registration'),
            ),
          ],
        );
      },
    );
  }
}
