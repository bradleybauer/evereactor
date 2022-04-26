import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../adapters/build_items.dart';
import '../../adapters/table_targets.dart';
import '../my_theme.dart';
import 'flyout_bp_options.dart';
import 'table.dart';
import 'table_add_del_hover_button.dart';
import 'table_text_field.dart';

class TargetsTable extends StatelessWidget {
  const TargetsTable({Key? key}) : super(key: key);

  static const colFlexs = [58, 8, 15, 15, 7, 15, 15, 15, 10];
  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final adapter = Provider.of<TargetsTableAdapter>(context);
    final int numItems = adapter.getNumberOfItems();
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
        itemBuilder: (_, index) => TargetsTableItem(tid: adapter.getTid(index), row: adapter.getRowData(index)),
      );
    }
    return TableContainer(
      // maxHeight: MediaQuery.of(context).size.height - 206,
      maxHeight:  590,
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
    final theme = Provider.of<MyTheme>(context);
    return TableHeader(
      height: TargetsTable.headerHeight,
      textStyle:
          TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground),
      items: [
        TableContainer.getCol(TargetsTable.colFlexs[0],
            child: const Text('Targets'),
            padding: const EdgeInsets.fromLTRB(TargetsTable.padding + TableAddDelButton.innerPadding, 0, 0, 0),
            align: Alignment.centerLeft),
        TableContainer.getCol(TargetsTable.colFlexs[1], child: const Text('Runs')),
        TableContainer.getCol(TargetsTable.colFlexs[2], child: const Text('Profit'), onTap: () {}),
        TableContainer.getCol(TargetsTable.colFlexs[3], child: const Text('Cost'), onTap: () {}),
        TableContainer.getCol(TargetsTable.colFlexs[4], child: const Text('%'), onTap: () {}),
        TableContainer.getCol(TargetsTable.colFlexs[5], child: const Text('Cost/u'), onTap: () {}),
        TableContainer.getCol(TargetsTable.colFlexs[6], child: const Text('Sell/u'), onTap: () {}),
        TableContainer.getCol(TargetsTable.colFlexs[7], child: const Text('Out m3'), onTap: () {}),
        TableContainer.getCol(
          TargetsTable.colFlexs[8],
          align: Alignment.centerRight,
          child: const Text('BP'),
          padding: const EdgeInsets.symmetric(horizontal: MyTheme.appBarPadding),
        ),
      ],
    );
  }
}

class TargetsTableItem extends StatelessWidget {
  const TargetsTableItem({required this.tid, required this.row, Key? key}) : super(key: key);

  final TargetsRowData row;
  final int tid;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final buildItems = Provider.of<BuildItemsAdapter>(context, listen: false);
    return Material(
      color: Colors.transparent,
      textStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onBackground),
      child: InkWell(
        onTap: () {},
        hoverColor: theme.outline.withOpacity(.1),
        focusColor: theme.outline.withOpacity(.1),
        mouseCursor: MouseCursor.defer,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyTableCell(
              TargetsTable.colFlexs[0],
              align: Alignment.centerLeft,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: TargetsTable.padding),
                    child: TableAddDelButton(
                      onTap: () => buildItems.removeTarget(tid),
                      closeButton: true,
                      color: theme.background,
                      hoveredColor: theme.tertiaryContainer,
                      splashColor: theme.onTertiaryContainer.withOpacity(.35),
                    ),
                  ),
                  Expanded(child: Text(row.name)),
                ],
              ),
            ),
            // wrap(1, child: TableTextField(activeBorderColor: theme.primary, onChanged: (int runs){})),
            MyTableCell(TargetsTable.colFlexs[1],
                child: TableTextField(
                    initialText: row.runs.toString(),
                    activeBorderColor: theme.primary,
                    textColor: theme.onBackground,
                    onChanged: (String runs) {
                      if (runs != '') {
                        buildItems.setRuns(tid, int.parse(runs));
                      }
                    })),
            MyTableCell(TargetsTable.colFlexs[2], child: Text(row.profit)),
            MyTableCell(TargetsTable.colFlexs[3], child: Text(row.cost)),
            MyTableCell(TargetsTable.colFlexs[4], child: Text(row.percent)),
            MyTableCell(TargetsTable.colFlexs[5], child: Text(row.cost_per_unit)),
            MyTableCell(TargetsTable.colFlexs[6], child: Text(row.sell_per_unit)),
            MyTableCell(TargetsTable.colFlexs[7], child: Text(row.out_m3)),
            MyTableCell(TargetsTable.colFlexs[8], child: BpOptionsTableWidget(adapter: buildItems, tid: tid)),
          ],
        ),
      ),
    );
  }
}
