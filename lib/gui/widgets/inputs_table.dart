import 'package:flutter/material.dart';

import '../my_theme.dart';

class InputsTable extends StatelessWidget {
  const InputsTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.outline, width: 1),
          color: theme.background,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
          child: DataTable(
            dataTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onBackground),
            headingTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.onBackground),
            showCheckboxColumn: false,
            dividerThickness: .000001,
            dataRowHeight: 24,
            columnSpacing: 8,
            headingRowHeight: 38,
            columns: [
              DataColumn(
                  label: Row(
                children: [Text('Inputs'), const SizedBox(width: 100)],
              )),
              DataColumn(label: const Text('Quantity'), onSort: (i, b) {}),
              DataColumn(label: const Text('Value'), onSort: (i, b) {}),
            ],
            rows: [
              DataRow(cells: List<DataCell>.filled(3, const DataCell(Text('11')))),
              DataRow(cells: List<DataCell>.filled(3, const DataCell(Text('21')))),
              DataRow(cells: List<DataCell>.filled(3, const DataCell(const Text('21')))),
              DataRow(cells: List<DataCell>.filled(3, const DataCell(const Text('21')))),
              DataRow(cells: List<DataCell>.filled(3, const DataCell(Text('21')))),
              DataRow(cells: List<DataCell>.filled(3, const DataCell(Text('21')))),
            ],
          ),
        ),
      ),
    );
  }
}
