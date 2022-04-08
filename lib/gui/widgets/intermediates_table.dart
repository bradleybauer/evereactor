import 'package:flutter/material.dart';

import 'build_buy_toggle_buttons.dart';
import '../my_theme.dart';

class IntermediatesTable extends StatelessWidget {
  const IntermediatesTable({Key? key}) : super(key: key);

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
            DataColumn(label: Text('Intermediates                         '), onSort: (i, b) {}),
            DataColumn(label: Text('Value'), onSort: (i, b) {}),
            DataColumn(label: Text('Build/Buy     '), onSort: (i, b) {}),
            DataColumn(label: Text('BPs              ')),
          ],
          rows: [
            DataRow(cells: List<DataCell>.filled(4, DataCell(Text('11')))),
            DataRow(cells: [DataCell(Text('21')), DataCell(Text('21')), DataCell(BuildBuyToggleButtons()), DataCell(Text('21'))]),
            DataRow(cells: List<DataCell>.filled(4, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(4, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(4, DataCell(Text('21')))),
            DataRow(cells: List<DataCell>.filled(4, DataCell(Text('21')))),
          ],
        ),
      ),
    );
  }
}
