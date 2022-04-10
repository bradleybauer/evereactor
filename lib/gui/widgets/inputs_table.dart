import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'table_header.dart';
import 'table_container.dart';

class InputsTable extends StatelessWidget {
  const InputsTable({Key? key}) : super(key: key);

  static const colFlexs = [60, 15, 15];
  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    return TableContainer(
      maxHeight: 500, // TODO Temporary
      borderColor: theme.outline,
      color: theme.background,
      header: const InputsTableHeader(),
      listTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onTertiaryContainer),
      listView: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
        itemCount: 4,
        itemExtent: itemHeight,
        itemBuilder: (_, index) => InputsTableItem(index: index),
      ),
    );
  }
}

class InputsTableHeader extends StatelessWidget {
  const InputsTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableHeader(
      height: InputsTable.headerHeight,
      textStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onTertiaryContainer),
      items: [
        TableContainer.getCol(InputsTable.colFlexs[0],
            child: Text('Inputs'), align: Alignment.centerLeft, padding: const EdgeInsets.fromLTRB(InputsTable.padding, 0, 0, 0)),
        TableContainer.getCol(InputsTable.colFlexs[1], child: Text('Quantity'), onTap: () {}),
        TableContainer.getCol(InputsTable.colFlexs[2],
            child: Text('Value'), padding: const EdgeInsets.fromLTRB(0, 0, InputsTable.padding, 0), onTap: () {}),
      ],
    );
  }
}

class InputsTableItem extends StatelessWidget {
  const InputsTableItem({required this.index, Key? key}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyTableCell(
          InputsTable.colFlexs[0],
          padding: const EdgeInsets.fromLTRB(InputsTable.padding, 0, 0, 0),
          align: Alignment.centerLeft,
          child: Container(height: 30, color: theme.primary),
        ),
        MyTableCell(InputsTable.colFlexs[1], child: Container(color: theme.secondary)),
        MyTableCell(InputsTable.colFlexs[2], child: Container(color: theme.secondaryContainer)),
      ],
    );
  }
}
