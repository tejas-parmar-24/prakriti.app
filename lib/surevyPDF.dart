import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

String formatUserResponsesToCSV(List<Map<String, dynamic>> userResponses) {
  final StringBuffer csvBuffer = StringBuffer();

  // Add CSV header row
  csvBuffer.writeln('Question Number,Question,Selected Options,Option Points');

  // Iterate through user responses and add them to the CSV
  for (int i = 0; i < userResponses.length; i++) {
    final response = userResponses[i];
    final question = response['question'];
    final selectedOptions = response['selectedOptions'];

    for (int j = 0; j < selectedOptions.length; j++) {
      final option = selectedOptions[j]['option'];
      final points = selectedOptions[j]['points'];
      csvBuffer.writeln('$i,"$question","$option",$points');
    }
  }

  return csvBuffer.toString();
}

Future<void> generateCSVFile(
    List<Map<String, dynamic>> userResponses, String customUserId) async {
  try {
    final csvData = formatUserResponsesToCSV(userResponses);

    // You can use a package like 'path_provider' to get the document directory
    // and save the CSV file there.
    final directory = 'prakriti-users/$customUserId/survey-responses';
    final filePath = '$directory/$customUserId-responses.csv';

    final File file = File(filePath);
    await file.writeAsString(csvData);

    // Now, you have the CSV file saved in the app's document directory.
    // You can provide the user with options to share or download it.

    // Upload the CSV file to Firebase Storage
    await uploadFile(filePath, customUserId);
  } catch (e) {
    print('Error generating and uploading CSV file: $e');
  }
}

Future<void> uploadFile(String filePath, String customUserId) async {
  try {
    File file = File(filePath);
    Reference storageReference = FirebaseStorage.instance.ref().child(
        'prakriti-users/$customUserId/survey-responses/$customUserId-responses.csv');
    await storageReference.putFile(file);
    print('File uploaded to Firebase Storage');
  } catch (error) {
    print('Error uploading file: $error');
  }
}

Future<String?> getDownloadURL(String userId) async {
  try {
    String fileName =
        'user_responses.csv'; // Name of the file you want to download
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('prakriti-users/$userId/survey-responses/$fileName');
    String downloadURL = await storageReference.getDownloadURL();
    return downloadURL;
  } catch (error) {
    print('Error getting download URL: $error');
    return null;
  }
}
