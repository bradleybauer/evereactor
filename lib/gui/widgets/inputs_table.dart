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
          border: Border.all(color: theme.colors.outline, width: 1),
          color: theme.colors.background,
        ),
        child: DataTable(
          dataTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.colors.onBackground),
          headingTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.colors.onBackground),
          showCheckboxColumn: false,
          dividerThickness: .000001,
          dataRowHeight: 24,
          columnSpacing: 8,
          headingRowHeight: 38,
          columns: [
            DataColumn(
                label: Row(
                  children: [Text('Inputs'), const SizedBox(width: 100)],
                ),
                onSort: (i, b) {}),
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
    );
  }
}
