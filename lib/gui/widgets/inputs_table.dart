import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'table_header.dart';
import 'table_container.dart';
import 'table_add_del_hover_button.dart';

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
      listView: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
        itemCount: 3,
        itemExtent: itemHeight,
        itemBuilder: (_, index) => InputsTableItem(index: index),
      ),
    );
  }
}

class InputsTableItem extends StatelessWidget {
  const InputsTableItem({required this.index, Key? key}) : super(key: key);

  final int index;

  Widget wrap(int n, {Widget? child}) {
    return Flexible(
      flex: InputsTable.colFlexs[n],
      child: Container(
        alignment: Alignment.centerRight,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onTertiaryContainer),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          wrap(0, child: Container(width: 30, height: 30)),
          wrap(1),
          wrap(2),
        ],
      ),
    );
  }
}

class InputsTableHeader extends StatelessWidget {
  const InputsTableHeader({Key? key}) : super(key: key);

  TableColumn getCol(String title, int index, void Function() onTap) {
    return TableColumn(
        onTap: onTap,
        widget: Container(
          alignment: Alignment.centerRight,
          child: Text(title, style: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return TableHeader(
      flexs: InputsTable.colFlexs,
      height: InputsTable.headerHeight,
      items: [
        TableColumn(
            widget: Container(
          padding: const EdgeInsets.fromLTRB(InputsTable.padding + TableAddDelButton.innerPadding, 0, 0, 0),
          child: Text('Inputs', style: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground)),
        )),
        getCol('Quantity', 1, () {}),
        getCol('Value', 2, () {}),
      ],
    );
  }
}
