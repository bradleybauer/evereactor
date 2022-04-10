import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'table_header.dart';
import 'table_container.dart';
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
        itemCount: 25,
        itemExtent: itemHeight,
        itemBuilder: (_, index) => IntermediatesTableItem(index: index),
      ),
    );
  }
}

class IntermediatesTableHeader extends StatelessWidget {
  const IntermediatesTableHeader({Key? key}) : super(key: key);

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
      flexs: IntermediatesTable.colFlexs,
      height: IntermediatesTable.headerHeight,
      textStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground),
      items: [
        TableColumn(
            widget: Container(
          padding: const EdgeInsets.fromLTRB(IntermediatesTable.padding + TableAddDelButton.innerPadding, 0, 0, 0),
          child: const Text('Intermediates'),
        )),
        getCol('Value', 1, () {}),
        TableColumn(
            widget: Container(
          alignment: Alignment.centerRight,
          color: theme.primary,
        )),
        TableColumn(
            widget: Container(
          alignment: Alignment.centerRight,
          color: theme.primary,
        )),
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

class _AddButton extends StatelessWidget {
  const _AddButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableAddDelButton(
      onTap: () {},
      closeButton: false,
      color: theme.background,
      hoveredColor: theme.tertiaryContainer,
      splashColor: theme.onTertiaryContainer.withOpacity(.4),
    );
  }
}
