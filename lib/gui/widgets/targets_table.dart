import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'table_header.dart';
import 'table_container.dart';
import 'table_add_del_hover_button.dart';

class TargetsTable extends StatelessWidget {
  const TargetsTable({Key? key}) : super(key: key);

  static const colFlexs = [60, 15, 15, 15, 7, 15, 15, 15, 18];
  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    return TableContainer(
      maxHeight: 500, // TODO want this to be function of the screen width
      borderColor: theme.outline,
      color: theme.background,
      header: const TargetsTableHeader(),
      listTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onTertiaryContainer),
      listView: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
        itemCount: 50,
        itemExtent: itemHeight,
        itemBuilder: (_, index) => TargetsTableItem(index: index),
      ),
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
          child: Text(title),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return TableHeader(
      flexs: TargetsTable.colFlexs,
      height: TargetsTable.headerHeight,
      textStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onTertiaryContainer),
      items: [
        TableColumn(
            widget: Container(
          padding: const EdgeInsets.fromLTRB(TargetsTable.padding + TableAddDelButton.innerPadding, 0, 0, 0),
          child: Text('Targets'),
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
          padding: const EdgeInsets.symmetric(horizontal: theme.appBarPadding),
          color: theme.primary,
        )),
      ],
    );
  }
}

class TargetsTableItem extends StatelessWidget {
  const TargetsTableItem({required this.index, Key? key}) : super(key: key);

  final int index;

  Widget wrap(int n, {EdgeInsets? padding, Alignment? align, Widget? child}) {
    return Flexible(
      flex: TargetsTable.colFlexs[n],
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
          align: Alignment.centerLeft,
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
                  child: Container(
                color: theme.secondary,
              )),
            ],
          ),
        ),
        wrap(1, child: Container(color: theme.primary)),
        wrap(2, child: Container(color: theme.primaryContainer)),
        wrap(3, child: Container(color: theme.secondary)),
        wrap(4, child: Container(color: theme.secondaryContainer)),
        wrap(5, child: Container(color: theme.tertiary)),
        wrap(6, child: Container(color: theme.tertiaryContainer)),
        wrap(7, child: Container(color: theme.error)),
        wrap(8, child: Container(color: theme.errorContainer)),
      ],
    );
  }
}
