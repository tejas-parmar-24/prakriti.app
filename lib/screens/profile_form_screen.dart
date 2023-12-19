import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prakriti/screens/profile_screen.dart';
import 'package:prakriti/screens/welcome.dart';

class SignUpProfileScreen extends StatefulWidget {
  static const String id = 'signup_profile_screen';

  @override
  _SignUpProfileScreenState createState() => _SignUpProfileScreenState();
}

class _SignUpProfileScreenState extends State<SignUpProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late int _contactNumber;
  late int _age;
  late String _sex;
  late double _height;
  late double _weight;
  late double _waistSize;
  late double _wristSize;
  late double _hipSize;
  late String _currentAddress;
  String _migrationAddress = "";
  bool _isMigrated = false;

  double? _bmi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Setup'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Icon
                CircleAvatar(
                  radius: 60.0,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.0),
                // Full Name
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Full Name',
                    icon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                SizedBox(height: 20.0),
                // Contact Number
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Contact Number',
                    icon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }
                    if (value.length != 10) {
                      return 'Mobile number must be 10 digits';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _contactNumber = int.parse(value!);
                  },
                ),
                SizedBox(height: 20.0),
                // Age
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Age',
                    icon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _age = int.parse(value!);
                  },
                ),
                SizedBox(height: 20.0),
                // Sex Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Sex',
                    icon: Icon(Icons.person_outline),
                  ),
                  items: ['Male', 'Female', 'Other'].map((String sex) {
                    return DropdownMenuItem<String>(
                      value: sex,
                      child: Text(sex),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your sex';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _sex = value!;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                // Height
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Height (cm)',
                    icon: Icon(Icons.height),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height in cm';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _height = double.parse(value!);
                  },
                ),
                SizedBox(height: 20.0),
                // Weight
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Weight (kg)',
                    icon: Icon(Icons.line_weight),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight in kg';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _weight = double.parse(value!);
                  },
                ),
                SizedBox(height: 20.0),
                // Height
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Waist Size(inches)',
                    icon: Icon(Icons.height),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your waist size in inches';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _waistSize = double.parse(value!);
                  },
                ),
                SizedBox(height: 20.0),
                // Height
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Wrist Size (cm)',
                    icon: Icon(Icons.height),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your wrist size in cm';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _wristSize = double.parse(value!);
                  },
                ),
                SizedBox(height: 20.0),
                // Height
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Hip Size (inches)',
                    icon: Icon(Icons.height),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your hip size in inches';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _hipSize = double.parse(value!);
                  },
                ),
                SizedBox(height: 20.0),
                // Current Address
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Current Address',
                    icon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _currentAddress = value!;
                  },
                ),
                SizedBox(height: 20.0),
                // Migrated Checkbox
                Row(
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 10.0),
                    Text('Migrated: '),
                    Checkbox(
                      value: _isMigrated,
                      onChanged: (value) {
                        setState(() {
                          _isMigrated = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
                // Migration Address (if migrated)
                if (_isMigrated)
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Migration Address',
                      icon: Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (_isMigrated && (value == null || value.isEmpty)) {
                        return 'Please enter your migration address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _migrationAddress = value!;
                    },
                  ),
                SizedBox(height: 20.0),
                // BMI Display
                if (_bmi != null)
                  Card(
                    elevation: 3.0,
                    child: ListTile(
                      leading: Icon(Icons.accessibility),
                      title: Text('BMI: ${_bmi!.toStringAsFixed(2)}'),
                    ),
                  ),
                // Register Button
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      _bmi = _calculateBMI(_height, _weight);

                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          final customUserID = await _generateUniqueUserID();

                          await _firestore
                              .collection('users-survey-v02')
                              .doc(user.uid)
                              .set({
                            'firebaseUid': user.uid,
                            'customUserId': customUserID,
                            'name': _name,
                            'contactNumber': _contactNumber,
                            'age': _age,
                            'sex': _sex,
                            'height': _height,
                            'weight': _weight,
                            'waistSize': _waistSize,
                            'wristSize': _wristSize,
                            'hipSize': _hipSize,
                            'currentAddress': _currentAddress,
                            'isMigrated': _isMigrated,
                            'migrationAddress': _migrationAddress,
                            'bmi': _bmi,
                            'surveyCompleted': false,
                            'surevyCount': 0
                          });

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Registration Successful'),
                                content: Text(
                                  'You have successfully created your profile.',
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProfileHomeScreen(
                                            user: user,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20.0, // Increase the height
                                      ),
                                      minimumSize:
                                          Size(200, 0), // Increase the width
                                    ),
                                    child: Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 20.0, // Increase font size
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } catch (e) {
                        print('Error storing user data: $e');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.0, // Increase horizontal padding
                    ),
                    primary: Colors.blue, // Background color
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 30.0, // Increase font size
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateBMI(double height, double weight) {
    return (weight / ((height / 100) * (height / 100))).toDouble();
  }

  Future<String> _generateUniqueUserID() async {
    final currentYear = DateTime.now().year % 100;
    final currentMonth = DateTime.now().month.toString().padLeft(2, '0');

    final latestCounter = await _getLatestCounterFromFirestore();
    final nextCounter = latestCounter + 1;
    final counterString = nextCounter.toString().padLeft(5, '0');
    final uniqueUserID = 'AYT$currentYear$currentMonth$counterString';
    return uniqueUserID;
  }

  Future<int> _getLatestCounterFromFirestore() async {
    try {
      final userSurveyCollection = _firestore.collection('users-survey-v02');
      final querySnapshot = await userSurveyCollection.get();
      final latestCounter = querySnapshot.docs.length;
      return latestCounter;
    } catch (e) {
      print('Error fetching counter from Firestore: $e');
      throw e;
    }
  }
}
