import 'package:flutter/material.dart';

class FilterInput extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const FilterInput({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Filter',
        suffixIcon: Icon(Icons.search),
      ),
      onChanged: onChanged,
    );
  }
}
