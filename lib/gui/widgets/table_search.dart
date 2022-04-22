import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../adapters/search.dart';
import '../my_theme.dart';
import 'table.dart';
import 'table_add_del_hover_button.dart';

class SearchBarFlyoutContent extends StatelessWidget {
  // static const maxNumEntries = 4000;
  static const Size size = Size(400, 600);
  static const colFlexs = [125, 30];
  static const List<double> columnWidths = [320, 80];

  const SearchBarFlyoutContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchAdapter = Provider.of<SearchAdapter>(context);
    final numSearchResults = searchAdapter.getNumberOfSearchResults();
    Widget listContent;
    if (numSearchResults == 0) {
      listContent = SizedBox(
          height: SearchListItem.height,
          child: Center(
            child: Text("¯\\_(ツ)_/¯", style: TextStyle(fontFamily: '', fontSize: 15, color: theme.onTertiaryContainer)),
          ));
    } else {
      listContent = ListView.builder(
        shrinkWrap: true,
        itemExtent: SearchListItem.height, // vertical height of the items
        // itemCount: min(sortIndices.length, maxNumEntries),
        itemCount: numSearchResults,
        itemBuilder: (_, index) => SearchListItem(listIndex: index, searchAdapter: searchAdapter),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: size.height, maxWidth: size.width),
      child: TableContainer(
        maxHeight: size.height,
        color: theme.tertiaryContainer,
        elevation: 2,
        borderRadius: 4,
        header: const SearchListHeader(),
        listTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onTertiaryContainer),
        listView: listContent,
      ),
    );
  }
}

class SearchListHeader extends StatelessWidget {
  const SearchListHeader({
    Key? key,
  }) : super(key: key);

  static const double height = 35;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 1,
      shadowColor: theme.shadow,
      child: TableHeader(
        color: theme.tertiaryContainer,
        height: height,
        textStyle: TextStyle(
            fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.onTertiaryContainer),
        items: [
          TableContainer.getCol(
            SearchBarFlyoutContent.colFlexs[0],
            child: Text('Items'),
            align: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: theme.appBarPadding),
          ),
          TableContainer.getCol(
            SearchBarFlyoutContent.colFlexs[1],
            padding: const EdgeInsets.symmetric(horizontal: theme.appBarPadding),
            align: Alignment.centerRight,
            child: Text('Profit %'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class SearchListItem extends StatelessWidget {
  const SearchListItem({
    required this.listIndex,
    required this.searchAdapter,
    Key? key,
  }) : super(key: key);

  static const double height = 30;

  final SearchAdapter searchAdapter;
  final int listIndex;

  // TODO If I use MyTableCell here and do not specify column widths, then the text does not wrap for long lines.
  // Not really sure how to fix this atm. Going to leave it as-is since it could also be a performance issue to not
  // set widths as static consts?
  @override
  Widget build(BuildContext context) {
    const buttonPadding = 8.0;
    const columnWidthFudgeFactor = 30.0;

    final SearchTableRowData rowData = searchAdapter.getRowData(listIndex);
    return Container(
      color: listIndex % 2 == 1 ? null : theme.colors.tertiary.withOpacity(.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: buttonPadding),
        child: Row(
          children: [
            TableAddDelButton(
              onTap: () => searchAdapter.addToBuild(listIndex),
              closeButton: false,
              color: theme.background,
              hoveredColor: theme.tertiary,
              splashColor: theme.onTertiary.withOpacity(.35),
            ),
            // Hovering this makes the search_bar_flyout disapper if textfield not selected. oh well.
            Tooltip(
              verticalOffset: 13,
              preferBelow: false,
              waitDuration: const Duration(milliseconds: 600),
              message: rowData.category,
              child: Container(
                width: SearchBarFlyoutContent.columnWidths[0] -
                    TableAddDelButton.width -
                    buttonPadding * 2 +
                    columnWidthFudgeFactor,
                padding: const EdgeInsets.symmetric(horizontal: buttonPadding),
                child: Text(rowData.name),
              ),
            ),
            Container(
              width: SearchBarFlyoutContent.columnWidths[1] - columnWidthFudgeFactor,
              alignment: Alignment.centerRight,
              child: Text(rowData.percent + '%'),
            )
          ],
        ),
      ),
    );
  }
}
