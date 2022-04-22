import 'package:EveIndy/gui/widgets/table_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../adapters/table_targets.dart';
import '../my_theme.dart';
import 'table.dart';
import 'table_add_del_hover_button.dart';

class TargetsTable extends StatelessWidget {
  const TargetsTable({Key? key}) : super(key: key);

  static const colFlexs = [60, 8, 15, 15, 7, 15, 15, 15, 18];
  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    final targetsTableAdapter = Provider.of<TargetsTableAdapter>(context);
    final int numItems = targetsTableAdapter.getNumberOfItems();
    Widget list;
    if (numItems == 0) {
      list = Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
        child: SizedBox(
            height: itemHeight,
            child: Center(
              child: Text("Use the search bar to find and add items to the build.",
                  style: TextStyle(fontFamily: '', fontSize: 15, color: theme.primary)),
            )),
      );
    } else {
      list = ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
        itemCount: numItems,
        itemExtent: itemHeight,
        itemBuilder: (_, index) => TargetsTableItem(index: index, targetsTableAdapter: targetsTableAdapter),
      );
    }
    return TableContainer(
      maxHeight: 500,
      // TODO want this to be function of the screen height
      borderColor: theme.outline,
      color: theme.background,
      header: const TargetsTableHeader(),
      listTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onBackground),
      listView: list,
    );
  }
}

class TargetsTableHeader extends StatelessWidget {
  const TargetsTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableHeader(
      height: TargetsTable.headerHeight,
      textStyle:
      TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground),
      items: [
        TableContainer.getCol(TargetsTable.colFlexs[0],
            child: Text('Targets'),
            padding: const EdgeInsets.fromLTRB(TargetsTable.padding + TableAddDelButton.innerPadding, 0, 0, 0),
            align: Alignment.centerLeft),
        TableContainer.getCol(TargetsTable.colFlexs[1], child: Text('Runs')),
        TableContainer.getCol(TargetsTable.colFlexs[2], child: Text('Profit'), onTap: () {}),
        TableContainer.getCol(TargetsTable.colFlexs[3], child: Text('Cost'), onTap: () {}),
        TableContainer.getCol(TargetsTable.colFlexs[4], child: Text('%'), onTap: () {}),
        TableContainer.getCol(TargetsTable.colFlexs[5], child: Text('Cost/u'), onTap: () {}),
        TableContainer.getCol(TargetsTable.colFlexs[6], child: Text('Sell/u'), onTap: () {}),
        TableContainer.getCol(TargetsTable.colFlexs[7], child: Text('Out m3'), onTap: () {}),
        TableContainer.getCol(
          TargetsTable.colFlexs[8],
          align: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: theme.appBarPadding),
        ),
      ],
    );
  }
}

class TargetsTableItem extends StatelessWidget {
  const TargetsTableItem({required this.index, required this.targetsTableAdapter, Key? key}) : super(key: key);

  final TargetsTableAdapter targetsTableAdapter;
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
    final row = targetsTableAdapter.getRowData(index);
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
                  onTap: () => targetsTableAdapter.remove(index),
                  closeButton: true,
                  color: theme.background,
                  hoveredColor: theme.tertiaryContainer,
                  splashColor: theme.onTertiaryContainer.withOpacity(.35),
                ),
              ),
              Expanded(
                  child: Container(
                    child: Text(row.name),
                  )),
            ],
          ),
        ),
        // wrap(1, child: TableTextField(activeBorderColor: theme.primary, onChanged: (int runs){})),
        wrap(1, child: TableTextField(initialText: row.runs.toString(), onChanged: (String runs) {
          if (runs != '') {
            targetsTableAdapter.setRuns(index, int.parse(runs));
          }
        })),
        wrap(2, child: Text(row.profit)),
        wrap(3, child: Text(row.cost)),
        wrap(4, child: Text(row.percent)),
        wrap(5, child: Text(row.cost_per_unit)),
        wrap(6, child: Text(row.sell_per_unit)),
        wrap(7, child: Text(row.out_m3)),
        wrap(8, child: Text("bpops")),
      ],
    );
  }
}
