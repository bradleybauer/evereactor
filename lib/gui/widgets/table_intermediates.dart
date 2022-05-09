import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/build_items.dart';
import '../../controllers/table_intermediates.dart';
import '../../platform.dart';
import '../my_theme.dart';
import 'flyout_bp_options.dart';
import 'table.dart';
import 'table_add_del_hover_button.dart';
import 'table_build_buy_toggle_buttons.dart';

class IntermediatesTable extends StatelessWidget {
  const IntermediatesTable({Key? key}) : super(key: key);

  static const colFlexs = [600, 200, 190, 120];
  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final controller = Provider.of<IntermediatesTableController>(context);
    return TableContainer(
      // maxHeight: MediaQuery.of(context).size.height - 206,
      maxHeight: (Platform.isWeb() ? MyTheme.webTableHeight : MyTheme.desktopTableHeight),
      borderColor: theme.outline,
      color: theme.background,
      header: const IntermediatesTableHeader(),
      listTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onTertiaryContainer),
      listView: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
        itemCount: controller.getNumberOfItems(),
        itemExtent: itemHeight,
        itemBuilder: (_, index) => IntermediatesTableItem(row: controller.getRowData(index)),
      ),
    );
  }
}

class IntermediatesTableHeader extends StatelessWidget {
  const IntermediatesTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return TableHeader(
      height: IntermediatesTable.headerHeight,
      textStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground),
      items: [
        TableContainer.getCol(
          IntermediatesTable.colFlexs[0],
          child: const Text('Intermediates'),
          align: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(IntermediatesTable.padding + TableAddDelButton.innerPadding, 0, 0, 0),
        ),
        TableContainer.getCol(IntermediatesTable.colFlexs[1], child: const Text('Build Value')),
        TableContainer.getCol(IntermediatesTable.colFlexs[2]),
        TableContainer.getCol(IntermediatesTable.colFlexs[3]),
      ],
    );
  }
}

class IntermediatesTableItem extends StatelessWidget {
  const IntermediatesTableItem({required this.row, Key? key}) : super(key: key);

  final IntermediatesRowData row;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final buildItems = Provider.of<BuildItemsController>(context, listen: false);
    final shouldBuild = buildItems.getShouldBuild(row.tid);
    final style = TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onBackground);
    return Material(
      color: Colors.transparent,
      textStyle: style,
      child: InkWell(
        onTap: () {},
        hoverColor: theme.outline.withOpacity(.1),
        focusColor: theme.outline.withOpacity(.1),
        mouseCursor: MouseCursor.defer,
        child: Row(
          children: [
            MyTableCell(
              IntermediatesTable.colFlexs[0],
              align: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(IntermediatesTable.padding, 0, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TableAddDelButton(
                    onTap: () => buildItems.addTarget(row.tid, 1),
                    closeButton: false,
                    color: theme.background,
                    hoveredColor: theme.tertiaryContainer,
                    splashColor: theme.onTertiaryContainer.withOpacity(.35),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(IntermediatesTable.padding, 0, 0, 0),
                    child: Text(row.name),
                  ),
                ],
              ),
            ),
            MyTableCell(IntermediatesTable.colFlexs[1],
                child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: row.valuePositive ? Colors.transparent : theme.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      row.value,
                      style: row.valuePositive ? style : style.copyWith(color: theme.onError),
                    ))),
            MyTableCell(IntermediatesTable.colFlexs[2],
                child: BuildBuyToggleButtons(
                  shouldBuild: shouldBuild,
                  onChange: (bool asdf) {
                    buildItems.setShouldBuild(row.tid, asdf);
                  },
                )),
            MyTableCell(IntermediatesTable.colFlexs[3],
                child: !shouldBuild ? Container() : BpOptionsTableWidget(tid: row.tid, controller: buildItems)),
          ],
        ),
      ),
    );
  }
}
