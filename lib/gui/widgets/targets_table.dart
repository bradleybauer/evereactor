import 'package:flutter/material.dart';

class TargetsTable extends StatelessWidget {
  const TargetsTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(4),
      child: DataTable(
        showCheckboxColumn: false,
        dataRowHeight: 32,
        columnSpacing: 8,
        headingRowHeight: 38,
        columns: const [DataColumn(label: Text('hai')), DataColumn(label: Text('bye'))],
        rows: const [
          DataRow(cells: [DataCell(Text('11')), DataCell(Text('12'))]),
          DataRow(cells: [DataCell(Text('21')), DataCell(Text('22'))]),
          DataRow(cells: [DataCell(Text('21')), DataCell(Text('22'))]),
          DataRow(cells: [DataCell(Text('21')), DataCell(Text('22'))]),
          DataRow(cells: [DataCell(Text('21')), DataCell(Text('22'))]),
          DataRow(cells: [DataCell(Text('21')), DataCell(Text('22'))]),
          DataRow(cells: [DataCell(Text('21')), DataCell(Text('22'))]),
          DataRow(cells: [DataCell(Text('21')), DataCell(Text('22'))]),
        ],
      ),
    );
  }
}
