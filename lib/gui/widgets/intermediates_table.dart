import 'package:flutter/material.dart';

import 'build_buy_toggle_buttons.dart';
import '../my_theme.dart';
import 'table_add_del_hover_button.dart';

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
          child: DataTable(
            dataTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.colors.onBackground),
            headingTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.colors.onBackground),
            showCheckboxColumn: false,
            dividerThickness: .000001,
            dataRowHeight: 24,
            columnSpacing: 8,
            headingRowHeight: 38,
            horizontalMargin: 7,
            columns: [
              DataColumn(label: Text('')),
              DataColumn(label: Text('Intermediates                         ')),
              DataColumn(label: Text('Value'), onSort: (i, b) {}),
              DataColumn(label: Text('Build/Buy     ')),
              DataColumn(label: Text('BPs              ')),
            ],
            rows: [
              DataRow(cells: [
                DataCell(_AddButton()),
                DataCell(Text('21')),
                DataCell(Text('21')),
                DataCell(BuildBuyToggleButtons()),
                DataCell(BPOptions())
              ]),
              DataRow(cells: [
                DataCell(_AddButton()),
                DataCell(Text('21')),
                DataCell(Text('21')),
                DataCell(BuildBuyToggleButtons()),
                DataCell(Text('21'))
              ]),
              DataRow(cells: [
                DataCell(_AddButton()),
                DataCell(Text('21')),
                DataCell(Text('ha')),
                DataCell(BuildBuyToggleButtons()),
                DataCell(Text('ai'))
              ]),
              DataRow(cells: [
                DataCell(_AddButton()),
                DataCell(Text('21')),
                DataCell(Text('ha')),
                DataCell(BuildBuyToggleButtons()),
                DataCell(Text('ai'))
              ]),
              DataRow(cells: [
                DataCell(_AddButton()),
                DataCell(Text('21')),
                DataCell(Text('ha')),
                DataCell(BuildBuyToggleButtons()),
                DataCell(Text('ai'))
              ]),
              DataRow(cells: [
                DataCell(_AddButton()),
                DataCell(Text('21')),
                DataCell(Text('ha')),
                DataCell(BuildBuyToggleButtons()),
                DataCell(Text('ai'))
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class BPOptions extends StatelessWidget {
  const BPOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableAddDelButton(
      onTap: () {},
      closeButton: false,
      color: theme.colors.background,
      hoveredColor: theme.colors.primary,
      iconColor: theme.colors.onBackground,
      iconHoveredColor: theme.colors.onPrimary,
      splashColor: theme.colors.onPrimary.withOpacity(.5),
    );
  }
}
