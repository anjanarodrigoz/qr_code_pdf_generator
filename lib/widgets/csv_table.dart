import 'package:flutter/material.dart';

import '../models/data_model.dart';

class CsvTable extends StatelessWidget {
  final List<String> columns;
  final List<Student> students;
  final int? sortColumnIndex;
  final bool sortAscending;
  final Function(int, bool) onSort;

  const CsvTable({
    Key? key,
    required this.columns,
    required this.students,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      columns: columns.map((column) {
        return DataColumn(
          label: Text(column),
          onSort: (int columnIndex, bool ascending) {
            onSort(columnIndex, ascending);
          },
        );
      }).toList(),
      rows: students.map((student) {
        return DataRow(
          cells: student.data
              .map((cell) => DataCell(Text(cell.toString())))
              .toList(),
        );
      }).toList(),
    );
  }
}
