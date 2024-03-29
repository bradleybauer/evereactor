import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/build_items.dart';
import '../../controllers/table_products.dart';
import '../../platform.dart';
import '../my_theme.dart';
import 'flyout_bp_options.dart';
import 'table.dart';
import 'table_add_del_hover_button.dart';
import 'table_text_field.dart';

class ProductsTable extends StatefulWidget {
  const ProductsTable({super.key});

  static const colFlexs = [35, 8, 10, 10, 7, 10, 10, 7, 6];
  static const double headerHeight = 35;
  static const double itemHeight = 30;
  static const double padding = 8;

  @override
  State<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final controller = Provider.of<ProductsTableController>(context);
    final int numItems = controller.getNumberOfItems();
    Widget list;
    if (numItems == 0) {
      list = Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, ProductsTable.padding),
        child: SizedBox(
            height: ProductsTable.itemHeight,
            child: Center(
              child: Text("Click the 'Get Market Data' button then use the search bar to find and add items to the build.",
                  style: TextStyle(fontFamily: '', fontSize: 15, color: theme.primary)),
            )),
      );
    } else {
      list = ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, ProductsTable.padding),
        itemCount: numItems,
        itemExtent: ProductsTable.itemHeight,
        itemBuilder: (_, index) => TargetsTableItem(
          focusNode:controller.getRowData(index).focusNode,
          key:ValueKey(controller.getRowData(index).tid),
            row: controller.getRowData(index)),
      );
    }
    return TableContainer(
      // maxHeight: MediaQuery.of(context).size.height - 206,
      maxHeight: (Platform.isWeb() ? MyTheme.webTableHeight : MyTheme.desktopTableHeight),
      borderColor: theme.outline,
      color: theme.background,
      header: ProductsTableHeader(controller: controller),
      listTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onBackground),
      listView: list,
    );
  }
}

class ProductsTableHeader extends StatelessWidget {
  const ProductsTableHeader({required this.controller, super.key});

  final ProductsTableController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return TableHeader(
      height: ProductsTable.headerHeight,
      textStyle:
          TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.bold, color: theme.onBackground),
      items: [
        TableContainer.getCol(ProductsTable.colFlexs[0],
            child: const Text('Products'),
            padding: const EdgeInsets.fromLTRB(ProductsTable.padding + TableAddDelButton.innerPadding, 0, 0, 0),
            align: Alignment.centerLeft),
        TableContainer.getCol(ProductsTable.colFlexs[1], child: const Text('Runs')),
        TableContainer.getCol(ProductsTable.colFlexs[2],
            child: const Text('Net'), onTap: () => controller.sortProfit()),
        TableContainer.getCol(ProductsTable.colFlexs[3], child: const Text('Cost'), onTap: () => controller.sortCost()),
        TableContainer.getCol(ProductsTable.colFlexs[4], child: const Text('%'), onTap: () => controller.sortPercent()),
        TableContainer.getCol(ProductsTable.colFlexs[5],
            child: const Text('Cost/u'), onTap: () => controller.sortCostPerUnit()),
        TableContainer.getCol(ProductsTable.colFlexs[6],
            child: const Text('Sell/u'), onTap: () => controller.sortSellPerUnit()),
        TableContainer.getCol(ProductsTable.colFlexs[7],
            child: const Text('Out m3'), onTap: () => controller.sortOutM3()),
        TableContainer.getCol(ProductsTable.colFlexs[8])
      ],
    );
  }
}

class TargetsTableItem extends StatelessWidget {
  const TargetsTableItem({required this.row,  required this.focusNode, super.key});

  final ProductsRowData row;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final buildItems = Provider.of<BuildItemsController>(context, listen: false);
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
              ProductsTable.colFlexs[0],
              align: Alignment.centerLeft,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ProductsTable.padding),
                    child: TableAddDelButton(
                      onTap: () => buildItems.removeTarget(row.tid),
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
            MyTableCell(ProductsTable.colFlexs[1],
                child: TableTextField(
                  focusNode:focusNode,
                    width: 45,
                    maxNumDigits: 6,
                    initialText: row.runs.toString(),
                    activeBorderColor: theme.primary,
                    textColor: theme.onBackground,
                    onChanged: (String runs) {
                      if (runs != '') {
                        buildItems.setRuns(row.tid, int.parse(runs));
                      }
                    })),
            MyTableCell(ProductsTable.colFlexs[2], child: Text(row.profit)),
            MyTableCell(ProductsTable.colFlexs[3], child: Text(row.cost)),
            MyTableCell(ProductsTable.colFlexs[4], child: Text(row.percent)),
            MyTableCell(ProductsTable.colFlexs[5], child: Text(row.costPerUnit)),
            MyTableCell(ProductsTable.colFlexs[6], child: Text(row.sellPerUnit)),
            MyTableCell(ProductsTable.colFlexs[7], child: Text(row.outM3)),
            MyTableCell(ProductsTable.colFlexs[8], child: BpOptionsTableWidget(controller: buildItems, tid: row.tid)),
          ],
        ),
      ),
    );
  }
}
