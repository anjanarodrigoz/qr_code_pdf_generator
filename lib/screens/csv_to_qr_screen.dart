import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/data_model.dart';
import '../services/file_picker_service.dart';
import '../widgets/csv_table.dart';
import '../widgets/filter_input.dart';
import '../widgets/qr_code_setting.dart';
import '../widgets/loading_indicator.dart';

class CsvToQrScreen extends StatefulWidget {
  const CsvToQrScreen({super.key});

  @override
  _CsvToQrScreenState createState() => _CsvToQrScreenState();
}

class _CsvToQrScreenState extends State<CsvToQrScreen> {
  List<Student> _students = [];
  List<String> _columns = [];
  List<bool> _includeInQrCode = [];
  List<bool> _includeInPdf = [];
  bool _isLoading = false;
  int _qrPerPage = 8;
  String _filterText = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  void _startFilePicker() async {
    final csvData = await FilePickerService.pickFile();
    if (csvData != null) {
      setState(() {
        _students = csvData;
        if (_students.isNotEmpty) {
          _columns = List<String>.from(_students[0].data);
          _includeInQrCode = List<bool>.filled(_columns.length, false);
          _includeInPdf = List<bool>.filled(_columns.length, true);
          _students.removeAt(0); // Remove headers
        }
      });
    }
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isLoading = true;
    });

    final pdf = pw.Document();
    const pageWidth = 400;
    const pageHeight = 600;
    const margin = 20.0;

    const usableHeight = pageHeight - margin * 2;
    const usableWidth = pageWidth - margin * 2;

    int itemsPerRow = (_qrPerPage == 1)
        ? 1
        : (_qrPerPage == 2)
            ? 1
            : 2;
    int itemsPerColumn = (_qrPerPage) ~/ itemsPerRow;

    double qrSize = (usableHeight) / itemsPerColumn;
    double fontSize = 15.0;

    for (var i = 0; i < _students.length; i += _qrPerPage) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(margin),
          build: (context) => pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              for (var row = 0; row < itemsPerColumn; row++)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var col = 0; col < itemsPerRow; col++)
                      if (i + row * itemsPerRow + col < _students.length)
                        pw.Container(
                          width: pageWidth / 2,
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          child: _buildStudentInfo(
                            _students[i + row * itemsPerRow + col].data,
                            qrSize,
                            fontSize,
                          ),
                        ),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'students_qr.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);

    setState(() {
      _isLoading = false;
    });
  }

  pw.Widget _buildStudentInfo(
      List<dynamic> student, double qrSize, double fontSize) {
    final qrData = _columns
        .asMap()
        .entries
        .where((entry) => _includeInQrCode[entry.key])
        .map((entry) => '${student[entry.key]}')
        .join('\n');
    final pdfData = _columns
        .asMap()
        .entries
        .where((entry) => _includeInPdf[entry.key])
        .map((entry) => '${entry.value}: ${student[entry.key]}')
        .join('\n');

    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          'Admission for semester 01 exam 23S1',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: fontSize - 2,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          pdfData,
          textAlign: pw.TextAlign.center,
          style:
              pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: qrData,
          width: qrSize - 40,
          height: qrSize - 40,
        ),
        pw.Text(
          'Please keep this paper until the end of all semester 01 exams',
          style: pw.TextStyle(fontSize: fontSize - 2),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10)
      ],
    );
  }

  void _sortData() {
    if (_sortColumnIndex != null) {
      _students.sort((a, b) {
        int columnIndex = _sortColumnIndex!;
        return _sortAscending
            ? a.data[columnIndex].compareTo(b.data[columnIndex])
            : b.data[columnIndex].compareTo(a.data[columnIndex]);
      });
    }
  }

  List<Student> get _filteredData {
    if (_filterText.isEmpty) {
      return _students;
    } else {
      return _students
          .where((row) =>
              row.data.any((cell) => cell.toString().contains(_filterText)))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV to QR Code Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: _startFilePicker,
              child: const Text('Upload CSV'),
            ),
            const SizedBox(height: 20),
            if (_columns.isNotEmpty)
              Column(
                children: [
                  QrCodeSettings(
                    columns: _columns,
                    includeInQrCode: _includeInQrCode,
                    includeInPdf: _includeInPdf,
                    qrPerPage: _qrPerPage,
                    onQrPerPageChanged: (value) {
                      setState(() {
                        _qrPerPage = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  FilterInput(
                    onChanged: (value) {
                      setState(() {
                        _filterText = value;
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (_students.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: CsvTable(
                    columns: _columns,
                    students: _filteredData,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    onSort: (int columnIndex, bool ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                        _sortData();
                      });
                    },
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _students.isNotEmpty && !_isLoading ? _generatePdf : null,
              child: const Text('Generate PDF'),
            ),
            if (_isLoading) const LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
