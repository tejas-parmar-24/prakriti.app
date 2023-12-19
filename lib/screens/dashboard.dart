import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share/share.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

class DashboardScreen extends StatelessWidget {
  static const String id = 'dashboard_screen';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Uint8List> loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: FutureBuilder(
        future: fetchPrakritiDistribution(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Unable to fetch survey results.'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          } else {
            final prakritiDistribution = snapshot.data;
            final pieChart = createPieChart(prakritiDistribution!);

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Prakriti Distribution',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 16.0),
                  FutureBuilder(
                    future: getCustomUserId(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (userSnapshot.hasError) {
                        return Text('Error fetching User ID');
                      } else {
                        final customUserId = userSnapshot.data as String;
                        return Text(
                          'User ID: $customUserId',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    },
                  ),
                  Divider(height: 16.0),
                  SizedBox(height: 20.0),
                  SizedBox(
                    height: 300.0,
                    child: pieChart,
                  ),
                  Divider(),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      _downloadResults(context, prakritiDistribution!);
                    },
                    child: Text('Download Results'),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<String?> getCustomUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 'User is not authenticated';
      }

      final userSurveyRef =
          _firestore.collection('users-survey-v02').doc(user.uid);

      final userDocument = await userSurveyRef.get();

      if (userDocument.exists) {
        final userData = userDocument.data();
        return userData?['customUserId'] ?? 'N/A';
      } else {
        return 'N/A';
      }
    } catch (e) {
      print('Error fetching custom user ID: $e');
      return 'N/A';
    }
  }

  Future<Map<String, double>> fetchPrakritiDistribution() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'User is not authenticated';
      }

      final userSurveyRef =
          _firestore.collection('users-survey-v02').doc(user.uid);

      final QuerySnapshot userResponsesResultSnapshot =
          await userSurveyRef.collection('user-survey-result').get();

      if (userResponsesResultSnapshot.docs.isNotEmpty) {
        final userResponsesResult = userResponsesResultSnapshot.docs.last;
        final userData = userResponsesResult.data() as Map<String, dynamic>?;
        final prakritiDistribution =
            Map<String, dynamic>.from(userData!['prakritiDistribution']);

        return prakritiDistribution.cast<String, double>();
      } else {
        throw 'Prakriti distribution data not found';
      }
    } catch (e) {
      print('Error fetching survey results: $e');
      throw e;
    }
  }

  Widget createPieChart(Map<String, double> data) {
    final sortedKeys = data.keys.toList()..sort();

    List<PieChartSectionData> sections = [];

    sortedKeys.forEach((key) {
      final double value = data[key] ?? 0.0;
      final Color color = _getColorForOption(key);

      sections.add(
        PieChartSectionData(
          title: '$key\n${value.toStringAsFixed(2)}%',
          value: value,
          color: color,
          radius: 100,
        ),
      );
    });

    return PieChart(
      PieChartData(
        sections: sections,
      ),
    );
  }

  Color _getColorForOption(String option) {
    switch (option) {
      case 'Vata':
        return Color.fromARGB(255, 87, 125, 156);
      case 'Pitta':
        return Color.fromARGB(255, 156, 92, 90);
      case 'Kapha':
        return Color.fromARGB(255, 100, 160, 103);
      default:
        return Color.fromARGB(255, 146, 146, 144);
    }
  }

  void _downloadResults(
    BuildContext context,
    Map<String, double> prakritiDistribution,
  ) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final uniqueUserID = await getCustomUserId();
    final IITJ_logo = await loadImage('assets/images/iitj_logo.png');
    final prakriti_logo = await loadImage('assets/images/logo.png');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(10.0),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.black,
                width: 1.5,
              ),
              borderRadius: pw.BorderRadius.circular(12.0),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  children: [
                    pw.SizedBox(height: 16),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Image(
                          pw.MemoryImage(IITJ_logo),
                          width: 50,
                          height: 50,
                        ),
                        pw.SizedBox(width: 16),
                        pw.Image(
                          pw.MemoryImage(prakriti_logo),
                          width: 50,
                          height: 50,
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Indian Institute of Technology, Jodhpur',
                      style: pw.TextStyle(
                        fontSize: 19,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Center of Excellence in AyurTech',
                    style: pw.TextStyle(
                      fontSize: 17,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Jodhpur, Rajasthan - 342030, India',
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'User ID: $uniqueUserID',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Date: $formattedDate',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Divider(
                  color: PdfColors.black,
                  thickness: 1.0,
                ),
                pw.SizedBox(height: 25),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Prakriti Phenotyping',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Center(
                  child: pw.AspectRatio(
                    aspectRatio: 1.5,
                    child: createPieChartPDF(prakritiDistribution),
                  ),
                ),
                pw.SizedBox(height: 100),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Thanks for choosing our service!',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Contact the AyurVedic Hospital for any clarifications.',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Divider(
                  color: PdfColors.black,
                  thickness: 1.0,
                ),
              ],
            ),
          );
        },
      ),
    );
    try {
      // Save the PDF to a temporary file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/survey_results.pdf');
      await file.writeAsBytes(await pdf.save());

      // Show a dialog to inform the user of the successful download
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Download Successful'),
          content: Text(
            'The survey results have been successfully downloaded as a PDF.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        ),
      );

      // Optionally, open or share the PDF
      OpenFile.open(file.path); // Open the PDF using a PDF viewer
      Share.shareFiles([file.path],
          text: 'Survey Results PDF'); // Share the PDF
    } catch (e) {
      // Handle errors in case of download failure
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Download Error'),
          content: Text(
            'An error occurred while trying to download the survey results as a PDF.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        ),
      );
      print('Error during download: $e');
    }
  }

  pw.Widget createPieChartPDF(Map<String, double> data) {
    final List<pw.Widget> sections = [];
    final Map<String, PdfColor> colorMap = {
      'Vata': PdfColors.blue,
      'Pitta': PdfColors.red,
      'Kapha': PdfColors.green,
      'NA': PdfColors.grey,
    };

    data.forEach((key, value) {
      final color = colorMap[key] ?? PdfColors.orange;
      final double percentage = value;
      sections.add(
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 8.0),
          child: pw.Row(
            children: [
              pw.Container(
                width: 40,
                height: 40,
                decoration: pw.BoxDecoration(
                  color: color,
                ),
              ),
              pw.SizedBox(width: 15),
              pw.Text('$key\n${percentage.toStringAsFixed(2)}%'),
            ],
          ),
        ),
      );
    });

    return pw.Column(children: sections);
  }
}
