import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> writeToFile(
    String fileName, List<Map<String, dynamic>> data) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsString(jsonEncode(data), flush: true);
    print("$fileName created successfully at $filePath!");
  } catch (e) {
    print("Error creating $fileName: $e");
  }
}

Future readJsonFile(String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    final jsonContent = await file.readAsString();
    return jsonDecode(jsonContent);
  } catch (e) {
    print("Error reading $fileName: $e");
    return {};
  }
}
