import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'table_header.dart';
import 'table_container.dart';
import 'table_add_del_hover_button.dart';

class TargetsTable extends StatelessWidget {
  const TargetsTable({Key? key}) : super(key: key);

  static const colFlexs = [60, 15, 15, 15, 9, 15, 15, 15, 18];
  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    return TableContainer(
      maxHeight: 500,
      borderColor: theme.outline,
      color: theme.background,
      header: const TargetsTableHeader(),
      listView: DefaultTextStyle(
        // TODO could add this to TableContainer?
        style: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onTertiaryContainer),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
          itemCount: 3,
          itemExtent: itemHeight,
          itemBuilder: (_, index) => TargetsTableItem(index: index),
        ),
      ),
    );
  }
}

class TargetsTableItem extends StatelessWidget {
  const TargetsTableItem({required this.index, Key? key}) : super(key: key);

  final int index;

  Widget wrap(int n, {Widget? child}) {
    return Flexible(
      flex: TargetsTable.colFlexs[n],
      child: Container(
        alignment: Alignment.centerRight,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: TargetsTable.colFlexs[0],
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TargetsTable.padding),
                child: TableAddDelButton(
                  onTap: () {
                    print('meow');
                  },
                  closeButton: true,
                  color: theme.background,
                  hoveredColor: theme.tertiaryContainer,
                  splashColor: theme.onTertiaryContainer.withOpacity(.35),
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
        wrap(1),
        wrap(2),
        wrap(3),
        wrap(4),
        wrap(5),
        wrap(6),
        wrap(7),
        Flexible(
          flex: TargetsTable.colFlexs[8],
          child: Container(alignment: Alignment.centerRight),
        ),
      ],
    );
  }
}

class TargetsTableHeader extends StatelessWidget {
  const TargetsTableHeader({Key? key}) : super(key: key);

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
      flexs: TargetsTable.colFlexs,
      height: TargetsTable.headerHeight,
      items: [
        TableColumn(
            widget: Container(
          padding: const EdgeInsets.fromLTRB(TargetsTable.padding + TableAddDelButton.innerPadding, 0, 0, 0),
          child:
              Text('Targets', style: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground)),
        )),
        getCol('Runs', 1, () {}),
        getCol('Profit', 2, () {}),
        getCol('Cost', 3, () {}),
        getCol('%', 4, () {}),
        getCol('Cost/u', 5, () {}),
        getCol('Sell/u', 6, () {}),
        getCol('Out m3', 7, () {}),
        TableColumn(
            widget: Container(
          alignment: Alignment.centerRight,
          // padding: const EdgeInsets.symmetric(horizontal: theme.appBarPadding),
        )),
      ],
    );
  }
}
