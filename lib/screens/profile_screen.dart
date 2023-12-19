import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prakriti/screens/dashboard.dart';
import 'package:prakriti/screens/login_screen.dart';
import 'package:prakriti/screens/survey_screen.dart';

class ProfileHomeScreen extends StatefulWidget {
  static const String id = 'profile_home_screen';

  final User? user;

  ProfileHomeScreen({required this.user});

  @override
  _ProfileHomeScreenState createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends State<ProfileHomeScreen> {
  Map<String, dynamic> _userData = {
    'name': '',
    'age': 0,
    'sex': '',
    'height': 0.0,
    'weight': 0.0,
    'currentAddress': '',
    'isMigrated': false,
    'migrationAddress': '',
    'bmi': 0.0,
    'surveyCompleted': false,
  };
  bool _surveyCompleted = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fetchUserData();
      print(widget.user!.uid);
    } else {
      // If no user is logged in, navigate to the login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.id,
        (route) => true,
      );
    }
  }

  Future<void> _fetchUserData() async {
    final DocumentSnapshot userDocument = await FirebaseFirestore.instance
        .collection('users-survey-v02')
        .doc(widget.user!.uid)
        .get();

    if (userDocument.exists) {
      final userData = userDocument.data() as Map<String, dynamic>;
      print('User Data: $userData'); // Add this line for debugging

      setState(() {
        _userData = {
          'customUserId': userData['customUserId'] ?? '',
          'name': userData['name'] ?? '',
          'age': userData['age'] ?? 0,
          'sex': userData['sex'] ?? '',
          'height': userData['height'] ?? 0.0,
          'weight': userData['weight'] ?? 0.0,
          'currentAddress': userData['currentAddress'] ?? '',
          'isMigrated': userData['isMigrated'] ?? false,
          'migrationAddress': userData['migrationAddress'] ?? '',
          'bmi': userData['bmi'] ?? 0.0,
          'surveyCompleted': userData['surveyCompleted'] ?? false,
        };
        _surveyCompleted = _userData['surveyCompleted'] ?? false;
      });
    } else {
      print('User document does not exist.'); // Add this line for debugging
    }
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 16) {
      return 'Severe Thinness';
    } else if (bmi < 17) {
      return 'Moderate Thinness';
    } else if (bmi < 18.5) {
      return 'Mild Thinness';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else if (bmi < 35) {
      return 'Obese Class I';
    } else if (bmi < 40) {
      return 'Obese Class II';
    } else {
      return 'Obese Class III';
    }
  }

  IconData _getBmiCategoryIcon(double bmi) {
    if (bmi < 16) {
      return Icons.sentiment_very_dissatisfied;
    } else if (bmi < 17) {
      return Icons.sentiment_dissatisfied;
    } else if (bmi < 18.5) {
      return Icons.sentiment_neutral;
    } else if (bmi < 25) {
      return Icons.sentiment_satisfied;
    } else if (bmi < 30) {
      return Icons.sentiment_dissatisfied;
    } else if (bmi < 35) {
      return Icons.sentiment_very_dissatisfied;
    } else if (bmi < 40) {
      return Icons.sentiment_very_dissatisfied;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }

  Color _getBmiCategoryColor(double? bmi) {
    if (bmi == null) {
      return Colors.black;
    }

    if (bmi < 16) {
      return Colors.red;
    } else if (bmi < 17) {
      return Colors.orange;
    } else if (bmi < 18.5) {
      return Colors.yellow;
    } else if (bmi < 25) {
      return Colors.green;
    } else if (bmi < 30) {
      return Colors.orange;
    } else if (bmi < 35) {
      return Colors.red;
    } else if (bmi < 40) {
      return Colors.red;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    double? bmi = _userData['bmi'];

    String bmiCategory = 'N/A';
    IconData bmiCategoryIcon = Icons.sentiment_neutral;
    Color bmiCategoryColor = Colors.black;

    if (bmi != null) {
      bmiCategory = _getBmiCategory(bmi);
      bmiCategoryIcon = _getBmiCategoryIcon(bmi);
      bmiCategoryColor = _getBmiCategoryColor(bmi);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Prakriti'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.id,
                (route) => false,
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome, ${_userData['name'] ?? 'User'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'User ID : ${_userData['customUserId'] ?? 'User'}',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 16.0),
                        if (!_surveyCompleted)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, SurveyScreen.id);
                            },
                            child: Container(
                              width: double.infinity,
                              child: Center(child: Text('Start Survey')),
                            ),
                          )
                        else
                          Column(
                            children: [
                              Text(
                                'Survey Completed',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 34, 194, 39),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, DashboardScreen.id);
                                },
                                child: Container(
                                  width: double.infinity,
                                  child:
                                      Center(child: Text('Prakriti Dashboard')),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              _buildProfileDetailCard('Age', _userData['age'].toString()),
              _buildProfileDetailCard('Sex', _userData['sex']),
              _buildProfileDetailCard(
                  'Height', _userData['height'].toString() + ' cm'),
              _buildProfileDetailCard(
                  'Weight', _userData['weight'].toString() + ' kg'),
              _buildProfileDetailCard(
                'Current Address',
                _userData['currentAddress'].toString(),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _buildProfileDetailCard(
                      'BMI',
                      bmi?.toStringAsFixed(2) ?? 'N/A',
                      color: bmiCategoryColor,
                    ),
                  ),
                  Expanded(
                    child: _buildProfileDetailCard(
                      'BMI Category',
                      bmiCategory,
                      color: bmiCategoryColor,
                      icon: Icon(
                        bmiCategoryIcon,
                        color: bmiCategoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailCard(String label, String value,
      {Color? color, Icon? icon}) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Divider(),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? 'N/A' : value,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: color ?? Colors.black,
                    ),
                  ),
                ),
                if (icon != null) icon,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
