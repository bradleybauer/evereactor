import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'search_bar.dart';
import '../my_theme.dart';
import 'table_add_del_hover_button.dart';
import 'table_container.dart';
import 'table_header.dart';

class SearchBarFlyoutContent extends StatelessWidget {
  // static const maxNumEntries = 4000;
  static const Size size = Size(400, 600);

  static const List<double> columnWidths = [320, 80];

  const SearchBarFlyoutContent({
    required this.itemUniverse,
    Key? key,
    required this.searchBarChangeNotifier,
  }) : super(key: key);

  final SearchBarChangeNotifier searchBarChangeNotifier;
  final List<List<String>> itemUniverse;

  @override
  Widget build(BuildContext context) {
    return TableContainer(
      maxHeight: size.height,
      color: theme.tertiaryContainer,
      elevation: 2,
      borderRadius: 4,
      header: const SearchListHeader(),
      listTextStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.onTertiaryContainer),
      listView: ChangeNotifierProvider<SearchBarChangeNotifier>.value(
          value: searchBarChangeNotifier,
          builder: (_, __) => Consumer<SearchBarChangeNotifier>(
                builder: (_, value, __) {
                  final sortIndices = value.get();
                  // final len = min(value.get().length, maxNumEntries);
                  final len = sortIndices.length;
                  if (len == 0) {
                    return SizedBox(
                        height: SearchListItem.height,
                        child: Center(
                          child: Text("¯\\_(ツ)_/¯", style: TextStyle(fontFamily: '', fontSize: 15, color: theme.onTertiaryContainer)),
                        ));
                  }
                  // var s = ScrollController();
                  // s.offset > 0 ? animate header elevate up
                  return ListView.builder(
                      // controller: ,
                      shrinkWrap: true,
                      itemExtent: SearchListItem.height, // vertical height of the items
                      // itemCount: min(sortIndices.length, maxNumEntries),
                      itemCount: sortIndices.length,
                      itemBuilder: (_, index) => SearchListItem(itemUniverse: itemUniverse, index: index, itemIndex: sortIndices[index]));
                },
              )),
    );
  }
}

class SearchListHeader extends StatelessWidget {
  const SearchListHeader({
    Key? key,
  }) : super(key: key);

  static const double height = 35;
  static const double ratio = .8;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 1,
      shadowColor: theme.shadow,
      child: TableHeader(
        flexs: const [125, 30],
        color: theme.tertiaryContainer,
        height: height,
        textStyle: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.onTertiaryContainer),
        items: [
          TableColumn(
            widget: Container(
              padding: const EdgeInsets.symmetric(horizontal: theme.appBarPadding),
              child: Text('Items'),
            ),
          ),
          TableColumn(
            widget: Container(
              padding: const EdgeInsets.symmetric(horizontal: theme.appBarPadding),
              alignment: Alignment.centerRight,
              child: Text('Profit %'),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class SearchListItem extends StatelessWidget {
  const SearchListItem({
    required this.index,
    required this.itemIndex,
    required this.itemUniverse,
    Key? key,
  }) : super(key: key);

  static const double height = 30;

  final int index;
  final int itemIndex;
  final List<List<String>> itemUniverse;

  @override
  Widget build(BuildContext context) {
    const buttonPadding = 8.0;
    const columnWidthFudgeFactor = 30.0;
    return Container(
      color: index % 2 == 1 ? null : theme.colors.tertiary.withOpacity(.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: buttonPadding),
        child: Row(
          children: [
            TableAddDelButton(
              onTap: () {
                print("adding ${itemUniverse[itemIndex][0]}");
              },
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
              message: itemUniverse[itemIndex].sublist(1).join(' > '),
              child: Container(
                width: SearchBarFlyoutContent.columnWidths[0] - TableAddDelButton.width - buttonPadding * 2 + columnWidthFudgeFactor,
                padding: const EdgeInsets.symmetric(horizontal: buttonPadding),
                child: Text(itemUniverse[itemIndex][0]),
              ),
            ),
            Container(
              width: SearchBarFlyoutContent.columnWidths[1] - columnWidthFudgeFactor,
              alignment: Alignment.centerRight,
              child: Text('${itemIndex}%'),
            )
          ],
        ),
      ),
    );
  }
}
