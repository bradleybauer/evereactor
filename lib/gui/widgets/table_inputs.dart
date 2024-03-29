import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../platform.dart';
import '../../controllers/table_inputs.dart';
import '../my_theme.dart';
import 'table.dart';

class InputsTable extends StatelessWidget {
  const InputsTable({Key? key}) : super(key: key);

  static const colFlexs = [52, 17, 20, 17, 24];
  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final controller = Provider.of<InputsTableController>(context);
    return TableContainer(
      // maxHeight: MediaQuery.of(context).size.height - 206,
      maxHeight: (Platform.isWeb() ? MyTheme.webTableHeight : MyTheme.desktopTableHeight),
      borderColor: theme.outline,
      color: theme.background,
      header: const InputsTableHeader(),
      listTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onBackground),
      listView: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
        itemCount: controller.getNumberOfItems(),
        itemExtent: itemHeight,
        itemBuilder: (_, index) => InputsTableItem(row: controller.getRowData(index)),
      ),
    );
  }
}

class InputsTableHeader extends StatelessWidget {
  const InputsTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final controller = Provider.of<InputsTableController>(context);
    return TableHeader(
      height: InputsTable.headerHeight,
      textStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground),
      items: [
        TableContainer.getCol(InputsTable.colFlexs[0],
            child: const Text('Inputs'), align: Alignment.centerLeft, padding: const EdgeInsets.fromLTRB(InputsTable.padding, 0, 0, 0)),
        TableContainer.getCol(InputsTable.colFlexs[1],
            child: const Text('Cost'), padding: const EdgeInsets.fromLTRB(0, 0, InputsTable.padding, 0), onTap: ()=>controller.sortTotalCost()),
        TableContainer.getCol(InputsTable.colFlexs[2],
            child: const Text('Cost/u'), padding: const EdgeInsets.fromLTRB(0, 0, InputsTable.padding, 0), onTap: ()=>controller.sortCostPerUnit()),
        TableContainer.getCol(InputsTable.colFlexs[3],
            child: const Text('m3'), padding: const EdgeInsets.fromLTRB(0, 0, InputsTable.padding, 0), onTap: ()=>controller.sortM3()),
        TableContainer.getCol(InputsTable.colFlexs[4],
            child: const Text('isk/m3'), padding: const EdgeInsets.fromLTRB(0, 0, InputsTable.padding, 0), onTap: ()=>controller.sortIskPerM3()),
      ],
    );
  }
}

class InputsTableItem extends StatelessWidget {
  const InputsTableItem({required this.row, Key? key}) : super(key: key);

  final InputsRowData row;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final style = TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onBackground);
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
            MyTableCell(InputsTable.colFlexs[0],
                padding: const EdgeInsets.fromLTRB(InputsTable.padding, 0, 0, 0),
                align: Alignment.centerLeft,
                child: Text(row.name, style: style)),
            MyTableCell(InputsTable.colFlexs[1], child: Text(row.totalCost, style: style)),
            MyTableCell(InputsTable.colFlexs[2], child: Text(row.costPerUnit, style: style)),
            MyTableCell(InputsTable.colFlexs[3], child: Text(row.m3, style: style)),
            MyTableCell(InputsTable.colFlexs[4], padding: const EdgeInsets.fromLTRB(0, 0, 12, 0), child: Text(row.iskPerM3, style: style)),
          ],
        ),
      ),
    );
  }
}
