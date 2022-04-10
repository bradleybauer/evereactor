import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'table_header.dart';
import 'table_container.dart';
import 'table_add_del_hover_button.dart';

// bottom padding of 6
// border color = outline
// color = theme
// data font size = 11
// header font size = 13
// data row height = 24

// TableAddDelButton(
//   onTap: () {},
//   closeButton: true,
//   color: theme.background,
//   hoveredColor: theme.tertiaryContainer,
//   splashColor: theme.onTertiaryContainer.withOpacity(.5),
// ),
class IntermediatesTable extends StatelessWidget {
  const IntermediatesTable({Key? key}) : super(key: key);

  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;
  static const double border = 1;
  static const colFlexs = [600, 200, 200, 175];

  @override
  Widget build(BuildContext context) {
    return TableContainer(
      maxHeight: 500,
      borderColor: theme.outline,
      color: theme.background,
      header: const IntermediatesTableHeader(),
      listView: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
        itemCount: 1,
        itemExtent: itemHeight,
        itemBuilder: (_, index) => IntermediatesTableItem(index: index),
      ),
    );
  }
}

class IntermediatesTableItem extends StatelessWidget {
  const IntermediatesTableItem({required this.index, Key? key}) : super(key: key);

  final int index;

  Widget wrap(int n, {Widget? child}) {
    return Container(
      alignment: Alignment.centerRight,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onTertiaryContainer),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: IntermediatesTable.padding),
        child: Row(
          children: [
            TableAddDelButton(
              onTap: () {
                print('meow');
              },
              closeButton: false,
              color: theme.background,
              hoveredColor: theme.tertiaryContainer,
              splashColor: theme.onTertiaryContainer.withOpacity(.35),
            ),
            Container(
              color: theme.primary,
              padding: const EdgeInsets.fromLTRB(IntermediatesTable.padding, 0, 0, 0),
            ),
            wrap(1, child: Container(color: theme.primary)),
          ],
        ),
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
          child: Text(title, style: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return TableHeader(
      flexs: IntermediatesTable.colFlexs,
      height: IntermediatesTable.headerHeight,
      items: [
        TableColumn(
            widget: Container(
          padding: const EdgeInsets.fromLTRB(IntermediatesTable.padding + TableAddDelButton.innerPadding, 0, 0, 0),
          child: Text('Intermediates',
              style: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground)),
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
