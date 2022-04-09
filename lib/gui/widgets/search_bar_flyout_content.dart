import 'dart:math';

import 'package:EveIndy/gui/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';
import 'table_add_del_hover_button.dart';

class SearchBarFlyoutContent extends StatelessWidget {
  static const MaxNumEntries = 1000;
  static const Size size = Size(500, 500);

  const SearchBarFlyoutContent({
    required this.itemUniverse,
    Key? key,
    required this.searchBarChangeNotifier,
  }) : super(key: key);

  final SearchBarChangeNotifier searchBarChangeNotifier;
  final List<List<String>> itemUniverse;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 60, maxHeight: size.height),
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: 2,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
            color: theme.colors.tertiaryContainer,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SearchListHeader(),
                Flexible(
                    child: ChangeNotifierProvider<SearchBarChangeNotifier>.value(
                  value: searchBarChangeNotifier,
                  builder: (_, __) => Consumer<SearchBarChangeNotifier>(
                    builder: (_, value, __) {
                      final sortIndices = value.get();
                      final len = min(value.get().length, MaxNumEntries);
                      if (len == 0) {
                        return SizedBox(
                            width: size.width,
                            height: 20,
                            child: Center(child: Text("¯\\_(ツ)_/¯", style: TextStyle(fontSize: 13, color: theme.colors.onTertiaryContainer))));
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          itemExtent: 23, // vertical height of the items
                          itemCount: min(value.get().length, MaxNumEntries),
                          itemBuilder: (_, index) => SearchListItem(itemUniverse: itemUniverse, index: sortIndices[index]));
                    },
                  ),
                )),
                // const SearchListFooter(), // not going to do this right now. will just show the top 300 items based on sort.
              ],
            )),
      ),
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
      child: Container(
        color: theme.colors.tertiaryContainer,
        child: Row(children: [
          SizedBox(
            width: SearchBarFlyoutContent.size.width * ratio,
            height: height,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Item",
                style: TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.colors.onTertiaryContainer),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: SizedBox(
                width: SearchBarFlyoutContent.size.width * (1 - ratio),
                height: height,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Profit %",
                    style:
                        TextStyle(fontFamily: 'NotoSans', fontSize: 13, fontWeight: FontWeight.w700, color: theme.colors.onTertiaryContainer),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class SearchListItem extends StatelessWidget {
  const SearchListItem({
    required this.index,
    required this.itemUniverse,
    Key? key,
  }) : super(key: key);

  final int index;
  final List<List<String>> itemUniverse;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TableAddDelButton(
            onTap: () {
              print("adding ${itemUniverse[index][0]}");
            },
            closeButton: false,
            color: theme.colors.background,
            hoveredColor: theme.colors.tertiary,
            iconColor: theme.colors.onBackground,
            iconHoveredColor: theme.colors.onTertiary,
            splashColor: theme.colors.onTertiary.withOpacity(.35),
          ),
        ),
        Tooltip(
          message: itemUniverse[index][0] + '\n' + itemUniverse[index].sublist(1).join(' > '),
          padding: const EdgeInsets.all(3),
          margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
          verticalOffset: 13,
          preferBelow: false,
          waitDuration: const Duration(milliseconds: 600),
          child: SizedBox(
            width: 370,
            child: Text(
              itemUniverse[index][0],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.colors.onTertiaryContainer),
            ),
          ),
        ),
        const SizedBox(width: MyTheme.appBarPadding),
        Text(
          '32%',
          style: TextStyle(fontFamily: 'NotoSans', fontSize: 11, color: theme.colors.onTertiaryContainer),
        )
      ],
    );
  }
}
