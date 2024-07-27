import 'dart:async';
import 'dart:html' as html;
import 'package:csv/csv.dart';

import '../models/data_model.dart';

class FilePickerService {
  static Future<List<Student>?> pickFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.csv';
    uploadInput.click();

    final completer = Completer<List<Student>?>();
    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files!.length == 1) {
        final reader = html.FileReader();
        reader.readAsText(files[0]);
        reader.onLoadEnd.listen((e) {
          final csvData = reader.result as String;
          final data = const CsvToListConverter().convert(csvData);
          final students = data.map((e) => Student(e)).toList();
          completer.complete(students);
        });
      } else {
        completer.complete(null);
      }
    });

    return completer.future;
  }
}
