import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../adapters/build_items.dart';
import '../../adapters/table_intermediates.dart';
import '../my_theme.dart';
import 'flyout_bp_options.dart';
import 'table.dart';
import 'table_add_del_hover_button.dart';
import 'table_build_buy_toggle_buttons.dart';

class IntermediatesTable extends StatelessWidget {
  const IntermediatesTable({Key? key}) : super(key: key);

  static const colFlexs = [600, 200, 190, 90];
  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;

  @override
  Widget build(BuildContext context) {
    final adapter = Provider.of<IntermediatesTableAdapter>(context);
    return TableContainer(
      maxHeight: 600,
      borderColor: theme.outline,
      color: theme.background,
      header: const IntermediatesTableHeader(),
      listTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onTertiaryContainer),
      listView: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
        itemCount: adapter.getNumberOfItems(),
        itemExtent: itemHeight,
        itemBuilder: (_, index) => IntermediatesTableItem(tid: adapter.getTid(index), row: adapter.getRowData(index)),
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
        TableContainer.getCol(IntermediatesTable.colFlexs[2], child: Text('Build/Buy')),
        TableContainer.getCol(IntermediatesTable.colFlexs[3],
            padding: const EdgeInsets.fromLTRB(0, 0, IntermediatesTable.padding, 0), child: Text('BP')),
      ],
    );
  }
}

class IntermediatesTableItem extends StatelessWidget {
  const IntermediatesTableItem({required this.row, required this.tid, Key? key}) : super(key: key);

  final IntermediatesRowData row;
  final int tid;

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
    final buildItems = Provider.of<BuildItemsAdapter>(context, listen: false);
    final shouldBuild = buildItems.getShouldBuild(tid);
    return Row(
      children: [
        wrap(
          0,
          align: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(IntermediatesTable.padding, 0, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              TableAddDelButton(
                onTap: () => buildItems.addTarget(tid, 1),
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
        wrap(1, child: Text(row.value)),
        wrap(2,
            child: BuildBuyToggleButtons(
              shouldBuild: shouldBuild,
              onChange: (bool asdf) {
                buildItems.setShouldBuild(tid, asdf);
              },
            )),
        wrap(3, child: BpOptionsTableWidget(tid: tid, adapter: buildItems)),
      ],
    );
  }
}
