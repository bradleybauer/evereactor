import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'table.dart';
import 'table_add_del_hover_button.dart';

class IntermediatesTable extends StatelessWidget {
  const IntermediatesTable({Key? key}) : super(key: key);

  static const colFlexs = [600, 200, 200, 175];
  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    return TableContainer(
      maxHeight: 500,
      borderColor: theme.outline,
      color: theme.background,
      header: const IntermediatesTableHeader(),
      listTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onTertiaryContainer),
      listView: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
        itemCount: 2,
        itemExtent: itemHeight,
        itemBuilder: (_, index) => IntermediatesTableItem(index: index),
      ),
    );
  }
}

class IntermediatesTableHeader extends StatelessWidget {
  const IntermediatesTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableHeader(
      height: IntermediatesTable.headerHeight,
      textStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground),
      items: [
        TableContainer.getCol(
          IntermediatesTable.colFlexs[0],
          child: Text('Intermediates'),
          align: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(IntermediatesTable.padding + TableAddDelButton.innerPadding, 0, 0, 0),
        ),
        TableContainer.getCol(IntermediatesTable.colFlexs[1], child: Text('Value'), onTap: () {}),
        TableContainer.getCol(IntermediatesTable.colFlexs[2], child: Text('bul/buy')),
        TableContainer.getCol(IntermediatesTable.colFlexs[3],
            padding: const EdgeInsets.fromLTRB(0, 0, IntermediatesTable.padding, 0), child: Text('bpops')),
      ],
    );
  }
}

class IntermediatesTableItem extends StatelessWidget {
  const IntermediatesTableItem({required this.index, Key? key}) : super(key: key);

  final int index;

  Widget wrap(int n, {EdgeInsets? padding, Alignment? align, Widget? child}) {
    return Flexible(
      flex: IntermediatesTable.colFlexs[n],
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
      children: [
        wrap(
          0,
          align: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(IntermediatesTable.padding, 0, 0, 0),
          child: Container(
            color: theme.primary,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                TableAddDelButton(
                  onTap: () => print('meow'),
                  closeButton: false,
                  color: theme.background,
                  hoveredColor: theme.tertiaryContainer,
                  splashColor: theme.onTertiaryContainer.withOpacity(.35),
                ),
              ],
            ),
          ),
        ),
        wrap(1, child: Container(color: theme.primary)),
        wrap(2, child: Container(color: theme.primaryContainer)),
        wrap(3, padding: const EdgeInsets.fromLTRB(0, 0, IntermediatesTable.padding, 0), child: Container(color: theme.secondary)),
      ],
    );
  }
}
