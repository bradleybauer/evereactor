import 'package:flutter/material.dart';

import '../my_theme.dart';

class TargetsTable extends StatelessWidget {
  const TargetsTable({Key? key}) : super(key: key);

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
          dividerThickness: .000001,
          showCheckboxColumn: false,
          dataRowHeight: 24,
          columnSpacing: 8,
          headingRowHeight: 38,
          columns: [
            DataColumn(label: Text('Targets                 '), onSort: (i, b) {}),
            DataColumn(label: Text('Runs'), onSort: (i, b) {}),
            DataColumn(label: Text('Cost'), onSort: (i, b) {}),
            DataColumn(label: Text('Profit'), onSort: (i, b) {}),
            DataColumn(label: Text('%'), onSort: (i, b) {}),
            DataColumn(label: Text('Cost/u'), onSort: (i, b) {}),
            DataColumn(label: Text('Sell/u'), onSort: (i, b) {}),
            DataColumn(label: Text('Out m3'), onSort: (i, b) {}),
            DataColumn(label: Text('BPs')),
          ],
          rows: [
            DataRow(cells: List<DataCell>.filled(9, DataCell(Text('11')))),
            DataRow(cells: List<DataCell>.filled(9, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(9, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(9, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(9, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(9, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(9, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(9, DataCell(Text('21')))),
          ],
        ),
      ),
    );
  }
}
