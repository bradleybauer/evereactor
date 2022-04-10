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
        itemCount: 40,
        itemExtent: itemHeight,
        itemBuilder: (_, index) => InputsTableItem(index: index),
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
          child: Text(title),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return TableHeader(
      flexs: InputsTable.colFlexs,
      height: InputsTable.headerHeight,
      textStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onTertiaryContainer),
      items: [
        TableColumn(
            widget: Container(
          padding: const EdgeInsets.fromLTRB(InputsTable.padding, 0, 0, 0),
          child: Text('Inputs'),
        )),
        getCol('Quantity', 1, () {}),
        // TODO pad this
        getCol('Value', 2, () {}),
      ],
    );
  }
}

class InputsTableItem extends StatelessWidget {
  const InputsTableItem({required this.index, Key? key}) : super(key: key);

  final int index;

  Widget wrap(int n, {EdgeInsets? padding, Alignment? align, Widget? child}) {
    return Flexible(
      flex: InputsTable.colFlexs[n],
      child: Container(
        padding: padding,
        alignment: align ?? Alignment.centerRight,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        wrap(
          0,
          padding: const EdgeInsets.fromLTRB(InputsTable.padding, 0, 0, 0),
          align: Alignment.centerLeft,
          child: Container(height: 30, color: theme.primary),
        ),
        wrap(1, child: Container(color: theme.secondary)),
        wrap(2, child: Container(color: theme.secondaryContainer)),
      ],
    );
  }
}
