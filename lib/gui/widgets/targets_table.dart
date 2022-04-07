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
          dataTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 12, color: theme.colors.onBackground),
          headingTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.colors.onBackground),
          showCheckboxColumn: false,
          dataRowHeight: 32,
          columnSpacing: 8,
          headingRowHeight: 38,

          //(x, icon, name, runs, cost, profit, %, ppu, sale ppu, out m3, BpOptions?!?!(me, te, m#r, m#bps))
          columns: [
            DataColumn(label: Text('Targets'), onSort: (i, b) {}),
            DataColumn(label: Text('Runs')),
            DataColumn(label: Text('Cost')),
            DataColumn(label: Text('Profit')),
            DataColumn(label: Text('%')),
            DataColumn(label: Text('Cost/u')),
            DataColumn(label: Text('Sell/u')),
            DataColumn(label: Text('Out m3')),
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
