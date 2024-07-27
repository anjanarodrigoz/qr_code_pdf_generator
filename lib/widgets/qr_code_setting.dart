import 'package:flutter/material.dart';

class QrCodeSettings extends StatelessWidget {
  final List<String> columns;
  final List<bool> includeInQrCode;
  final List<bool> includeInPdf;
  final int qrPerPage;
  final ValueChanged<int?> onQrPerPageChanged;

  const QrCodeSettings({
    Key? key,
    required this.columns,
    required this.includeInQrCode,
    required this.includeInPdf,
    required this.qrPerPage,
    required this.onQrPerPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select columns to include in QR code'),
              Wrap(
                spacing: 10,
                children: List.generate(columns.length, (index) {
                  return CheckboxListTile(
                    title: Text(columns[index]),
                    value: includeInQrCode[index],
                    onChanged: (value) {
                      includeInQrCode[index] = value!;
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select columns to include in PDF'),
              Wrap(
                spacing: 10,
                children: List.generate(columns.length, (index) {
                  return CheckboxListTile(
                    title: Text(columns[index]),
                    value: includeInPdf[index],
                    onChanged: (value) {
                      includeInPdf[index] = value!;
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        Column(
          children: [
            const Text('Select number of QR codes per page'),
            DropdownButton<int>(
              value: qrPerPage,
              items: [1, 2, 4, 6, 8].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: onQrPerPageChanged,
            ),
          ],
        ),
      ],
    );
  }
}
