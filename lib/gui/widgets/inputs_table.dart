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
          dataTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.colors.onBackground),
          headingTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.colors.onBackground),
          showCheckboxColumn: false,
          dataRowHeight: 32,
          columnSpacing: 8,
          headingRowHeight: 38,

          //(icon, name, quantity (amount provided by inventory), value)
          columns: [
            DataColumn(label: Text('Inputs                       '), onSort: (i, b) {}),
            DataColumn(label: Text('Quantity'), onSort: (i, b) {}),
            DataColumn(label: Text('Value')),
          ],
          rows: [
            DataRow(cells: List<DataCell>.filled(3, DataCell(Text('11')))),
            DataRow(cells: List<DataCell>.filled(3, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(3, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(3, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(3, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(3, DataCell(Text('21')))),
          ],
        ),
      ),
    );
  }
}
